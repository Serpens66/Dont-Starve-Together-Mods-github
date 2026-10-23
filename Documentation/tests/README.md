# Isolierte Prüfungen ohne Spielstart

Aus dem Workspace-Root mit den in AGENTS.md bezeichneten Interpretern:

    python -B Documentation/tests/test_reference.py
    lua5.1.exe Documentation/tests/own_logic.lua

Lua außerhalb der Sandbox gemäß Nutzerfreigabe. Compilerprüfung getrennt:

    python -B Documentation/tools/verify_reference.py --output Documentation/CHECK_RESULTS.json

Der Compiler läuft ausschließlich mit -p für jede Lua-Datei unter Documentation, einschließlich Testdatei. Kein Bytecode.

## Tatsächlich geprüfte eigene Logik

Die 13 bisherigen und neun zusätzlichen Lua-Fälle (insgesamt 22) laden echte eigene Component-/Rezeptdateien, modmain und das Callbackfragment. MRU/Duplikate/Eviction; positive/negative Wirkung; Vorwrapperorder; Saveversion/Datensanitizing; eigener/fremder Wrapperrückbau; Timerfortschritt/Optionsmigration/NaN/Infinity/Grenzen/Rearm/Cancel; Anfragevalidierung/Budget/Sequenz; UIcallback ohne unqualifiziertes tonumber. Ein Sprachfall bestätigt historische Negation und doppelte Tabellenkeys.

Sechs Python-Fälle prüfen Kommentar-/Stringmaskierung, Longstrings/Quotes/Positionen, Markdownanker, fehlenden Compiler, Startfehler nach vorherigem Erfolg und Syntaxfehler mit Fortsetzung. Infrastrukturfehler werden bewusst gemockt, nicht als real aufgetreten behauptet.

## Beweisgrenze

Class, Events, Tasks, Query und Widgets sind eng begrenzte explizite Stubs. Keine echten Netvars, native Zeiten, Controllerinput, Rendering, Netzwerkserialisierung oder DST-Entities. Sie erkennen konkrete Logikregressionen. Host/Client/Dedicated/Savegraph/Reconnect/Shards bleiben offen. OnSave/OnLoad-Datenroundtrip ist keine durchgeführte Weltspeicherung.


## Gespeicherte Ergebnisse

[run_logic_tests.py](../tools/run_logic_tests.py) führt beide Suites aus, prüft Pythonquellen ohne pyc und speichert nur tatsächliche Erfolge. [LOGIC_TEST_RESULTS](../LOGIC_TEST_RESULTS.json) enthält Exitcodes und originale Ausgaben. Fehlender Interpreter/Startfehler ist Infrastrukturfehler, kein bestandener Test.

## Zusätzliche isolierte Fälle

own_logic.lua lädt das tatsächliche Rezeptmodul der Vorlage 13 mit minimalen TUNING/FOODTYPE/Atlas-Stubs. Geprüft werden sämtliche fünf Roh/Gekocht-Verteilungen, ausgeschlossene Fremd-/Grenzzutaten, unveränderte Eingabetabellen, endliche positive Gewichte, zusammenpassende Grafikfelder und die tatsächliche modmain-Registrierung in allen drei Kochern. Zwei weitere Fälle prüfen den eigenen Character-Datenrundlauf und ungültige Savewerte. Es werden weder Stewer noch Factory, Spawn, Netzwerk, Physics oder Assetdarstellung simuliert oder als bestanden ausgegeben.

Ein zusätzlicher Fall lädt den echten Spicerfilterwrapper und prüft die gezielte Ablehnung samt unveränderter Delegation an den vorherigen Filter. Es wird keine native Containeraufnahme oder Gewürzverarbeitung als getestet behauptet.

Die aktuelle cooking.lua wird zusätzlich mit leeren externen Speisenregistries geladen: synthetische Konkurrenzrezepte prüfen niedrigere, höhere und gleiche Priority sowie gewichtete Auswahl. Das ist ein Test des echten Lua-Auswahlcodes, keine vollständige Prüfung aller Vanilla-/Fremdmod-Rezeptkombinationen. Der Snapshotpfad steht im Test; bei Updates zuerst Audit und Quellenmanifest erneuern.
