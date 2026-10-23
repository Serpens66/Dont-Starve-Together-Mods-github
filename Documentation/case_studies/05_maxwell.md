# Maxwell Shadows – Hauptstand und historische Varianten

**Prüfart:** statische Ablaufanalyse; Architektur und wesentliche Pfade beschrieben; offene Spezialverträge unten. Keine Ingame-Funktionszusage. Alle Verzeichnisse: `Evolving Maxwell Shadows 1868560353`, `Evolving Maxwell Shadows 1868560353_vormultitools`, `DST-Evolving-Maxwell-Shadows_mithunger`.

## Einstieg und Abhängigkeiten

Der Hauptstand verwendet modmain, helper, eigene shadowtoggleable-Component, journalpage und Brain-/SG-Erweiterungen. [Evolving Maxwell Shadows 1868560353/modmain.lua — ShadowApplyUpgrades](<../../Evolving Maxwell Shadows 1868560353/modmain.lua>) (Zeile 229) ist der gemeinsame Ableitungspunkt. Konfiguration definiert Jobliste, Levelgrenzen, Decay, Ausrüstung, Bindung und Visuals. Alle Varianten belegen dieselben Namen; sie sind alternative historische Stände, keine gemeinsam zu aktivierenden Module.

## Initialisierung, Interaktion und Serverwirkung

PrefabPostInit erweitert shadowduelist und Arbeiter: serverseitiges Equip-Inventar mit Overflowcontainer, Containerregeln und Itemtests, level/decay, Arbeitsmultiplikatoren, Trefferverhalten. Öffnen nimmt Ausrüstung aus den Slots in den Container; Schließen verbraucht Nightmarefuel zuerst gegen Decay, danach für Level, leitet Werte neu ab und wählt Ausrüstung. Die Toggleaction prüft serverseitig petleash:IsPet; owner-Prüfung ist hier Teil der Action.

Brainziele wählen Arbeitsaktionen und Werkzeuge; Stategraphänderungen liefern passende Aktionen/Animationen. MatchSpeedAndBoundPosition wird periodisch ausgeführt, Teleporterwrapper lehnt gebundene Schatten ab. Decay verbraucht Fuel, senkt Level und danach Sichtbarkeit/Lebensdauer. Beim finalen Despawn werden Inventar und Container abgelegt; willdespawn verhindert erneute Close-Upgrades.

## Replikation, UI, Speicherung und Wiederherstellung

Gemeinsame Containerparameter und Tags machen Interaktion/UI möglich; die eigentlichen Werte und Mutationen sind serverseitig. onsave schreibt level/decay, onpreload stellt diese **vor** Healthdaten wieder her. ShadowApplyUpgrades bewahrt Healthprozent beim Maximalwechsel, setzt Damage-/Work-/Speedmodifier sowie Regeneration/Visuals. Container und Inventory besitzen jeweils ihre Vanilla-Persistenz. Beim Hauptstand ersetzt ein Container-OnLoad die Standardroutine, um historische Inhalte durch Itemtests zu bringen; Referenzbehandlung muss deshalb separat überprüft werden.

## Cleanup und Lebensdauer

Speedtasks werden an death/onremove abgebrochen. Decay und attackbedingter Rückgabeprozess dürfen nicht doppelt Items erzeugen. Beim Equip-/Werkzeugwechsel müssen fremde Tags und Modifier erhalten bleiben; Fastpicker kann ebenfalls von einer Sense stammen. Beim Entfernen gebundener Leader ist Follower-/Petleash-Cleanup maßgeblich.

## Aktuelle Vanilla-Kette

