# Vorlage 05 – Einfache Client-HUD-Erweiterung

Dateien: [modinfo](modinfo.lua), [modmain](modmain.lua). Reine Clientmod. Ergänzt bei widgets/controls ein Textwidget unter topleft_root: „Mod-Beispiel aktiv“, Größe 24 und Position (180, -70).

## Einbau und Voraussetzungen

Vollständigen Ordner als neue Mod installieren und unter Clientmods aktivieren. Kein Serverdownload nötig. Geprüfte Grundlage: [UI und Eingabe](../../11_UI_Eingabe_Localisierung.md), `widgets/controls.lua` und `widgets/text.lua` im [Audit](../../17_Vanilla_Audit.md).

AddClassPostConstruct läuft nach dem Controls-Konstruktor, sodass die Root verfügbar ist. TheNet:IsDedicated verhindert HUD-Arbeit ohne Bildschirm. SetClickable(false) hält den Hinweis aus der Mausinteraktion heraus; ein Instanzfeld vermeidet doppelte Anlage an derselben Controls-Instanz. Das Widget gehört zum Controlsbaum und benötigt hier weder globalen Inputhandler noch eigene periodische Task.

## Konkrete Prüfungen

1. Syntax prüfen; Client mit Mod verbinden, Dedicated ohne Clientmod starten.
2. HUD zeigt einen einzigen Hinweis. Verschiedene Auflösungen/UI-Skalierungen und Controller prüfen; Text darf wichtige HUD-Inhalte nicht verdecken.
3. Disconnect/Reconnect, Charakterwechsel und Tod/Wiederbelebung: neue Controlsinstanz korrekt, kein alter Text oder doppelte Meldung.
4. Pause, Menüs und HUD-Ausblendung testen. Verhalten folgt dem Parentwidget; eigener Fokus darf nicht hängen bleiben.
5. Zweiter Client ohne Mod sieht keinen Hinweis und kann normal spielen.

Für Eingabe, Buttons oder einen aktualisierten Wert die Cleanup-/Fokusverträge zusätzlich auditieren. Diese Vorlage zeigt ausschließlich statischen Text.

**Status:** Darstellung und Controller im Spiel ungeprüft; Syntaxprüfung separat ausgewiesen.


## Erneute statische Prüfung

Ladeumgebung, Registrierungen, Vanilla-Aufrufer, Rollen, Speicherung und Cleanup erneut geprüft. [Vorlagenmatrix](../../24_Statische_Vertragspruefung.md#zwölf-vorlagen-geprüfte-schnittstellen) benennt Sonderfälle und Grenzen. [Isolierte Tests](../../tests/README.md) gelten nur für die dort genannten Logikpfade, keine Laufzeitabnahme dieser Mod.
