# Prüfstatus – praktische Erweiterung 03.10.2026

22 Fallstudien für alle 26 Modverzeichnisse wurden ergänzt; 13 eigenständige Vorlagen enthalten 42 Lua-Dateien. Hinzu kommen zwei abgegrenzte Lua-Fragmente, eine Lua-Testdatei, Navigations-/Vertragskapitel 24–27 und vier praktische Ergänzungskapitel 28–31, genaue Definitionsbelege und Prüfwerkzeuge. [Reviewmatrix](REVIEW_MATRIX.json) trennt erneute Einstiegssichtung und ausgewählte vertiefte Mechanismen. Inventarisierte 236 Workspace-Lua-Dateien sind kein behaupteter vollständiger Audit aller Kontrollpfade.

## Änderungen

- Kochablauf vollständig für den beschriebenen regulären Pfad ergänzt; eigenständige Speisevorlage mit getrenntem Produkt, passenden Vanilla-Overrides und gezieltem Spicerfilter.
- Rabbit-/Characterfactory-Lebenszyklen, Callback-Capture, Erstspawn/Ghost/Wiederbelebung sowie Classified/Prediction/Session/Migration vertieft; zwei kommentierte Fragmente mit Voraussetzungen.
- Projektworkflow und Aufgabenindex korrigiert/erweitert; vier Abdeckungsdimensionen zeigen Beispiel, beschriebenen Ablauf, weiteren Projekt-Audit und offenen Vertrag. [Praxis-Audit](31_Praxis_Auditnachweise.md) nennt die neue Prüftiefe.

- Mod-Closureumgebung korrigiert: UI nutzt GLOBAL.tonumber. Modmain und Prefab-/Componentmodule haben unterschiedliche Ladeverträge.
- Foodhistorywrapper deaktiviert eigene Wirkung nach Componententfernung auch innerhalb späterer fremder Wrapper.
- Prefabtweak/Worldgendichte weisen positive Unendlichkeit ab.
- Weltoptionssymbol auf tatsächlich vorhandenes spiders.tex im angegebenen Atlas korrigiert.
- Fallstudien erklären weitere Sonder-/Fehlerpfade, auskommentierte Loader, Legacy-Maxwell gegenüber modernem Worker, Show-Me-Schätzwerte, Form/Wake/Save, Transferphasen, Innenraum-/Skinportgrenzen und alte Eismechanik. Unzutreffende Cachebehauptungen korrigiert.
- Prüfer kontrolliert Markdownanker, aktive Quellvorkommen, genaue Funktionsdefinition/Signatur/Zeile, literale Modul-/Prefab-/Componentabhängigkeiten und ausgewählte fehlende Modglobals. Definitionserkennung ist lexikalisch, kein AST-/Kontrollflussbeweis.
- Assetprüfung kontrolliert deklarierte Pfade, ZIP-Mitglieder und ausgewählte XMLregionen. Werkzeug-/Audiogrenzen und nicht erreichbare Primärbeiträge bleiben ausdrücklich benannt.

## Tatsächlich bestanden

- Vollständiger SHA-256-Vergleich: 4.044 Archivdateien identisch zum Snapshot; keine fehlenden/geänderten/zusätzlichen Dateien. Archivhash/Stand im [Manifest](SOURCE_MANIFEST.json).
- 93 modutil-Signaturen/Quellzeilen, 126 Vanillaquellenhashes, 236 unveränderte Workspace-Lua-Hashes und 210 genaue Definitionsbelege kontrolliert.
- Lokale Links, Markdownanker, Vorlagenstruktur/-Abhängigkeiten sowie UTF-8 ohne BOM/CRLF fehlerfrei im [Gesamtbericht](CHECK_RESULTS.json).
- Alle 45 Lua-Dateien: 42 Vorlagendateien, zwei Fragmente und eine Testdatei ausschließlich mit -p außerhalb der Sandbox erfolgreich geparst. Keine Lua-Bytecodeausgabe.
- 22 isolierte Lua-Logikfälle und sechs Pythonprüfer-Fälle bestanden; alle sechs Pythondateien ohne Bytecodeausgabe kompiliert. Echte Outputs im [Logikbericht](LOGIC_TEST_RESULTS.json), Testumfang in [tests/README](tests/README.md).
- Neun Assetdeklarationen und acht literalische Inventarbildaufrufe mit tatsächlich vorhandenen Regionen sowie Weltoptionssymbol geprüft. [Assetbericht](ASSET_CHECK_RESULTS.json) enthält Pfade, Inhalts-SHA-256 und ZIP-Mitglieder.

