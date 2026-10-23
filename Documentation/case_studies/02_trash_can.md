# Trash Can – Behälter und irreversible Inhaltsverarbeitung

**Prüfart:** statische Ablaufanalyse; wesentlicher Ablauf beschrieben. Keine Ingame-Funktionszusage. Alle Verzeichnisse: `Trash Can 1879090052`.

## Einstieg und Abhängigkeiten

[Trash Can 1879090052/modmain.lua — PrefabFiles](<../../Trash Can 1879090052/modmain.lua>) (Zeile 7) lädt das Gebäude, legt Rezept und Texte an und kopiert Containerparameter der treasurechest. Legacy AddRecipe ist vom aktuellen Mod-Hook noch unterstützt; neues Rezept mit AddRecipe2 und Filter registrieren.

## Initialisierung, Interaktion und Serverwirkung

Das Prefab erzeugt Netzwerkentity und Darstellung; serverseitig container, machine, workable und lootdropper. [Trash Can 1879090052/scripts/prefabs/trashcan.lua — OnActivate](<../../Trash Can 1879090052/scripts/prefabs/trashcan.lua>) (Zeile 77) schließt den Container und verarbeitet seine Slots: irreplaceable ausnehmen, Stackanzahl merken, Objekt aus Slot entfernen/vernichten, je Einheit Asche erzeugen und zurückgeben. Der Vorgang ist Serverwirkung; Clientbutton ist nur der Auslöser. TurnOn startet die Aktivierung und lässt die Maschine verzögert wieder ausschalten. Hammerpfad und Aktivierung sind unterschiedliche Interaktionen.

## Replikation, UI, Speicherung und Wiederherstellung

Containerklassifizierung überträgt Slotinhalte und Öffnungszustand. SaveRecords der Inhalte entstehen durch container, nicht durch einen besonderen Mülleimer-Speicher. Machine-/Animationszustand ist getrennt davon; ein Save mitten in verzögerter Verarbeitung benötigt einen konkreten Reentranztest. Das Rezeptbild und Prefab-Assets müssen jeweils aus ihrem tatsächlichen Assetpfad betrachtet werden.

## Cleanup und Lebensdauer

Abbau legt die verbliebenen Inhalte ab und entfernt die Entity. Der verzögerte Entitytask darf danach nicht weiter auf den entfernten Container zugreifen. Die Schleife verändert den Container während der Verarbeitung; neu eingefügte Asche und Stackmerging deshalb mit mehreren gefüllten Slots testen.

## Aktuelle Vanilla-Kette

[containers.lua — widgetsetup](<../../../_scripts/scripts_02_10_2026/scripts/containers.lua>) (Zeile 9) → [components/container.lua — RemoveItemBySlot](<../../../_scripts/scripts_02_10_2026/scripts/components/container.lua>) (Zeile 128) / [components/container.lua — GiveItem](<../../../_scripts/scripts_02_10_2026/scripts/components/container.lua>) (Zeile 447) / OnSave / OnLoad → [components/machine.lua — TurnOn](<../../../_scripts/scripts_02_10_2026/scripts/components/machine.lua>) (Zeile 59) → [components/workable.lua — WorkedBy](<../../../_scripts/scripts_02_10_2026/scripts/components/workable.lua>) (Zeile 75).

## Altlasten und konkrete Prüfgrenze

hitedCount ist eine Dateilokale und damit zwischen allen Instanzen geteilt; der Wert wird nicht als per-Entity Savezustand wiederhergestellt. Die modmain-lokale Assetliste enthält eine verdächtige Texturzeichenfolge, aber das Prefab deklariert seine eigenen Bildassets: daraus folgt kein pauschaler Nachweis, dass das Bild fehlt. Prefab-Namenspfade und historische Sound-/Machine-Parameter vor Portierung prüfen.

## Szenarien für die spätere Laufzeitabnahme

Zwei Mülleimer bauen und abwechselnd hämmern; getrennte Lebensdauer erwarten und aktuellen Zählerbefund nachvollziehen. Neun Slots: Asche, ein voller Stack, irreplaceable, unstackbarer Gegenstand und leere Slots. Zweiter Spieler öffnet während Aktivierung. Save/Load mit gefülltem Container; Dedicated und Höhlenbau. Saubere Grundstruktur: [Containergebäude](../templates/07_container_building/README.md).

Alle Szenarien sind **offen**. Für Dedicated-Server, separaten Client, Reconnect und Shardwechsel gelten zusätzlich die [allgemeinen Checklisten](../19_Checklisten.md). Statische Symbol-/Hashprüfung ersetzt diese Abnahme nicht. [Katalog](../16_Workspace_Mods.md) · [Abdeckungsmatrix](../21_Abdeckungsmatrix.md) · [Projektworkflow](../20_Projektworkflow.md).


## Dateiregister: Trash Can 1879090052

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [modinfo.lua](<../../Trash Can 1879090052/modinfo.lua>)
- [modmain.lua](<../../Trash Can 1879090052/modmain.lua>)
- [scripts/prefabs/trashcan.lua](<../../Trash Can 1879090052/scripts/prefabs/trashcan.lua>)


## Erneute Prüfung: mehrere Instanzen und Inhaltstransaktion

OnActivate iteriert Slots, entfernt nicht-irreplaceable Inhalte und erzeugt pro Stackeinheit Asche. GiveItem kann Inhalte nicht beliebig erweitern, wenn die Tasche voll ist; Containerfallback/Drop und eventuell bereits hineingegebene Asche gehören in Tests. Irreplaceable bleibt erhalten. OnTurnOn plant TurnOff nach einer Sekunde; gespeicherte Componentinhalte sind von kurzlebiger Machineanimation getrennt.

hitedCount ist eine Dateilokale für alle Truhen. Mehrere Instanzen können zusammen die fünfte Treffergrenze erreichen; der Zähler steigt weiter und wird nicht je Entity gespeichert. OnHit entfernt bei dieser Grenze die Entity und greift anschließend wieder auf container:Close zu. OnHammered besitzt daneben den regulären Workable-Finishdrop. Für eine neue Implementation genau einen Abbaupfad, Instanzzustand und eine wohldefinierte Reihenfolge Close → Inhalte/Loot → FX → Remove verwenden. Der vorhandene Prefab deklariert eigene Assets; die unexportierte modmain-Liste ist davon getrennt.


Konkrete zusätzliche Funktionsdefinitionen: [Vertragsbelege](../27_Vertragsbelege.md). Die [Reviewmatrix](../REVIEW_MATRIX.json) trennt Einstiegssichtung und ausgewählte vertiefte Abläufe; weitere Featureänderungen benötigen einen eigenen aktuellen Audit.
