# 05 — Save/Load, Referenzen und Migration

## Unterschiedliche Callback-Verträge

| Besitzer | Speichern | Laden |
|---|---|---|
| Component | `cmp:OnSave()` → data, references | `cmp:OnLoad(data, newents)` |
| Prefab | `inst.OnSave(inst, data)` verändert Tabelle → references | `inst:OnLoad(data, newents)` |
| Component-Referenzen | GUIDs in references | `cmp:LoadPostPass(newents, componentdata)` |
| Prefab-Referenzen | GUIDs in references | `inst:OnLoadPostPass(newents, savedata)` |

**Components geben ihre Datentabelle zurück. Prefab-OnSave schreibt in die übergebene Tabelle und gibt gegebenenfalls Referenzen zurück.** `return data` beim Prefab kann deshalb als Referenzliste interpretiert werden.

Component-Daten liegen unter ihrem Namen. Beim Laden läuft `OnPreLoad` vor den Component-OnLoad-Aufrufen und danach Prefab-OnLoad. Die Component-Iteration verwendet `pairs`; ihre Reihenfolge ist nicht festgelegt. Referenzauflösung findet später im PostPass statt.

Belege: [entityscript.lua — function EntityScript:GetPersistData](<../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 1903), [entityscript.lua — function EntityScript:SetPersistData](<../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 1954), [entityscript.lua — function EntityScript:LoadPostPass](<../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 1939).

## Persistenter Wert und Defaults

    function Demo:OnSave()
        return { version = 1, value = self.value }
    end
    function Demo:OnLoad(data)
        if data ~= nil and type(data.value) == "number" then
            self:SetValue(data.value)
        end
    end

Im Konstruktor einen gültigen Default setzen, weil alte Spielstände den Component-Eintrag noch nicht enthalten. Beim Laden Werte validieren und über einen Setter anwenden, wenn dadurch Netvars oder Tags aktualisiert werden. Die Zählervorlage begrenzt Werte auf den Bereich ihrer `net_ushortint`.

## Originaldaten und Referenzen erhalten

Component-Wrapper:

    local old = self.OnSave
    self.OnSave = function(self, ...)
        local data, refs
        if old ~= nil then data, refs = old(self, ...) end
        data = data or {}
        data.my_mod_value = self.my_mod_value
        return data, refs
    end

Prefab-Wrapper:

    local old = inst.OnSave
    inst.OnSave = function(inst, data, ...)
        local refs = old ~= nil and old(inst, data, ...) or nil
        data.my_mod_value = inst.my_mod_value
        return refs
    end

Keine globale `data`-Variable erzeugen. Originalreferenzen erhalten. Eigene Daten eindeutig benennen; eine separate Component vermeidet flache Feldkollisionen. Die Beispiele gelten für die hier geprüften Save-Verträge, nicht beliebige Methoden mit anderen Rückgaben.

Historischer Vergleich: [Repair Combine 767776640/modmain.lua — local old_OnSave = self.OnSave](<../Repair Combine 767776640/modmain.lua>) (Zeile 69). Dieser Code verwendet teilweise nicht lokale `data`-Variablen und dient deshalb nicht als allgemeine Wrapper-Vorlage.

## Entity-Referenzen

Eine Laufzeit-Entity oder GUID-Netvar ist kein dauerhafter Lua-Verweis. `SpawnSaveRecord` erzeugt Entities neu und trägt sie als `newents[old_guid].entity` ein. Für Beziehungen zwischen normalen persistierenden Welt-Entities die Ziel-GUID speichern, in references melden und im PostPass auflösen. Ein fehlendes Ziel zulassen.

Container speichern enthaltene Items als vollständige Save-Records und sammeln deren Referenzen. Nur Prefab-Namen zu speichern würde Zustand wie Haltbarkeit und Component-Daten verlieren.

**Spieler sind ein Sonderfall:** `player_common.lua` sagt ausdrücklich, dass normale Save-Referenzen für Netzwerkspieler nicht gelten. Session-, Besitz- und Migration-Verträge gesondert prüfen.

Belege: [mainfunctions.lua — SpawnSaveRecord](<../../_scripts/scripts_02_10_2026/scripts/mainfunctions.lua>) (Zeile 438; Eintrag in newents: Zeile 462), [components/container.lua — function Container:OnSave](<../../_scripts/scripts_02_10_2026/scripts/components/container.lua>) (Zeile 979), [prefabs/player_common.lua: Kommentar zu Spielerreferenzen](<../../_scripts/scripts_02_10_2026/scripts/prefabs/player_common.lua>) (Zeile 1233).

