# Physics-Based Spacing

**Prüfart:** statische Ablaufanalyse; wesentlicher Ablauf beschrieben. Keine Ingame-Funktionszusage. Alle Verzeichnisse: `Physics-Based Spacing 2840497376`.

## Einstieg und Abhängigkeiten

World-Prefabhook plant nach einem Frame eine Iteration über AllRecipes. GetFabRad spawnt jedes Produkt temporär, liest Physicsradius und entfernt es.

## Initialisierung, Interaktion und Serverwirkung

Cache setzt radius+1, danach weiterer Buffer1. min_spacing wird nur verkleinert; bei fehlender Physics wird build_distance auf0 gesetzt. Rezeptdefinitionen werden im aktuellen Runtimeprozess verändert, nicht Worldsavewerte. Client- und Serverrezeptstand müssen übereinstimmen; auch ein sofort entfernter Testprefab hat Konstruktor-/PostInit-Seiteneffekte.

## Replikation, UI, Speicherung und Wiederherstellung

Speicher-/Clientvertrag ist im oben beschriebenen Ablauf eingeordnet. Keine zusätzliche Persistenz oder Replica annehmen, wenn der Code nur Vanilla-Werte/Tags ändert. Reconnect rekonstruiert die aktuelle Modinitialisierung; Konfigurationsänderungen wirken deshalb nach ihrem tatsächlichen Ladepunkt.

## Cleanup und Lebensdauer

Entityeigene Tasks und Listener werden beim Entfernen bereinigt; das ersetzt keine Prüfung bereits gestarteter, fremder oder global registrierter Callbackpfade. Entfernen eigener Modifier/Tags darf keine fremde Quelle löschen.

## Aktuelle Vanilla-Kette

[Physics-Based Spacing 2840497376/modmain.lua — GetFabRad](<../../Physics-Based Spacing 2840497376/modmain.lua>) (Zeile 7); [components/builder_replica.lua — CanBuildAtPoint](<../../../_scripts/scripts_02_10_2026/scripts/components/builder_replica.lua>) (Zeile 420) / [components/placer.lua — OnUpdate](<../../../_scripts/scripts_02_10_2026/scripts/components/placer.lua>) (Zeile 403) / [mainfunctions.lua — function SpawnPrefab(](<../../../_scripts/scripts_02_10_2026/scripts/mainfunctions.lua>) (Zeile 403).

## Altlasten und konkrete Prüfgrenze

Keine serverseitige Spawnbegrenzung im Einstieg. obj.prefab="" ist kein Ersatz für inst.persists=false und verhindert Konstruktor-/Hookkosten nicht. Neue Lösung braucht bekannte Radien oder eng begrenzten serverseitigen Auditcache; Client-Spawn neuer Gameplayentities nicht voraussetzen.

## Szenarien für die spätere Laufzeitabnahme

Große/kleine Physics, Produkte ohne Physics, Boote, Skinprodukte, Modprefabs mit Spawneffekt. Clientplacer und serverseitige Ablehnung vergleichen; Save/Load/Reconnect und Cave.

Alle Szenarien sind **offen**. Für Dedicated-Server, separaten Client, Reconnect und Shardwechsel gelten zusätzlich die [allgemeinen Checklisten](../19_Checklisten.md). Statische Symbol-/Hashprüfung ersetzt diese Abnahme nicht. [Katalog](../16_Workspace_Mods.md) · [Abdeckungsmatrix](../21_Abdeckungsmatrix.md) · [Projektworkflow](../20_Projektworkflow.md).


## Dateiregister: Physics-Based Spacing 2840497376

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [modinfo.lua](<../../Physics-Based Spacing 2840497376/modinfo.lua>)
- [modmain.lua](<../../Physics-Based Spacing 2840497376/modmain.lua>)


## Erneute Prüfung: Probeentities sind echte Konstruktionen

GetFabRad spawnt für Recipeprodukte echte Prefabs, liest Physicsradius, speichert radius+1 und entfernt das Objekt. Buffer addiert nochmals 1; für bekannte Radien wird daher radius+2 mit min_spacing verglichen, nur kleinere Werte werden gesetzt. Ohne ermittelten Radius setzt der Mod build_distance=0. Er ändert damit neben Abstand auch Bauentfernung.

Prefab='' unterdrückt keine Constructor-/PostInit-/Netzwerk-/Tasknebenwirkungen. Zwei Rezepte mit gleichem Product können erneut spawnkosten verursachen, obwohl ein Cache vorhanden ist. Für neue Abstandsdaten statische bekannte Radien bevorzugen oder eng begrenzte echte Proben ausdrücklich serverseitig und mit Nebeneffektaudit behandeln. Kein universeller sicherer Client-Spawnaudit. Persistenz betrifft Rezeptdaten nicht als Entity-Save; Reload baut aus Modinitialisierung neu auf.


Konkrete zusätzliche Funktionsdefinitionen: [Vertragsbelege](../27_Vertragsbelege.md). Die [Reviewmatrix](../REVIEW_MATRIX.json) trennt Einstiegssichtung und ausgewählte vertiefte Abläufe; weitere Featureänderungen benötigen einen eigenen aktuellen Audit.
