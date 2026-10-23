# Vorlage 04 – Truhe einmalig markieren

Dateien: [modinfo](modinfo.lua), [modmain](modmain.lua), [doc_markable](scripts/components/doc_markable.lua). Alle Clients benötigen die Mod. Neue SCENE-Action `DOC_MARK_CHEST` bietet per Rechtsklick „Markieren“ an einer Vanilla-treasurechest. Eine Markierung setzt das replizierte Tag doc_marked, schreibt eine Logmeldung und wird gespeichert. Es wird keine sichtbare Grafik eingefärbt.

## Einbau und Voraussetzungen

Ordner als neue Mod installieren. Action-ID, Componentname und Tagpräfix bei produktiver Nutzung gemeinsam umbenennen. Die Component wird serverseitig an treasurechest angefügt; Component-Actionregistrierung und Action/SG-Handler laufen auf allen benötigten Peers.

Geprüfte Verträge: [Actions und SG](../../08_Actions_Stategraphs.md), [Persistenz](../../05_Persistenz.md) und [Audit](../../17_Vanilla_Audit.md). SCENE sammelt anhand verfügbarer Tags und der replizierten Component-Actionregistrierung; dazu ist keine eigene Component-Replica notwendig. Beide Spielerstategraphs verwenden doshortaction. Die serverseitige Action prüft erneut Player, Ghoststatus, Gesundheit, Target, Component und Distanz. Reichweite hier maximal vier Einheiten (quadrierte Distanz 16).

Das Markieren hat höhere Actionpriorität als gewöhnliche Truheninteraktionen. Nach Markierung verschwindet das Angebot und die normale Interaktion wird wieder gewählt. Für ein produktives Tool wären eigenes Inventarobjekt, Modifier oder passende Prioritätsregeln zusätzliche Designentscheidungen.

## Konkrete Prüfungen

1. Syntax prüfen; frische Testwelt mit Host und Remoteclient starten.
2. `c_spawn("treasurechest")` serverseitig. Rechtsklick in erreichbarer Nähe: Animation, Meldung und einmalige Markierung prüfen.
3. Nach Markierung soll die Action verschwinden; Truhe normal öffnen und Containerinhalt benutzen. Truhe mit c_select auswählen, danach Tag über `print(c_sel():HasTag("doc_marked"))` serverseitig prüfen.
4. Zweiter Spieler und Remoteclient müssen die Action ebenfalls anbieten/entfernen. Bei hoher Latenz keine doppelte Wirkung.
5. Ghost, entfernte/gelöschte Truhe, zu große Distanz und konkurrierende Bewegung prüfen. Fehlgeschlagene Action darf keine Markierung setzen.
6. Speichern/Laden sowie Reconnect: Markierung bleibt erhalten. Auf Dedicated und sowohl Forest als auch Caves testen. Truhe ist shardlokal; sie migriert nicht automatisch mit dem Spieler.
7. Mit anderer SCENE-/Truhenmod Prioritätskonflikte prüfen.

**Status:** Ingame-/Predictiontests offen. Syntaxstatus steht im Abschlussbericht.


## Erneute statische Prüfung

Ladeumgebung, Registrierungen, Vanilla-Aufrufer, Rollen, Speicherung und Cleanup erneut geprüft. [Vorlagenmatrix](../../24_Statische_Vertragspruefung.md#zwölf-vorlagen-geprüfte-schnittstellen) benennt Sonderfälle und Grenzen. [Isolierte Tests](../../tests/README.md) gelten nur für die dort genannten Logikpfade, keine Laufzeitabnahme dieser Mod.
