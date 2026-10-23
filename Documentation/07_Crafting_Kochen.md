# 07 — Crafting und Kochen

## Neue Crafting-Rezepte

`AddRecipe2(name, ingredients, tech, config, filters)` ist die aktuelle Mod-Schnittstelle. Zutaten sind Ingredient-Objekte, `tech` eine TECH-Tabelle, `config` eine optionale Tabelle und `filters` eine Liste von Filternamen.

    AddRecipe2("my_mod_spear",
        { GLOBAL.Ingredient("twigs", 2), GLOBAL.Ingredient("flint", 1) },
        GLOBAL.TECH.NONE,
        { image = "spear.tex", atlas = GLOBAL.GetInventoryItemAtlas("spear.tex") },
        { "WEAPONS" })

Ohne anderes `product` stimmen Rezept- und Produktname überein. Verschiedene Rezepte für dasselbe Produkt benötigen verschiedene Rezeptnamen. Das neue Produkt-Prefab muss unabhängig davon über `PrefabFiles` registriert sein.

Belege: [modutil.lua — env.AddRecipe2](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 732), [recipe.lua — Recipe2 = Class](<../../_scripts/scripts_02_10_2026/scripts/recipe.lua>) (Zeile 229), [recipes.lua — Recipe2("spear"](<../../_scripts/scripts_02_10_2026/scripts/recipes.lua>) (Zeile 478).

## Wichtige Konfiguration

| Feld | Funktion |
|---|---|
| product | Abweichendes Ergebnis-Prefab |
| numtogive | Anzahl Ergebnisse |
| atlas / image | Rezeptbild, image mit .tex |
| placer | Platzierungsvorschau für Gebäude |
| min_spacing | Gebäudeabstand |
| builder_tag / builder_skill | Charakter-/Skill-Voraussetzung |
| nounlock | Stationgebundene Herstellung |
| testfn | Zusätzliche Platzierungsprüfung |
| build_mode / build_distance | Besondere Platzierungsregeln |

`Recipe2` reicht die Konfiguration an `Recipe` weiter. Für zusätzliche Felder Konstruktor und zuständige Verbraucher lesen; eine gefundene Feldbezeichnung allein legt den Callback-Vertrag nicht fest.

Beleg: [recipe.lua — Recipe = Class](<../../_scripts/scripts_02_10_2026/scripts/recipe.lua>) (Zeile 67).

## Filter und bestehende Rezepte

Reguläre AddRecipe2-Rezepte landen automatisch im MODS-Filter. Der aktuelle Wrapper wählt bei `config.nounlock` stattdessen CRAFTING_STATION. Weitere Filter über den letzten Parameter oder `AddRecipeToFilter` ergänzen.

Eigene Filter zuerst mit `AddRecipeFilter` erstellen. `filter_def.recipes` ist laut API-Kommentar kein unterstützter Registrierungsweg. `AddCharacterRecipe` benutzt CHARACTER bei `builder_tag` oder `builder_skill`, sonst MODS. `AddRecipePostInit` bearbeitet auch bereits vorhandene Rezepte direkt.

Belege: [modutil.lua — config.nounlock](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 739), [modutil.lua — filter_def.recipes](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 680), [modutil.lua — env.AddCharacterRecipe](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 758), [modutil.lua — env.AddRecipePostInit](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 602).

## Historische Schnittstellen und Internetbeispiele

Der aktuelle Mod-Wrapper warnt bei AddRecipe, Recipe und AddRecipeTab. Scythe, Trash Can und Skins Project nutzen ältere Rezepte; deren Aufbau nicht für neue Mods übernehmen.

Der [Beitrag zur neuen Rezept-API](https://kleiforums.com/forums/topic/140881-documentation-new-recipe-system-functions-other-info/) erklärt AddRecipe2 und Filter. Seine allgemeine Aussage zur automatischen MODS-Zuordnung muss mit dem heutigen nounlock-Zweig abgeglichen werden. Ein [weiteres Tutorial](https://kleiforums.com/forums/topic/147251-tutorialcomplete-tutorial-for-dsts-new-craft-menu/) bezeichnet tech in einer Parameterliste als String; maßgeblich sind die Vanilla-TECH-Tabellen.

## Crockpot-Rezepte sind separat

`AddCookerRecipe(cooker, recipe)` registriert Kochrezepte, beispielsweise für cookpot und zusätzlich portablecookpot. Das sind getrennte Registrierungen. `AddIngredientValues(names, tags, cancook, candry)` definiert numerische Kochkategorien; diese sind keine Entity-Tags.

Ein Kochrezept enthält name, test(cooker, names, tags), priority, weight und cooktime sowie passende weitere Speisendaten. Grafik, Nährwerte und Verderb des Ergebnis-Prefabs müssen ebenfalls existieren. Vor Implementation ein passendes preparedfoods-Rezept und sein Prefab verfolgen.

Die geprüfte Auswahlkette: Stewer sammelt Zutaten-Prefabnamen, Cooking bildet Namenmengen und Tags, alle Tests laufen, höchste Priority gewinnt, bei Gleichstand entscheidet Weight. Stewer setzt Produkt und Zeit, schließt den Container und entfernt Zutaten.

Tests dürfen nicht nachträglich auf Instanzen bereits verarbeiteter Zutaten zugreifen. Names zählt genaue Prefabs, tags Kategorien. Überlappende gleichrangige Rezepte können sich mit anderen Mods beeinflussen.

Belege: [modutil.lua — env.AddCookerRecipe](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 643), [cooking.lua — local function GetIngredientValues](<../../_scripts/scripts_02_10_2026/scripts/cooking.lua>) (Zeile 217), [cooking.lua — function GetCandidateRecipes](<../../_scripts/scripts_02_10_2026/scripts/cooking.lua>) (Zeile 238), [cooking.lua — local function CalculateRecipe](<../../_scripts/scripts_02_10_2026/scripts/cooking.lua>) (Zeile 268), [components/stewer.lua — function Stewer:StartCooking](<../../_scripts/scripts_02_10_2026/scripts/components/stewer.lua>) (Zeile 130).

## Prüffälle

Mit echten Zutaten und ohne Freecrafting herstellen; Tech-Sperren, Suche, Filter und Inventarbild prüfen. Gebäude platzieren und abbrechen. Kochrezepte mit Grenzzutaten, konkurrierenden Rezepten und allen vorgesehenen Kochern testen. Ein laufendes Rezept speichern und nach Neustart fortsetzen.


## Vertiefung mit Workspace-Beispielen

Die dazugehörigen konkreten Abläufe, Daten-/Cleanupentscheidungen und Altlasten sind im [Praxismechanismen-Kapitel](23_Praxismechanismen.md) erklärt. Über die [Abdeckungsmatrix](21_Abdeckungsmatrix.md) zu passenden Fallstudien und eigenständigen Vorlagen navigieren; Grenzen komplexer Systeme stehen ausdrücklich dort.

## Vollständiger Kochablauf und neues Beispiel

[Kochinhalte](28_Kochinhalte.md) verfolgt getrennte Registrierungen, Zutatenersatz, Priorität/Weight, validierten Buttonpfad, Produktgrafik, Chef/Cookbook, Frische, Save/Load, LongUpdate und Hammer. [Vorlage 13](templates/13_cooked_food/README.md) verbindet diesen Pfad mit einem eigenen Produkt-Prefab und vorhandenen Assets.
