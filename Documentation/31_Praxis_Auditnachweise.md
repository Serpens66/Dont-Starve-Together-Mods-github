# 31 — Auditnachweise der praktischen Ergänzung

03.10.2026. Archiv und Snapshot stimmen weiterhin für alle 4.044 Dateien überein. Änderungen dieser Revision betreffen ausschließlich Documentation. Es wurden keine Spielinstanzen gestartet. Der Bericht erweitert ausgewählte Featureketten; er behauptet keine vollständige Prüfung aller Funktionen in den aufgeführten Dateien.

## Definition, Aufrufer und Lebenszyklus

| Feature | Definition und Initialisierung | Aufrufer / Rückweg | Persistenz / Cleanup | Ergebnis |
|---|---|---|---|---|
| Kochregistrierung | modutil.AddCookerRecipe → cooking.AddCookerRecipe; ingredient registry und normalisierte Namen | containers Widgetbutton, RPC.DoWidgetButtonAction, ACTIONS.COOK.fn | Rezeptregistry je Kocher; eigener Prefab separat | [Kochanleitung](28_Kochinhalte.md), Vorlage 13 |
| Kochzustand | Stewer ctor, StartCooking, dostew/dospoil; cookpot callbacks | HARVEST → Harvest; SetProductSymbol, ShowProduct | OnSave/OnLoad/LongUpdate; Hammer, Entityremove | Produkt, Frische, Restzeit, Grafik und Chef vollständig im beschriebenen regulären Pfad verfolgt |
| Speise | preparedfoods.MakePreparedFood, edible, inventoryitem, stackable, perishable | Eater.Eat/PrefersToEat, Cookbook-Lernereignis und UIatlas | Component-OnSave/OnLoad; spoil replacement | Eigenes Prefab mit bestehenden Assets; keine automatisch erzeugten Modfoods |
| Passive Kreatur | rabbit ctor vollständig, RabbitBrain vollständig, SGrabbit vollständig | DoAction.Visit → locomotor.PushAction → SG → BufferedAction.Do | Wintertask/Watcher, Timerload, Traptransfer; Health death/Corpse; Entityremove | Passive ausgewählte Rabbit-Kette; keine universelle Bossarchitektur |
| Charakter | Wilson vollständig; MakePlayerCharacter Konstruktion/Common/Master/Capture | Erstspawn, Load, Death, Ghost, OnRespawnFromGhost → DoActualRez/CommonActualRez | player_common Save/PreLoad/Load/Despawn/Remove und Sessions | [Charakteranleitung](29_Kreaturen_Charaktere_Lebenszyklus.md), abgegrenztes Callbackfragment |
| Classified | player_common Erzeugung/Owner, player_classified Replicated-/Listenerpfad; Wagpunkclassified vollständig | Attach/Detach, hats Equip/Remove; container SetOpener als Vergleich | Nichtpersistenter Transport, eigener Serverprimärzustand; expliziter Rückbau | [Multiplayer-Lebenszyklen](30_Multiplayer_Lebenszyklen.md); keine native Privacygarantie |
| Prediction | Controller.DoAction/RemoteBufferedAction; locomotor Preview/Push; Entityscript Pufferfunktionen | Klickpreview-RPC → serverseitiger Controller; doshortaction beider SGs | Timeout, onexit, erneute BufferedActionvalidität | Wirkung nur autoritativ; Predicting/Nonpredicting-Pfade getrennt |
| Session/Migration | SerializeUserSession, ResumeExistingUserSession, RestoreSnapshotUserSession | playerspawner Despawn/Migrate → PlayerRemove; Ziel SpawnAtLocation | OnPreLoad → Components → Prefab; Ghost/Startitems; fehlgeschlagene Rückkehr | Lua-Fluss belegt, native Ausführung/Atomarität offen |

Die maschinenlesbaren Definitionsbelege im [Manifest](SOURCE_MANIFEST.json) enthalten tatsächliche aktive Definitionen samt Signatur, Zeile und Auszug. Die neuen Quellenhashes wurden nach Lesen der angegebenen Abläufe aufgenommen. Ein Quellenhash bescheinigt den Stand einer Datei; die fachliche Prüftiefe steht in dieser Tabelle und den jeweiligen Kapiteln.

## Erkannte und behobene Dokumentationslücken

- Workflow nannte eine fehlende Container-Vorlage, obwohl Vorlage 07 vorhanden ist; Navigation korrigiert.
- Kapitel 09 nannte den Sondermodus-Aufruf an Zeile 2715 als regulären master_postinit-Aufruf; tatsächlicher regulärer Aufruf ist 2937.
- Kochregistrierung versus Prefaberzeugung, Ersatzverhalten der Zutatenkategorien und nicht durchgehender Weightdefault jetzt ausdrücklich erklärt.
- Gewürzstation akzeptiert Modspeisen über preparedfood auch ohne passende Varianten; Vanilla-Fallback kann die Speise umwandeln. Vorlage 13 grenzt sie über den bestehenden gemeinsamen Itemfilter ab, ohne andere Items umzudeuten.
- Speisebild, Topfsymbol und Cookbookatlas sind getrennte Verträge; die Vorlage verwendet konkrete Vanilla-Overrides.
- Factory-Capture der Charactercallbacks, Entitysleep versus Spielfigurenschlaf und Player-Sessionreferenzen waren zu knapp erklärt.
- Classifiedtarget nil und Equip/Unequip-Verhalten werden an tatsächlichen Aufrufern erklärt, statt eine allgemeine Zielregel zu erfinden.

## Abnahmestufen

1. Vorhandenes Beispiel: eigener ausführbarer Lua-Pfad beziehungsweise eindeutig abgegrenztes Fragment.
2. Beschriebener Ablauf: Definition, Initialisierung, Aufrufer, Rollen, Speicherung/Wiederherstellung und Cleanup des benannten Pfads nachvollzogen.
3. Projektbezogener Audit: neue Fähigkeiten, Assets, Kocher, Charaktere, Privatdaten, Bosse und Sondermodi benötigen weitere konkrete Quellketten.
4. Offener Vertrag: native Transport-/Prediction-/Speicherinternals und sämtliche Spieltests.

Der aktualisierte [Prüfstatus](VALIDATION.md) zählt nur tatsächlich ausgeführte Prüfungen. Aus isolierten Stubs entstehen keine bestandenen Engineprüfungen.
