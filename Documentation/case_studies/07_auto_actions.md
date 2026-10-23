# Auto Actions – Cliententscheidung und Vanilla-Ausführung

**Prüfart:** statische Ablaufanalyse; Architektur und wesentliche Pfade beschrieben; offene Spezialverträge unten. Keine Ingame-Funktionszusage. Alle Verzeichnisse: `Auto Actions (Serp) 732459815`.

## Einstieg und Abhängigkeiten

Client-only-Mod; Helperfunktionen wählen Werkzeuge/Ziele anhand Config und replizierter Daten. [Auto Actions (Serp) 732459815/modmain.lua — addPlayeractionpicker](<../../Auto Actions (Serp) 732459815/modmain.lua>) (Zeile 1339) und [Auto Actions (Serp) 732459815/modmain.lua — addPlayerController](<../../Auto Actions (Serp) 732459815/modmain.lua>) (Zeile 1372) werden nur für ThePlayer erweitert. AA-Settings-UI hängt am Controls-Widget. Kommentarblöcke enthalten nicht aktive ältere Varianten.

## Initialisierung, Interaktion und Serverwirkung

Originale GetLeftClickActions/GetRightClickActions liefern Actions; GetClickActions/GetRightClickActions ersetzen ausgewählte Kandidaten. Controller GetActionButtonAction nimmt ursprüngliche BufferedAction als Ausgangspunkt, berücksichtigt priorisiertes Ziel und reicht Ergebnis an DoAction. Der Wrapper akzeptiert alternative Action oder "empty" und ruft danach den Originalcontroller auf. OnUpdate führt zuerst Vanilla aus, verarbeitet Toggle und danach optionale Automation. pcall schützt die Ergänzung und fällt auf Vanillaresultat zurück; es ist keine Serverautorisierung.

## Replikation, UI, Speicherung und Wiederherstellung

Keine eigene Servercomponent und kein eigenes Saveformat für Automation: wirksame Aktionen gehen über Standardcontroller/RPC/SG an den Server. Clientkenntnis aus Replica/Tags ist begrenzt; Ziel kann beim Eintreffen entfernt oder unzulässig sein. Einstellungen und flüchtige Prioritäts-/Equipfelder sind getrennt von Worldsave. Nach Reconnect Controller/Picker neu initialisieren; stale BufferedActions nicht weiterverwenden.

## Cleanup und Lebensdauer

Toggle kann die Originalfunktionen wieder einsetzen. Originalfunctiontabellen sind modlokal, nicht pro Controller isoliert; Mehrfachkonstruktion/Neuinitialisierung und andere Controllerwrapper deshalb kritisch. Werkzeugwechsel/Abbruch muss die alte Ausrüstung eindeutig wiederherstellen. Keine universelle Automationsvorlage: jeder neue Aktionstyp braucht den gesamten Vanilla-Actionvertrag.

## Aktuelle Vanilla-Kette

[components/playeractionpicker.lua — GetLeftClickActions](<../../../_scripts/scripts_02_10_2026/scripts/components/playeractionpicker.lua>) (Zeile 301) → [components/playercontroller.lua — GetActionButtonAction](<../../../_scripts/scripts_02_10_2026/scripts/components/playercontroller.lua>) (Zeile 2096) / [components/playercontroller.lua — DoAction](<../../../_scripts/scripts_02_10_2026/scripts/components/playercontroller.lua>) (Zeile 632) → [bufferedaction.lua — IsValid](<../../../_scripts/scripts_02_10_2026/scripts/bufferedaction.lua>) (Zeile 23) → [networkclientrpc.lua — LeftClick](<../../../_scripts/scripts_02_10_2026/scripts/networkclientrpc.lua>) (Zeile 61) → [stategraphs/SGwilson_client.lua — PerformPreviewBufferedAction](<../../../_scripts/scripts_02_10_2026/scripts/stategraphs/SGwilson_client.lua>) (Zeile 728) / [stategraphs/SGwilson.lua — PerformBufferedAction](<../../../_scripts/scripts_02_10_2026/scripts/stategraphs/SGwilson.lua>) (Zeile 1521).

## Altlasten und konkrete Prüfgrenze

pcall kann einen defekten Automationszweig still deaktivieren, wenn Debugausgabe ausgeschaltet ist. Nicht alle Ziel-/Werkzeugheuristiken sind durch diesen Architekturbericht als aktuell funktionsfähig bewertet; insbesondere fremde Tools, Controller und neuere Actiontypen. Native Prediction und RPC-Argumentverträge lassen sich nicht allein aus einem Clientwrapper garantieren. Für Erweiterungen konkrete Aktionen wählen und bis zur Serverwirkung verfolgen.

## Szenarien für die spätere Laufzeitabnahme

