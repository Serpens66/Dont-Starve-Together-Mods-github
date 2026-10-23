# 06 — Gegenstände, Gebäude und Container

## Item-Bausteine

Die [Item-Vorlage](templates/02_item/README.md) erzeugt einen eigenen Trainingsspeer mit Vanilla-Grafik und eigenem Rezept. Für diesen Fall gehören `inventoryitem`, `equippable`, `weapon`, `finiteuses` und `inspectable` zum serverseitigen Setup. Components nach dem tatsächlichen Feature wählen; nicht jedes Item braucht Ausrüstung oder Haltbarkeit.

Beleg: [prefabs/spear.lua — local function fn()](<../../_scripts/scripts_02_10_2026/scripts/prefabs/spear.lua>) (Zeile 28).

## Inventarbild und Haltbarkeit

`inventoryitem.imagename` erhält normalerweise den Bildnamen ohne `.tex`, `atlasname` den Atlaspfad. Die Property-Callbacks aktualisieren die Replica. Rezept-`image` enthält dagegen das `.tex`-Suffix.

Für Vanilla-Bilder `GetInventoryItemAtlas("spear.tex")` verwenden. Der aktuelle Resolver durchsucht mehrere aufgeteilte Atlanten; alte pauschale Pfade wie `images/inventoryimages.xml` nicht ungeprüft übernehmen.

`finiteuses:SetMaxUses` setzt das Maximum, `SetUses` den aktuellen Stand. `SetConsumption(action, uses)` definiert Action-Verbrauch, `SetOnFinished(inst.Remove)` entfernt ein erschöpftes Item. Waffen können zusätzlich Combat-Verbrauch haben. Dynamisch individuelle Maximalwerte benötigen eine Save-/Load-Prüfung.

Belege: [components/inventoryitem.lua — local function onimagename](<../../_scripts/scripts_02_10_2026/scripts/components/inventoryitem.lua>) (Zeile 5), [simutil.lua — function GetInventoryItemAtlas_Internal](<../../_scripts/scripts_02_10_2026/scripts/simutil.lua>) (Zeile 670), [components/finiteuses.lua — function FiniteUses:SetConsumption](<../../_scripts/scripts_02_10_2026/scripts/components/finiteuses.lua>) (Zeile 27).

## Ausrüstung und Boni

`equippable:SetOnEquip` und `SetOnUnequip` erhalten Item und Träger. Der Speer ersetzt `swap_object`, zeigt `ARM_carry` und versteckt `ARM_normal`; beim Ablegen setzt er die Arme zurück.

Gameplay-Boni benötigen ebenfalls einen Rückbau. Bereits vorhandene Charakterfähigkeiten respektieren. Die Scythe merkt sich ein bestehendes `fastpicker`-Tag; das motiviert einen vorsichtigen Rückbau, modelliert aber mehrere unabhängige Bonusquellen nicht vollständig. Wo Vanilla quellenspezifische Modifier bietet, deren passende Schnittstelle prüfen und verwenden.

Die Lehrvorlage enthält keine eigene Skinintegration. Skins brauchen die entsprechenden Item-/Symbol-Verträge und zulässige Inhalte.

Belege: [prefabs/spear.lua — local function onequip](<../../_scripts/scripts_02_10_2026/scripts/prefabs/spear.lua>) (Zeile 7), [Scythe 733887349/scripts/prefabs/scythe.lua — fastpickerorignal](<../Scythe 733887349/scripts/prefabs/scythe.lua>) (Zeile 16).

## Gebäude und Placer

Ein Gebäude benötigt Darstellung, Netzwerk und passende Tags, häufig `structure`. Abbau, Loot, Brennbarkeit und Container sind separate Mechanismen. Die Truhenfactory zeigt `workable:SetWorkAction(ACTIONS.HAMMER)`, WorkLeft und Hit-/Finish-Callbacks. Ein Finish-Callback muss Inhalte und Loot korrekt behandeln.

