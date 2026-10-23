# Vorlage 03 – Persistente Component, Replica und RPC

Dateien: [modinfo](modinfo.lua), [modmain](modmain.lua), [Prefab](scripts/prefabs/doc_counter_token.lua), [Component](scripts/components/doc_counter.lua), [Replica](scripts/components/doc_counter_replica.lua). Alle Clients benötigen die Mod.

`doc_counter_token` sieht wie ein Speer aus, ist aber ein einfacher Inventargegenstand ohne Waffe/Ausrüstung. Er hat einen gespeicherten öffentlichen Zähler von 0 bis 65.535. Der Server verwaltet den Wert; `net_ushortint` transportiert ihn, die Replica bietet GetCount, und ein Dirty-Event schreibt eine Meldung ins jeweilige Log. Kein eigener HUD und kein Rezept.

## Einbau und Verträge

Ordner vollständig als neue Mod installieren. Prefab-/Component-/RPC-Namen überall gemeinsam umbenennen. Netvar-Deklaration bleibt vor SetPristine auf beiden Peers; Registrierung von AddReplicableComponent/AddModRPCHandler bleibt symmetrisch.

Siehe [Multiplayer](../../04_Multiplayer.md), [Speichern](../../05_Persistenz.md) und [Audit](../../17_Vanilla_Audit.md). Die Replica liest das vom Prefab angelegte Netzfeld und kopiert keine Component-Tabelle. OnLoad setzt den Serverwert erneut, wodurch das Netzfeld mit aktualisiert wird. Schema v1/nil wird geladen; unbekannte spätere Schema-Versionen werden nicht interpretiert. Cooldown ist absichtlich transient.

Der RPC prüft echte Entity-Identität über Ents, Prefabname, Eigentum über GetGrandOwner, Playerzustand und einen Cooldown pro Token von einer Sekunde. Er akzeptiert keine frei gewählte Zahl. Der Zähler ist öffentlich für Peers im entsprechenden Replikationsbereich; für geheime Daten wäre ein anders ausgerichtetes Classified nötig.

## Konkrete Prüfungen

1. Syntax prüfen und Host mit separatem Client starten. Token im geeigneten Serverkontext mit `c_give("doc_counter_token")` erzeugen.
2. Token als aktiven Inventargegenstand am Mauszeiger halten. In der **lokalen Clientkonsole**:

```lua
SendModRPCToServer(GetModRPC("doc_counter_demo", "Increment"), ThePlayer.replica.inventory:GetActiveItem())
print(ThePlayer.replica.inventory:GetActiveItem().replica.doc_counter:GetCount())
```

3. Zuerst Netzübertragung abwarten; Getter nicht direkt nach Send als synchron aktualisiert betrachten. Erwartung: Erhöhung um eins und Dirty-Meldung. Nach mindestens einer Sekunde erneut senden.
4. Schnell mehrfach senden: akzeptierte Erhöhungen werden durch Cooldown begrenzt. Nil, String, anderen Prefab und Gegenstand eines anderen Spielers senden: keine Wirkung und kein Handlerfehler. Token wieder zurückgeben.
5. Speichern und laden: Wert erhalten; Schema/OnLoad bei alten Daten separat prüfen. Spät beitretender Client muss den aktuellen Wert lesen können, auch ohne historisches Dirty-Event.
6. Gegenstand werfen, in Container legen, aufnehmen, zum anderen Spieler geben; GetGrandOwner muss zur serverseitigen Entscheidung passen. Containerzugriff allein berechtigt nicht zum fremden Eigentum.
7. Dedicated und Höhlenmigration mit Token im Inventar prüfen. Grenzwert 65.535 über serverseitige Component setzen und weiter inkrementieren: bleibt begrenzt.

Die Console-Erzeugung auf Dedicated erfordert eine explizite Spielerreferenz; es gibt dort keinen lokalen HUD/ThePlayer. Tests mit manipulierter RPC-Eingabe nur in eigener Testwelt durchführen.

**Status:** Kein laufender Netz-/Save-/Shard-Test durchgeführt. Die Vorlage ist ein nachvollziehbares Minimalbeispiel, keine abgenommene Produktmod.


## Erneute statische Prüfung

Ladeumgebung, Registrierungen, Vanilla-Aufrufer, Rollen, Speicherung und Cleanup erneut geprüft. [Vorlagenmatrix](../../24_Statische_Vertragspruefung.md#zwölf-vorlagen-geprüfte-schnittstellen) benennt Sonderfälle und Grenzen. [Isolierte Tests](../../tests/README.md) gelten nur für die dort genannten Logikpfade, keine Laufzeitabnahme dieser Mod.
