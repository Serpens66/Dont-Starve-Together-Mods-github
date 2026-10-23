# 03 — Prefabs, Components, Tags und Lebenszyklus

## Verantwortlichkeiten

Ein Prefab beschreibt die Erzeugung einer Entity einschließlich Grafik, Physik, Tags und Gameplay-Components. `Prefab(name, fn, assets, prefabs)` koppelt den Konstruktor mit Assets und abhängigen Prefabs. Components bündeln Verhalten; eine Replica bietet eine lesbare Schnittstelle zu replizierten Daten. Eine Replica ist keine automatische Kopie aller Component-Felder.

`CreateEntity` erzeugt die Lua-EntityScript-Hülle über ein natives Entity-Objekt und registriert sie in `Ents`. Details von `TheSim:CreateEntity` bleiben eine Engine-Grenze. Die Lua-seitigen Aufrufketten sind in [Audit 17](17_Vanilla_Audit.md) festgehalten.

Belege: [mainfunctions.lua — function CreateEntity](<../../_scripts/scripts_02_10_2026/scripts/mainfunctions.lua>) (Zeile 486), [prefabs/spear.lua — local function fn()](<../../_scripts/scripts_02_10_2026/scripts/prefabs/spear.lua>) (Zeile 28), [entityreplica.lua — function EntityScript:ReplicateComponent](<../../_scripts/scripts_02_10_2026/scripts/entityreplica.lua>) (Zeile 34).

## Reihenfolge eines Netzwerk-Prefabs

Das aktuelle Speer-Prefab demonstriert:

1. Entity und benötigte native Teilobjekte anlegen: Transform, AnimState, Network.
2. Physik, Bank/Build, Animation und gemeinsam benötigte Tags festlegen.
3. Eigene Netzvariablen auf allen beteiligten Instanzen in derselben Reihenfolge deklarieren.
4. `inst.entity:SetPristine()` aufrufen.
5. Auf Nicht-MasterSim-Instanzen zurückkehren.
6. Serverseitige Components samt Setter und Callbacks installieren.
7. Fertige Instanz zurückgeben.

Im aktuellen Speer stehen `SetPristine()` und erst danach der Client-Return. Die Workspace-Scythe kehrt dagegen vor `SetPristine()` zurück. Diesen historischen Aufbau nicht als Standard kopieren.

Eigene Netzvariablen nicht nur in eine Server-Component packen, die auf Clients fehlt. Die Netzwerkvorlage hält die Definition bewusst im eigenen Prefab. Bei Erweiterung eines bestehenden Prefabs muss dessen vollständige Konstruktion einschließlich vorhandener Netvars geprüft werden.

Belege: [prefabs/spear.lua — inst.entity:SetPristine()](<../../_scripts/scripts_02_10_2026/scripts/prefabs/spear.lua>) (Zeile 49), [netvars.lua: dokumentierter nativer Netvarvertrag](<../../_scripts/scripts_02_10_2026/scripts/netvars.lua>) (Zeile 29), [Scythe 733887349/scripts/prefabs/scythe.lua — if not TheWorld.ismastersim](<../Scythe 733887349/scripts/prefabs/scythe.lua>) (Zeile 58).

## Component-Klasse

    local Demo = Class(function(self, inst)
        self.inst = inst
        self.value = 0
    end)

    function Demo:SetValue(value)
        self.value = value
    end

    return Demo

Der Loader erwartet `scripts/components/demo.lua`. `inst:AddComponent("demo")` lädt die Klasse, repliziert eine registrierte Replica, konstruiert die Component, speichert sie unter `inst.components.demo`, ruft die PostInit-Callbacks und registriert Component-Actions.

Wichtig: Während des Component-Konstruktors ist `inst.components.demo` noch nicht gesetzt. Eigene Konstruktorlogik verwendet daher `self`. Property-Callbacks in der DST-`Class` können bei Feldänderungen weitere Logik oder Replica-Setter auslösen; direktes Feldsetzen ist deshalb nicht immer ein rein lokaler Schreibzugriff.

Belege: [entityscript.lua — function EntityScript:AddComponent](<../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 610), [components/inventoryitem.lua — atlasname = onatlasname](<../../_scripts/scripts_02_10_2026/scripts/components/inventoryitem.lua>) (Zeile 94).

## Tags und Replicas

