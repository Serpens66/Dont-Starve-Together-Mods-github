# 19 – Arbeitschecklisten

## Vanilla-Audit vor der Implementierung

- [ ] Archiv gegen Snapshot geprüft; Datum und Hash dokumentiert.
- [ ] Nächstliegendes Vanilla-Prefab und alle betroffenen Components gelesen.
- [ ] Definition, Konstruktor, Setter und tatsächliche Aufrufer verfolgt.
- [ ] Hook-Zeitpunkt relativ zu Prefabinitialisierung und Component-Initialisierung festgestellt.
- [ ] Shared-, Mastersim-, Client- und Dedicated-Verhalten bestimmt.
- [ ] Tags, Netvar-Deklarationen, Replica/Classified und Action-Auswahl verfolgt.
- [ ] Änderungen an Aufrufreihenfolge, Parametern und Rückgabewerten berücksichtigt.
- [ ] OnSave/OnPreLoad/OnLoad/PostPass, Referenzen und Migration untersucht.
- [ ] Unbekannte Engineverträge als offen festgehalten; keine Annahmen als Fakten verwendet.

## Implementierung

- [ ] Eigener Modul-/Prefab-/RPC-/Action-Präfix; keine unnötigen GLOBAL-Änderungen.
- [ ] Clientflags passen zum tatsächlich benötigten Clientcode.
- [ ] Netzwerkdefinitionen auf beiden Peers gleich und vor SetPristine.
- [ ] Gameplaywirkung nur auf zuständiger Serverinstanz.
- [ ] Client-/RPC-Eingaben auf Typ, Entity-Gültigkeit, Eigentum, Distanz, Zustand und Häufigkeit geprüft.
- [ ] Wrapper bewahrt self, Argumente, Rückgaben und relevante Originalwirkung.
- [ ] Nullfälle, Funktionswerte und Eingriffe anderer Mods berücksichtigt.
- [ ] Events/Watcher/Tasks haben begrenzte Lebensdauer und Cleanup.
- [ ] Save-Daten verwenden einfache serialisierbare Werte, Schema und Migration.
- [ ] Assets, Bildnamen, Atlas und Placer passen zusammen.
- [ ] Neue Texte UTF-8/CRLF, vorhandene Codierungen unverändert.

## Fehlerdiagnose

- [ ] Reproduktion mit konkreten Schritten, Modliste und Spielstand festgehalten.
- [ ] Client-, Master- und Caves-Logs dem richtigen Prozess zugeordnet.
- [ ] Erste relevante Fehlermeldung samt Stacktrace gelesen.
- [ ] Instanz, Prefab, Component/Replica, Tag und Netzfeld vor Zugriff geprüft.
- [ ] Mit nur dieser Mod und danach mit Konfliktmod verglichen.
- [ ] Konstruktorfehler von Hook-/Load-/Dirty-Event-Fehler getrennt.
- [ ] Altes Save und neu erzeugte Welt getrennt getestet.
- [ ] Ursache auf aktuellen Vanilla-Vertrag zurückgeführt; keine beliebigen Delays als Ersatz für Initialisierungsverständnis.

## Laufzeitmatrix und Freigabe

| Fall | Prüffrage |
|---|---|
| Host ohne Remoteclient | Erzeugung, Aktion, Werte und Abbau korrekt? |
| Separater Client | Sichtbarkeit, Interaktion, Dirty-Events und Prediction korrekt? |
| Dedicated Server | Kein Zugriff auf HUD/ThePlayer; Gameplay korrekt? |
| Zweiter Spieler | Rechte, Reichweite, Inventareigentum und Sichtbarkeit korrekt? |
| Save/Load | Alle eigenen Daten wiederhergestellt; keine Duplikate oder Resetwerte? |
| Reconnect/Spätbeitritt | Netvars und UI vollständig initialisiert? |
| Oberfläche/Höhlen | Mod auf beiden Shards geladen; Inventar-/Spielermigration korrekt? |
| Weltgenerierung | Forest und Caves mit Seed/Optionen getrennt neu erzeugt? |
| Konfliktmods | Wrapperketten, Namen und geänderte Felder verträglich? |
| Update/Deaktivierung | Alte Saves und fehlende eigene Prefabs verstanden? |

- [ ] `luac5.1.exe -p` für jede Lua-Datei bestanden.
- [ ] Dokumentations-/Quellenprüfung bestanden.
- [ ] Tatsächliche Testergebnisse mit Spielstand und Prozessen dokumentiert.
- [ ] Beschreibung, Optionen, Screenshots und Assetrechte geprüft.
- [ ] Workshopversion und Changelog aktualisiert; Backup des letzten funktionierenden Standes vorhanden.

Diese Liste beschreibt notwendige Prüfungen. Leere Kästchen sind keine bestandenen Tests. Der tatsächliche Status dieser Sammlung steht in [VALIDATION](VALIDATION.md).


## Zusatzcheck für die vertieften Mechanismen

- Ernährung: Callback vor Deltas, Event danach; Grundwerte/Charakterwerte/Stackfaktor/Favorit/Potion/Basisgericht bewusst wählen; historische Daten/Timer wiederherstellen.
- Upgrades: aktueller/maximaler Wert getrennt, Settercallbacks und Replica berücksichtigen; Stacksplit/merge und Fremdmod speichern/ablehnen.
- Boni: Quelle/Key eindeutig; Equip/Unequip/Break/Death/Remove/Migration, fremder Bonus bleibt erhalten.
- Daten-UI: Serverinput und Budget, private/öffentliche Antwort, Sequenz/Entityvalidität, leere und verspätete Antwort, Widgetcleanup/Controllerfocus.
- Worldgen: Task-/Room-/Layoutname vorhanden und aktives Taskset richtig; Gewichte/Dichte/count nicht verwechseln; mehrere Seeds, aktuelle Saves unverändert.
- Weltoption: Customize/Override/Runtimewirkung vollständig; Pre ohne TheWorld; geladener/laufender/pausierter Resttimer und neue Option.
- Reset/Innenräume: Referenzen, Offlineprofile, Weltgebundenheit, Idempotenz, fehlende Shardantwort und Cleanup ausdrücklich entwerfen; keine Freigabe allein aus Syntaxprüfung.
