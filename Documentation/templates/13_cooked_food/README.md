# 13 — Eigene gekochte Speise

Eigenständige Gameplay-Mod mit gemeinsamem Rezeptmodul, eigenem Ergebnis-Prefab und Vanilla-Grafik. Vier rohe/gekochte Karotten ergeben doc_carrot_stew. Regulärer Kochtopf, tragbarer Kochtopf und Archivkochtopf werden separat registriert. Keine eigene Zutat, Kochstation oder Gewürzvariante wird eingeführt. Die Speise wird deshalb im gemeinsamen Filter der Gewürzstation gezielt abgelehnt.

## Einbau und Voraussetzungen

1. Diesen ganzen Ordner in einen neuen Modordner kopieren; alle beteiligten Instanzen benötigen die Mod. Präfix und Prefabnamen überall konsistent ändern.
2. README und [vollständigen Kochablauf](../../28_Kochinhalte.md) lesen; den dortigen Audit im aktuellen Spielstand nachvollziehen.
3. modmain registriert PrefabFiles und die drei Kocher. scripts/doc_stew_recipe.lua läuft über GLOBAL.require in der gewöhnlichen Scriptumgebung; das Ergebnis-Prefab verwendet dasselbe Modul. Kein unqualifiziertes FOODTYPE/TUNING im modmain.
4. Der Archivkochtopf ist nicht überall regulär verfügbar. Nur seine passende Registry wird ergänzt; keine Zugangsregeln oder Weltgenerierung ändern.

## Daten- und Grafikvertrag

priority=30 schlägt im untersuchten Vanilla-Stand die passende Ratatouille-Auswahl; andere Mods können gleich- oder höherrangige Rezepte hinzufügen. weight=1 ist ausdrücklich positiv. Der Test erwartet die von cooking gebildete names-Tabelle, keine Entityliste. Er verändert weder Namen noch Tags. AddIngredientValues ist für bereits vorhandene Karotten unnötig.

Das neue Prefab ist keine automatisch erzeugte preparedfoods-Instanz. Grafikvertrag: anim/cook_pot_food.zip; Bank/Build cook_pot_food; idle; Bodensymbol swap_food→ratatouille. Das Kochtopfsymbol wird unabhängig davon über overridebuild/overridesymbolname gewählt. Inventar und Cookbook verwenden ratatouille.tex und dessen nachgewiesenen Inventaratlas. Nährwerte sind Demonstrationswerte, kein Balancingvorschlag.

Vanilla-Components speichern Inventar-/Stapel-/Verderbsdaten. Stewer speichert laufendes Produkt, Zutaten, Kochenden und Restzeit selbst. Die Mod setzt diese Felder nach Laden nicht zurück. Cookbook-Einträge liegen in der Modkategorie; der registrierte Atlas ist ein vorhandenes Inventarbild, kein neu exportiertes hochauflösendes Portrait.

## Grenze zur Gewürzstation

Vanilla akzeptiert preparedfood auch ohne produktspezifisches Gewürzrezept. spicedfoods erzeugt Varianten nur aus den Vanilla-Speisetabellen; das neue AddCookerRecipe-Produkt gehört nicht automatisch dazu. Der Fallback für wetgoop-Spices kann stattdessen auswählen und die Speise verbrauchen. Daher umschließt modmain ausschließlich portablespicer.itemtestfn: doc_carrot_stew wird abgelehnt; andere Items gehen unverändert an die vorherige Funktion. Server und Client erhalten denselben Filter vor Containerkonstruktion. Die Vorlage behauptet keine Gewürzunterstützung.

Für echte Gewürzvarianten sind eigene Rezept-/Produkt-/Buff-/Grafik-/Frischepfade erforderlich. Einen bereits gefüllten gespeicherten Topf oder Fremdmods, die den Filter ersetzen, deckt der Eingabefilter allein nicht ab; diese Fälle bleiben Projekt-Audit und Spieltest.

## Quellenkette

[modutil.lua — env.AddCookerRecipe](<../../../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) → [cooking.lua — local function CalculateRecipe](<../../../../_scripts/scripts_02_10_2026/scripts/cooking.lua>) → [components/stewer.lua — function Stewer:StartCooking](<../../../../_scripts/scripts_02_10_2026/scripts/components/stewer.lua>) → [prefabs/cookpot.lua — local function SetProductSymbol](<../../../../_scripts/scripts_02_10_2026/scripts/prefabs/cookpot.lua>). Produktkonstruktion: [prefabs/preparedfoods.lua — local function MakePreparedFood](<../../../../_scripts/scripts_02_10_2026/scripts/prefabs/preparedfoods.lua>); Verderb: [components/perishable.lua — function Perishable:OnLoad](<../../../../_scripts/scripts_02_10_2026/scripts/components/perishable.lua>).

## Konkrete Tests — Spieltests nicht durchgeführt

| Test | Erwartung |
|---|---|
| Isolierte Logik | Vier Karotten in jeder Roh/Gekocht-Verteilung akzeptiert; drei, fünf oder Fremdzutaten abgelehnt; Rezeptdaten konsistent |
| Host + separater Client | Beide sehen dieselbe Speise im Topf, auf dem Boden, im Inventar; Zutaten verschwinden einmal |
| Dedicated | Gleiche Resultate ohne HUD auf dem Server; Client kann Kochen und Ernten |
| Alle drei Kocher | Rezept korrekt vorhanden; Anforderungen des tragbaren Kochers bleiben bestehen |
| Grenzzutaten/Konfliktmod | Drei Karotten plus Beere ergeben kein doc_carrot_stew; höhere/equal Priority dokumentieren |
| Save/Load laufend/fertig/verdorben | Kochrestzeit, verschlossener Topf, Produktgrafik und Verderb korrekt fortgesetzt |
| Alte Zutaten | Fertige Speise übernimmt die Stewer-Frischeberechnung; kein Frischsetzen bei Ernte oder Load |
| Gewürzstation | Neue Speise in Slot 1 abgelehnt; Vanilla-Speise/Gewürzfilter unverändert; Host/Client gleich |
| Stack/Lager/Wasser/Feuer | Bild, Stapel, verderbliche Lagerung, Float und Verbrennen prüfen |
| Hammer während/nach Kochen | Laufende Zutaten werden nicht wieder erzeugt; fertiges Produkt gemäß Vanilla geerntet |
| Cookbook | Derselbe Kochende erntet und lernt; anderer Spieler erntet: keine falsche Chefzuordnung; Essen lernt Speisenwerte |
| Reconnect/Höhlenwechsel | Inventarprodukt und Frische bleiben erhalten; keine neuen Startitems |

Gewürzvarianten, neue Kochstationen, eigene Audio-/Grafikexports und Enginevalidierung sind nicht Teil dieser Vorlage. Syntaxerfolg und reine Tests sind keine Ingamefreigabe.
