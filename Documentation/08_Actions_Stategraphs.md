# 08 — Actions und Stategraphs

## Vier gekoppelte Schichten

| Schicht | Aufgabe |
|---|---|
| Action | ID, Text, Parameter und Gameplay-Funktion |
| Component-Action | Aktion für ein Ziel oder Item anbieten |
| Stategraph | Animation, Timing, Preview und Ausführung |
| Serverprüfung | Aktuelle Voraussetzungen und Wirkung |

`AddAction` registriert unter ACTIONS, ordnet Mod-Namen und Action-Code zu. Eindeutige Mod-Präfixe verhindern globale Namenskollisionen. Auf beiden beteiligten Seiten gleich registrieren.

Belege: [modutil.lua — env.AddAction](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 442), [componentactions.lua — function AddComponentAction](<../../_scripts/scripts_02_10_2026/scripts/componentactions.lua>) (Zeile 3108), [stategraph.lua — StateGraph = Class](<../../_scripts/scripts_02_10_2026/scripts/stategraph.lua>) (Zeile 274).

## Component-Action-Argumente

| Typ | Callback-Argumente laut componentactions.lua |
|---|---|
| SCENE | inst, doer, actions, right |
| USEITEM | inst, doer, target, actions, right |
| POINT | inst, doer, pos, actions, right |
| EQUIPPED | inst, doer, target, actions, right |
| INVENTORY | inst, doer, actions, right |
| ISVALID | inst, action, right |

Bei USEITEM ist inst das verwendete Item, nicht das Ziel. Collector-Callbacks ergänzen actions, ohne Gameplay-Wirkung auszuführen. Ihre Daten müssen auf Clients existieren: Tags oder Replicas, nicht ausschließlich Server-Components.

`AddComponent` registriert die Component-Action-Zuordnung serverseitig; IDs werden repliziert. Eine eigene Replica ist für reine Action-Erkennung daher nicht immer nötig.

Belege: [componentactions.lua — SCENE =](<../../_scripts/scripts_02_10_2026/scripts/componentactions.lua>) (Zeile 140), [componentactions.lua — USEITEM =](<../../_scripts/scripts_02_10_2026/scripts/componentactions.lua>) (Zeile 1038), [componentactions.lua — POINT =](<../../_scripts/scripts_02_10_2026/scripts/componentactions.lua>) (Zeile 1988), [componentactions.lua — EQUIPPED =](<../../_scripts/scripts_02_10_2026/scripts/componentactions.lua>) (Zeile 2201), [componentactions.lua — INVENTORY =](<../../_scripts/scripts_02_10_2026/scripts/componentactions.lua>) (Zeile 2513), [componentactions.lua — ISVALID =](<../../_scripts/scripts_02_10_2026/scripts/componentactions.lua>) (Zeile 3049), [componentactions.lua — function EntityScript:RegisterComponentActions](<../../_scripts/scripts_02_10_2026/scripts/componentactions.lua>) (Zeile 3121).

## Lehrbeispiel: Truhe markieren

Die [Action-Vorlage](templates/04_action/README.md) ergänzt Vanilla-Truhen um eine persistente serverseitige doc_markable-Component. Eine rechte SCENE-Aktion markiert die Truhe einmal. Der Server prüft Entfernung, Spielerzustand und Ziel. Ein repliziertes Tag verhindert anschließend erneute Auswahl.

Gemeinsame Handlerregistrierung:

    AddStategraphActionHandler("wilson",
        GLOBAL.ActionHandler(action, "doshortaction"))
    AddStategraphActionHandler("wilson_client",
        GLOBAL.ActionHandler(action, "doshortaction"))

Diese Namen bezeichnen Stategraphs, nicht einzelne Charakter-Prefabs. Fremde Stategraphs und besondere Spielmodi benötigen eigene Tests und gegebenenfalls Handler.

## Preview und Wirkung

Server-doshortaction führt die gespeicherte BufferedAction an einem Timeline-Punkt mit PerformBufferedAction aus. Client-doshortaction verwendet PerformPreviewBufferedAction und wartet auf Bestätigung oder Timeout.

Die Action-Funktion erhält act.doer, act.target und gegebenenfalls act.invobject oder Position. Erneut prüfen, denn zwischen Auswahl und Ausführung können Ziel und Inventar ungültig werden. Den Erfolg als passend ausgewertete Rückgabe liefern; keine doppelte Wirkung in Collector oder Preview.

Belege: [stategraphs/SGwilson.lua — name = "doshortaction"](<../../_scripts/scripts_02_10_2026/scripts/stategraphs/SGwilson.lua>) (Zeile 7906), [stategraphs/SGwilson_client.lua — name = "doshortaction"](<../../_scripts/scripts_02_10_2026/scripts/stategraphs/SGwilson_client.lua>) (Zeile 3087), [bufferedaction.lua — function BufferedAction:Do](<../../_scripts/scripts_02_10_2026/scripts/bufferedaction.lua>) (Zeile 22).

## Eigene States

AddStategraphState, AddStategraphEvent und AddStategraphActionHandler werden vom Stategraph-Konstruktor integriert. Busy-/Doing-Tags, onenter, timeline, ontimeout und onexit müssen gemeinsam mit Movement und Abbruch funktionieren.

Die Definition ist geteilt; inst.sg.statemem enthält zustandsspezifische Daten. Ein langer State muss bei Unterbrechung aufräumen, nicht erst bei Erfolg. Zunächst passende Vanilla-States prüfen; eigene Server-/Clientstates erst für zusätzliche Anforderungen entwickeln.

## Diagnose

- Sichtbarer Text ohne Wirkung: Handler, Action-Rückgabe und Serverprüfung untersuchen.
- Nur Host funktioniert: gemeinsame Registrierung, Action-IDs, Component-Zuordnung und Client-Stategraph prüfen.
- Spieler bleibt hängen: Timeout, Busy-Tags, onexit und BufferedAction prüfen.
- Andere Rechtsklickaktion verschwindet: Priority, rmb und Collector-Voraussetzungen vergleichen.
- Doppelte Wirkung: Gameplay-Änderung aus Collector/Client-Preview entfernen.

Praxis: [Repair Combine 767776640/modmain.lua — AddComponentAction("USEITEM"](<../Repair Combine 767776640/modmain.lua>) (Zeile 59), [Evolving Maxwell Shadows 1868560353/scripts/stategraphadditions.lua — AddStategraphActionHandler](<../Evolving Maxwell Shadows 1868560353/scripts/stategraphadditions.lua>) (Zeile 243).


## Vertiefung mit Workspace-Beispielen

Die dazugehörigen konkreten Abläufe, Daten-/Cleanupentscheidungen und Altlasten sind im [Praxismechanismen-Kapitel](23_Praxismechanismen.md) erklärt. Über die [Abdeckungsmatrix](21_Abdeckungsmatrix.md) zu passenden Fallstudien und eigenständigen Vorlagen navigieren; Grenzen komplexer Systeme stehen ausdrücklich dort.
