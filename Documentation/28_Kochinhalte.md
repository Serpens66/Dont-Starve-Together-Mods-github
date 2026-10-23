# 28 — Kochinhalte vom Rezept bis zur Wiederherstellung

Geprüft am 03.10.2026 gegen den vollständig identischen Snapshot scripts_02_10_2026. Dies ist eine Ablaufbeschreibung für reguläre Crockpot-Speisen, keine Freigabe von Engineverhalten. Einstieg: [Grundlagen](07_Crafting_Kochen.md), [Vorlage 13](templates/13_cooked_food/README.md), [Ernährung](23_Praxismechanismen.md).

## Drei unabhängige Registrierungen

Ein Crafting-Rezept, ein Crockpot-Rezept und ein Produkt-Prefab sind unterschiedliche Verträge. AddCookerRecipe legt einen Eintrag in cooking.recipes[cooker][recipe.name] an und führt den Namen in der Modumgebung. Es erzeugt kein Prefab und fügt die Daten nicht automatisch in preparedfoods ein. PrefabFiles lädt das eigene Produkt separat. Nährwerte im Rezept ersetzen keine edible-Component am Ergebnis.

Der Wrapper in [modutil.lua](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) ruft die globale AddCookerRecipe-Funktion mit is_mod_food=true auf. Diese setzt cookbook_category="mod". Den Wrapper nicht zur Umgehung der Modkategorie durch eine direkte Vanilla-Registrierung ersetzen. [cooking.lua](<../../_scripts/scripts_02_10_2026/scripts/cooking.lua>): AddCookerRecipe, IsModCookingProduct; [prefabs/preparedfoods.lua](<../../_scripts/scripts_02_10_2026/scripts/prefabs/preparedfoods.lua>): MakePreparedFood und die Schleifen über die drei Vanilla-Datentabellen.

cookpot, portablecookpot und archive_cookpot haben getrennte Rezeptregistries. Warly-Rezepte sind zusätzlich ein eigener Datenbestand für portablecookpot. portablespicer ist eine andere Verarbeitungskette; die allgemeine Speisenvorlage unterstützt keine automatischen Gewürzvarianten. Ein anderer Kochername bekommt durch AddCookerRecipe allein weder Container noch Fallbackrezept, Action oder Darstellung.

## Zutaten und Auswahl

AddIngredientValues(names, tags, cancook, candry) ersetzt für jeden Namen die bisherige tags-Tabelle. Es führt vorhandene Kategorien nicht zusammen. Bei bestehenden Zutaten deshalb zuerst alle Verbraucher prüfen; ein vermeintliches Zusatz-Tag kann deren meat/monster/veggie-Werte entfernen. cancook und candry erzeugen Namen mit _cooked beziehungsweise _dried; cooking normalisiert außerdem bestimmte historische Namen. Diese Kategorien sind numerische Kochdaten, keine Entity-Tags.

GetIngredientValues zählt normalisierte Namen und summiert Kategorien. Jeder Rezepttest erhält test(cooker, names, tags); die Zutateninstanzen werden nicht übergeben. GetCandidateRecipes prüft alle Tests und behält nur die höchste Priority. CalculateRecipe wählt daraus gewichtet. Obwohl Sortierung und Summierung weight or 1 verwenden, subtrahiert die anschließende Auswahl candidates[idx].weight direkt. Für eigene Rezepte ausdrücklich ein endliches positives weight setzen. Der Default in zwei vorherigen Zeilen ist kein durchgehender Fallbackvertrag.

Fehlt jeder Kandidat, liefert CalculateRecipe kein Produkt; StartCooking greift danach auf den gefundenen Rezeptdatensatz zu. Eigene Kochstationen benötigen daher eine vollständig geprüfte Auswahl samt Fallback. Bei gleichrangigen Fremdmodrezepten ist das Ergebnis gewichtetes Verhalten, keine verlässliche Ladereihenfolge. Vorlage 13 beschränkt den Test auf vier Karotten und hat explizite Priority/Weight. Keine Vanilla-Kategorien werden geändert.

