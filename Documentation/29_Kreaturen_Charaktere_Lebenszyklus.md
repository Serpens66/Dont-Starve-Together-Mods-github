# 29 — Kreaturen und Charaktere praktisch entwerfen

Stand 03.10.2026; [Basis](09_Brains_Charaktere.md), [Actions](08_Actions_Stategraphs.md), [Persistenz](05_Persistenz.md), [Beleg-/Auditregister](31_Praxis_Auditnachweise.md). Die Beispiele unter examples sind geprüfte Lua-Fragmente mit benannten Voraussetzungen, keine zusätzlichen installierbaren Modvorlagen.

## Rabbit: vollständiger ausgewählter Lebenszyklus

[prefabs/rabbit.lua](<../../_scripts/scripts_02_10_2026/scripts/prefabs/rabbit.lua>) stellt vor Pristine Netzwerk, Physik, Bank/Build, Richtungen, Schatten, gemeinsame Tags, clientabhängige Insanity-Grafik und Livestock-Pristine bereit. Der Client kehrt danach zurück. Der Master fügt locomotor vor SGrabbit hinzu, anschließend Brain, Eater, Inventar-/Kochbarkeit, KnownLocations, Timer, Health, Loot und Sleeper. Das sind aufeinander angewiesene Verträge: SGrabbit greift auf inst.sounds zu; ein neuer Konstruktor ohne sounds ist trotz korrekter Lua-Syntax unvollständig.

[brains/rabbitbrain.lua](<../../_scripts/scripts_02_10_2026/scripts/brains/rabbitbrain.lua>): Priorität ist Panik/Zaun, Flucht, Heimkehr bei Event/Nacht/Frühling, Futter, Wandern. GoHomeAction darf nil liefern, wenn keine gültige Heimat existiert. Eine Kreatur ohne Homeseeker erhält dadurch kein automatisches Heim. EatFoodAction sucht ein essbares Baitobjekt, schließt gehaltene/gepflanzte/unerreichbare Kandidaten aus und prüft Passierbarkeit sowie gemeinsame Plattform. validfn kontrolliert erneut, ob das Objekt inzwischen gehalten wird.

[behaviours/doaction.lua](<../../_scripts/scripts_02_10_2026/scripts/behaviours/doaction.lua>) übergibt die BufferedAction an locomotor und wartet auf Success/Fail beziehungsweise Timeout/Invalidität. [components/locomotor.lua](<../../_scripts/scripts_02_10_2026/scripts/components/locomotor.lua>): PushAction prüft Startvalidität und führt zum Ziel oder zur Entity-Pufferung. [stategraphs/SGrabbit.lua](<../../_scripts/scripts_02_10_2026/scripts/stategraphs/SGrabbit.lua>) ordnet EAT→eat und GOHOME→action zu. Das Essen erfolgt beim State-Timeout durch PerformBufferedAction, nicht beim Finden der Nahrung. [bufferedaction.lua](<../../_scripts/scripts_02_10_2026/scripts/bufferedaction.lua>): Do prüft aktuelle Gültigkeit und ruft action.fn auf. Zielsuche und tatsächlicher Effekt müssen getrennt bleiben.

## Schlaf, Rückkehr, Tod und Wiederherstellung

Entity-Schlaf ist nicht gleich Sleeper-Spielverhalten. [mainfunctions.lua](<../../_scripts/scripts_02_10_2026/scripts/mainfunctions.lua>): OnEntitySleep meldet Event/Prefabcallback, deaktiviert den Brain, hiberniert den SG und ruft Componentcallbacks. Wake meldet entsprechend Rückkehr und erzeugt/aktiviert den Brain wieder. [entityscript.lua](<../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>): SetBrain, _DisableBrain_Internal und _EnableBrain_Internal; [brain.lua](<../../_scripts/scripts_02_10_2026/scripts/brain.lua>): _Start_Internal/_Stop_Internal. Brain-PostInit kann nach Wiedererzeugung erneut laufen: keine persistenten Zähler im Brainobjekt speichern und keine ungebremst wiederholte globale Listenerregistrierung.

Rabbit.OnWake registriert den Winter-Watcher und synchronisiert die Form; OnSleep entfernt Watcher und Formtask. Erzwungene Beardlingform nutzt timer forcenightmare und pausiert in Limbo. OnLoad findet den bereits geladenen Timer und stellt Build/Sounds/Listener wieder her; es benötigt kein doppeltes eigenes OnSave für die Timerdaten. Traptransfer exportiert/restauriert dagegen gezielt beardlingtime. Inventar, Traptransfer und gewöhnlicher Worldsave sind drei verschiedene Übergänge.

