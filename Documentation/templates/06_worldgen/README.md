# Vorlage 06 – Relative Blumenhäufigkeit in BGForest

Dateien: [modinfo](modinfo.lua), [modmain](modmain.lua), [modworldgenmain](modworldgenmain.lua). Servermod ohne erforderlichen Clientcode; benötigt eine neu generierte Welt. Der Hook multipliziert das vorhandene flower-Gewicht im Room BGForest um 1, 2 oder 4 (Default 2).

## Einbau und Voraussetzungen

Ordner vollständig installieren und für den Server aktivieren. Neue Forest-Welt generieren. Bestehende Welten werden nicht umgebaut; Caves besitzen eine eigene Generierung und müssen gesondert untersucht werden.

Geprüfte Grundlage: [Weltgenerierung](../../10_Weltgenerierung.md) und [Audit](../../17_Vanilla_Audit.md). AddRoomPreInit wird auf die geladene Kopie eines vorhandenen Rooms angewendet. Die Vorlage prüft contents/distributeprefabs/flower, statt unbekannte Tabellen oder Rooms zu erfinden. Ein relatives Gewicht ist keine absolute Spawnchance; Gesamtverteilung und verfügbare Fläche spielen mit hinein. MODMAIN ist absichtlich ohne Runtimewirkung.

modworldgenmain wird auch in der Runtime-Ladeumgebung geladen. Der hier verwendete Hook ist dort verfügbar; er verändert erst die Verarbeitung entsprechender Roomdaten, nicht schon vorhandene Entities.

## Konkrete Prüfungen

1. Syntax prüfen. Mehrere Testwelten mit gleicher Seed-/Optionskombination je Faktor erzeugen und BGForest-Flächen vergleichen.
2. Room-Hook temporär mit Logmeldung instrumentieren, um tatsächlich betroffene Rooms nachzuweisen. Danach Debugausgabe entfernen.
3. Blumen und andere verteilte Prefabs zählen; keine exakte Verdopplung pro Welt erwarten. Mehrere Seeds verwenden, um lokale Zufallseffekte zu erkennen.
4. Bestehende Welt mit Mod starten: keine nachträgliche Blumenanlage. Speichern/Laden ändert den generierten Zustand nicht erneut.
5. Forest plus Caves auf Dedicated neu erzeugen; Logs getrennt prüfen. Mod soll fehlende/anders strukturierte Roomdaten ohne Fehler überspringen.
6. Mit anderer BGForest-Mod testen: Gewichtsmultiplikatoren können sich kombinieren; Overrides und andere Hooks können das Ergebnis verändern.

**Status:** Keine Weltgenerierung oder statistische Ingame-Prüfung ausgeführt; nur Syntax und dokumentierte Quellenstruktur geprüft.


## Erneute statische Prüfung

Ladeumgebung, Registrierungen, Vanilla-Aufrufer, Rollen, Speicherung und Cleanup erneut geprüft. [Vorlagenmatrix](../../24_Statische_Vertragspruefung.md#zwölf-vorlagen-geprüfte-schnittstellen) benennt Sonderfälle und Grenzen. [Isolierte Tests](../../tests/README.md) gelten nur für die dort genannten Logikpfade, keine Laufzeitabnahme dieser Mod.
