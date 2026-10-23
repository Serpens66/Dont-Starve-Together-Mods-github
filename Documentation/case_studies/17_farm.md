# More Farm Harvest

**Prüfart:** statische Ablaufanalyse; wesentlicher Ablauf beschrieben. Keine Ingame-Funktionszusage. Alle Verzeichnisse: `More Farm Harvest 736398747`.

## Einstieg und Abhängigkeiten

Serverseitiger crop-Componenthook wrappt Harvest und bewahrt ret,product. Aktuelle farmplant-Systeme werden nicht mit erfasst.

## Initialisierung, Interaktion und Serverwirkung

Nur bei erfolgreicher Ernte wird ein gemeinsamer Zufallswert gegen zwei Configschwellen geprüft. Ergebnis 0/1/2 zusätzliche Produkte; die Zweierschwelle überschreibt die Einerschwelle. Tasks am Harvester geben nach .23/.46 Sekunden neue Produkte, übernehmen Weltwetness und legen bei fehlendem inventoryitem auf den Boden. Keine Extra-Savefelder; geplante noch nicht ausgeführte Tasks werden nicht als zukünftige Ernte gespeichert.

## Replikation, UI, Speicherung und Wiederherstellung

Speicher-/Clientvertrag ist im oben beschriebenen Ablauf eingeordnet. Keine zusätzliche Persistenz oder Replica annehmen, wenn der Code nur Vanilla-Werte/Tags ändert. Reconnect rekonstruiert die aktuelle Modinitialisierung; Konfigurationsänderungen wirken deshalb nach ihrem tatsächlichen Ladepunkt.

## Cleanup und Lebensdauer

Entityeigene Tasks und Listener werden beim Entfernen bereinigt; das ersetzt keine Prüfung bereits gestarteter, fremder oder global registrierter Callbackpfade. Entfernen eigener Modifier/Tags darf keine fremde Quelle löschen.

## Aktuelle Vanilla-Kette

[More Farm Harvest 736398747/modmain.lua — CropPostInit](<../../More Farm Harvest 736398747/modmain.lua>) (Zeile 5); [components/crop.lua — Harvest](<../../../_scripts/scripts_02_10_2026/scripts/components/crop.lua>) (Zeile 43) / [components/inventory.lua — GiveItem](<../../../_scripts/scripts_02_10_2026/scripts/components/inventory.lua>) (Zeile 131) / [entityscript.lua — DoTaskInTime](<../../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 1522).

## Altlasten und konkrete Prüfgrenze

Verzögerter Harvester kann ungültig sein oder kein inventory besitzen; task-local Spawnfehlermeldung/Guard fehlt. Kommentierte Stackanzeige-Begründung ist historisch, kein aktueller Netzwerkbeweis. Keine Unterstützung neuer Farm Soil allein durch Hook auf crop.

## Szenarien für die spätere Laufzeitabnahme

Crop und moderne Farmplant getrennt, volles Inventar, Ernteabbruch, sofortiger Disconnect, Save zwischen Tasks. Zufallsverteilung mit genügend Samples; Dedicated und Cave.

Alle Szenarien sind **offen**. Für Dedicated-Server, separaten Client, Reconnect und Shardwechsel gelten zusätzlich die [allgemeinen Checklisten](../19_Checklisten.md). Statische Symbol-/Hashprüfung ersetzt diese Abnahme nicht. [Katalog](../16_Workspace_Mods.md) · [Abdeckungsmatrix](../21_Abdeckungsmatrix.md) · [Projektworkflow](../20_Projektworkflow.md).


## Dateiregister: More Farm Harvest 736398747

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [modinfo.lua](<../../More Farm Harvest 736398747/modinfo.lua>)
- [modmain.lua](<../../More Farm Harvest 736398747/modmain.lua>)


## Erneute Prüfung: Ertragswahrscheinlichkeit und zeitversetzte Drops

Ein gemeinsamer Zufallswert wird nacheinander gegen one_harvest und two_harvest geprüft; der zweite Treffer überschreibt count. Das sind keine zwei unabhängigen Bernoulliversuche. Original Crop:Harvest liefert bereits product nach eigenem Inventar-/Growercleanup; die Mod übernimmt product.prefab und spawnt Extras nach 0.23/0.46 Sekunden beim Harvester. Moderne Farmplants verwenden weitere Mechanismen und werden durch diesen crop-Hook nicht automatisch erfasst.

Zwischen Harvest und Task können Harvester, Inventar oder Produktprefab ungültig sein. Der Spawn benötigt Gültigkeits-/Nilprüfungen; nasse Extras verwenden Weltwetness statt exakt jeden modernen Standortsonderfall. Ein neuer Wrapper muss das Originalergebnis erhalten, Workable-/Growercleanup nicht doppelt ausführen und Erfolg von GiveItem nicht mit garantiertem Stackverbleib verwechseln. Tests: volle Tasche, Feuerernte, Harvesterentfernung vor Delay und unterschiedliche Wahrscheinlichkeitseinstellungen.


Konkrete zusätzliche Funktionsdefinitionen: [Vertragsbelege](../27_Vertragsbelege.md). Die [Reviewmatrix](../REVIEW_MATRIX.json) trennt Einstiegssichtung und ausgewählte vertiefte Abläufe; weitere Featureänderungen benötigen einen eigenen aktuellen Audit.
