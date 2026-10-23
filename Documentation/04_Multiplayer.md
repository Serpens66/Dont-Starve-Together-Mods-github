# 04 — Multiplayer, Netvars, RPCs und Shards

## Zuständigkeit der Instanzen

`TheWorld.ismastersim` bezeichnet die autoritative Simulation des jeweiligen Shards. `TheWorld.ismastershard` bezeichnet den Haupt-Shard. Auch die Höhlen besitzen eine MasterSim. Ein Listen-Host vereint Serverlogik und lokale Darstellung; ein Dedicated Server hat keine normale Spieler-HUD. Ein entfernter Client besitzt meist keine serverseitigen Gameplay-Components.

`ThePlayer` ist der lokale Spieler und kann bei Initialisierung fehlen. Ein Server-RPC verwendet den vom Aufruf gelieferten Spieler. Ein HUD-Callback darf nicht sämtliche fremden Spielerinstanzen wie den lokalen Spieler behandeln.

Belege: [prefabs/player_common.lua — if not TheWorld.ismastersim](<../../_scripts/scripts_02_10_2026/scripts/prefabs/player_common.lua>) (Zeile 967), [networkclientrpc.lua — function HandleModRPC](<../../_scripts/scripts_02_10_2026/scripts/networkclientrpc.lua>) (Zeile 1896), [shardnetworking.lua — TheShard:GetShardId()](<../../_scripts/scripts_02_10_2026/scripts/shardnetworking.lua>) (Zeile 17).

## Zustandsfluss

    Client-Eingabe -> Action oder RPC -> Serverprüfung
        -> Component-Zustand -> Netvar -> Replica/Dirty-Event -> Darstellung

Netvars übertragen Serverzustand; RPCs übertragen Anfragen oder Nachrichten. Ein Client-`set_local` ist keine autoritative Serveränderung. Speicherung ist separat: Netvars überleben nicht automatisch Neustarts.

## Netzwerkvariablen

| Typ | Wertebereich beziehungsweise Zweck laut netvars.lua |
|---|---|
| net_bool | Wahrheitswert |
| net_tinybyte | 0–7 |
| net_smallbyte | 0–63 |
| net_byte | 0–255 |
| net_ushortint | 0–65.535 |
| net_shortint | dokumentiert: −32.767–32.767 |
| net_int / net_uint | dokumentierte 32-Bit-Zahlenbereiche |
| net_float | Fließkomma |
| net_string | String; häufige Änderungen kosten Bandbreite |
| net_hash | Hash; Lesen liefert nicht den ursprünglichen String |
| net_entity | Entity-Referenz, deren Sichtbarkeit geprüft werden muss |
| net_event | Einmalige Meldung, kein dauerhafter Zustand |
| net_*array | Begrenzte Arrays; Vanilla warnt vor Kosten |

Beide Seiten deklarieren Variablen identisch an derselben Entity. Die API erhält GUID, Feldname und optional einen Dirty-Event-Namen:

    inst._doc_count = net_ushortint(inst.GUID, "doc_counter.count", "doc_counter_dirty")

`:set(value)` schreibt serverseitig mit Synchronisierung. `:value()` liest den Stand. `:set_local(value)` schreibt ohne normale Synchronisierung und Dirty-Meldung und beeinflusst die nächste Dirty-Erkennung. Es eignet sich für bewusst entworfene Prediction-Pfade, nicht zum gewöhnlichen Client-Schreiben.

Die Definitionen des eigenen Netzwerk-Prefabs stehen vor `SetPristine()`. Nicht nur in einer Server-Component Netvars konstruieren, die auf Clients fehlen. Der konkrete Replikationspfad vorhandener Replicas ist separat zu prüfen: Vanilla konstruiert deren eigene Netvars teilweise während der Component-Replikation.

Dirty-Events setzen eine ausgelöste Änderung voraus. Getter müssen auch vor dem ersten Event einen gültigen Anfangswert liefern. Ein Listener liest aktuellen Zustand; er darf nicht erwarten, dass jede Zwischenänderung einzeln ankommt.

Belege: [netvars.lua: dokumentierter nativer Netvarvertrag](<../../_scripts/scripts_02_10_2026/scripts/netvars.lua>) (Zeile 29), [netvars.lua: Kommentar zur nativen set-Methode](<../../_scripts/scripts_02_10_2026/scripts/netvars.lua>) (Zeile 44), [netvars.lua — net_event = Class](<../../_scripts/scripts_02_10_2026/scripts/netvars.lua>) (Zeile 85). Die internen C++-Implementierungen der Netvar-Typen wurden nicht unabhängig geprüft.

## Replica und Classified

Die Replica ist eine Schnittstelle. `health_replica` liest beispielsweise `player_classified`. Container verwenden `container_classified`; beim Öffnen wird das Replikationsziel angepasst. Ein Client kennt dadurch nicht automatisch sämtliche Inhalte geschlossener Truhen.

Kleine öffentliche Daten können an einem eigenen Prefab liegen. Private Daten benötigen eine geprüfte Zielzuordnung. Die [Zählervorlage](templates/03_network_component/README.md) repliziert einen öffentlichen Gegenstandszähler und keine privaten Spielerdaten.

