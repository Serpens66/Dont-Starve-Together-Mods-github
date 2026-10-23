# 09 — Brains, Kreaturen und Charaktere

## Verhalten und Animation trennen

Ein Brain entscheidet über Verhalten; ein Stategraph steuert Zustände, Animationen und Actions. Das Rabbit-Beispiel baut einen PriorityNode mit Panik, Flucht, Heimkehr, Futtersuche und Wandern. Frühere höher priorisierte Knoten können spätere übersteuern. DoAction liefert eine BufferedAction, die zur eigentlichen Action-/Stategraph-Kette führt.

Bei einer Brain-Änderung zuerst den vollständigen Baum lesen. Ein eingefügter permanenter Knoten kann normales Fressen, Fliehen oder Heimkehren unerreichbar machen. Entitiesuche muss Tags, Reichweite, Passierbarkeit und Plattform berücksichtigen. Die Rabbit-Futtersuche prüft diese Voraussetzungen ausdrücklich.

Belege: [brains/rabbitbrain.lua — function RabbitBrain:OnStart](<../../_scripts/scripts_02_10_2026/scripts/brains/rabbitbrain.lua>) (Zeile 51), [brains/rabbitbrain.lua — local function EatFoodAction](<../../_scripts/scripts_02_10_2026/scripts/brains/rabbitbrain.lua>) (Zeile 29), [prefabs/rabbit.lua — inst:AddComponent("health")](<../../_scripts/scripts_02_10_2026/scripts/prefabs/rabbit.lua>) (Zeile 402).

## Brain-Hooks und Lebenszyklus

`AddBrainPostInit` ergänzt die Klassenliste modpostinitfns. Brain._Start_Internal führt sie nach OnStart und OnInitializationComplete aus. Ein Hook erhält die Brain-Instanz und kann den vorhandenen Baum erweitern. Die Definitionen und Instanzen unterscheiden; keine globale Instanzbindung über die Klasse erzeugen.

Wake/Sleep, Stop/Resume und Entity-Entfernung gehören zum Lebenszyklus. Ein eigener periodischer Task benötigt einen passenden Rückbau. Die Maxwell-Mod verwendet beispielsweise Tasks für Positions-/Geschwindigkeitsabgleich und beendet sie bei Tod beziehungsweise Entfernung.

Belege: [modutil.lua — env.AddBrainPostInit](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 627), [brain.lua — modpostinitfns](<../../_scripts/scripts_02_10_2026/scripts/brain.lua>) (Zeile 221), [Evolving Maxwell Shadows 1868560353/modmain.lua — inst.match_speed_task =](<../Evolving Maxwell Shadows 1868560353/modmain.lua>) (Zeile 538).

## Eigene Kreatur

Ein neues Monster braucht ein eigenes Prefab, passende Grafik/Physik, Health, Combat, Locomotor und nach Design Loot, Nahrung, Schlaf und besondere Fähigkeiten. Brain und Stategraph müssen dieselben Actions unterstützen. Zielauswahl, Angriffsreichweite, Trefferzeit und Loot separat prüfen. Aus dem Rabbit-Audit lässt sich kein universeller Combat-Vertrag für Bosse ableiten.

Für eine konkrete Kreatur zunächst ein möglichst ähnliches aktuelles Vanilla-Prefab wählen und dessen Konstruktor, Brain, Stategraph, Combat-Callbacks und Save/Load-Kette auditieren. Bei Bossen außerdem Phasenwechsel, Arena-/World-Components und PostPass untersuchen.

## Spielerfactory

`MakePlayerCharacter(name, customprefabs, customassets, common_postinit, master_postinit, starting_inventory)` ist der Einstieg in player_common. Common-PostInit läuft vor Pristine auf gemeinsamem Pfad, Master-PostInit später in der autoritativen Konstruktion. Der Aufbau enthält Classifieds, Prediction, Ghost- und Sessionlogik; kein gewöhnliches Monster-Prefab als Spieler umbauen.

Wilson zeigt Character-spezifische Tags, Startinventar aus GAMEMODE_STARTING_ITEMS, Assets, Beard-Mechanik und Skilltree-Abhängigkeiten. Eigene Charaktere zusätzlich über AddModCharacter anmelden. Gender und Modes müssen zu den benötigten Tabellen passen. Die API ergänzt bei fehlender Gender-Angabe einen Default mit Warnung; neue Mods geben sie ausdrücklich an.

Belege: [prefabs/player_common.lua — local function MakePlayerCharacter](<../../_scripts/scripts_02_10_2026/scripts/prefabs/player_common.lua>) (Zeile 1980), [prefabs/player_common.lua — common_postinit(inst)](<../../_scripts/scripts_02_10_2026/scripts/prefabs/player_common.lua>) (Zeile 2548), [prefabs/player_common.lua — master_postinit(inst)](<../../_scripts/scripts_02_10_2026/scripts/prefabs/player_common.lua>) (Zeile 2937), [prefabs/wilson.lua — local MakePlayerCharacter](<../../_scripts/scripts_02_10_2026/scripts/prefabs/wilson.lua>) (Zeile 1), [modutil.lua — local function AddModCharacter](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 73).

## Vollständigkeit eines Character-Mods

Zu Code und Balancing kommen Name, Beschreibung, Zitate, Inspect-Texte, Portraits, Auswahlbilder, Avatare, Körper-/Geistergrafik und Sounds. Neue Fähigkeiten brauchen gegebenenfalls Replica/Netvars, passende Actions sowie server- und clientseitige Zustände. Skilltrees sind ein eigenes UI-/Gameplay-System, nicht nur ein AddRecipe-Feld.

Bei Charakterwechsel und Respawn darf Startinventar nicht erneut als Load-Belohnung erzeugt werden. player_common.OnLoad entfernt den NewSpawn-Pfad bei bestehenden Sessions. Ghost, Wiederbelebung, Höhlenmigration und andere Spielmodi explizit prüfen.

Beleg: [prefabs/player_common.lua — local function OnLoad(inst, data)](<../../_scripts/scripts_02_10_2026/scripts/prefabs/player_common.lua>) (Zeile 1265). Diese Sammlung liefert keine vollständig gezeichnete Character-Vorlage; der konkrete Character-Audit und eigene Assets bleiben beim nächsten Feature erforderlich.


## Vertiefung mit Workspace-Beispielen

Die dazugehörigen konkreten Abläufe, Daten-/Cleanupentscheidungen und Altlasten sind im [Praxismechanismen-Kapitel](23_Praxismechanismen.md) erklärt. Über die [Abdeckungsmatrix](21_Abdeckungsmatrix.md) zu passenden Fallstudien und eigenständigen Vorlagen navigieren; Grenzen komplexer Systeme stehen ausdrücklich dort.

## Durchgehende Lebenszyklen

[Kreaturen und Charaktere](29_Kreaturen_Charaktere_Lebenszyklus.md) erklärt Rabbit einschließlich Nahrung/SG, Schlaf/Wake, Timer-/Traprestore und Tod sowie Wilson/Playerfactory einschließlich Callback-Capture, Startinventar, Ghost und Wiederbelebung. Die [Fragmente](examples/README.md) sind keine fertigen Creature-/Character-Mods und enthalten keine eigene Grafik.
