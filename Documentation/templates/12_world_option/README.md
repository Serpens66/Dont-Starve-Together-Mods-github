# Weltoption mit gespeichertem Intervall

Eigenständiger Modordner: den gesamten Inhalt dieses Ordners einschließlich `scripts` in einen neuen lokalen Modordner kopieren; nicht nur modmain in eine andere Vorlage einfügen. Vanilla-Assets benötigen keine eigenen Exporte. Die Beispieldateien haben eindeutige Namen. Vor Integration Namen, Konfiguration, Ladeordnung und gleichzeitige andere Hooks prüfen.

## Dateien und Zuständigkeit

- `modinfo.lua`
- `modmain.lua`
- `modworldgenmain.lua`
- `scripts/components/doc_worldpulse.lua`

## Funktionsweise und Grenzen

Die sichtbare Weltoption ändert tatsächlich das Intervall eines serverseitigen Log-Pulses und dessen gespeicherten Zähler. Keine ungewollten Spawns. Ein eigener Task besitzt eine einzige Daten-/Load-Verantwortung; unabhängig von der Reihenfolge anderer Component-OnLoad-Funktionen. Gespeichert werden Sekundenrest, altes Intervall, Zähler und Schema; kein Taskhandle. Bei geänderter Option bleibt der prozentuale Fortschritt erhalten (15 von 30 Sekunden → 30 von 60). Offline-Wallclockzeit wird nicht abgezogen; LongUpdate/Fast-forward ist kein implementierter Vertrag dieses Beispiels. Forest und Cave besitzen je ihren eigenen Timer; keine globale shardsynchrone Pulsuhr.

## Quellenkette des statischen Audits

[mods.lua — "modworldgenmain.lua"](<../../../../_scripts/scripts_02_10_2026/scripts/mods.lua>) (Zeile 445) → [modutil.lua — env.AddCustomizeGroup = function](<../../../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 212) → [map/customize.lua — local function AddCustomizeItem](<../../../../_scripts/scripts_02_10_2026/scripts/map/customize.lua>) (Zeile 1157) → [gamelogic.lua — WorldSettings_Overrides.Pre](<../../../../_scripts/scripts_02_10_2026/scripts/gamelogic.lua>) (Zeile 386) / [gamelogic.lua — WorldSettings_Overrides.Post](<../../../../_scripts/scripts_02_10_2026/scripts/gamelogic.lua>) (Zeile 608) → [entityscript.lua — SetPersistData](<../../../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 1954); Timersemantik verglichen mit [components/timer.lua — function Timer:OnSave](<../../../../_scripts/scripts_02_10_2026/scripts/components/timer.lua>) (Zeile 122) und [networkclientrpc.lua — SyncWorldSettings](<../../../../_scripts/scripts_02_10_2026/scripts/networkclientrpc.lua>) (Zeile 1571).

## Testprotokoll – offen, keine Spielinstanz gestartet

1. Neue Welt: Option sichtbar, normal alle 30 Sekunden ein Serverlog; fast 15, slow 60. Host und Dedicated jeweils separat. Client darf keinen eigenen Puls ausführen.
2. Nach halbem Intervall speichern/laden: erster nächster Puls nach verbliebener Hälfte. Mit geänderter Option laden: Rest proportional statt kompletter Neustart. Logzähler fortlaufend.
3. Fehlende Daten/älterer Save startet Standardtimer; ungültige Datentypen fallen sicher zurück. Reconnect verändert Timer nicht.
4. Forest/Cave mit verschiedenen Optionen, Wechsel und Neustart beider Shards: je eigener Zähler. Live-Welteinstellung prüfen: Post skaliert bestehenden Rest. Pause/Fast-forward separat testen; Offlinezeitablauf wird nicht zugesichert.

Syntaxprüfung mit `luac5.1.exe -p` prüft weder Engine-Globals noch Assets, Prediction oder Multiplayer. Ergebnisse stehen im [Prüfbericht](../../VALIDATION.md). Für ein neues Projekt außerdem den [Workflow](../../20_Projektworkflow.md) und die [Checklisten](../../19_Checklisten.md) verwenden.


## Erneute statische Prüfung

Ladeumgebung, Registrierungen, Vanilla-Aufrufer, Rollen, Speicherung und Cleanup erneut geprüft. [Vorlagenmatrix](../../24_Statische_Vertragspruefung.md#zwölf-vorlagen-geprüfte-schnittstellen) benennt Sonderfälle und Grenzen. [Isolierte Tests](../../tests/README.md) gelten nur für die dort genannten Logikpfade, keine Laufzeitabnahme dieser Mod.