Health meldet bei Tod erst das Worldevent, dann death; SGrabbit geht in death, stoppt Physik, merkt Afflicter und ruft DropDeathLoot. Health.is_corpsing wird erst nach dem death-Event gesetzt. Deshalb beim SG-Entry den mitgegebenen corpsing-Wert beziehungsweise den tatsächlichen weiteren Ablauf beachten und keinen vorzeitig gesetzten Feldwert unterstellen. Health kontrolliert Fade/Corpse-Cleanup; der animover-Handler kann in corpse wechseln. [components/health.lua](<../../_scripts/scripts_02_10_2026/scripts/components/health.lua>): SetVal, OnSave/OnLoad; [stategraphs/commonstates.lua](<../../_scripts/scripts_02_10_2026/scripts/stategraphs/commonstates.lua>): ondeath, oncorpsedeathanimover und AddCorpseStates.

EntityScript:Remove stoppt Manager/Tasks, sendet onremove, entfernt Watcher/Listener und ruft Component-/Replica-/Prefab-Cleanup. Aufgaben auf einem fremden Entitybesitzer oder Einträge in eigenen globalen Tabellen müssen dennoch eigens entfernt werden. Beim Componentausbau gilt nicht automatisch derselbe Ablauf wie bei Entityentfernung.

## Eigenes passives Verhalten als begrenztes Beispiel

[creature_brain.lua](examples/creature_brain.lua) benötigt ein serverseitiges Prefab mit locomotor, bekanntem SG und knownlocations. Das Modul nach scripts/brains/<eigenes Präfix>.lua kopieren; vom eigenen Prefab laden und nach locomotor mit SetBrain zuweisen. Nur das Wandern wird gezeigt. Der Konstruktor muss benötigte Grafik, Bewegungsgeschwindigkeiten und alle vom gewählten SG verwendeten Components/Felder bereitstellen.

Soll eine Heimatposition erhalten bleiben, nach tatsächlicher Spawnposition KnownLocations:RememberLocation aufrufen. Nicht blind die anfängliche Konstruktorposition (oft 0,0,0) als Heimat festschreiben. [components/knownlocations.lua](<../../_scripts/scripts_02_10_2026/scripts/components/knownlocations.lua>) speichert Koordinaten und lädt sie erneut. Ein Brain kann ohne Heimat einen Fallback verwenden; dessen tatsächlichen Wandervertrag beim Projekt prüfen.

Für einen Angreifer ist Rabbit kein fertiger Bauplan. Zusätzlich vollständig verfolgen: Combat-Zielwahl/Retarget, KeepTarget, AttackPeriod/Range, SG-Angriffstimeline/DoAttack, Unterbrechung, AOE/Plattform, Loot und ggf. Bossphasen. Eigene neue Angriffszustände benötigen passende Clips und Treffermomente; Health plus Combat allein bildet keinen funktionierenden Angriff.

## Wilson und die Charakterfactory

[prefabs/wilson.lua](<../../_scripts/scripts_02_10_2026/scripts/prefabs/wilson.lua>) verbindet GameMode-Startitems, Abhängigkeiten, gemeinsame Tags/Reticule und serverseitige Beard-/Foodaffinity-Funktionen. Seine Skilltrees/Beard-Komponenten nicht versehentlich als Voraussetzungen jeder eigenen Figur übernehmen.

[prefabs/player_common.lua](<../../_scripts/scripts_02_10_2026/scripts/prefabs/player_common.lua>): MakePlayerCharacter übernimmt gemeinsame Playerfunktionen, common_postinit vor Pristine (2548), Server-Components und regulären master_postinit (2937). Danach werden eigene OnSave/OnPreLoad/OnLoad/OnNewSpawn/OnDespawn als _On*-Callbacks erfasst und durch die Factorywrapper ersetzt. Die frühere Dokumentationszeile 2715 ist der Lavaarena-Sonderpfad, kein Aufruf des übergebenen regulären Callbacks.

[character_callbacks.lua](examples/character_callbacks.lua) zeigt genau diesen Zeitpunkt. Im eigenen Prefab:

    local callbacks = require("character_callbacks")
    local MakePlayerCharacter = require("prefabs/player_common")
    -- customassets/customprefabs müssen im eigenen Projekt vollständig definiert sein.
    return MakePlayerCharacter("my_character", customprefabs, customassets,
        callbacks.common_postinit, callbacks.master_postinit)

Das Fragment nach scripts/character_callbacks.lua kopieren und alle doc-Präfixe ändern. Es zeigt ein versioniertes Datenfeld und Startinventar; es erhöht visits nicht selbst und repliziert es nicht. Für Gameplayfortschritt eine eigene gespeicherte Component und bei Clientbedarf passende Replica verwenden. Der Beispielzähler ist nur ein Callbackvertrag, keine fertige Fähigkeit.

