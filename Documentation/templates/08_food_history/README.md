# Persistente Nahrungshistorie

Eigenständiger Modordner: den gesamten Inhalt dieses Ordners einschließlich `scripts` in einen neuen lokalen Modordner kopieren; nicht nur modmain in eine andere Vorlage einfügen. Vanilla-Assets benötigen keine eigenen Exporte. Die Beispieldateien haben eindeutige Namen. Vor Integration Namen, Konfiguration, Ladeordnung und gleichzeitige andere Hooks prüfen.

## Dateien und Zuständigkeit

- `modinfo.lua`
- `modmain.lua`
- `scripts/components/doc_foodhistory.lua`

## Funktionsweise und Grenzen

Bei einem der letzten drei unterschiedlichen Prefabnamen werden positive Nahrungsdeltas halbiert. Nach erfolgreichem Essen wird der Name an den Anfang verschoben. Es gibt keinen Zeitablauf und keine eigene UI/Replica; Standardwerte werden durch Vanilla repliziert. Gewürzte Gerichte sind getrennte Prefabs; anders als foodmemory wird nicht auf ein Basisgericht normalisiert. Bestehendes foodmemory wirkt zusätzlich. Vorhandene custom_stats_mod_fn wird verkettet; kompatible Rückgaben müssen drei Zahlen sein. Ein späterer Mod, der den Callback ersetzt, kann diesen Effekt verdrängen. Das Beispiel behauptet keine allgemeine Kompatibilität mit allen Ernährungssystemen.

## Quellenkette des statischen Audits

[components/eater.lua — custom_stats_mod_fn](<../../../../_scripts/scripts_02_10_2026/scripts/components/eater.lua>) (Zeile 276) → [components/eater.lua — PushEvent("oneat"](<../../../../_scripts/scripts_02_10_2026/scripts/components/eater.lua>) (Zeile 302) → [components/foodmemory.lua — RememberFood](<../../../../_scripts/scripts_02_10_2026/scripts/components/foodmemory.lua>) (Zeile 32) / [components/foodmemory.lua — GetFoodMultiplier](<../../../../_scripts/scripts_02_10_2026/scripts/components/foodmemory.lua>) (Zeile 53) → [entityscript.lua — SetPersistData](<../../../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 1954). Die Reihenfolge wurde am vollständigen Eat-Ablauf geprüft.

## Testprotokoll – offen, keine Spielinstanz gestartet

1. Host/Client unterhalb voller Werte: zweimal dasselbe Essen, danach drei andere unterschiedliche Gerichte und erneut das erste. Zweite positive Wirkung ist halbiert; nach Verdrängung wieder normal. Giftige/negative Deltas nicht halbieren.
2. Save/Load und Reconnect: Reihenfolge bleibt; erfolglose Essversuche verändern sie nicht. Dedicated: nur Server besitzt doc_foodhistory.
3. Warly, Food Queue und anderer Callback-Mod jeweils separat und kombiniert in beiden Ladeordnungen prüfen; Modifier-Multiplikation dokumentieren.
4. Höhlenwechsel und Rückkehr: Historie über Vanilla-Spielermigration prüfen; Tod/Geist/Wiederbelebung separat. Kein Offline-Zeitablauf erwartet.

Syntaxprüfung mit `luac5.1.exe -p` prüft weder Engine-Globals noch Assets, Prediction oder Multiplayer. Ergebnisse stehen im [Prüfbericht](../../VALIDATION.md). Für ein neues Projekt außerdem den [Workflow](../../20_Projektworkflow.md) und die [Checklisten](../../19_Checklisten.md) verwenden.


## Erneute statische Prüfung

Ladeumgebung, Registrierungen, Vanilla-Aufrufer, Rollen, Speicherung und Cleanup erneut geprüft. [Vorlagenmatrix](../../24_Statische_Vertragspruefung.md#zwölf-vorlagen-geprüfte-schnittstellen) benennt Sonderfälle und Grenzen. [Isolierte Tests](../../tests/README.md) gelten nur für die dort genannten Logikpfade, keine Laufzeitabnahme dieser Mod.