Belege: [components/health_replica.lua — function Health:AttachClassified](<../../_scripts/scripts_02_10_2026/scripts/components/health_replica.lua>) (Zeile 27), [components/container_replica.lua — SetClassifiedTarget](<../../_scripts/scripts_02_10_2026/scripts/components/container_replica.lua>) (Zeile 25), [Food Queue 2843201996/scripts/components/_foodbuffer_replica.lua — net_string](<../Food Queue 2843201996/scripts/components/_foodbuffer_replica.lua>) (Zeile 6).

## Mod-RPCs

Gemeinsame Registrierung und anschließender Client-Versand:

    AddModRPCHandler(modname, "RequestExample", function(player, target)
        -- Spieler, Ziel und Berechtigung prüfen, dann Serveroperation.
    end)
    -- Nur auf der sendenden Seite aufrufen:
    SendModRPCToServer(GetModRPC(modname, "RequestExample"), target)

Namespace, Name und Registrierungsreihenfolge müssen auf den beteiligten Instanzen übereinstimmen. IDs entstehen aus der Reihenfolge. Keine abweichende Registrierung durch lokale Einstellungen oder frühe Server-Returns. `GetModRPC` ist der aktuelle Zugriff; `MOD_RPC` bleibt als Legacy-Oberfläche erhalten.

Server-Handler erhalten normalerweise den sendenden Spieler vor den Nutzdaten. Client-Handler erhalten Nutzdaten; Shard-Handler die Sender-Shardkennung vor den Nutzdaten. User-ID-RPC-Markierungen sind ein gesonderter, in den Vorlagen nicht verwendeter Pfad.

Eine Serverprüfung muss zum Feature passen: gültiger Spieler, richtiger Modus, Ziel gültig, Entfernung, Besitz/Inventar, Ghost-/Todesstatus, erforderliche Components und angemessene Rate. Engine-Ratelimits ersetzen keine fachlichen Prüfungen.

`SendModRPCToClient(id_table, ...)` und `SendModRPCToShard(id_table, ...)` reichen Transportargumente an native TheNet-Methoden weiter. Ziel-User-ID beziehungsweise Shard-Ziel und Payload stehen im variadischen Teil. Diese Verpackung nicht mit den Handler-Argumenten verwechseln. Neue komplexe Payloads anhand aktueller Aufrufer und im Spiel prüfen.

Belege: [networkclientrpc.lua — function AddModRPCHandler](<../../_scripts/scripts_02_10_2026/scripts/networkclientrpc.lua>) (Zeile 1834), [networkclientrpc.lua — function SendModRPCToClient](<../../_scripts/scripts_02_10_2026/scripts/networkclientrpc.lua>) (Zeile 1886), [networkclientrpc.lua — function HandleShardModRPC](<../../_scripts/scripts_02_10_2026/scripts/networkclientrpc.lua>) (Zeile 1943), [modutil.lua: historischer RPC-Hinweis](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 902), [FinderMod 786654500/modmain.lua — SendModRPCToServer(rpc](<../FinderMod 786654500/modmain.lua>) (Zeile 160).

## Prediction und Shards

Der Client startet sichtbare Actions über `PerformPreviewBufferedAction`; der Server führt deren Wirkung über `PerformBufferedAction` aus. Eine Gameplay-Wirkung darf nicht unabhängig auf beiden Seiten entstehen.

Beim Shard-Wechsel wird die Spielerinstanz serialisiert und entfernt; der Ziel-Shard erzeugt eine neue Instanz. Globale Tabellen und alte Entity-Referenzen wandern nicht automatisch mit. Spielerzustand, World-Zustand und shardübergreifender Zustand deshalb getrennt modellieren.

Belege: [stategraphs/SGwilson_client.lua — name = "doshortaction"](<../../_scripts/scripts_02_10_2026/scripts/stategraphs/SGwilson_client.lua>) (Zeile 3087), [stategraphs/SGwilson.lua — name = "doshortaction"](<../../_scripts/scripts_02_10_2026/scripts/stategraphs/SGwilson.lua>) (Zeile 7906), [components/playerspawner.lua — SerializeUserSession(player)](<../../_scripts/scripts_02_10_2026/scripts/components/playerspawner.lua>) (Zeile 95).


## Vertiefung mit Workspace-Beispielen

Die dazugehörigen konkreten Abläufe, Daten-/Cleanupentscheidungen und Altlasten sind im [Praxismechanismen-Kapitel](23_Praxismechanismen.md) erklärt. Über die [Abdeckungsmatrix](21_Abdeckungsmatrix.md) zu passenden Fallstudien und eigenständigen Vorlagen navigieren; Grenzen komplexer Systeme stehen ausdrücklich dort.

## Vertiefte Lebenszyklen

[Kapitel 30](30_Multiplayer_Lebenszyklen.md) verfolgt Player- und Equipment-Classifieds von Erstellung über Owner/Attach/initiale Werte bis Detach/Remove sowie Prediction, Nonprediction, Reconnect und Shardmigration. Vorlage 10 repliziert ihre Antwort öffentlich; für private Daten ist der zusätzliche Zielvertrag erforderlich.
