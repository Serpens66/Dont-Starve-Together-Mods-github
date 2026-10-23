# 13 — Debugging, Tests, Performance und Mod-Konflikte

## Fehler reproduzierbar eingrenzen

Auf einer separaten Testwelt beginnen, nur die eigene Mod und erforderliche Abhängigkeiten aktivieren. Spiel-/Mod-Version, Einstellungen, Shard, Host/Client und auslösende Aktion notieren. Den ersten relevanten Fehler im Stacktrace lesen; Folgefehler sind häufig nur Konsequenzen.

Typische lokale Klei-Logs heißen client_log.txt und server_log.txt. Ablage hängt von Benutzerprofil, Cluster, Shard und Startparametern ab. Den tatsächlich verwendeten Speicherpfad prüfen; diese Sammlung liest keine privaten Cluster-Tokens. Eigene Debugausgaben mit eindeutigem Mod-Präfix und sparsamer Rate versehen.

## Konsole

Vor der Eingabe den lokalen beziehungsweise Remote-Kontext kontrollieren. Spawn-, Give- und Save-Operationen für Gameplay in der autoritativen Simulation ausführen. Ein Dedicated Server hat kein gewöhnliches lokales ThePlayer.

| Befehl | Zweck |
|---|---|
| c_spawn("prefab", count) | Entity erzeugen |
| c_give("prefab", count) | Item dem ausgewählten Konsole-Spieler geben |
| c_select(inst) | Konsolen-Auswahl setzen |
| c_sel() | Bereits ausgewählte Entity lesen |
| c_find("prefab") | Entity suchen |
| c_countprefabs("prefab") | Vorkommen zählen |
| c_freecrafting(player) | GiveAllRecipes für den Konsole-Spieler ausführen; kein allgemeiner Toggle |
| c_save() | Welt speichern |

Belege: [consolecommands.lua — function c_spawn](<../../_scripts/scripts_02_10_2026/scripts/consolecommands.lua>) (Zeile 208), [consolecommands.lua — function c_give](<../../_scripts/scripts_02_10_2026/scripts/consolecommands.lua>) (Zeile 486), [consolecommands.lua — function c_save](<../../_scripts/scripts_02_10_2026/scripts/consolecommands.lua>) (Zeile 167), [consolecommands.lua — function c_freecrafting](<../../_scripts/scripts_02_10_2026/scripts/consolecommands.lua>) (Zeile 354). Vorlagen-READMEs nennen konkrete Ausdrücke; destructive Reset-Befehle gehören nicht zum normalen Prüflauf.

## Syntaxprüfung

    & 'D:\CDesktopLink\Portable\lua\lua5_1_4_Win64_bin\luac5.1.exe' -p 'Pfad\modmain.lua'

`-p` prüft Parserkompatibilität und erzeugt keinen Bytecode. Das Ausführen von modmain mit gewöhnlichem lua.exe ist kein Spieltest: Engine-Globals und Components fehlen. Der Sammlungsprüfer ruft den Compiler für jede Lua-Vorlagendatei getrennt auf und meldet Fehler mit Datei.

    & 'D:\CDesktopLink\Portable\Python\WinPy64\python\python.exe' 'Documentation\tools\verify_reference.py'

## Laufzeitmatrix

| Fall | Zu prüfende Wirkung |
|---|---|
| Listen-Host | Serverlogik und eigene Darstellung |
| Separater Client | Fehlende Components, Actions, Netvars und UI |
| Dedicated Server | Keine HUD-/ThePlayer-Annahmen |
| Neues Spiel | Defaults und Konstruktion |
| Save/Restart | Individuelle Daten und Originaldaten |
| Später Beitritt | Initialer Replikationszustand |
| Höhlenwechsel | Session, neue Instanzen und Datenmigration |
| Tod/Ghost/Respawn | Zustandswechsel und erlaubte Actions |
| Item-Transfer/Drop | Besitzwechsel, Zielgültigkeit und Inventarbild |
| Abbruch/Entfernung | Tasks, Listener und BufferedAction |
| Andere Mods | Wrapper, Rezepte, Tags und gemeinsame Daten |

Die Matrix ist eine Anleitung. Für diese Dokumentationsaufgabe wurde kein Spielserver gestartet und keine Vorlage ingame als bestanden markiert. Siehe [VALIDATION](VALIDATION.md).

## Performance

World-/Prefab-Events bevorzugen, wenn das Feature einen passenden Event besitzt. Periodische Tasks nicht ohne Zweck pro Entity installieren. PostInitAny zuerst günstig filtern. Große Suchradien, häufige FindEntities-Abfragen und veränderliche Netzwerkstrings messen und begrenzen.

Vorübergehendes Spawnen kann sämtliche Prefab-Hooks und deren Nebenwirkungen auslösen. Physics-Based Spacing erzeugt Objekte zur Radiusmessung; dieses Muster nur nach Prüfung verwenden und nicht als harmlose Metadatenabfrage verstehen. Nil-Prüfungen sind wichtig, dürfen jedoch einen verletzten Vertrag nicht still dauerhaft verstecken.

Belege: [modutil.lua: Performancehinweis im Kommentar](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 577), [mainfunctions.lua — function SpawnPrefabFromSim](<../../_scripts/scripts_02_10_2026/scripts/mainfunctions.lua>) (Zeile 347), [Physics-Based Spacing 2840497376/modmain.lua — local function GetFabRad](<../Physics-Based Spacing 2840497376/modmain.lua>) (Zeile 7).

## Kompatibilität

Eigene Namen präfixieren, Originalmethoden und Rückgaben erhalten, Originalreferenzlisten nicht verlieren. Geteilte Tabellen wie containers.params vor individuellen Änderungen tief kopieren. Ob Modifier oder Callback-Wrapper richtig sind, hängt vom konkreten Vanilla-Vertrag ab.

Upvalue-Hacking und direkte Ersetzung ganzer Dateien sind besonders updateempfindlich. Tests mit einer kleinen relevanten Mod-Kombination ausführen statt jede denkbare Mod zu installieren. Konflikte nach gemeinsam verändertem Prefab, Component, Rezept, UI-Klasse oder Global eingrenzen.