[prefabs/shadowwaxwell.lua — shadowduelist](<../../../_scripts/scripts_02_10_2026/scripts/prefabs/shadowwaxwell.lua>) (Zeile 671) → [components/petleash.lua — DespawnPet](<../../../_scripts/scripts_02_10_2026/scripts/components/petleash.lua>) (Zeile 242) / [components/follower.lua — leader](<../../../_scripts/scripts_02_10_2026/scripts/components/follower.lua>) (Zeile 3) → [components/inventory.lua — Equip](<../../../_scripts/scripts_02_10_2026/scripts/components/inventory.lua>) (Zeile 1) / [components/container.lua — OnLoad](<../../../_scripts/scripts_02_10_2026/scripts/components/container.lua>) (Zeile 996) → [components/health.lua — SetMaxHealth](<../../../_scripts/scripts_02_10_2026/scripts/components/health.lua>) (Zeile 503) → [util/sourcemodifierlist.lua — SetModifier](<../../../_scripts/scripts_02_10_2026/scripts/util/sourcemodifierlist.lua>) (Zeile 64); [brains/shadowwaxwellbrain.lua — ShadowWaxwellBrain](<../../../_scripts/scripts_02_10_2026/scripts/brains/shadowwaxwellbrain.lua>) (Zeile 13) und [stategraphs/SGshadowwaxwell.lua — StateGraph](<../../../_scripts/scripts_02_10_2026/scripts/stategraphs/SGshadowwaxwell.lua>) (Zeile 1479) sind das aktuelle Gegenstück zum Arbeitsablauf.

## Altlasten und konkrete Prüfgrenze

Hauptstand ergänzt Multitool-/Aktionswahl und automatische Werkzeugwahl. Der vormultitools-Stand dokumentiert frühere Job-/Equipentscheidungen; mithunger führt Hunger-/Fuelzustand mit eigener Ableitung. Ein textueller Unterschied beweist keine funktionale Überlegenheit. Unvollständig generalisierbar sind fremde Werkzeuge, Sonderangriffe, SG-Ersetzungen sowie Containerreferenzen: der Ersatz-OnLoad benutzt newents ohne lokalen Funktionsparameter. Alte direktersetzte Prefab-OnSave/OnPreLoad-Funktionen können neuere Vanilla-/Moddaten verdrängen. Der vollständige Katalog der Jobbedingungen bleibt im helper/Braincode; vor einer weiteren Jobart dessen Actionsammlung und alle Fehlpfade separat auditieren.

## Szenarien für die spätere Laufzeitabnahme

Schatten erzeugen, Fuel einlegen, öffnen/schließen, Waffen/Rüstung/Werkzeuge wechseln, arbeiten/kämpfen, binden und Wormhole betreten. Maxlevel, leeres Fuel, Decay bis Despawn, Leaderangriff, Tod des Leaders. Save/Load mit beschädigter Ausrüstung und Level; doppelte Drops ausschließen. Host/separater Client/Dedicated und Migration mit petleash. Jede Variante separat gegen denselben Szenariensatz testen.

Alle Szenarien sind **offen**. Für Dedicated-Server, separaten Client, Reconnect und Shardwechsel gelten zusätzlich die [allgemeinen Checklisten](../19_Checklisten.md). Statische Symbol-/Hashprüfung ersetzt diese Abnahme nicht. [Katalog](../16_Workspace_Mods.md) · [Abdeckungsmatrix](../21_Abdeckungsmatrix.md) · [Projektworkflow](../20_Projektworkflow.md).


## Gezielter Variantenvergleich und aktueller Arbeitsvertrag

| Stand | Belegbarer Unterschied | Konsequenz |
|---|---|---|
| Hauptstand | [Evolving Maxwell Shadows 1868560353/modmain.lua — BM_AUTOTOOLSWITCH](<../../Evolving Maxwell Shadows 1868560353/modmain.lua>) (Zeile 36) und GetActionForShadowTarget/FindEntityToWorkAction | Werkzeug-/Aktionswahl als zusätzlicher Teil des Brains, nicht bloß Equip beim Close |
| vormultitools | [Evolving Maxwell Shadows 1868560353_vormultitools/modmain.lua — BM_SHADOW_JOBS](<../../Evolving Maxwell Shadows 1868560353_vormultitools/modmain.lua>) (Zeile 107) mit CHOP/MINE/DIG/PICK | historische feste Jobliste; Namen überschneiden Hauptstand |
| mithunger | [DST-Evolving-Maxwell-Shadows_mithunger/modmain.lua — hunger:SetRate](<../../DST-Evolving-Maxwell-Shadows_mithunger/modmain.lua>) (Zeile 275) und hunger:SetKillRate, Nightmarefuel-edible | Decayidee teils durch tatsächlichen Verbrauch/Starvation ersetzt; Health-/Hunger-Persistenz getrennt |