Das Rezeptfeld `placer` bezeichnet ein Vorschau-Prefab. `MakePlacer` erzeugt eine nicht persistierende, nicht normal vernetzte Vorschau mit eigener Placer-Component. Bank, Build, Animation, Abstand und Placement-Tests müssen zum Gebäude passen. Besondere Abstandsregeln benötigen zusätzlich den aktuellen Builder-Audit.

Belege: [prefabutil.lua — function MakePlacer](<../../_scripts/scripts_02_10_2026/scripts/prefabutil.lua>) (Zeile 1), [prefabs/treasurechest.lua — inst.components.workable:SetWorkAction](<../../_scripts/scripts_02_10_2026/scripts/prefabs/treasurechest.lua>) (Zeile 162).

## Container-Layout auf beiden Seiten

`containers.params` hält Layout und Auswahlregeln; `containers.widgetsetup` überträgt sie auf Component beziehungsweise Replica. Server-`container:WidgetSetup` ruft auch die Replica-Methode auf. Auf Clients liest der Replica-Konstruktor die Parametertabelle.

Ein eigenes Layout im gemeinsam ausgeführten Mod-Code registrieren:

    local containers = GLOBAL.require("containers")
    containers.params.my_mod_chest = GLOBAL.deepcopy(containers.params.treasurechest)

Im eigenen Server-Prefab anschließend `inst.components.container:WidgetSetup("my_mod_chest")`. Weicht der Prefab-Name vom Parameternamen ab, muss auch die Client-Seite den passenden Schlüssel erhalten. Gemeinsam verwendete `itemtestfn`-Callbacks benötigen Client-verfügbare Tags/Replicas.

Slotpositionen, Slotanzahl, UI-Bank/Build und Öffnungsregeln abstimmen. `Container:SetNumSlots` enthält aktuell eine Nicht-Verkleinerungsprüfung. Layoutänderungen nach Befüllung benötigen daher Migrationen. Bei ungewöhnlich großen Layouts zusätzlich den Slotaufbau des Classified auditieren; keine beliebige Slotzahl voraussetzen.

Belege: [containers.lua — function containers.widgetsetup](<../../_scripts/scripts_02_10_2026/scripts/containers.lua>) (Zeile 9), [components/container.lua — function Container:WidgetSetup](<../../_scripts/scripts_02_10_2026/scripts/components/container.lua>) (Zeile 86), [components/container.lua — function Container:SetNumSlots](<../../_scripts/scripts_02_10_2026/scripts/components/container.lua>) (Zeile 115), [components/container_replica.lua — containers.widgetsetup(self)](<../../_scripts/scripts_02_10_2026/scripts/components/container_replica.lua>) (Zeile 47), [Trash Can 1879090052/modmain.lua — containers.params.trashcan =](<../Trash Can 1879090052/modmain.lua>) (Zeile 54).

## Suchregister für weitere Items

| Funktion | Einstieg für den nächsten Feature-Audit |
|---|---|
| Stack | components/stackable.lua und Ressourcenprefab |
| Essen/Verderb | edible.lua, perishable.lua und Speisenprefab |
| Brennstoff/Licht | fueled.lua und torch-Prefab |
| Werkzeug | tool.lua, finiteuses.lua und axe/pickaxe |
| Rüstung | armor.lua und equippable.lua |
| Deployment | deployable.lua und prefabutil.lua |
| Abbau | workable.lua, Actions und Stategraph |

Das Register nennt Suchstellen, keine pauschal auditierte Implementierung für sämtliche Varianten.


## Vertiefung mit Workspace-Beispielen

Die dazugehörigen konkreten Abläufe, Daten-/Cleanupentscheidungen und Altlasten sind im [Praxismechanismen-Kapitel](23_Praxismechanismen.md) erklärt. Über die [Abdeckungsmatrix](21_Abdeckungsmatrix.md) zu passenden Fallstudien und eigenständigen Vorlagen navigieren; Grenzen komplexer Systeme stehen ausdrücklich dort.