Tags sind schnelle Merkmale für Auswahl und Actions. Tags wie `weapon` oder `tool` werden in Vanilla teilweise bereits vor Pristine angelegt. Ein serverseitiges Tag kann repliziert werden; ein lokal erfundenes Client-Tag macht aber keinen serverseitigen Gameplay-Zustand gültig.

`AddReplicableComponent("doc_counter")` registriert den Namen; `scripts/components/doc_counter_replica.lua` liefert die zugehörige Klasse. Der Engine-/Lua-Replikationsablauf erkennt `_component`- beziehungsweise `__component`-Tags und konstruiert Replicas. Die Getter in `inst.replica` validieren deren aktuelle Nutzbarkeit über den Tag.

Eine Replica darf auf Clients nicht voraussetzen, dass `inst.components.doc_counter` existiert. Sie liest dort Netvars; serverseitig kann sie bei Bedarf die Component verwenden.

Belege: [entityscript.lua — local replica_mt](<../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 208), [entityreplica.lua — function EntityScript:ValidateReplicaComponent](<../../_scripts/scripts_02_10_2026/scripts/entityreplica.lua>) (Zeile 30), [entityreplica.lua — function AddReplicableComponent](<../../_scripts/scripts_02_10_2026/scripts/entityreplica.lua>) (Zeile 98).

## Events, Tasks und Aufräumen

`ListenForEvent(event, fn, source)` bindet einen Listener an eine Quelle. Fehlt `source`, wird die eigene Entity verwendet. Beim Event wird der Callback mit der **Quelle** und den Daten aufgerufen. `RemoveEventCallback` braucht dieselbe Funktion und Quelle; eine neu erzeugte Closure entfernt den alten Listener nicht.

`DoTaskInTime(delay, fn, ...)` und `DoPeriodicTask(period, fn, initialdelay, ...)` geben cancellable Tasks zurück. Die Entity wird dem Callback vor die weiteren Argumente gestellt. Beim Entfernen der Entity werden Tasks beendet; ein früherer Zustandswechsel benötigt gegebenenfalls eigenes `task:Cancel()`.

World-State-Watcher koppeln einen Zustand an die Entity; `StopWatchingWorldState` und `StopAllWatchingWorldStates` lösen sie. Anfangszustände trotzdem explizit anwenden, wenn die Funktion direkt nach dem Spawn gebraucht wird.

Entity-Watcher erhalten `fn(inst, value)`; die vom Componentloader installierte Component-Variante erhält `fn(component, value)`. Worldstate speichert das jeweilige Callbackziel explizit. Das unterscheidet sich vom Eventcallback, dessen erstes Argument die Ereignisquelle ist. Beispiel einer entitybezogenen Anzeige eines bereits geprüften Tageszustands:

    local function OnNight(inst, isnight)
        inst.my_mod_isnight = isnight
    end
    inst:WatchWorldState("isnight", OnNight)
    OnNight(inst, GLOBAL.TheWorld.state.isnight)
    -- Falls diese Funktion vor Entity-Entfernung abgeschaltet wird:
    inst:StopWatchingWorldState("isnight", OnNight)

Der Callback ändert hier nur ein eigenes Lua-Feld. Das Feld ist weder automatisch repliziert noch gespeichert. Für Gameplaywirkung Serverzuständigkeit prüfen und für Darstellung einen passenden Netz-/Replica-Vertrag ergänzen.

Belege: [entityscript.lua — local function ComponentWatchWorldState](<../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 42), [entityscript.lua — function EntityScript:WatchWorldState](<../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 1264), [components/worldstate.lua — function self:AddWatcher](<../../_scripts/scripts_02_10_2026/scripts/components/worldstate.lua>) (Zeile 281), [components/worldstate.lua — local function SetVariable](<../../_scripts/scripts_02_10_2026/scripts/components/worldstate.lua>) (Zeile 24).

`RemoveComponent` stoppt Updates, entfernt sie aus dem Component-Verzeichnis, ruft `OnRemoveFromEntity`, entfernt Replica-/Action-Zuordnung. Eigene Listener und Fremdreferenzen dort gezielt freigeben. Ein Task-Handle wird nicht als Save-Datum gespeichert.

Belege: [entityscript.lua — function EntityScript:ListenForEvent](<../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 1188), [entityscript.lua — function EntityScript:DoPeriodicTask](<../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 1512), [entityscript.lua — function EntityScript:RemoveComponent](<../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 648), [mainfunctions.lua — ent:KillTasks()](<../../_scripts/scripts_02_10_2026/scripts/mainfunctions.lua>) (Zeile 515).