[components/hunger.lua — DoDec](<../../../_scripts/scripts_02_10_2026/scripts/components/hunger.lua>) (Zeile 19) benutzt Rate×dt×Burnmodifier und verursacht erst beim Verhungern Schaden; OnSave speichert aktuellen Hunger, nicht jeden Mod-Maximalwert. SetMax setzt current zunächst auf amount, also beim Levelwechsel gewünschtes Prozent ausdrücklich bewahren. Der aktuelle [brains/shadowwaxwellbrain.lua — FindAnyEntityToWorkActionsOn](<../../../_scripts/scripts_02_10_2026/scripts/brains/shadowwaxwellbrain.lua>) (Zeile 88) nutzt Workableprüfung, Ignorierlisten und SpawnPoint-Radius sowie CHOP/MINE/DIG. Dieses vollständige Zielprotokoll muss eine zusätzliche PICK-/Werkzeugwahl ergänzen statt durch eine ungeprüfte alte Vollkopie verdrängen.


## Dateiregister: Evolving Maxwell Shadows 1868560353

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [BM_AllowedItemActions.lua](<../../Evolving Maxwell Shadows 1868560353/BM_AllowedItemActions.lua>)
- [BM_strings.lua](<../../Evolving Maxwell Shadows 1868560353/BM_strings.lua>)
- [modinfo.lua](<../../Evolving Maxwell Shadows 1868560353/modinfo.lua>)
- [modmain.lua](<../../Evolving Maxwell Shadows 1868560353/modmain.lua>)
- [scripts/BM_helpers.lua](<../../Evolving Maxwell Shadows 1868560353/scripts/BM_helpers.lua>)
- [scripts/components/shadowtoggleable.lua](<../../Evolving Maxwell Shadows 1868560353/scripts/components/shadowtoggleable.lua>)
- [scripts/prefabs/journalpage.lua](<../../Evolving Maxwell Shadows 1868560353/scripts/prefabs/journalpage.lua>)
- [scripts/stategraphadditions.lua](<../../Evolving Maxwell Shadows 1868560353/scripts/stategraphadditions.lua>)


## Dateiregister: Evolving Maxwell Shadows 1868560353_vormultitools

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [BM_AllowedItemActions.lua](<../../Evolving Maxwell Shadows 1868560353_vormultitools/BM_AllowedItemActions.lua>)
- [BM_strings.lua](<../../Evolving Maxwell Shadows 1868560353_vormultitools/BM_strings.lua>)
- [modinfo.lua](<../../Evolving Maxwell Shadows 1868560353_vormultitools/modinfo.lua>)
- [modmain.lua](<../../Evolving Maxwell Shadows 1868560353_vormultitools/modmain.lua>)
- [scripts/BM_helpers.lua](<../../Evolving Maxwell Shadows 1868560353_vormultitools/scripts/BM_helpers.lua>)
- [scripts/components/shadowtoggleable.lua](<../../Evolving Maxwell Shadows 1868560353_vormultitools/scripts/components/shadowtoggleable.lua>)
- [scripts/prefabs/journalpage.lua](<../../Evolving Maxwell Shadows 1868560353_vormultitools/scripts/prefabs/journalpage.lua>)
- [scripts/stategraphadditions.lua](<../../Evolving Maxwell Shadows 1868560353_vormultitools/scripts/stategraphadditions.lua>)


## Dateiregister: DST-Evolving-Maxwell-Shadows_mithunger

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [BM_AllowedItemActions.lua](<../../DST-Evolving-Maxwell-Shadows_mithunger/BM_AllowedItemActions.lua>)
- [BM_strings.lua](<../../DST-Evolving-Maxwell-Shadows_mithunger/BM_strings.lua>)
- [modinfo.lua](<../../DST-Evolving-Maxwell-Shadows_mithunger/modinfo.lua>)
- [modmain.lua](<../../DST-Evolving-Maxwell-Shadows_mithunger/modmain.lua>)
- [scripts/BM_helpers.lua](<../../DST-Evolving-Maxwell-Shadows_mithunger/scripts/BM_helpers.lua>)
- [scripts/components/shadowtoggleable.lua](<../../DST-Evolving-Maxwell-Shadows_mithunger/scripts/components/shadowtoggleable.lua>)
- [scripts/prefabs/journalpage.lua](<../../DST-Evolving-Maxwell-Shadows_mithunger/scripts/prefabs/journalpage.lua>)
- [scripts/stategraphadditions.lua](<../../DST-Evolving-Maxwell-Shadows_mithunger/scripts/stategraphadditions.lua>)


