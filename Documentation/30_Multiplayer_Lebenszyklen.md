# 30 — Classified, Prediction, Reconnect und Shardmigration

Für neue Projekte zusammen mit [Multiplayer](04_Multiplayer.md), [Persistenz](05_Persistenz.md), [Actions](08_Actions_Stategraphs.md) und [Auditbelegen](31_Praxis_Auditnachweise.md) lesen. Quellenstand: 03.10.2026, identischer Snapshot. Beschrieben werden Lua-Verträge; native Replikation, Timing und Speicheratomarität bleiben ungetestet.

## Öffentliche Daten und adressierte Classifieds

Ein CLASSIFIED-Tag verschlüsselt keine Daten und legt allein keinen Empfänger fest. Die Netzentity hat ihre eigenen Netvars und einen über Network:SetClassifiedTarget gewählten Zielvertrag. Kleine öffentliche Werte am gewöhnlichen Prefab und adressierte Hilfsentities sind unterschiedliche Designs. Vorlage 03 ist öffentlich; Vorlage 10 liefert ihre Antwort über eine öffentliche Replica. Dort ausschließlich öffentlich geeignete Daten verwenden. Ein privates Feature braucht zusätzlich eine vollständig geprüfte Ziel-/Besitzerzuordnung.

### Player-Classified: Erstellung bis Entfernung

[prefabs/player_common.lua](<../../_scripts/scripts_02_10_2026/scripts/prefabs/player_common.lua>): Der Master erzeugt nach Pristine player_classified, setzt den Parent auf den Spieler und registriert Gameplay-Listeners. OnSetOwner liest userid vom Networkobjekt und setzt ClassifiedTarget auf die Spielerinstanz. Der Zeitpunkt ist nicht beliebig: während der Konstruktion ist userid noch leer. Kein eigenes dauerhaftes Usermapping aus diesem frühen Wert ableiten.

[prefabs/player_classified.lua](<../../_scripts/scripts_02_10_2026/scripts/prefabs/player_classified.lua>): Der Konstruktor legt Netvars vor Pristine auf beiden Seiten an, plant RegisterNetListeners über DoStaticTaskInTime(0) nach initialer Deserialisierung und markiert die Serverentity persists=false. Clients bekommen OnEntityReplicated. Dort wird entity:GetParent gelesen, AttachClassified am Spieler aufgerufen und die relevanten Replicas/Clientcomponents angebunden. Playerwerte werden anschließend beispielsweise über health_replica gelesen, nicht über einen auf dem Client fehlenden autoritativen health-State.

player_common.AttachClassified merkt die Hilfsentity und registriert deren onremove. DetachClassified leert diese Verbindung. player_common.OnRemoveEntity entfernt auf dem Master die Hilfsentity; der Client trennt Parentreferenz und Callback. Die Hilfsentity ist abgeleiteter Transportzustand und wird beim Rekonstruieren neu erzeugt. Ein privater Primärwert gehört trotzdem in die serverseitig gespeicherte Component/Session, nicht ausschließlich in eine nicht persistente Netvarentity.

### Zweites Beispiel: adressiertes Equipment

[prefabs/wagpunkhat_classified.lua](<../../_scripts/scripts_02_10_2026/scripts/prefabs/wagpunkhat_classified.lua>) ist ein vollständiges kleines Beispiel: Netvars, Client-OnEntityReplicated, verzögerte Listenerregistrierung mit initialem OnSayDirty, Server-Say/Timeout und SetTarget. [prefabs/hats.lua](<../../_scripts/scripts_02_10_2026/scripts/prefabs/hats.lua>): wagpunk erzeugt/parentet die Hilfsentity; wagpunk_onequip setzt SetTarget(owner); wagpunk_onremoveentity entfernt beziehungsweise trennt sie. OnSayDirty prüft Parent und gültige Text-ID. Das Beispiel transportiert Darstellung, keinen persistenten Fortschritt.

Wichtiger Sonderfall: Der Konstruktor ruft SetTarget(nil) auf; SetTarget behandelt nil für den lokalen Listener als Ziel für alle. Das ist kein Muster für „private Daten an niemanden“. Beim Unequip wird die Sprache gestoppt, aber nicht in demselben Callback ein neuer Classifiedtarget gesetzt. Die tatsächlichen Vanilla-Entscheidungen nicht zu einer pauschalen Regel „Unequip setzt immer nil“ umdeuten.