### Speise ohne Gewürzvarianten

[spicedfoods.lua](<../../_scripts/scripts_02_10_2026/scripts/spicedfoods.lua>) erzeugt Varianten aus preparedfoods und preparedfoods_warly. AddCookerRecipe allein erweitert diese Tabellen nicht. Gleichzeitig akzeptiert params.portablespicer.itemtestfn jedes ungewürzte preparedfood. Das Fallbackrezept für wetgoop-Spice prüft nur das Gewürz und kann deshalb statt eines fehlenden modproduktspezifischen Rezepts gewählt werden. „Keine Gewürzvariante implementiert“ genügt als Voraussetzung nicht, um diese Eingabe auszuschließen.

Vorlage 13 lehnt daher genau ihre eigene Speise im gemeinsamen Itemfilter ab und delegiert alle anderen Fälle an die vorherige Funktion. containers.widgetsetup übernimmt den Filter; Container und ContainerReplica rufen ihn aus CanTakeItemInSlot auf. [prefabs/portablespicer.lua](<../../_scripts/scripts_02_10_2026/scripts/prefabs/portablespicer.lua>) verwendet Stewer mit keepspoilage=true. Bereits gespeicherte Fremdinhalte, Filterersetzung durch andere Mods und echte neue Gewürzvarianten benötigen einen weiteren eigenen Audit.

## Vom Clientknopf zur Serverwirkung

[containers.lua](<../../_scripts/scripts_02_10_2026/scripts/containers.lua>): params.cookpot akzeptiert IsCookingIngredient, keine Stapel als Mehrfachzutaten. Der Button prüft die Replica auf vollständige Slots. Auf dem Server führt er BufferedAction(..., ACTIONS.COOK):Do() aus; auf dem Client sendet er DoWidgetButtonAction.

[networkclientrpc.lua](<../../_scripts/scripts_02_10_2026/scripts/networkclientrpc.lua>): Der Handler kontrolliert Spielercontroller, Busy-Zustand, geöffneten Container und dessen tatsächliche buttoninfo/validfn. Er nimmt nicht beliebige Client-Buttonfunktionen entgegen. [actions.lua](<../../_scripts/scripts_02_10_2026/scripts/actions.lua>): ACTIONS.COOK.fn prüft Stewer-Zustand und andere Containerbenutzer und startet erst dann StartCooking. [componentactions.lua](<../../_scripts/scripts_02_10_2026/scripts/componentactions.lua>): Der stewer-Zweig bietet abhängig von Tags/Öffnung COOK oder HARVEST an. Die UI ist kein Ersatz für Serverprüfung.

## Kochen, Frische und Darstellung

[components/stewer.lua](<../../_scripts/scripts_02_10_2026/scripts/components/stewer.lua>): StartCooking merkt sich chef_id und ingredient_prefabs, wählt Produkt und Kochzeit, berechnet Frische aus verderblichen Zutaten, schließt den Container, zerstört dessen Inhalte und verhindert erneutes Öffnen. cooktime skaliert BASE_COOK_TIME und cooktimemult. Die verzögerte dostew-Funktion meldet Abschluss, bestimmt cookpot_perishtime oder perishtime und startet gegebenenfalls den Verderbstask. done wird gesetzt; dospoil ruft den Prefab-Callback auf, der beim Vanilla-Topf das Produkt in spoiled_food ändert.

Bodenprodukt und Topfinhalt haben getrennte Grafiken. [prefabs/cookpot.lua](<../../_scripts/scripts_02_10_2026/scripts/prefabs/cookpot.lua>): SetProductSymbol verwendet potlevel, overridebuild und overridesymbolname. Bei einer Modspeise ohne overridebuild kann ShowProduct auf den Produktnamen als Build zurückfallen. Deshalb beim neuen Produkt mit wiederverwendeter Grafik beide Overrides ausdrücklich setzen. [prefabs/preparedfoods.lua](<../../_scripts/scripts_02_10_2026/scripts/prefabs/preparedfoods.lua>): Das Bodenobjekt verwendet Bank cook_pot_food, idle und swap_food; Inventoryimage/Atlas werden separat gewählt.