Ein späterer AddPrefabPostInit sieht bereits die Factorywrapper. Dort nicht OnLoad ersatzlos überschreiben oder die Factory-Interna erneut installieren. Das Beispiel ist ausdrücklich für master_postinit. In modmain PrefabFiles/Assets/Strings und AddModCharacter(name, gender, modes) gemeinsam registrieren; [modutil.lua](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) ergänzt MODCHARACTERLIST/Gender/Modes, erzeugt aber keine Figur oder Grafik.

## Erstspawn, Ghost, Wiederbelebung und Session

OnNewSpawn verteilt starting_inventory; [networking.lua](<../../_scripts/scripts_02_10_2026/scripts/networking.lua>): SpawnNewPlayerOnServerFromSim ruft es nur im Neuspawnpfad auf. player_common.OnLoad entfernt OnNewSpawn, _OnNewSpawn und starting_inventory für bestehende Sessions. Konstruktor-SpawnPrefab/GiveItem statt dieser Schnittstelle würde beim Reconnect Items duplizieren. Der alte sechste Factoryparameter starting_inventory ist als deprecated markiert; neue Figuren setzen die Eigenschaft im Mastercallback.

Death, makeplayerghost und respawnfromghost sind unterschiedliche Events. [prefabs/player_common_extensions.lua](<../../_scripts/scripts_02_10_2026/scripts/prefabs/player_common_extensions.lua>): OnPlayerDeath bereitet Tod vor; OnMakePlayerGhost wechselt Bank, Skinmode, SG, Physik, Actions, Hunger/Sanity/Health-Zustand und Classifiedmodus. ms_becameghost kommt nach der Umstellung. OnRespawnFromGhost wählt einen quellabhängigen verzögerten Wiederbelebungspfad; DoActualRez/CommonActualRez stellen Spielerverhalten her und senden ms_respawnedfromghost. Beim geladenen Ghost wird der Ghostzustand aus OnLoad rekonstruiert. Unterschiedliche GameModes können Corpse-/Deletepfade verwenden.

Eine aktive Fähigkeit muss für Ghost/Corpse deaktiviert und für den lebenden Zustand idempotent wiederhergestellt werden. Save/Load speichert Primärzustand; laufende FX, Tasks und Modifier daraus ableiten. Nicht jeden Restore als neue Belohnung behandeln. Migration/Sessionreferenzen stehen im [Multiplayer-Lebenszyklus](30_Multiplayer_Lebenszyklen.md).

## Benötigte Inhalte und noch offene Arbeit

Für die Factory existiert zunächst Build name und Minimap name.png; skinner übernimmt später normale/Geisterformen. Ein frei gewählter Name erzeugt diese Builds nicht. Erforderlich sind Körper-/Ghostbuilds, Portrait, Auswahl-/Namensbilder, Avatare, Mapicon, Strings und kompatible Sounds. [characterutil.lua](<../../_scripts/scripts_02_10_2026/scripts/characterutil.lua>): aktive Portrait-/Namenshelfer unterscheiden bigportraits/name.xml und images/names_name.xml; Gold hat eigenen Fallback. Der Avatar-Helfer in dieser Datei ist als unbenutzt markiert und wird hier nicht als aktueller UI-Aufrufer behauptet. Tatsächliche Avatar-/Auswahlkonsumenten beim konkreten Projekt weiter verfolgen.

Eigene Skins/Ownership und Skilltrees sind zusätzliche Projekte; [Skins-Fallstudie](case_studies/14_skins_architecture.md) erklärt die Grenzen historischer Beispiele. Die [Assetpipeline](12_Assets_Animation_Audio.md) liefert Exportgrundlagen. Das Callbackfragment enthält keine eigenen Assets und ist deshalb kein auswählbarer fertiger Charakter.

## Offene Spieltests pro Entwurf

Kreatur: Host/Client/Dedicated, Bewegung/Clipwechsel, Nahrung weggenommen während Laufweg, Ziel auf anderer Plattform, Schlaf/Wake/Winter/Limbo, lebend/verletzt/tot laden, Traptransfer, Remove ohne Restlistener oder doppelte Beute. Charakter: Auswahlbild, Erstspawn/Inventar, Reconnect ohne Duplikate, Schlaf mit Hand-/Aktivitem, Tod/Ghost/Corpse, jede vorgesehene Rezquelle, Ghost laden, Höhlenwechsel, eigene Modifier/Tasks entfernen und einmal wiederherstellen. Alle diese Engineprüfungen bleiben nicht durchgeführt.
