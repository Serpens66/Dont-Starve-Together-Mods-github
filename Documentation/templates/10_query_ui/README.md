# Clientabfrage mit Serverantwort

Eigenständiger Modordner: den gesamten Inhalt dieses Ordners einschließlich `scripts` in einen neuen lokalen Modordner kopieren; nicht nur modmain in eine andere Vorlage einfügen. Vanilla-Assets benötigen keine eigenen Exporte. Die Beispieldateien haben eindeutige Namen. Vor Integration Namen, Konfiguration, Ladeordnung und gleichzeitige andere Hooks prüfen.

## Dateien und Zuständigkeit

- `modinfo.lua`
- `modmain.lua`
- `scripts/components/doc_query.lua`
- `scripts/components/doc_query_replica.lua`

## Funktionsweise und Grenzen

Der Client übermittelt nur eine begrenzte ganzzahlige Sequenz. Position, Radius und Ergebnis bestimmt der Server; pro Spieler höchstens eine zugelassene Anfrage je Sekunde. Replica-Netstring enthält Sequenz und höchstens vierstellige Zahl. UI verwirft Antworten anderer Sequenzen. Keine beliebigen Entity-/GUID-Zugriffe und keine Remote-Änderung. Die Antwort ist öffentlich replizierbarer Zustand des Spielers, keine private Classified-Nachricht. Nur öffentliche Blumenanzahl verwenden; für vertrauliche Inventardaten owner-targeted Classified oder separat auditierter Client-RPC nötig. Kein Persistenzbedarf: Antwort/Rate-Limit sind flüchtig. Widgetlisteners gehören der Widget-Entity; ihr Entfernen bereinigt Events/Tasks. Controller-Navigation zu diesem hinzugefügten Button ist noch zu prüfen; es wird kein Focuspfad zugesichert.

## Quellenkette des statischen Audits

[networkclientrpc.lua — AddModRPCHandler](<../../../../_scripts/scripts_02_10_2026/scripts/networkclientrpc.lua>) (Zeile 1834) → [entityscript.lua — ReplicateComponent](<../../../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 599) → [widgets/controls.lua — self.owner = owner](<../../../../_scripts/scripts_02_10_2026/scripts/widgets/controls.lua>) (Zeile 57) → [widgets/imagebutton.lua — ImageButton](<../../../../_scripts/scripts_02_10_2026/scripts/widgets/imagebutton.lua>) (Zeile 4) / [widgets/button.lua — SetOnClick](<../../../../_scripts/scripts_02_10_2026/scripts/widgets/button.lua>) (Zeile 235) → [prefabs/flower.lua — AddTag("flower")](<../../../../_scripts/scripts_02_10_2026/scripts/prefabs/flower.lua>) (Zeile 152). Replica-Konstruktion verglichen mit [Food Queue 2843201996/scripts/components/_foodbuffer_replica.lua — net_string](<../../../Food Queue 2843201996/scripts/components/_foodbuffer_replica.lua>) (Zeile 6).

## Testprotokoll – offen, keine Spielinstanz gestartet

1. Host und separater Client zählen Blumen im Radius 8; Pflanzen aufnehmen/setzen, erneut fragen. Zweiter Spieler darf andere Antwort haben.
2. Dedicated: kein Widget geladen; gültige Anfrage beantwortet, nil/string/NaN/Bruch/0/65536 abgelehnt. Schnell wiederholte gültige Requests erzeugen höchstens eine Suche je Sekunde.
3. Bei Latenz zuerst bewegen und nochmals fragen: nur Antwort der aktuellen Sequenz anzeigen. Reconnect und Save/Load beginnen ohne alte UI-Antwort; erneut klicken.
4. Höhlenwechsel: neue Controls/Replica, Antwort aus aktuellem Shard. Controller-, HUD-Skalierungs- und UI-Fokusprüfung offen. Bei zurückgewiesener Anfrage bleibt Warteanzeige bis neuer Anfrage; kein Zustellungsversprechen.

Syntaxprüfung mit `luac5.1.exe -p` prüft weder Engine-Globals noch Assets, Prediction oder Multiplayer. Ergebnisse stehen im [Prüfbericht](../../VALIDATION.md). Für ein neues Projekt außerdem den [Workflow](../../20_Projektworkflow.md) und die [Checklisten](../../19_Checklisten.md) verwenden.


## Erneute statische Prüfung

Ladeumgebung, Registrierungen, Vanilla-Aufrufer, Rollen, Speicherung und Cleanup erneut geprüft. [Vorlagenmatrix](../../24_Statische_Vertragspruefung.md#zwölf-vorlagen-geprüfte-schnittstellen) benennt Sonderfälle und Grenzen. [Isolierte Tests](../../tests/README.md) gelten nur für die dort genannten Logikpfade, keine Laufzeitabnahme dieser Mod.
