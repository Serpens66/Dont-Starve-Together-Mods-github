# FoodMemory Everyone

**Prüfart:** statische Ablaufanalyse; wesentlicher Ablauf beschrieben. Keine Ingame-Funktionszusage. Alle Verzeichnisse: `FoodMemory Everyone 2839957838`.

## Einstieg und Abhängigkeiten

PlayerPostInit fügt foodmemory bei aktivierter everyone-Option hinzu; Warly bekommt eigene Dauer/Multiplikatoren. Sprachtexte werden auf allen Instanzen eingerichtet.

## Initialisierung, Interaktion und Serverwirkung

Eater multipliziert Grunddeltas vor dem custom callback und merkt nach erfolgreichem Essen den normalisierten Namen. Foodmemory verwaltet Count/Task pro Gericht; Wiederholungen rearmen Ablauf. Gespeicherte count/t-Restwerte stellen Timer wieder her, nicht Wallclockofflinezeit. Kein eigener HUD/Replica nötig; Standardstats replizieren.

## Replikation, UI, Speicherung und Wiederherstellung

Speicher-/Clientvertrag ist im oben beschriebenen Ablauf eingeordnet. Keine zusätzliche Persistenz oder Replica annehmen, wenn der Code nur Vanilla-Werte/Tags ändert. Reconnect rekonstruiert die aktuelle Modinitialisierung; Konfigurationsänderungen wirken deshalb nach ihrem tatsächlichen Ladepunkt.

## Cleanup und Lebensdauer

Entityeigene Tasks und Listener werden beim Entfernen bereinigt; das ersetzt keine Prüfung bereits gestarteter, fremder oder global registrierter Callbackpfade. Entfernen eigener Modifier/Tags darf keine fremde Quelle löschen.

## Aktuelle Vanilla-Kette

[FoodMemory Everyone 2839957838/modmain.lua — SetDuration](<../../FoodMemory Everyone 2839957838/modmain.lua>) (Zeile 118); [components/foodmemory.lua — RememberFood](<../../../_scripts/scripts_02_10_2026/scripts/components/foodmemory.lua>) (Zeile 32) / [components/foodmemory.lua — OnRemoveFromEntity](<../../../_scripts/scripts_02_10_2026/scripts/components/foodmemory.lua>) (Zeile 10) / [components/eater.lua — GetFoodMultiplier](<../../../_scripts/scripts_02_10_2026/scripts/components/eater.lua>) (Zeile 237).

## Altlasten und konkrete Prüfgrenze

not inst.components ~= nil ist wegen Lua-Rangfolge ein boolean-gegen-nil-Vergleich und kein Komponenten-Existenztest. Der Serverhook braucht verständliche Nilguards. foodmemory koexistiert nicht automatisch mit exklusiver Food Queue.

## Szenarien für die spätere Laufzeitabnahme

Wiederholungen und gewürzte Basisgerichte, Wartezeit, Save/Load kurz vor Ablauf, Warly/Modcharakter, Food Queue kombiniert; Dedicated, Reconnect und Migration.

Alle Szenarien sind **offen**. Für Dedicated-Server, separaten Client, Reconnect und Shardwechsel gelten zusätzlich die [allgemeinen Checklisten](../19_Checklisten.md). Statische Symbol-/Hashprüfung ersetzt diese Abnahme nicht. [Katalog](../16_Workspace_Mods.md) · [Abdeckungsmatrix](../21_Abdeckungsmatrix.md) · [Projektworkflow](../20_Projektworkflow.md).


## Dateiregister: FoodMemory Everyone 2839957838

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [modinfo.lua](<../../FoodMemory Everyone 2839957838/modinfo.lua>)
- [modmain.lua](<../../FoodMemory Everyone 2839957838/modmain.lua>)


## Erneute Prüfung: Ablaufzeit statt Queue

Vanilla Foodmemory speichert pro normalisiertem Basefood einen Count und Forgettask. Wiederholung erhöht Count und verschiebt den Ablauf auf duration; OnSave hält tatsächliche verbleibende Taskzeit, OnLoad rearmt sie. Das ist eine zeitbasierte Erinnerung, nicht Food Queues positionaler Sechserbuffer. Spicedvarianten teilen den Basefoodcount. Eater fragt den alten Count vor RememberFood ab. RemoveComponent cancelt Forgettasks, ein fremder Callback kann dennoch auf erwartete foodmemory angewiesen sein.

Die historische Bedingung not inst.components~=nil ergibt einen boolean-gegen-nil-Vergleich und ist immer true; sie validiert die Componenttabelle nicht. Der konkrete Sprachfall ist im isolierten Test enthalten. Neue Population von Modcharakteren über erlaubte Liste/Option behandeln und vorhandene Foodmemorykonfiguration nicht versehentlich ersetzen. Laufzeit: wiederholtes Essen vor/nach Cooldown, Save kurz vor Ablauf, Food Queue aktiviert und Modcharaktere.


Konkrete zusätzliche Funktionsdefinitionen: [Vertragsbelege](../27_Vertragsbelege.md). Die [Reviewmatrix](../REVIEW_MATRIX.json) trennt Einstiegssichtung und ausgewählte vertiefte Abläufe; weitere Featureänderungen benötigen einen eigenen aktuellen Audit.
