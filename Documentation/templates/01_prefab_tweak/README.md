# Vorlage 01 – Bestehenden Speer konfigurieren

Dateien: [modinfo.lua](modinfo.lua), [modmain.lua](modmain.lua). Eigenständige Servermod ohne erforderlichen Clientdownload. Sie multipliziert den vorhandenen numerischen weapon-Schaden des Vanilla-Speers beim Erzeugen. Defaultfaktor: 1,25; weitere Optionen: 1 und 1,5.

## Einbau und Voraussetzungen

Den gesamten Ordner als neuen Ordner unter der Spielinstallation `mods` kopieren. Namen/Autor in modinfo anpassen, Servermod aktivieren und Option einstellen. Nicht einzelne Dateien in eine andere Mod einfügen, ohne deren vorhandene Hooks und Metadaten abzugleichen.

Geprüfte Verträge: [Prefab-Hook und Initialisierung](../../02_Ladeumgebungen_Hooks.md), [weapon und Gegenstände](../../06_Gegenstaende_Gebaeude_Container.md), [Audit](../../17_Vanilla_Audit.md). Der Prefab-PostInit folgt dem Konstruktor, sodass weapon vorhanden sein kann. Mastersim-Guard schützt den Zugriff auf serverseitige Components. Funktionsbasierter Schaden anderer Mods wird bewusst nicht multipliziert. Das Beispiel verändert keine Gesundheit und keine maximalen Verwendungen.

## Konkrete Prüfungen

1. Syntaxprüfung mit luac -p oder dem [Prüfwerkzeug](../../tools/verify_reference.py).
2. Frische Testwelt starten, Speer mit serverseitigem `c_give("spear")` erzeugen. Im Host/Remote-Kontext muss der ausgewählte Spieler feststehen; Dedicated hat keinen lokalen ThePlayer.
3. Speer über `c_select(inst)` auswählen und dann untersuchen: `print(c_sel().components.weapon.damage)`. c_select ohne Argument wählt die Entity unter der Maus, c_sel liest die bestehende Auswahl. Erwartung: Vanilla-Ausgangsschaden × eingestellter Faktor. Alternativ Treffer an einem geeigneten Testziel messen; Rüstung/Multiplikatoren des Ziels berücksichtigen.
4. Faktoren 1 und 1,5 jeweils nach Neustart mit neu erzeugtem Speer prüfen. PostInit ist kein laufender Konfigurationswatcher.
5. Speichern/Laden, separaten Client und Dedicated prüfen. Schaden wird aus Konstruktor/Hook rekonstruiert, nicht als eigenes Savefeld geschrieben.
6. Mit einer weiteren Speer-Schadensmod testen: Faktoren können sich durch Hookreihenfolge kombinieren. Verhalten dokumentieren.

**Status:** Syntaxprüfung wird im Abschlussbericht ausgewiesen; diese Laufzeitfälle wurden für die Sammlung nicht ausgeführt.


## Erneute statische Prüfung

Ladeumgebung, Registrierungen, Vanilla-Aufrufer, Rollen, Speicherung und Cleanup erneut geprüft. [Vorlagenmatrix](../../24_Statische_Vertragspruefung.md#zwölf-vorlagen-geprüfte-schnittstellen) benennt Sonderfälle und Grenzen. [Isolierte Tests](../../tests/README.md) gelten nur für die dort genannten Logikpfade, keine Laufzeitabnahme dieser Mod.
