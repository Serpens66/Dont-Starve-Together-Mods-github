# 02 — Ladeumgebungen, Hooks und verträgliche Erweiterungen

## Environment und Ausführungszeit

`mods.lua:CreateEnvironment` erzeugt eine Mod-Umgebung mit ausgewählten Funktionen, `GLOBAL = _G`, `modname`, `MODROOT` und `env`. Deshalb ist ein globaler Spielbezeichner in `modmain.lua` nicht automatisch als freier Name verfügbar. Die Vorlagen verwenden ausdrücklich `local G = GLOBAL` und greifen darüber auf Spielklassen und Konstanten zu.

`modimport("scripts/meine_datei.lua")` lädt aus dem Mod-Ordner, setzt dasselbe Environment und führt den Chunk aus. `require("components/meinecomponent")` folgt der Modulauflösung und gibt einen gepufferten Modulwert zurück. Im Mod-Workspace existieren gleichnamige Hilfsmodule wie `upvaluehacker`: Bei eigenen Modulen ein eindeutiges Präfix verwenden, damit `package.loaded` keine ungewollte gemeinsame Instanz erzeugt.

`modworldgenmain.lua` wird auch außerhalb der eigentlichen Kartengenerierung für die Anpassungsoberfläche benötigt. Die Datei darf deshalb keine lebende `TheWorld` voraussetzen. Runtime- und Worldgen-Kontext werden über unterschiedliche Hook-Verfügbarkeit getrennt. `modservercreationmain.lua` erhält ein Frontend-Environment.

Belege: [mods.lua — function CreateEnvironment](<../../_scripts/scripts_02_10_2026/scripts/mods.lua>) (Zeile 297), [mods.lua — modservercreationmain.lua](<../../_scripts/scripts_02_10_2026/scripts/mods.lua>) (Zeile 444), [mods.lua: Kommentar zur Worldgen-Ladung](<../../_scripts/scripts_02_10_2026/scripts/mods.lua>) (Zeile 581), [modutil.lua — if isworldgen then](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 436).

## Den passenden Hook wählen

| Hook | Geeignet für | Zeitpunkt und Argumente |
|---|---|---|
| AddPrefabPostInit(name, fn) | Bestehendes Objekt fertig konfigurieren | Nach prefab.fn; fn(inst) |
| AddPrefabPostInitAny(fn) | Allgemeine Erweiterung mit schnellem Filter | Jedes erzeugte Prefab; fn(inst) |
| AddPlayerPostInit(fn) | Spielerinstanzen | PrefabPostInitAny plus Prüfung des player-Tags |
| AddComponentPostInit(name, fn) | Jede Instanz einer Component | Nach Konstruktor; fn(component, inst) |
| AddClassPostConstruct(package, fn) | Klassen einschließlich Widgets | Wrapper des Klassenkonstruktors; fn(self, ...) |
| AddStategraphPostInit(name, fn) | Stategraph-Definition | Nach Zusammenstellen der Definition |
| AddBrainPostInit(name, fn) | Brain-Instanzen | Mod-Liste wird vom Brain-Lebenszyklus verarbeitet |
| AddSimPostInit(fn) | Sim-Initialisierung | ModWrangler-Aufruf; kein Ersatz für einzelne Prefab-Hooks |
| AddRecipePostInit(name, fn) | Bestehendes Rezept | Bereits vorhandene Rezepte werden auch direkt bearbeitet |

Eine Component kann während des Prefab-Konstruktors bereits erzeugt sein, bevor das Prefab anschließend deren Werte setzt. Deshalb kann eine Änderung im Component-Hook später überschrieben werden. Wenn eine Mod einen Endwert eines bestimmten Prefabs ändern will, ist der Prefab-Hook meist der passende geprüfte Ort.

Die Parameter der Hook-Registrierung und die Parameter des später aufgerufenen Callbacks sind unterschiedliche Schnittstellen. Das vollständige Register steht in [Kapitel 15](15_API_Register.md).

Belege: [mainfunctions.lua — function SpawnPrefabFromSim](<../../_scripts/scripts_02_10_2026/scripts/mainfunctions.lua>) (Zeile 347), [entityscript.lua — function EntityScript:AddComponent](<../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 610), [modutil.lua — local function DoAddClassPostConstruct](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 153), [modutil.lua — env.AddRecipePostInit](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 602), [brain.lua — modpostinitfns](<../../_scripts/scripts_02_10_2026/scripts/brain.lua>) (Zeile 221).

## Serverzuständigkeit im Callback prüfen

    AddPrefabPostInit("spear", function(inst)
        if not GLOBAL.TheWorld.ismastersim then
            return
        end
        if inst.components.weapon ~= nil then
            inst.components.weapon:SetDamage(40)
        end
    end)

Ein globaler früher Return in `modmain.lua` ist ungeeignet, wenn darunter gemeinsame Registrierungen für Rezepte, Actions, RPCs oder Assets stehen. Solche Registrierungen müssen auf den jeweils beteiligten Instanzen übereinstimmen; nur die Gameplay-Wirkung wird serverseitig begrenzt.

## Methoden erhalten und korrekt erweitern

Eine Mod soll die zum Installationszeitpunkt vorhandene Methode erhalten, nicht blind eine Vanilla-Implementierung ersetzen. Bei einem Wrapper müssen `self`, Argumente, Rückgaben und gegebenenfalls Referenzlisten erhalten bleiben.

    local old = component.SomeMethod
    component.SomeMethod = function(self, ...)
        -- Eigene Vorbereitung; die ursprüngliche Methode entscheidet weiterhin.
        return old(self, ...)
    end

Wenn nach dem Aufruf noch etwas geschehen muss, Rückgaben mit Anzahl packen:

    local function pack(...)
        return { n = GLOBAL.select("#", ...), ... }
    end
    local result = pack(old(self, ...))
    -- Eigene Nachbearbeitung.
    return GLOBAL.unpack(result, 1, result.n)

Eine nur einmal zurückgegebene Variable ist kein allgemeiner Wrapper für eine Methode mit mehreren Resultaten. Save-Wrapper benötigen außerdem den zum Objekt passenden Vertrag; siehe [Persistenz](05_Persistenz.md). Einen fehlenden Originalcallback nur dann zulassen, wenn er optional ist.

## Grenzen und Konflikte

- PostInitAny läuft auch für sehr viele irrelevante Prefabs. Tags/Components zuerst prüfen; keine Weltabfrage vor dem Filter.
- Klassendefinitionen werden durch PostConstruct gemeinsam erweitert. Eigene Felder eindeutig benennen und keine Constructor-Rekursion erzeugen.
- Reihenfolge kann Ergebnisse verändern. Ein höherer `priority`-Wert ist keine universelle Zusicherung kompatibler Ergebnisse.
- Upvalue-Hacking hängt an lokalen Namen und Closure-Struktur. Ein passender öffentlicher Hook oder Setter ist wartbarer; andernfalls den konkreten Upvalue-Pfad pro Spielstand auditieren.
- Dass ein Hook registriert werden kann, beweist nicht, dass die zugehörige Component auf dem Client existiert.

Praxis: [More Worldsettings 2838382897/modmain.lua — AddPrefabPostInitAny](<../More Worldsettings 2838382897/modmain.lua>) (Zeile 25), [Auto Actions (Serp) 732459815/modmain.lua — AddClassPostConstruct("components/playercontroller"](<../Auto Actions (Serp) 732459815/modmain.lua>) (Zeile 1436).