[components/container_replica.lua](<../../_scripts/scripts_02_10_2026/scripts/components/container_replica.lua>) zeigt einen weiteren Zielwechsel: SetOpener verwendet opener oder die Containerinstanz, setzt Itemowner neu und attach/detach verwaltet Slots. Ein geschlossener Container liefert nicht automatisch allen Clients seinen kompletten Inhalt. Diese Sonderregeln nicht als ungeprüfte allgemeine Privacy-API übernehmen.

## Initialer Wert, Dirty-Event und Late Join

Dirty-Events sind Benachrichtigungen über Transportwerte, keine Ersatzspeicherung. Eine neue Anzeige muss auch ihren initialen Zustand nach Replikation lesen, ohne auf eine erst später eintretende Änderung zu warten. Wagpunk ruft OnSayDirty im verzögerten RegisterNetListeners ausdrücklich auf. Ein fehlender Parent oder noch nicht angehängte Replica ist ein Ladezustand, den Getter/UI behandeln müssen.

Für eigene Classifieds: gemeinsames Layout vor Pristine; nachvollziehbarer Serverbesitzer; Zielsetzung zu dessen gültigem Zeitpunkt; initiales Client-Refresh; definierter Attach/Detach; keine Restreferenzen nach Verlust der Netzsicht; Serverprimärdaten separat speichern. Die Nativefunktion selbst ist in scripts.zip nicht implementiert. Es wird hier keine garantierte Paketgröße, Deliveryzeit oder Zugriffssicherheit aus ihrem Namen abgeleitet.

## Prediction: wirkliche Actionkette

[components/playercontroller.lua](<../../_scripts/scripts_02_10_2026/scripts/components/playercontroller.lua>): Die Eingabepfade konstruieren BufferedActions und passende preview_cb/non_preview_cb zum tatsächlichen RPC. DoAction prüft aktuelle Entities und Busy-Zustand, vermeidet Duplikate und behandelt drei Wege: Master→locomotor:PushAction; Client ohne Locomotor→non_preview_cb; Client mit Prediction→locomotor:PreviewAction. Ein nur im Host geprüftes Feature kann daher einen der Clientwege vollständig verpassen.

[components/locomotor.lua](<../../_scripts/scripts_02_10_2026/scripts/components/locomotor.lua>) führt beziehungsweise previewt den Weg zum Ziel. [entityscript.lua](<../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>): PerformPreviewBufferedAction ruft RemoteBufferedAction auf und markiert ispreviewing; es ruft hier nicht action.fn auf. RemoteBufferedAction löst bei enabled Classified die passende preview_cb aus. [networkclientrpc.lua](<../../_scripts/scripts_02_10_2026/scripts/networkclientrpc.lua>): LeftClick/RightClick kontrollieren Typen, Plattformbezug und Koordinatenreichweite und delegieren an den authentifizierten Spielercontroller.

[SGwilson_client](<../../_scripts/scripts_02_10_2026/scripts/stategraphs/SGwilson_client.lua>): doshortaction startet die Vorschau, erwartet server_states, gleicht Serverzustand ab oder räumt nach Timeout auf. [SGwilson](<../../_scripts/scripts_02_10_2026/scripts/stategraphs/SGwilson.lua>): Die tatsächliche kurze Action erfolgt in der Timeline nach sechs Frames durch PerformBufferedAction. BufferedAction:Do validiert erneut, führt action.fn aus und meldet Success/Fail.

Neue Gameplaywirkungen gehören an den autoritativen Ausführungspunkt. Keine Itemvergabe/Durabilityänderung zusätzlich in Clientpreview, OnClick und Action.fn. Die allgemeine RPCprüfung ersetzt nicht Besitz-, Component-, Entfernungs- und Zustandsvalidierung in der eigenen Action. Ein fremder Modcallback kann die Entity zwischen Auswahl und Wirkung verändern.

Für gewöhnliche Interaktionen [Vorlage 04](templates/04_action/README.md) verwenden und den passenden Vanilla-State wählen. Neue lange Zustände benötigen Abbruch, onexit, Client-Server-Zuordnung und tatsächliche Animation. Native Prediction-/Korrekturtiming wird nicht als statisch bewiesen ausgegeben.

## Sessionzustand und Reconnect

[networking.lua](<../../_scripts/scripts_02_10_2026/scripts/networking.lua>): SerializeUserSession holt GetSaveRecord, serialisiert Daten und übergibt userid, Daten, Newspawnflag, Classifiedentity und Metadaten an TheNet. Der Lua-Code ignoriert die zusätzlichen Save-Referenzen ausdrücklich. Ein normaler GUID-/newents-Vertrag einer Worldentity ist damit nicht automatisch für Player-Sessions gültig.

