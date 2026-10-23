# Skins Project und Skins – historisches Aussehens-API

**Prüfart:** statische Ablaufanalyse; Architektur und wesentliche Pfade beschrieben; offene Spezialverträge unten. Keine Ingame-Funktionszusage. Alle Verzeichnisse: `Skins Project (API) 733788733`, `Skins 733791077`.

## Einstieg und Abhängigkeiten

[Skins Project (API) 733788733/modmain.lua — SkinsProject.AddSkin](<../../Skins Project (API) 733788733/modmain.lua>) (Zeile 24) exportiert CharacterList/AddSkin in GLOBAL, registriert Legacyrecipetab und kostenfreie Switchrezepte. Skins-Erweiterung prüft rawget(GLOBAL,"SkinsProject") und registriert seine Varianten. Das prüft Präsenz, installiert aber weder Abhängigkeit noch richtige Ladeordnung.

## Initialisierung, Interaktion und Serverwirkung

AddSkin fügt CharacterList-Eintrag hinzu, erzeugt Rezept und Texte. Beim Laden generic_switch werden für jeden registrierten Charakter Switchprefabs und Bild-/eventuell Buildassets erzeugt. OnBuiltFn verwendet SetSkinsOnAnim am Builder und entfernt das temporäre Switchobjekt. Das verändert Darstellung, nicht automatisch den Characterprefab, Fähigkeiten oder den vollständigen Skinnerzustand.

## Replikation, UI, Speicherung und Wiederherstellung

[Skins Project (API) 733788733/scripts/prefabs/generic_switch.lua — SetSkinsOnAnim](<../../Skins Project (API) 733788733/scripts/prefabs/generic_switch.lua>) (Zeile 18) nimmt aktuelle Clothingdaten aus skinner, aber die direkte Animänderung ist kein eigener OnSave/OnLoad-Vertrag. Switch ist CLASSIFIED, persists=false und entfernt sich nach Task0. Keine eigene Replica oder Besitzer-Netnachricht: Sichtbarkeit für andere Clients sowie Save/Rejoinreset müssen explizit getestet werden. CharacterList ist Registrierungszustand beim Modladen, kein Worldsave.

## Cleanup und Lebensdauer

Switchcleanup ist sofortig. Skinwechsel darf Ausrüstungs-Overrides, Ghostbuild, Clothing und nächste Animstate-Neuinitialisierung nicht inkonsistent hinterlassen. Doppelte AddSkin-Aufrufe erzeugen doppelte Registrierungen; Namespacing/Idempotenz ergänzen, wenn das API weiterentwickelt wird.

## Aktuelle Vanilla-Kette

[components/skinner.lua — SetSkinsOnAnim](<../../../_scripts/scripts_02_10_2026/scripts/components/skinner.lua>) (Zeile 11) → [components/skinner.lua — OnSave](<../../../_scripts/scripts_02_10_2026/scripts/components/skinner.lua>) (Zeile 803) / [components/skinner.lua — OnLoad](<../../../_scripts/scripts_02_10_2026/scripts/components/skinner.lua>) (Zeile 814) → [prefabs/player_common.lua — skinner](<../../../_scripts/scripts_02_10_2026/scripts/prefabs/player_common.lua>) (Zeile 1830); [components/builder.lua — prod:OnBuilt(self.inst)](<../../../_scripts/scripts_02_10_2026/scripts/components/builder.lua>) (Zeile 791). Aktuelle Inventarskin-/Berechtigungswege sind zusätzliche Engine-/Backendverträge, die dieses historische API nicht implementiert.

## Altlasten und konkrete Prüfgrenze

**Vorhanden:** Registrierung, Recipes, Switchprefabs, Animbuild-Anwendung. **Historisch:** altes recipetab und Anim-only-Charakterwechsel. **Nicht belegt/fehlend:** dauerhaft gespeicherter neuer Appearancezustand, durchgängiger Multiplayer-/Ghost-/Reconnectpfad und modernes Workshop-/Inventarskin-API. Kein Freischalten kostenpflichtiger Skins aus dieser Mod ableiten; eigene Assets oder erlaubte Vanillaressourcen nutzen. Eine neue kosmetische Mod muss einen konkreten replizierbaren Skinner/Buildvertrag wählen.