CHECK_RESULTS trennt errors (Dokumentation), syntax_errors (Lua) und infrastructure_errors (Compilerstart). Alle sind im letzten Gesamtprüflauf leer; static_passed, syntax_complete, syntax_passed und passed sind true. STATIC_CHECK_RESULTS ist bewusst ohne Lua: static_passed=true, syntax_skipped=true und passed=false. Das ist keine fehlgeschlagene Syntaxprüfung, sondern keine Syntaxprüfung. Compiler-Startfehler und Syntaxfehler sind durch gezielte Prüfertests voneinander getrennt.

## Nicht durchgeführt und konkrete Grenzen

Keine Spielinstanz, kein Dedicated/separater Client, keine Weltgenerierung, kein echter Save/Load/Reset, keine Engine-Netzwerk-/Prediction-/Controllerprüfung, kein Assetexport/Rendering-/Audiohörtest und kein Workshopupload. Bestehende Mods, AGENTS.md und Spielinstallation nicht bearbeitet.

Die isolierten Class/Event/Task/Widgetstubs prüfen eigene Logik, nicht DST. OnSave/OnLoad-Datenroundtrip ist keine Weltspeicherung. Existierende anim.bin/build.bin beweisen weder korrekte Clips/Bank-/Symbolnamen noch kompatible native Interpretation.

Native RPCserialisierung/-Budgets/-Timing, Audioformate, Reset-/Schreibatomarität, Performance und GemCore-Shardverträge bleiben nicht vollständig Lua-seitig belegt. Hamlet-Innenräume fehlen als fertiger aktueller Multiplayervertrag; historische Skins liefern kein heutiges Backendownershipsystem. Andere Spezialfälle stehen bei jeder Fallstudie und Vorlage als konkreter Testauftrag. Kein Funktionszertifikat für vorhandene Mods oder universeller ungeprüfter Reset-/Automations-/Innenraumport.

## Wiederholung

Aus Workspace mit vorhandenem portablem Python, für Lua außerhalb der Sandbox gemäß Nutzerfreigabe:

    python -B Documentation/tools/audit_scripts.py
    python -B Documentation/tools/verify_reference.py --output Documentation/CHECK_RESULTS.json
    python -B Documentation/tools/verify_assets.py --output Documentation/ASSET_CHECK_RESULTS.json
    python -B Documentation/tools/run_logic_tests.py --output Documentation/LOGIC_TEST_RESULTS.json

Ein rein dokumentarischer Lauf: verify_reference.py --skip-lua. Pfade per --archive/--snapshot, --luac/--vanilla, --data bzw. --lua anpassbar. Ein neuer Pfad ersetzt keinen fachlichen Audit. Manifeste nach Spielupdate erst nach neuem Quellenvergleich ändern; [Aufgabenindex](25_Aufgabenindex.md) und [Vertragsbelege](27_Vertragsbelege.md) führen zu betroffenen Mechanismen.

## Bedeutung für neue Projekte

Die Sammlung bietet jetzt 13 eigenständige Vorlagen und praktische Ablaufbeschreibungen für die zusätzlich untersuchten Mechanismen. Creature-/Charactercode liegt als begrenztes Fragment vor, ohne eigene auswählbare Figuren/Assets. Die sieben neuen Koch-/Callbackfälle plus ein Spicerfilterfall und eine Prüfung der tatsächlichen Vanilla-Rezeptauswahl erhöhen die isolierten Lua-Tests von 13 auf 22. Native Classified-, Prediction-, Session-, Speicher-/Migrationsverträge wurden nicht im Spiel ausgeführt.

Geprüfter Stand: installiertes Archiv mit SHA-256 f8d7cff2e9f86cdab3de08c6e750ecec2986c9bc95b364724f4c77244a798bf1 und 4.044 identischen Dateien. Keine Aussage über einen noch nicht installierten neueren Klei-Build. Alle bestehenden Mods und AGENTS.md blieben unverändert.