[mainfunctions.lua](<../../_scripts/scripts_02_10_2026/scripts/mainfunctions.lua>): ResumeExistingUserSession erhält die vom nativen Pfad bereits erzeugte Spielerentity, ruft SetPersistData, aktiviert LoadingProtection, löst gespeicherte Position/Plattform auf und übergibt an SpawnAtLocation(..., true). RestoreSnapshotUserSession ist ein eigener Restorepfad mit SpawnPrefab und Snapshotmarkierung. Keine Gleichsetzung aller Loadpfade.

[entityscript.lua](<../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>): OnPreLoad vor Component-OnLoad, danach Prefab-OnLoad. Components werden über pairs geladen; keine feste Reihenfolge zwischen zwei Componentnamen voraussetzen. PostPass ist separat. player_common rekonstruiert Ghost-/Schlafdaten und verhindert erneute Startitemvergabe. Ein eigener Primary-State muss früh als Component vorhanden sein und während Load geprüft übernommen werden. Netvars, Listener und UI aus diesem Zustand neu aufbauen.

## Shardwechsel und Fehlerpfad

[components/playerspawner.lua](<../../_scripts/scripts_02_10_2026/scripts/components/playerspawner.lua>): ms_playerdespawnandmigrate führt über OnPlayerDespawnAndMigrate zu Deaktivierung/FX/Tween und verzögertem PlayerRemove. PlayerRemove ruft OnDespawn(migrationdata), legt Ursprungsshardsitzung/Portal/Zielkoordinaten in player.migration ab, serialisiert, entfernt die alte Entity und ruft TheShard:StartMigration(userid, Zielshard) auf.

player_common.OnDespawn beendet aktive Nutzungssysteme, löst Schlaf-/Reittier-/Bundle-/Constructionzustand auf, behandelt Inventar gemäß Modus, meldet player_despawn, trennt Follower und stoppt Bewegung. Nicht die ganze Routine ersetzen, um einen eigenen Modwert zu übertragen. Eigene OnDespawn-Erweiterung darf ihre gespeicherten Primärdaten nicht vor dem folgenden SerializeUserSession versehentlich löschen.

Am Ziel übernimmt OnPreLoad migration vor Componentload. playerspawner.SpawnAtLocation löst anhand der gespeicherten Ursprungsshardskennung den Portal-/Petpfad auf. Ist die Entity nach fehlgeschlagener Migration wieder im Ursprungsshardskontext, wird dieser Relokationszweig übersprungen. migration/migrationpets werden danach geleert. Globale Tabellen, alte GUIDs, Worldcomponents und existierende FXinstanzen reisen dadurch nicht mit.

Eigene Playerwerte in einer versionierten Component, shardlokale Weltwerte in einer Worldcomponent, shardübergreifende Daten über ein eigens geprüftes Synchronisationsprotokoll halten. Teleportato/Adventure-Reset ist ein weiterer Vertrag und bleibt in seinen [Fallstudien](case_studies/11_teleportato.md) abgegrenzt. TheNet-/TheShard-Speicheratomarität, Netzwerkfehlerreihenfolge und native Sessionerstellung sind hier nicht intern sichtbar.

## Konkrete nicht durchgeführte Spieltests

| Mechanismus | Erwarteter Nachweis |
|---|---|
| Classified/Privacy | Besitzer und zweiter Client; Zielwechsel, Late Join, Verlust/Wiederkehr der Netzsicht; fremder Client erhält keine privaten Werte |
| Initiale UI | Bereits gesetzter Serverwert erscheint nach Reconnect ohne neue Zustandsänderung |
| Actionprediction | Host, separater Client mit Prediction an/aus, Dedicated; Busy/Abbruch/entferntes Ziel; Effekt genau einmal |
| Speicherzustand | Neuer Spieler versus vorhandene Session; eigener Wert und Ghostzustand; keine Itemduplikate |
| Shardwechsel | Hin-/Rückweg, Ghost, Inventar, Pet, am Ziel fehlende Component/Mod; keine alten GUIDannahmen |
| Migrationsfehler | Abbruch/Disconnect/Zielausfall, Reconnect auf Ursprung; Zustand und Cleanup nachvollziehen |

Diese Tabelle beschreibt Abnahmefälle, keine bestandenen Engine- oder Multiplayerprüfungen.