Harvest erzeugt das Produkt erst bei Ernte. Ein eventueller stacksize-Wert setzt stackable voraus. Die Frische wird aus product_spoilage und verbleibender Topfverderbzeit auf perishable übertragen. Danach gehen Produkt/Task/Restzeit/Frische zurück auf den leeren Zustand und der Container wird wieder geöffnet. Das Ergebnis nicht zusätzlich in einem onharvest-Callback spawnen. Eater verarbeitet foodtype und vorbereitete Speise; individuelle Diäten, Foodmemory und Spoilage können die Basisspeisenwerte verändern.

## Speichern, LongUpdate und Abbau

Stewer:OnSave speichert Produkt, done, Frische, Verderbsspanne, Chef, Zutaten und verbleibende Zeit; keine Taskobjekte. OnLoad rekonstruiert den passenden Koch-/Verderbstask und ruft oncontinuecooking beziehungsweise oncontinuedone für Bild, Licht und Sound auf. Auch ein am Speicherzeitpunkt abgelaufener Task hat einen eigenen Nachholpfad. LongUpdate kann zuerst Kochen abschließen und danach die überschüssige Zeit auf den fertigen Inhalt anwenden.

Das Produkt-Prefab übernimmt perishable-, stackable- und inventoryitem-Persistenz. Perishable:OnLoad stellt Restzeit und Pausenzustand wieder her. Eine Mod darf ihre Defaults im Konstruktor setzen, aber nicht nach jedem Load das geladene Essen auf volle Frische setzen.

Beim Hammern erntet der Vanilla-Topf fertigen, nicht verbrannten Inhalt, droppt noch vorhandene Containeritems und entfernt sich. Laufende Zutaten wurden bereits verbraucht. Verbrennen und die im Quellcode auskommentierte frühere Haunt-Verwandlung nicht als aktive gleiche Mechanik behandeln. Entityentfernung beendet Tasks; isoliertes Entfernen einer Stewer-Component ist ein anderer Cleanupvertrag.

## Cookbook und konkrete Fehlerfälle

Harvest sendet learncookbookrecipe nur bei passender Chef-ID und registriertem Cookbook-Eintrag. [components/cookbookupdater.lua](<../../_scripts/scripts_02_10_2026/scripts/components/cookbookupdater.lua>) aktualisiert Daten und informiert erforderlichenfalls den zuständigen Client. [widgets/redux/cookbookpage_crockpot.lua](<../../_scripts/scripts_02_10_2026/scripts/widgets/redux/cookbookpage_crockpot.lua>): cookbook_tex/cookbook_atlas übersteuern das ansonsten vom Produktnamen abgeleitete Bild. Ein fremder Spieler kann ernten, ohne dadurch automatisch der gespeicherte Kochende zu werden.

| Symptom | Zuerst prüfen |
|---|---|
| Neues Rezept kocht Vanilla-Gericht | Kocherregistry, Testzählung, Priority, konkurrierende Mod |
| Produkt fehlt bei Ernte | PrefabFiles/Name/Abhängigkeit; Rezeptregistrierung erzeugt kein Produkt |
| Topf zeigt unsichtbares Essen | Produktname gegenüber overridesymbolname und overridebuild |
| Inventarbild geht, Cookbook fehlt | Separate cookbook_tex/Atlas und Lernvoraussetzung |
| Nach Neustart falsche Frische | Constructor versus OnLoad; eigener Reset; gespeicherte Produktdaten |
| Nur Client knallt/Knopf tut nichts | gemeinsame Registrierung, Replica, Controller/OpenBy-Validierung |

Die [Vorlagentests](templates/13_cooked_food/README.md) nennen Host, Client, Dedicated, konkurrierende Rezepte, Save/Load, Reconnect und Shardwechsel ausdrücklich als offene Spieltests.