## Szenarien für die spätere Laufzeitabnahme

API allein, Erweiterung allein und beide Ladeordnungen; Switch bauen, Ausrüstung wechseln, Ghost/Respawn, andere Clients beobachten. Save/Load, Reconnect und Höhlenwechsel: gewünschtes Appearance bleibt oder wird bewusst zurückgesetzt. Fehlendes Atlas-/Ghostbuild diagnostizieren.

Alle Szenarien sind **offen**. Für Dedicated-Server, separaten Client, Reconnect und Shardwechsel gelten zusätzlich die [allgemeinen Checklisten](../19_Checklisten.md). Statische Symbol-/Hashprüfung ersetzt diese Abnahme nicht. [Katalog](../16_Workspace_Mods.md) · [Abdeckungsmatrix](../21_Abdeckungsmatrix.md) · [Projektworkflow](../20_Projektworkflow.md).


## Dateiregister: Skins Project (API) 733788733

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [modinfo.lua](<../../Skins Project (API) 733788733/modinfo.lua>)
- [modmain.lua](<../../Skins Project (API) 733788733/modmain.lua>)
- [scripts/prefabs/generic_switch.lua](<../../Skins Project (API) 733788733/scripts/prefabs/generic_switch.lua>)


## Dateiregister: Skins 733791077

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [modinfo.lua](<../../Skins 733791077/modinfo.lua>)
- [modmain.lua](<../../Skins 733791077/modmain.lua>)


## Erneute Prüfung: historische Appearance-API und heutiger Skinner

[`Skins Project (API) 733788733/modmain.lua`](<../../Skins Project (API) 733788733/modmain.lua>) installiert Characterliste/AddSkin; [`Skins 733791077/modmain.lua`](<../../Skins 733791077/modmain.lua>) registriert nur bei vorhandener API. API muss vor Contentregistrierung bereitstehen; stille Abwesenheit ist keine erfolgreiche Registrierung. Generic-Switch bildet seine Prefabliste aus dem beim Prefabfileladen bekannten Registryinhalt.

Der kurzlebige CLASSIFIED-Switch ruft im Buildcallback SetSkinsOnAnim am Builder auf und entfernt sich. Das ändert keine Charactercomponents oder Prefabidentität. Der historische sechste Parameter ist ein Charaktername; das heutige [`components/skinner.lua`](<../../../_scripts/scripts_02_10_2026/scripts/components/skinner.lua>) erwartet dort skintype und ggf. siebtes default_build. Kleidung hängt an erkannten Skintypes; ein vorhandener Characterbuild ist kein vollständiger heutiger Skin.

Skinner verwaltet Skinname/Clothing/Skinmode/Beard/Monkeycurse und Savedaten. SetSkinName liest Prefabskindaten, SetSkinMode leitet AnimState ab, OnLoad prüft Ownership. Direkter AnimStatewechsel ohne Skinnerzustand ist nicht automatisch persistent; Equip/Form/Ghost/Load können ihn überschreiben. Die alte Mod erzeugt keine Backendberechtigung.

Eigene Kosmetik muss Scope (lokal/repliziert), Basissymbole/Clothing, persistente Moddaten, Wiederanwendung und Sonderformen definieren. Ownership-/Backendinternals sind kein frei rekonstruierter Lua-Vertrag. Offen: deaktivierte API, Ladepriorität, late join, Kleidung, Ghost/Transformation und Reconnect. Diese Architektur ist ein historischer Appearance-Switch, kein universelles aktuelles Skinsystem.


Konkrete zusätzliche Funktionsdefinitionen: [Vertragsbelege](../27_Vertragsbelege.md). Die [Reviewmatrix](../REVIEW_MATRIX.json) trennt Einstiegssichtung und ausgewählte vertiefte Abläufe; weitere Featureänderungen benötigen einen eigenen aktuellen Audit.
