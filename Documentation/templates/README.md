# Eigenständige Lua-Vorlagen

Jeden Unterordner **einzeln und vollständig** als neue lokale Mod kopieren. Nicht alle modmain-Dateien zusammenführen. Die Demo-Namen vor produktiver Nutzung durch ein eigenes eindeutiges Präfix ersetzen; bei Modulen auch Dateinamen und require-/Component-Verweise anpassen.

| Vorlage | Fähigkeit | Aktivierung |
|---|---|---|
| [01 prefab tweak](01_prefab_tweak/README.md) | Konfigurierbarer Speerschaden | Server-Mod, Clients nicht erforderlich |
| [02 item](02_item/README.md) | Neuer Trainingsspeer und Rezept | Server und alle Clients |
| [03 network component](03_network_component/README.md) | Persistenter öffentlicher Zähler, Replica und RPC | Server und alle Clients |
| [04 action](04_action/README.md) | Persistente Truhenmarkierung per Action | Server und alle Clients |
| [05 client UI](05_client_ui/README.md) | Lokale HUD-Beschriftung | Client-Mod |
| [06 worldgen](06_worldgen/README.md) | Room-Gewicht bei neuer Welterzeugung | Server-Mod, neue Welt |

Alle Lua-Dateien verwenden UTF-8 ohne BOM, CRLF und Lua-5.1-Syntax. Es werden Vanilla-Assets referenziert und keine fremden Grafikdateien kopiert. Keine Vorlage enthält eine eigene Workshop-ID.

**Status: statischer Quellenabgleich und Lua-5.1-Syntaxprüfung aller 42 Vorlagen-Lua-Dateien mit -p bestanden; keine Ingame-Freigabe.** Die jeweiligen READMEs beschreiben die noch auszuführenden Laufzeittests. Diese Vorlagen ändern keine Spielinstallation und keine vorhandene Workspace-Mod.

Metadaten gelten für die demonstrierten Inhalte. Wer zusätzliche Assets, Netvars, UI oder Character-Funktionen ergänzt, muss Mod-Typ und Client-Anforderungen erneut prüfen.


## Zusätzliche praktische Beispiele

| Ordner | Beispiel | Zentrale neue Verträge |
|---|---|---|
| [07_container_building](07_container_building/README.md) | Containergebäude | Widgetparameter, Placer, HAMMER, Slotpersistenz |
| [08_food_history](08_food_history/README.md) | Ernährungshistorie | Callbackreihenfolge, versionierter Save, Eigencleanup |
| [09_source_bonus](09_source_bonus/README.md) | Equipbonus | Entityquelle/Key, Rückbau, Equip nach Load |
| [10_query_ui](10_query_ui/README.md) | Serverabfrage und UI | Input-/Ratevalidierung, Replicaantwort, Sequenz |
| [11_room_task](11_room_task/README.md) | eigene Weltstruktur | Room/Taskregistrierung, default-Taskset, Layout |
| [12_world_option](12_world_option/README.md) | wirksame Weltoption | Pre/Post, eigener persistenter Timer, Restzeitskalierung |

Alle 13 Ordner sind eigenständige Modbeispiele. Ihre READMEs benennen Voraussetzungen, Designgrenzen, Quellenketten und konkrete noch offene Tests. Das [Prüfergebnis](../VALIDATION.md) trennt statische Dokumentationsqualität und Lua-Syntax von Laufzeit. [Praxismechanismen](../23_Praxismechanismen.md) erklären die Zusammensetzung.


Erneute Prüfung und fünf gezielte Vorlagenkorrekturen: [Prüfstatus](../VALIDATION.md). Die 42 Vorlagendateien, zwei separate Fragmente und eine Testdatei werden im Gesamtbericht als 45 Syntaxdateien gezählt. Die Logiktests betreffen nur ihre ausdrücklich bezeichneten Pfade.

## Kochinhalte

[13_cooked_food](13_cooked_food/README.md) ist die zusätzliche eigenständige Kochvorlage: neues Produkt-Prefab, drei Kocherregistrierungen, explizite Auswahlfelder, wiederverwendete Speisengrafik und Cookbookbild. Die [Fragmente für Brains/Charactercallbacks](../examples/README.md) werden getrennt geführt; sie sind keine installierbaren Modordner.