Autoequip bei Hacken/Graben/Abbauen, beschädigtes/fehlendes Werkzeug, volles Inventar, Chat/Screen-Fokus, Toggle während laufender Action. Hohe Latenz/Serverablehnung, Ziel entfernt, Reittier und Controller. Separater Client und listen Host; Dedicated führt nur Vanillaaktionen aus. Reconnect/Shardwechsel darf keine alte Entityreferenz übernehmen.

Alle Szenarien sind **offen**. Für Dedicated-Server, separaten Client, Reconnect und Shardwechsel gelten zusätzlich die [allgemeinen Checklisten](../19_Checklisten.md). Statische Symbol-/Hashprüfung ersetzt diese Abnahme nicht. [Katalog](../16_Workspace_Mods.md) · [Abdeckungsmatrix](../21_Abdeckungsmatrix.md) · [Projektworkflow](../20_Projektworkflow.md).


## Dateiregister: Auto Actions (Serp) 732459815

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [modinfo.lua](<../../Auto Actions (Serp) 732459815/modinfo.lua>)
- [modmain.lua](<../../Auto Actions (Serp) 732459815/modmain.lua>)
- [scripts/widgets/aas.lua](<../../Auto Actions (Serp) 732459815/scripts/widgets/aas.lua>)
- [scripts/widgets/aas_new.lua](<../../Auto Actions (Serp) 732459815/scripts/widgets/aas_new.lua>)


## Erneute Prüfung: Toolwahl, Preview, Wiederholung und Fehlerpfade

[`Auto Actions (Serp) 732459815/modmain.lua`](<../../Auto Actions (Serp) 732459815/modmain.lua>) erweitert PlayerActionPicker/PlayerController und UI. Toolwahl durchsucht Inventar/Overflow nach Actiontags, bevorzugt ggf. Gold und kann bekannte/bau­bare Rezepte über Builder anfordern. Equip/Unequip verwendet Inventory-Replicaoperationen; kurze Wiederholung behandelt noch nicht angekommenen Zustand, bestätigt keinen Servererfolg. OnUpdate berücksichtigt aktive Arbeit/Eingabe/Angriff und stellt alte Ausrüstung im Leerlauf zurück.

Actionbuttonwege umfassen Catch, Trap, Repair, Fuel, Cook, Dig/Replant. Replant hält die Position, wartet auf verschwundenes Ziel und prüft Deployment. Host mit Locomotor und Client mit Preview/RPC sind unterschiedliche Wege. Die heutigen RPC-Typ-/Inventarprüfungen stehen in [`networkclientrpc.lua`](<../../../_scripts/scripts_02_10_2026/scripts/networkclientrpc.lua>), die spätere Actiongültigkeit in [`bufferedaction.lua`](<../../../_scripts/scripts_02_10_2026/scripts/bufferedaction.lua>). Auswahl einer Clientaction autorisiert keine Wirkung.

Statisch auffällige Pfade: Eine Replantsuche übergibt FindEntities eine Tagtabelle an der Radiusposition, an der aktuelle Aufrufer Zahlen verwenden. DoAttackButton(playercontroller,...) verwendet im Retargetzweig self:GetCombatTarget(), ohne self als Parameter zu erhalten. NET-Zielprüfung verwendet target.components.health, das einem entfernten Client nicht allgemein zur Verfügung steht. Das beobachtbare Fehlerbild ist erst unter passender Eingabe/Clientrolle zu prüfen.

pcall-Wrapper können zum Original zurückfallen und Fachfehler verdecken. Debugausgabe und gewählter Zweig gehören deshalb zur Diagnose. Alte kopierte Actionbuttonlogik nicht allein wegen gleicher Funktionsnamen als aktuell behandeln. Für neue Automation Originalauswahl möglichst erhalten, Ersatzaction begrenzen, serverseitig validieren und Ausrüstungsrückgabe abbrechen, wenn der Spieler bewusst etwas anderes gewählt hat. Client-Zielfelder sind keine persistente Farmauftragsliste. Offen: Craft/Equip/Action unter Lag, Netfang remote, verschwundenes Angriffs-/Replantziel, volle Tasche, Controller und Plattformen.


Auch einzelne Trapsuchen und die kopierte Actionbuttonfunktion benutzen TheSim unqualifiziert. Im normalen Modenvironment ist dieser Zugriff ohne eigenen Alias nicht verfügbar; die tatsächliche Callbackumgebung vor Übernahme ausdrücklich prüfen.


Konkrete zusätzliche Funktionsdefinitionen: [Vertragsbelege](../27_Vertragsbelege.md). Die [Reviewmatrix](../REVIEW_MATRIX.json) trennt Einstiegssichtung und ausgewählte vertiefte Abläufe; weitere Featureänderungen benötigen einen eigenen aktuellen Audit.
