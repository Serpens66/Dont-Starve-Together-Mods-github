# Vorlage 02 – Neuer Gegenstand mit Vanilla-Assets

Dateien: [modinfo.lua](modinfo.lua), [modmain.lua](modmain.lua), [Prefab](scripts/prefabs/doc_training_spear.lua). Alle Clients benötigen die Mod. `doc_training_spear` ist ein eigenständiger Übungsspeer: 20 Basisschaden, 50 Verwendungen, Rezept aus zwei Zweigen und einem Flint ohne Prototyper.

## Einbau und Voraussetzungen

Den gesamten Ordner als neue Mod installieren und auf dem Server aktivieren; für Netzwerkclients müssen dieselben Dateien vorliegen. Die Präfixe `doc_` und Stringschlüssel durch eigene eindeutige Namen ersetzen, einschließlich PrefabFiles und Rezeptname.

Verwendet die bereits vorhandenen Animationsarchive spear und swap_spear sowie spear.tex über GetInventoryItemAtlas. Es wird kein neues Bild exportiert. Vorhandene Assets bedeuten hier nicht, dass beliebige fremde Mod-Assets ohne Erlaubnis übernommen werden dürfen.

Geprüfte Grundlage: [Prefabkonstruktion](../../03_Prefabs_Components.md), [Ausrüstung](../../06_Gegenstaende_Gebaeude_Container.md), [Recipe2](../../07_Crafting_Kochen.md) und [Bank/Build](../../12_Assets_Animation_Audio.md). Shared Konstruktion, Netzwerk und Tags liegen vor SetPristine; anschließend kehrt der Client zurück. Equip/Unequip überschreibt swap_object und schaltet Arm-Symbole. Component-Serverdaten werden vom Vanilla-Savevertrag übernommen. Das Beispiel enthält keine eigenen Skins oder Charakteranimationen.

## Konkrete Prüfungen

1. Syntax prüfen; Welt mit Mod auf Host und separatem Client starten.
2. Rezept in MODS/WEAPONS suchen, Kosten und Anzeigenamen prüfen. Tatsächlich craften und Zutatenverbrauch prüfen; Freecrafting reicht dafür nicht.
3. `c_give("doc_training_spear")` im passenden Serverkontext. Inventarbild, Handbild und Bodenbild prüfen; ausrüsten und ablegen.
4. An einem Testziel ohne zusätzliche Schadensmod den Basisschaden und sinkende Haltbarkeit prüfen. Nach Verbrauch muss das Objekt verschwinden.
5. Ins Wasser werfen: Float-Verhalten und Symbol prüfen. Controller-Inventar und Ausrüstung ebenfalls testen.
6. Speichern/Laden mit teils verbrauchtem Speer; erneut verbinden; mit dem Gegenstand zwischen Forest und Caves wechseln. Haltbarkeit und Ausrüstung müssen konsistent bleiben.
7. Dedicated prüfen, insbesondere Assetfehler und fehlende Client-Prefabs.

**Status:** Keine dieser Ingame-Prüfungen wurde ausgeführt; Compilerprüfung ist separat dokumentiert.


## Erneute statische Prüfung

Ladeumgebung, Registrierungen, Vanilla-Aufrufer, Rollen, Speicherung und Cleanup erneut geprüft. [Vorlagenmatrix](../../24_Statische_Vertragspruefung.md#zwölf-vorlagen-geprüfte-schnittstellen) benennt Sonderfälle und Grenzen. [Isolierte Tests](../../tests/README.md) gelten nur für die dort genannten Logikpfade, keine Laufzeitabnahme dieser Mod.
