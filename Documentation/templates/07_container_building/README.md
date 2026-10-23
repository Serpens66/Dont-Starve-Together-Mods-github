# Dokumentationskiste

Eigenständiger Modordner: den gesamten Inhalt dieses Ordners einschließlich `scripts` in einen neuen lokalen Modordner kopieren; nicht nur modmain in eine andere Vorlage einfügen. Vanilla-Assets benötigen keine eigenen Exporte. Die Beispieldateien haben eindeutige Namen. Vor Integration Namen, Konfiguration, Ladeordnung und gleichzeitige andere Hooks prüfen.

## Dateien und Zuständigkeit

- `modinfo.lua`
- `modmain.lua`
- `scripts/prefabs/doc_storage_chest.lua`

## Funktionsweise und Grenzen

Die Containerparameter sind auf beiden Seiten bekannt. Spielinhalt und Abbau laufen auf dem Server; container_classified überträgt Slots und Öffnerzustand. `container:OnSave/OnLoad` speichert enthaltene SaveRecords bereits: kein zweiter eigener Slot-Speicher. Dieses kleine Gebäude hat bewusst keine Brennbarkeit, Skins, Aufwertung, Minimap oder Rückerstattung aller Baukosten. Beim Abbau fällt ein Brett; Inhalt wird vorher vollständig abgelegt.

## Quellenkette des statischen Audits

[prefabs/treasurechest.lua — MakeChest](<../../../../_scripts/scripts_02_10_2026/scripts/prefabs/treasurechest.lua>) (Zeile 100) → [containers.lua — widgetsetup](<../../../../_scripts/scripts_02_10_2026/scripts/containers.lua>) (Zeile 9) → [components/container.lua — function Container:OnSave](<../../../../_scripts/scripts_02_10_2026/scripts/components/container.lua>) (Zeile 979) / [components/container.lua — function Container:OnLoad](<../../../../_scripts/scripts_02_10_2026/scripts/components/container.lua>) (Zeile 996) → [components/container_replica.lua — container_classified](<../../../../_scripts/scripts_02_10_2026/scripts/components/container_replica.lua>) (Zeile 23); [prefabutil.lua — MakePlacer](<../../../../_scripts/scripts_02_10_2026/scripts/prefabutil.lua>) (Zeile 1); [components/workable.lua — SetOnFinishCallback](<../../../../_scripts/scripts_02_10_2026/scripts/components/workable.lua>) (Zeile 177).

## Testprotokoll – offen, keine Spielinstanz gestartet

1. Host und separater Client: am Forschungsgerät bauen, Placer drehen, beide Seiten müssen neun Slots sehen. Zwei Spieler öffnen/schließen und verschieben gestapelte sowie verderbliche Gegenstände; keine Verdopplung.
2. Dedicated Server: identische Dateien, Clientbeitritt und Öffnen prüfen; HUD-Code darf nicht serverseitig nötig sein.
3. Vor und nach Save/Load Slotposition, Stackgröße, Haltbarkeit und Inhalt vergleichen; Reconnect während geöffnetem Container.
4. Mit gefüllter Kiste hämmern: alle Inhalte plus ein Brett auf Boden, Entity entfernt. Höhlen: dort separat bauen/speichern; eine ortsfeste Kiste migriert nicht mit dem Spieler.

Syntaxprüfung mit `luac5.1.exe -p` prüft weder Engine-Globals noch Assets, Prediction oder Multiplayer. Ergebnisse stehen im [Prüfbericht](../../VALIDATION.md). Für ein neues Projekt außerdem den [Workflow](../../20_Projektworkflow.md) und die [Checklisten](../../19_Checklisten.md) verwenden.


## Erneute statische Prüfung

Ladeumgebung, Registrierungen, Vanilla-Aufrufer, Rollen, Speicherung und Cleanup erneut geprüft. [Vorlagenmatrix](../../24_Statische_Vertragspruefung.md#zwölf-vorlagen-geprüfte-schnittstellen) benennt Sonderfälle und Grenzen. [Isolierte Tests](../../tests/README.md) gelten nur für die dort genannten Logikpfade, keine Laufzeitabnahme dieser Mod.
