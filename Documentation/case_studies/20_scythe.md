# Scythe

**Prüfart:** statische Ablaufanalyse; wesentlicher Ablauf beschrieben. Keine Ingame-Funktionszusage. Alle Verzeichnisse: `Scythe 733887349`.

## Einstieg und Abhängigkeiten

Neue Sense/goldene Sense mit eigenen anim-/swap-/Bildassets und Legacyrezept. Prefabs ergänzen tool/weapon/finiteuses/equippable und Equip-Tags für schnelleres Arbeiten.

## Initialisierung, Interaktion und Serverwirkung

Gemeinsame Darstellung und Tags erlauben Aktionen; Servercomponents bestimmen Wirkung/Verbrauch. Equip setzt Symbol und Fastpickerfunktion, Unequip baut zurück. Standardfiniteuses/inventory speichern Itemzustand, kein eigenes Upgradeformat. Ein Charakter kann fastpicker bereits aus anderer Quelle besitzen; reines RemoveTag beim Unequip benötigt Herkunftsprüfung.

## Replikation, UI, Speicherung und Wiederherstellung

Speicher-/Clientvertrag ist im oben beschriebenen Ablauf eingeordnet. Keine zusätzliche Persistenz oder Replica annehmen, wenn der Code nur Vanilla-Werte/Tags ändert. Reconnect rekonstruiert die aktuelle Modinitialisierung; Konfigurationsänderungen wirken deshalb nach ihrem tatsächlichen Ladepunkt.

## Cleanup und Lebensdauer

Entityeigene Tasks und Listener werden beim Entfernen bereinigt; das ersetzt keine Prüfung bereits gestarteter, fremder oder global registrierter Callbackpfade. Entfernen eigener Modifier/Tags darf keine fremde Quelle löschen.

## Aktuelle Vanilla-Kette

[Scythe 733887349/scripts/prefabs/scythe.lua — SetOnEquip](<../../Scythe 733887349/scripts/prefabs/scythe.lua>) (Zeile 83); [prefabs/spear.lua — SetPristine](<../../../_scripts/scripts_02_10_2026/scripts/prefabs/spear.lua>) (Zeile 49) / [components/tool.lua — SetAction](<../../../_scripts/scripts_02_10_2026/scripts/components/tool.lua>) (Zeile 41) / [components/finiteuses.lua — OnSave](<../../../_scripts/scripts_02_10_2026/scripts/components/finiteuses.lua>) (Zeile 48) / [stategraphs/SGwilson.lua — fastpicker](<../../../_scripts/scripts_02_10_2026/scripts/stategraphs/SGwilson.lua>) (Zeile 1047).

## Altlasten und konkrete Prüfgrenze

Historischer Clientreturn vor SetPristine ist gegenüber aktuellem Speerbau ein problematisches Netzwerk-Muster. Golden/Standard getrennt und alle Assetbank-/Buildnamen prüfen. Fehlende Runtimeabnahme kann durch Syntax nicht ersetzt werden.

## Szenarien für die spätere Laufzeitabnahme

Beide Varianten bauen, equip/unequip, viele Pick-/Workaktionen bis Verbrauch, Doppelbonuscharakter. Save/Load ausgerüstet, late join, Dedicated, Höhlenwechsel und Controller.

Alle Szenarien sind **offen**. Für Dedicated-Server, separaten Client, Reconnect und Shardwechsel gelten zusätzlich die [allgemeinen Checklisten](../19_Checklisten.md). Statische Symbol-/Hashprüfung ersetzt diese Abnahme nicht. [Katalog](../16_Workspace_Mods.md) · [Abdeckungsmatrix](../21_Abdeckungsmatrix.md) · [Projektworkflow](../20_Projektworkflow.md).


## Dateiregister: Scythe 733887349

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [modinfo.lua](<../../Scythe 733887349/modinfo.lua>)
- [modmain.lua](<../../Scythe 733887349/modmain.lua>)
- [scripts/prefabs/scythe.lua](<../../Scythe 733887349/scripts/prefabs/scythe.lua>)
- [scripts/prefabs/scythe_golden.lua](<../../Scythe 733887349/scripts/prefabs/scythe_golden.lua>)


## Erneute Prüfung: Tagbesitz und Aktionsverbrauch

Equip merkt vorhandenes fastpicker über fastpickerorignal und setzt sonst fastpicker; Unequip entfernt entsprechend. Das schützt nur das beim Equip beobachtete Tag, keinen inzwischen hinzugekommenen fremden Tagbesitz. Mehrere Mods mit gemeinsamer Markerlogik sind eigene Konfliktfälle. Tool setzt ACTIONS.PICK, finiteuses verbraucht PICK-Anwendungen; Weapon benutzt eigene Damagekonfiguration. Ein Tooltag allein bestimmt noch keinen heutigen vollständigen Actionhandler.

Der Clientreturn erfolgt vor SetPristine; aktuelle Vanilla-Beispiele tun dies umgekehrt. Bodenbuild und swapbuild sind getrennte Assets/Symbole. Normal-/Goldprefab und Rezept nicht über gleiche Namen gleichsetzen. Neue Ausrüstung präzise eigene Modifierquelle bzw. koordinierten Tagbesitz verwenden und Original-Equip-/Unequiporder erhalten. Tests: bereits vorhandenes fastpicker, fremd während Equip hinzugefügter Beitrag, letzter Use, beschädigter Load und remote PICK.


Konkrete zusätzliche Funktionsdefinitionen: [Vertragsbelege](../27_Vertragsbelege.md). Die [Reviewmatrix](../REVIEW_MATRIX.json) trennt Einstiegssichtung und ausgewählte vertiefte Abläufe; weitere Featureänderungen benötigen einen eigenen aktuellen Audit.
