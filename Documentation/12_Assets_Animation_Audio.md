# 12 — Assets, Animation und Audio

## Dateiformate und Registrierung

| Inhalt | Typischer Runtime-Inhalt |
|---|---|
| Inventar-/UI-Bild | .tex plus XML-Atlas |
| Animation | anim/*.zip mit kompiliertem Build und Animationen |
| Quellgrafik | PNG beziehungsweise Animationsprojekt im Quellbereich |
| Sounds | Kompilierte Soundbank und Eventnamen |
| Layout | Aus Tiled exportierte Lua-Daten |

Asset("ANIM", path), Asset("ATLAS", path) und Asset("IMAGE", path) deklarieren die jeweils benötigten Ressourcen. Mod-Assets und Prefab-Assets werden vom Loader registriert; lokale Tabellen mit beliebigem Namen werden nicht automatisch zu Mod.Assets. Vanilla-Assets müssen nicht ins Repository kopiert werden, wenn die geprüfte Runtime sie bereitstellt.

Belege: [mods.lua — function ModWrangler:RegisterPrefabs](<../../_scripts/scripts_02_10_2026/scripts/mods.lua>) (Zeile 677), [mainfunctions.lua — resolvefilepath(asset.file](<../../_scripts/scripts_02_10_2026/scripts/mainfunctions.lua>) (Zeile 121), [prefabs/spear.lua — local assets =](<../../_scripts/scripts_02_10_2026/scripts/prefabs/spear.lua>) (Zeile 1).

## PNG, TEX und Atlas

Eine XML-Region muss zum angeforderten Bildnamen passen; ein vorhandener TEX-Pfad allein reicht nicht. Inventarname, Rezeptbild, Atlasregion und Registrierungen konsistent halten. GetInventoryItemAtlas kann für aktuelle Vanilla-Bilder den richtigen aufgeteilten Atlas ermitteln. Eigene Bilder bei Bedarf über RegisterInventoryItemAtlas registrieren und Assets bereitstellen.

Fehler wie fehlende Atlasregionen oder falsche Extensions zuerst am Consumer und der XML prüfen. Trash Can enthält beispielsweise eine lokale, nicht als Assets exportierte Tabelle und den verdächtigen IMAGE-Pfad trashcantex; das ist ein dokumentierter Wartungshinweis, kein getesteter Crashbefund.

Belege: [simutil.lua — function RegisterInventoryItemAtlas](<../../_scripts/scripts_02_10_2026/scripts/simutil.lua>) (Zeile 658), [modutil.lua — env.RegisterInventoryItemAtlas](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 954), [Trash Can 1879090052/modmain.lua — local assets=](<../Trash Can 1879090052/modmain.lua>) (Zeile 10).

## Bank, Build und Symbol

Bank beschreibt verfügbare Animationsabläufe; Build die zugehörigen grafischen Symbole. Eine Animation wie idle oder closed muss in der gewählten Bank vorhanden sein. Beim Speer verwendet Vanilla die Bank spear und den Build swap_spear für die Weltansicht. Ausrüstung ersetzt im Spieler ein Symbol, etwa swap_object, durch ein Symbol aus dem passenden Build.

Eine sichtbare Weltgrafik beweist nicht, dass die Ausrüstungsgrafik stimmt. Hände, Schatten, Facing, Floater und Skin-Symbolpfade separat prüfen. Die Item-Vorlage folgt den geprüften ungeskinnten Speerpfaden.

Belege: [prefabs/spear.lua — inst.AnimState:SetBank](<../../_scripts/scripts_02_10_2026/scripts/prefabs/spear.lua>) (Zeile 37), [prefabs/spear.lua — OverrideSymbol("swap_object"](<../../_scripts/scripts_02_10_2026/scripts/prefabs/spear.lua>) (Zeile 13).

## Lokale Werkzeuge

Installiert sind ModUploader.exe, mod_tools/autocompiler.exe, png.exe und scml.exe. Die lokale compilers.txt nennt png, scml und exported. Installation wurde geprüft, Export-/Uploadbetrieb nicht ausgeführt.

Das [Klei-Mod-Tools-Repository](https://github.com/kleientertainment/ds_mod_tools) dokumentiert einen Port und Verbesserungen des SCML-Compilers. Dort beschriebene historische Python-/Compiler-Abhängigkeiten gelten nicht automatisch für den vorhandenen Windows-Steam-Build. Das Repository beschreibt direkten SCML-Aufruf mit Quellprojekt und Ziel-Modverzeichnis; vor tatsächlichem Export den lokalen Toolstand und dessen Hilfe prüfen.

Eine belastbare Pipeline erhält bearbeitbare Quellen, erzeugt Runtime-Assets und testet anschließend deren Auflösung im Spiel. Die richtige Quellordnerstruktur für autocompiler nicht aus einem beliebigen alten Tutorial übernehmen. Keine bloß umbenannte PNG als TEX einsetzen.

## Minimap, Audio und eigene Kunst

AddMinimapAtlas registriert einen Atlas; ein passendes MiniMapEntity-Icon und enthaltene Region sind zusätzlich nötig. Die aktuelle Truhe setzt ein Icon anhand ihres Namens. Inventar- und Minimap-Bildnamen können unterschiedliche Suffixkonventionen haben.

SoundEmitter spielt registrierte Eventpfade ab. Truhen definieren eigene Open-/Close-Eventnamen; diese sind keine Dateipfade zu WAV-Dateien. Eigene Sounds benötigen eine passende kompilierte Bank, Assets und Eventregistrierung. RemapSoundEvent verändert die Zuordnung eines vorhandenen Events; es erzeugt keine neue Soundbank. Die native Audio-Compilerkette ist hier nicht vollständig getestet und wird nicht als fertiges Rezept ausgegeben.

Belege: [modutil.lua — env.AddMinimapAtlas](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 512), [prefabs/treasurechest.lua — SetIcon(name](<../../_scripts/scripts_02_10_2026/scripts/prefabs/treasurechest.lua>) (Zeile 121), [prefabs/treasurechest.lua — SoundEmitter:PlaySound](<../../_scripts/scripts_02_10_2026/scripts/prefabs/treasurechest.lua>) (Zeile 29), [modutil.lua — env.RemapSoundEvent](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 842).

Bei Veröffentlichung fremder Assets die tatsächliche Erlaubnis und erforderliche Attribution prüfen; die [Klei-Richtlinien](https://support.klei.com/hc/en-us/articles/360029555992-Modding-Don-t-Starve-and-Don-t-Starve-Together) regeln das. Vorhandene Workspace-Assets werden durch diese Sammlung nicht automatisch zur freien Wiederverwendung erklärt.


## Praktischer Bild-/Atlasworkflow

Die lokale Mod-Tools-Installation wurde statisch gelesen. [image_build.py](<E:/ProgrammeE/Steam/steamapps/common/Don't Starve Mod Tools/mod_tools/compiler_scripts/image_build.py>) enthält process_file_to_atlas, Import von klei/Pillow und die Argumente --force, --square, --outputdir sowie Bildpfade. Die aktive Atlasroutine schreibt neben dem PNG gleichnamige .tex und .xml; --outputdir allein verschiebt diese nicht in den Modordner. ROOT/CWD beeinflusst den XML-Texturepfad. Deshalb in einer isolierten Assetarbeitskopie arbeiten, Zielpfade vor Export prüfen und das XML anschließend lesen.

1. Eigenes transparentes PNG anlegen, zum Beispiel 64×64 für ein Inventarsymbol. Pixelrand/Alpha in heller und dunkler Vorschau prüfen; Dateibasename als eindeutigen Elementnamen wählen.
2. Gebündelten kompatiblen Toolinterpreter und Imports prüfen. Der Arbeits-Python für Dokumentation ist kein Nachweis, dass historische Python-2-Compiler darunter laufen.
3. image_build.py mit dem PNG aufrufen; erforderliche Binär-Textureconverter müssen auffindbar sein. Verifizierte CLIform: `python image_build.py --force <absoluter PNG-Pfad>`. Das ist eine Anleitung, hier nicht ausgeführt.
4. .tex/.xml zusammen nach images/inventoryimages kopieren. XML-Texture filename und Element name prüfen: basename.tex muss genau zu imagename/image passen; ggf. exportierten Texturepfad auf die tatsächlich ausgelieferte Texturdatei korrigieren. Nicht rohe PNGs als TEX umbenennen.
5. Asset("ATLAS",...), Asset("IMAGE",...) registrieren; inventoryitem.atlasname/imagename und Rezeptatlas/image konsistent setzen. Separate Minimapgrafik über AddMinimapAtlas und MiniMapEntity:SetIcon einbinden.
6. Statisch alle Pfade/Elementnamen prüfen, später Inventar-, Rezept-, Boden-, Controller- und Minimapdarstellung sowie Dedicated-Laden testen. Fehlender Atlasregion-Log und unsichtbare/weiße Textur sind unterschiedliche Diagnosen.

Bei Atlanten für mehrere Elemente alle UV-Rechtecke und exakten Elementnamen prüfen. Kein pauschales manuelles 0..1-Rechteck für ein gepacktes Mehrbildatlas. Der direkte ExportImage-Helfer hat zusätzlich eine Vielfache-von-4-Prüfung; das ist nicht automatisch die gesamte aktive Atlasroutine.

## Nachvollziehbarer Animationsworkflow

[zipanim.py](<E:/ProgrammeE/Steam/steamapps/common/Don't Starve Mod Tools/mod_tools/compiler_scripts/zipanim.py>) packt build.xml, animation.xml und images.lst-Bilder in ein **Quell-ZIP**. [buildanimation.py](<E:/ProgrammeE/Steam/steamapps/common/Don't Starve Mod Tools/mod_tools/tools/scripts/buildanimation.py>) akzeptiert dieses ZIP, erzeugt Binärdaten/Texturen und schreibt <data_path>/anim/<basename>.zip. Dieses kompilierte ZIP gehört zur Mod. [export.py](<E:/ProgrammeE/Steam/steamapps/common/Don't Starve Mod Tools/mod_tools/exported/export.py>) delegiert an gebündeltes python27, benötigt Prefabsmetadaten und besitzt eigene Outputpfadberechnung.

1. Projekt in Spriter/SCML mit getrennten Symbolbildern, definierten Pivots, Animationnamen und Bank anlegen. Equipment zusätzlich swap-Symbol entsprechend dem Spieler-Override entwerfen.
2. SCML-Compiler erzeugt exportierte XML-/Bildzwischenstufen; in der lokalen Toolvariante anschließend zipanim/export/buildanimation-Kette nachvollziehen. Nicht einen Compileaufruf aus einem anderen Toolpaket ungeprüft übernehmen.
3. Für das hier gelesene buildanimation ist die Form `python buildanimation.py <Quell-ZIP> --outputdir=<Pfad>` vorhanden. Outputdir wird relativ zu parent des Quellpfads berechnet; vor Ausführung mit absolutem Ziel in einer Arbeitskopie auflösen. Export.py berechnet anders und benötigt prefabs.xml. Hier wurde kein Compiler/Exporter ausgeführt.
4. In den geladenen ZIPs die jeweils benötigten build.bin/anim.bin und Texturen prüfen; sie können getrennt vorliegen. Dateiname des ZIP, Buildname, Bankname, Animationname und Symbolname sind verschiedene Namen: Asset lädt ZIP; SetBank wählt Animationsbank; SetBuild wählt Symbolbuild; PlayAnimation wählt Clip; OverrideSymbol wählt konkretes Symbol.
5. Prefab mit Vanilla-Assets zuerst funktional halten, anschließend eigene Grafik einsetzen. Bodenidle, Equip/Unequip, jede Animationrichtung, Skalierung, Pivots, Ghost-/Skinfall und Clientlatejoin getrennt ansehen. Compilererfolg beweist keinen passenden Banknamen.

Das [Klei-Repository](https://github.com/kleientertainment/ds_mod_tools) beschreibt zusätzlich einen direkten SCML-Compiler mit Eingabe-SCML und Zielmodordner. Das ist eine andere Werkzeugoberfläche; lokale Pythonpipeline und Repositorycompiler nicht als identische CLI behandeln.

## Audio und spezielle Inhalte: belegbare Voraussetzungen

SOUNDPACK/SOUND und SoundEmitter-Aufrufe im Grundlagenabschnitt zeigen Registrierung/Abspielseite. Für eigene Samples braucht es bearbeitbare Quelle, passende FMOD-Projekt-/Eventstruktur, kompatibles Exportformat und die tatsächlich geladenen Bank-/Eventnamen. Die lokale Anwesenheit von FMOD Designer/Studio allein beweist keine DST-kompatible Bank. Ohne verifizierten Projektbuild und Abhörtest wird hier keine moderne FMOD-Version als universell geeignet behauptet. Native Audiobudget-/Codec-/Bankversionverträge sind nicht vollständig in scripts.zip enthalten.

Charakterporträts, Inventarskins, Shader, Maptiles und Innenraumgrafik benötigen zusätzlich ihre jeweils konkreten Registrierungs-/Engineverträge. [Skins](case_studies/14_skins_architecture.md) und [Hamlet WIP](case_studies/13_hamlet_architecture.md) trennen vorhandene Assets von fehlender Runtimearchitektur. Für ein neues Assetprojekt die genaue Toolversion, Befehlszeile, Input-/Outputhashes und visuellen/auditiven Test protokollieren.


### Lokaler Audiowerkzeugstand

[FMOD Designer README](<E:/ProgrammeE/Steam/steamapps/common/Don't Starve Mod Tools/mod_tools/FMOD_Designer/README.TXT>) nennt 4.44.07; daneben existiert ein FMOD-Studio-1.10.10-Verzeichnis mit Template-Bank. Beide sind unterschiedliche Werkzeuggenerationen. Diese Beobachtung bestätigt vorhandene Werkzeuge, keinen erfolgreichen DST-Audioexport. Die gelesenen Toolquellen sind mit Hash und klarer Prüftiefe im Manifest erfasst.


## Erneute Dateiformat-/Atlasprüfung

Der [Assetprüfer](tools/verify_assets.py) untersucht tatsächliche installierte Dateien/Archivmetadaten, keine Engineausgabe. Vanilla anim/spear.zip enthält nur anim.bin, swap_spear.zip hingegen build.bin und atlas-0.tex. Beide werden gemeinsam registriert. Treasurechest- und UI-Chest-ZIP enthalten beide Binärteile. Deshalb nicht pauschal beide Dateien in jedem einzelnen ZIP verlangen.

Die literalisch verwendeten Inventarregionen spear.tex und boards.tex wurden in images.zip nachgewiesen. GetInventoryItemAtlas findet sie über die aufgeteilten inventoryimages1..4.xml; ein nicht gefundenes Bild kann ohne no_fallback trotzdem einen Fallbackatlas liefern. Ein nichtnil Getter beweist daher keine vorhandene Region.

Die Weltoption der Vorlage 12 verwendete zuvor spiderden.tex mit images/customisation.xml. Dieser Atlas enthält spiders.tex; spiderden.tex ist ein anderer Bildvertrag. Die Vorlage ist auf die nachgewiesene Region korrigiert. Consumer: [SettingsList](<../../_scripts/scripts_02_10_2026/scripts/widgets/redux/worldsettings/settingslist.lua>) übernimmt Optionimage/Atlas in SetTexture. Ein gültiger XML-Dateipfad allein hätte diesen Fehler nicht erkannt.

[ASSET_CHECK_RESULTS](ASSET_CHECK_RESULTS.json) hält Pfade, Inhalts-SHA-256, ZIP-Mitglieder und gefundene Regionen. Texturen wurden nicht dekodiert, Animationnamen/Bankbuilds nicht binär interpretiert, Audio nicht exportiert/abgehört. Native Resolverpriorität gegenüber Fremdmods bleibt Laufzeitfrage.
