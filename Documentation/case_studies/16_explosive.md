# More Explosive Range

**Prüfart:** statische Ablaufanalyse; wesentlicher Ablauf beschrieben. Keine Ingame-Funktionszusage. Alle Verzeichnisse: `More Explosive Range 763290344`.

## Einstieg und Abhängigkeiten

Serverreturn begrenzt Registrierung; PrefabPostInit für gunpowder und slurtleslime addiert Configwerte zu explosiverange/explosivedamage.

## Initialisierung, Interaktion und Serverwirkung

Explosive verwendet diese Felder beim Explodieren. Keine neuen Assets, Netvars oder gespeicherten Felder; Werte werden bei jedem Spawn/Load aus der Konfiguration wieder gesetzt. Bestehendes explosive-/burnable-Lifecycle bleibt Vanilla. Radius beeinflusst mehrere Ziele, Schaden pro Ziel folgt dessen weiteren Regeln.

## Replikation, UI, Speicherung und Wiederherstellung

Speicher-/Clientvertrag ist im oben beschriebenen Ablauf eingeordnet. Keine zusätzliche Persistenz oder Replica annehmen, wenn der Code nur Vanilla-Werte/Tags ändert. Reconnect rekonstruiert die aktuelle Modinitialisierung; Konfigurationsänderungen wirken deshalb nach ihrem tatsächlichen Ladepunkt.

## Cleanup und Lebensdauer

Entityeigene Tasks und Listener werden beim Entfernen bereinigt; das ersetzt keine Prüfung bereits gestarteter, fremder oder global registrierter Callbackpfade. Entfernen eigener Modifier/Tags darf keine fremde Quelle löschen.

## Aktuelle Vanilla-Kette

[More Explosive Range 763290344/modmain.lua — explosiverange](<../../More Explosive Range 763290344/modmain.lua>) (Zeile 7); [components/explosive.lua — OnBurnt](<../../../_scripts/scripts_02_10_2026/scripts/components/explosive.lua>) (Zeile 27); [prefabs/gunpowder.lua — explosive](<../../../_scripts/scripts_02_10_2026/scripts/prefabs/gunpowder.lua>) (Zeile 28).

## Altlasten und konkrete Prüfgrenze

Werte auf Typ/zulässigen Bereich prüfen, wenn freie Config erlaubt wird. Anderer Prefabhook kann denselben Wert danach ersetzen. Explosionsradius ist keine sichere Aussage über Feuer-Ausbreitungsradius.

## Szenarien für die spätere Laufzeitabnahme

Null/Standard/großer Radius, Ziele innen/außen, mehrere Pulverstacks; Host/Client/Dedicated sehen gleiche serverseitige Schäden. Save/Load unter geänderter Config. Caveexplosion.

Alle Szenarien sind **offen**. Für Dedicated-Server, separaten Client, Reconnect und Shardwechsel gelten zusätzlich die [allgemeinen Checklisten](../19_Checklisten.md). Statische Symbol-/Hashprüfung ersetzt diese Abnahme nicht. [Katalog](../16_Workspace_Mods.md) · [Abdeckungsmatrix](../21_Abdeckungsmatrix.md) · [Projektworkflow](../20_Projektworkflow.md).


## Dateiregister: More Explosive Range 763290344

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [modinfo.lua](<../../More Explosive Range 763290344/modinfo.lua>)
- [modmain.lua](<../../More Explosive Range 763290344/modmain.lua>)


## Erneute Prüfung: Radius, Stack und Schadenstypen

Der Einstieg addiert Configwerte nur an gunpowder/slurtleslime-explosive. Aktuelles explosive:OnBurnt multipliziert Damage/Buildingdamage mit Stackgröße, sucht Ziele im eingestellten Radius, prüft Workables, Brand, Combat, Zielresistenz und gesonderten Schaden. Radiusvergrößerung ändert Zielmenge, nicht alle anderen Einschränkungen. Explosivedamage ist kein direktes Setzen verlorener HP. Keine eigene Persistenz für Configderived Werte; sie werden beim Prefabaufbau erneut gesetzt. Nach Configänderung sowohl Singles als auch Stacks, Gebäude, Dock und Combatziele prüfen.


Konkrete zusätzliche Funktionsdefinitionen: [Vertragsbelege](../27_Vertragsbelege.md). Die [Reviewmatrix](../REVIEW_MATRIX.json) trennt Einstiegssichtung und ausgewählte vertiefte Abläufe; weitere Featureänderungen benötigen einen eigenen aktuellen Audit.