## Initialisierung nach Load

Ein Prefab-Hook läuft vor der späteren Wiederherstellung gespeicherter Werte. Zufallsauswahl oder einmalige Belohnungen dort können überschrieben oder bei jedem Laden wiederholt werden. Ein Delay von null garantiert nicht allgemein den Abschluss aller Cross-Entity- oder Shard-Abläufe. Für Referenzen PostPass einsetzen; andere Fälle am konkreten Loader prüfen.

Task-Handles nicht speichern. Timer speichern geeignete Zeit-/Zustandsdaten und starten beim Laden neu. Wenn nötig, Offline-Zeit, LongUpdate, Schlafzustände und fehlende Ziele mitprüfen.

Belege: [components/stewer.lua — function Stewer:OnSave](<../../_scripts/scripts_02_10_2026/scripts/components/stewer.lua>) (Zeile 203), [Teleportato 756229217/scripts/components/adv_startstuff.lua — function StartStuff:OnLoad](<../Teleportato 756229217/scripts/components/adv_startstuff.lua>) (Zeile 34).

## Vanilla-Sonderfälle

`health:SetMaxHealth(amount)` setzt auch currenthealth auf amount. Eine dynamische Obergrenzenänderung muss den gewünschten aktuellen Wert beziehungsweise Anteil bewusst erhalten. `health.save_maxhealth` speichert die Obergrenze; OnLoad stellt sie vor currenthealth wieder her.

`finiteuses:OnSave` speichert normalerweise abweichende aktuelle Uses; das Maximum kommt aus dem Konstruktor. Dynamisch individuelle Maximalwerte benötigen einen geprüften zusätzlichen Save-/Load-Pfad, einschließlich Item-Splitting, falls stapelbar.

Belege: [components/health.lua — function Health:SetMaxHealth](<../../_scripts/scripts_02_10_2026/scripts/components/health.lua>) (Zeile 503), [components/health.lua — save_maxhealth](<../../_scripts/scripts_02_10_2026/scripts/components/health.lua>) (Zeile 159), [components/finiteuses.lua — function FiniteUses:OnSave](<../../_scripts/scripts_02_10_2026/scripts/components/finiteuses.lua>) (Zeile 48), [Automatic Health Adjust 764204839/modmain.lua — save_maxhealth = true](<../Automatic Health Adjust 764204839/modmain.lua>) (Zeile 370).

## Schemaänderungen und Entfernen einer Mod

Neue Daten mit Defaults und Versionskennung einführen. Migrationen sollen alten Stand erkennen und genau einmal transformieren. Welt- und Spielerdateien getrennt berücksichtigen. Änderungen an Prefab-/Component-Namen können bestehende Save-Daten unbrauchbar machen.

Das Entfernen einer Mod mit eigenen Prefabs ist kein allgemeiner sicherer Rollback. Auf kopierter Testwelt prüfen, welche Inhalte vor Deaktivierung entfernt oder konvertiert werden müssen. Teleportatos eigene Weltwechsel-Mechanik ist ein umfangreicher Sonderablauf und keine normale Save/Load-Vorlage.


## Vertiefung mit Workspace-Beispielen

Die dazugehörigen konkreten Abläufe, Daten-/Cleanupentscheidungen und Altlasten sind im [Praxismechanismen-Kapitel](23_Praxismechanismen.md) erklärt. Über die [Abdeckungsmatrix](21_Abdeckungsmatrix.md) zu passenden Fallstudien und eigenständigen Vorlagen navigieren; Grenzen komplexer Systeme stehen ausdrücklich dort.

## Spieler sind ein eigener Speicherpfad

[Session und Shardmigration](30_Multiplayer_Lebenszyklen.md) beschreibt SerializeUserSession, ResumeExistingUserSession, Factory-OnLoad und den Migrationsfehlerpfad. Zusätzliche World-GUID-Referenzen werden vom Sessionserializer nicht automatisch übernommen. [Charactercallbacks](29_Kreaturen_Charaktere_Lebenszyklus.md) erklärt, wann die Playerfactory eigene OnSave/OnLoad-Funktionen erfasst.
