# Random DayDuskNight Events

**Prüfart:** statische Ablaufanalyse; wesentlicher Ablauf beschrieben. Keine Ingame-Funktionszusage. Alle Verzeichnisse: `Random DayDuskNight Events 2842755452`.

## Einstieg und Abhängigkeiten

Clockhook liest GetMoonPhase/MOON_PHASE_NAMES per Upvalue; Worldhook auf Forest/Master registriert cycleschanged und rememberstuff.

## Initialisierung, Interaktion und Serverwirkung

Gewichtete Wahl bestimmt reine day/dusk/night-Segmente oder nothing; ms_setclocksegs übermittelt die 16-Segmentverteilung. Weitere Wahl setzt Lunacy über sanityquellenbezogenen Modus. rememberstuff hält Auswahl zur Wiederherstellung; neue Spieler bekommen den aktuellen Effekt. Die Wahl darf beim Laden nicht unabsichtlich erneut gerollt werden.

## Replikation, UI, Speicherung und Wiederherstellung

Speicher-/Clientvertrag ist im oben beschriebenen Ablauf eingeordnet. Keine zusätzliche Persistenz oder Replica annehmen, wenn der Code nur Vanilla-Werte/Tags ändert. Reconnect rekonstruiert die aktuelle Modinitialisierung; Konfigurationsänderungen wirken deshalb nach ihrem tatsächlichen Ladepunkt.

## Cleanup und Lebensdauer

Entityeigene Tasks und Listener werden beim Entfernen bereinigt; das ersetzt keine Prüfung bereits gestarteter, fremder oder global registrierter Callbackpfade. Entfernen eigener Modifier/Tags darf keine fremde Quelle löschen.

## Aktuelle Vanilla-Kette

[Random DayDuskNight Events 2842755452/modmain.lua — ms_setclocksegs](<../../Random DayDuskNight Events 2842755452/modmain.lua>) (Zeile 39); [Random DayDuskNight Events 2842755452/scripts/components/rememberstuff.lua — OnSave](<../../Random DayDuskNight Events 2842755452/scripts/components/rememberstuff.lua>) (Zeile 17); [components/clock.lua — ms_setclocksegs](<../../../_scripts/scripts_02_10_2026/scripts/components/clock.lua>) (Zeile 296) / [components/sanity.lua — EnableLunacy](<../../../_scripts/scripts_02_10_2026/scripts/components/sanity.lua>) (Zeile 184).

## Altlasten und konkrete Prüfgrenze

Upvalue-Namen sind interne Implementierung. Tagesabschnitte werden auch von Seasons aktualisiert; Eventreihenfolge prüfen. Das Caveverhalten ist nicht dieselbe zufällige Wahl wie Forest; Shardsynchronisierung konkret testen. chance-Gewichte dürfen nicht alle null sein.

## Szenarien für die spätere Laufzeitabnahme

Auswahl deterministisch über Extremconfig erzwingen, Cyclewechsel/Seasonwechsel, Sleep/Fast-forward, Save/Load, Join/Respawn, Forest/Cave. Native Clockreplikation beobachten.

Alle Szenarien sind **offen**. Für Dedicated-Server, separaten Client, Reconnect und Shardwechsel gelten zusätzlich die [allgemeinen Checklisten](../19_Checklisten.md). Statische Symbol-/Hashprüfung ersetzt diese Abnahme nicht. [Katalog](../16_Workspace_Mods.md) · [Abdeckungsmatrix](../21_Abdeckungsmatrix.md) · [Projektworkflow](../20_Projektworkflow.md).


## Dateiregister: Random DayDuskNight Events 2842755452

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [modinfo.lua](<../../Random DayDuskNight Events 2842755452/modinfo.lua>)
- [modmain.lua](<../../Random DayDuskNight Events 2842755452/modmain.lua>)
- [scripts/components/rememberstuff.lua](<../../Random DayDuskNight Events 2842755452/scripts/components/rememberstuff.lua>)
- [scripts/upvaluehacker.lua](<../../Random DayDuskNight Events 2842755452/scripts/upvaluehacker.lua>)


## Erneute Prüfung: einmalige Auswahl und Shards

rememberstuff.stuff1 hält Segmente bzw. lunacy_should_be_enabled je relevanter Mondphase. nil bedeutet noch keine Entscheidung, false kann die bereits getroffene „nichts/off“-Wahl sein. Beim Verlassen der Phase wird die Entscheidung gelöscht; Wiederkehr würfelt neu. Playerspawn wendet gespeicherte Lunacy auf den Spieler an, Cavepfad entfernt den eigenen Sourcebeitrag. Das ist kein jeden Frame neu gewürfelter Tag.

Current clock aktualisiert Clienttime innerhalb von Segmenten selbst, wartet aber an Grenzen auf Masterupdates; Secondaryshards übernehmen secondary_clockupdate. Seasons beeinflusst Tagessegmente ebenfalls. Upvalue-GetMoonPhase/MOON_PHASE_NAMES gehört zur internen Clockimplementierung, nicht zur stabilen öffentlichen ModAPI. Rememberstuff löst nur direkt gespeicherte Entitywerte in PostPass; fehlt ein GUIDziel, ist ein verbliebener Marker keine Entity. Eigene Saves Marker entfernen oder fehlenden Zustand ausdrücklich behandeln. Tests: Phasenwechsel, Load mit false, Spielerbeitritt, Surface/Cave und Konflikt mit saisonaler Segmentänderung.


Konkrete zusätzliche Funktionsdefinitionen: [Vertragsbelege](../27_Vertragsbelege.md). Die [Reviewmatrix](../REVIEW_MATRIX.json) trennt Einstiegssichtung und ausgewählte vertiefte Abläufe; weitere Featureänderungen benötigen einen eigenen aktuellen Audit.