## Erneute Prüfung: Legacy-Arbeiter und vollständiger Actionweg

Der aktuelle [`brains/shadowwaxwellbrain.lua`](<../../../_scripts/scripts_02_10_2026/scripts/brains/shadowwaxwellbrain.lua>) besitzt verschiedene Architekturen. `shadowworker` arbeitet mit SpawnPoint, Pickup/Delivery und „Keep Working“; der Fallback enthält weiterhin „Leader In Range“ und einzelne CHOP/MINE/DIG-Arbeiter. Der Hauptmod erweitert diese historische Baumstruktur sowie `shadowlumber`/`shadowduelist`. Vorhandensein heutiger Maxwell-Arbeiter beweist keine Anwendung sämtlicher Modfunktionen auf `shadowworker`. Zuerst tatsächlich erzeugtes Prefab und zugehörigen Brainzweig bestimmen. Der Datei-Name SGshadowwaxwell.lua und der zurückgegebene Stategraphname shadowmaxwell sind unterschiedliche Bezeichner.

[`Evolving Maxwell Shadows 1868560353/scripts/BM_helpers.lua`](<../../Evolving Maxwell Shadows 1868560353/scripts/BM_helpers.lua>) verbindet Lebenszustand, Container-Itemregeln und verfügbares bzw. automatisch wechselbares Werkzeug. Im Arbeitercontainer ist Slot 1 reserviert. `EquipNewEquip` wählt HANDS/HEAD/BODY, verschiebt das Werkzeug nach Slot 1 und rüstet über Inventory aus. Slottausch, volle Container und abgewiesene GiveItem-Aufrufe sind eigene Fehlerfälle; diese Schritte sind kein atomarer Inventartransfer.

Die Jobwahl im [`Evolving Maxwell Shadows 1868560353/modmain.lua`](<../../Evolving Maxwell Shadows 1868560353/modmain.lua>) umfasst CHOP/MINE/DIG/PICK/PICKUP/INTERACT_WITH/HARVEST. Sie prüft Sichtbarkeit, Limbo, Brennen, Workableaktion, Pickablezustand, Produktraum und vorige Ziele. Auffälligkeiten: CHOP/MINE-Alternativsuche verwirft bei der bevorzugten Wachstumsstufe eine Gleichheit, während PICK auf Ungleichheit prüft. `next(loot)` liefert den Schlüssel eines Arrays und nicht automatisch den Prefabnamen. Vor Übernahme mit mehreren Baumstadien und voller Tasche prüfen.

[`Evolving Maxwell Shadows 1868560353/scripts/stategraphadditions.lua`](<../../Evolving Maxwell Shadows 1868560353/scripts/stategraphadditions.lua>) führt die Wirkung am Timelinepunkt oder Timeout über PerformBufferedAction aus. States halten die ursprüngliche Action in sg.statemem, beenden Sound/Actionmeter beim Verlassen und löschen nur die noch passende BufferedAction. Brainziel, Handler, Ablaufzustand, Ausrüstung und serverseitige Action müssen zusammenpassen.

Save/Load leitet Level/Decay vor Health-OnLoad wieder ab; Inhalt und beschädigte Ausrüstung folgen ihren eigenen Verträgen. Der Ersatz-Container-OnLoad benennt keinen newents-Parameter, übernimmt aber nicht automatisch die Vanilla-Referenzbehandlung. Für neue Systeme SpawnSaveRecord-Referenzen sammeln und Containervertrag erhalten. Offen: Jobwechsel während Arbeit, Angriff/Abbruch, leeres Fuel, Slotverlust, Leaderentfernung, Legacy gegenüber modernem Worker und Save/Load in jedem Zustand. Historische Varianten getrennt aktivieren; Hunger-/Fuelmodelle nicht vermischen.


Konkrete zusätzliche Funktionsdefinitionen: [Vertragsbelege](../27_Vertragsbelege.md). Die [Reviewmatrix](../REVIEW_MATRIX.json) trennt Einstiegssichtung und ausgewählte vertiefte Abläufe; weitere Featureänderungen benötigen einen eigenen aktuellen Audit.
