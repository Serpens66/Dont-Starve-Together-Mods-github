# Automatic Health Adjust – variable Maximalgesundheit

**Prüfart:** statische Ablaufanalyse; Architektur und wesentliche Pfade beschrieben; offene Spezialverträge unten. Keine Ingame-Funktionszusage. Alle Verzeichnisse: `Automatic Health Adjust 764204839`.

## Einstieg und Abhängigkeiten

Enemy-/Bosslisten und Config steuern Spielerzählung, Skalierung und Ausnahmebedingungen. Prefab-/Healthhooks registrieren Änderungen; spawn/leave lösen verzögerte Neubewertung aus.

## Initialisierung, Interaktion und Serverwirkung

Server berechnet gewünschte Maxhealth nach Spielern/Config, verändert Health und bewahrt den gewünschten aktuellen Anteil. Sondergegner besitzen zusätzliche eigener HP-/Phasenlogik: Crab King und seine PostPass-Rekonfiguration sind im Quelltext ausdrücklich problematisch. Entity-Wake- und Spawnpfade können nach Save/Load erneut rechnen.

## Replikation, UI, Speicherung und Wiederherstellung

health.save_maxhealth erlaubt zusätzliche Vanilla-Maxhealthpersistenz. Prefabwrapper halten weitere historische Werte/Spawnflags. Client-HUD liest Standardhealth-Replica, keine eigene globale HP-Tabelle. Loadinitialisierung, PostPass und delayed Recalc sind verschiedene Phasen und können gespeicherte Werte erneut übersteuern.

## Cleanup und Lebensdauer

Disconnect/Despawn muss Zählung nicht doppelt verändern; verzögerte Tasks brauchen gültige Entity/World. Ein bereits verwundeter Gegner sollte beim Join nicht unbeabsichtigt voll geheilt werden. Tote/entfernte Gegner aus Aktualisierung ausnehmen.

## Aktuelle Vanilla-Kette

[Automatic Health Adjust 764204839/modmain.lua — save_maxhealth](<../../Automatic Health Adjust 764204839/modmain.lua>) (Zeile 370) → [components/health.lua — SetMaxHealth](<../../../_scripts/scripts_02_10_2026/scripts/components/health.lua>) (Zeile 503) / [components/health.lua — OnSave](<../../../_scripts/scripts_02_10_2026/scripts/components/health.lua>) (Zeile 154) / [components/health.lua — OnLoad](<../../../_scripts/scripts_02_10_2026/scripts/components/health.lua>) (Zeile 163) → [prefabs/crabking.lua — OnLoadPostPass](<../../../_scripts/scripts_02_10_2026/scripts/prefabs/crabking.lua>) (Zeile 601).

## Altlasten und konkrete Prüfgrenze

Vollständige Sonderboss-Phasen-/Referenzkorrektheit bleibt offen; historische auskommentierte Fixes sind kein aktiver Patch. Der Standardlebensvertrag ist erklärt, aber nicht jedes modifizierte Bosspräfab als kompatibel zertifiziert. Neue Skalierung pro Gegnerfamilie auditieren.

## Szenarien für die spätere Laufzeitabnahme

Verwundeter Standardgegner bei Spielerjoin/leave, zwei schnelle Joins, Dedicated/Host, Save/Load mit anderem Spielerstand. Crab King, gepanzerte/transformierte Gegner, Wake nach Entfernung aus Sicht und Höhlenzählung getrennt.

Alle Szenarien sind **offen**. Für Dedicated-Server, separaten Client, Reconnect und Shardwechsel gelten zusätzlich die [allgemeinen Checklisten](../19_Checklisten.md). Statische Symbol-/Hashprüfung ersetzt diese Abnahme nicht. [Katalog](../16_Workspace_Mods.md) · [Abdeckungsmatrix](../21_Abdeckungsmatrix.md) · [Projektworkflow](../20_Projektworkflow.md).


## Dateiregister: Automatic Health Adjust 764204839

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [customsettings.lua](<../../Automatic Health Adjust 764204839/customsettings.lua>)
- [modinfo.lua](<../../Automatic Health Adjust 764204839/modinfo.lua>)
- [modmain.lua](<../../Automatic Health Adjust 764204839/modmain.lua>)


## Erneute Prüfung: Spielerzahl, Form, Wake und Save

[`Automatic Health Adjust 764204839/modmain.lua`](<../../Automatic Health Adjust 764204839/modmain.lua>) zählt lokale AllPlayers, plant nach Spawn/Leave verzögerte Neuberechnung und beendet bei null Spielern. Mehrere Events sind nicht automatisch zusammengefasst; clusterweite Zählung braucht Shardprotokoll. AdjustHealthEnt behandelt Shadowchesslevel, Klaus enraged, Deciduoustree-Workable, Leifscale, Merms und normale Health verschieden.

Maxhealth zuerst setzen und altes Prozent danach anwenden: [`components/health.lua`](<../../../_scripts/scripts_02_10_2026/scripts/components/health.lua>) SetMaxHealth setzt currenthealth zunächst auf amount. Penalty ist zusätzlicher Vertrag. Die Mappingtabelle enthält pigman doppelt; der spätere Werepigwert ersetzt Pig. Eine Pigkonfiguration wird dadurch nicht über den ersten verlorenen Tabelleneintrag unabhängig zugeordnet. [`prefabs/pigman.lua`](<../../../_scripts/scripts_02_10_2026/scripts/prefabs/pigman.lua>) setzt bei Formwechsel TUNING-Werte erneut.

Shadowchess-PreLoad berücksichtigt Level. Alterguardian 2/3 speichern Unloaded-Multiplikatoren und behandeln Wake; Nightmarecreaturewerte werden nach kopierter Initialisierung korrigiert. save_maxhealth nutzt Health-OnSave/OnLoad: optional Maxwert speichern, vor aktuellem Healthwert laden. Alte manuelle Savehealth- und Crabking-PostPasswrapper sind auskommentiert. Der heutige [`prefabs/crabking.lua`](<../../../_scripts/scripts_02_10_2026/scripts/prefabs/crabking.lua>) hält Healthprozent und rekonstruiert Gem-/Dekorzustand im PostPass; historische Heal-Kommentare sind kein heutiger Fehlerbeweis.

Ähnliche Mods müssen pro Familie Initial-TUNING gegenüber lebenden Entities, Prozent gegenüber absoluten HP, Form/Wake/Level, gespeicherte Maxwerte und Configwechsel bestimmen. Offen: verletzten Boss je Phase laden, Spielerzahl ändern, null Spieler, Klaus, Pigform, Shadowchesslevel, Schlaf/Wake und Höhlenzählung.


Konkrete zusätzliche Funktionsdefinitionen: [Vertragsbelege](../27_Vertragsbelege.md). Die [Reviewmatrix](../REVIEW_MATRIX.json) trennt Einstiegssichtung und ausgewählte vertiefte Abläufe; weitere Featureänderungen benötigen einen eigenen aktuellen Audit.


## Ergänzung vom 23.10.2026: sieben weitere Gegner

Quellenstand: installiertes `scripts.zip`, SHA-256 `9cd6a6284062101ec000e50ae16b802a430f842c51bbe671eb31cd15f85dfe00`. Alle 4.098 Dateien wurden nach `_scripts/scripts_23_10_2026` entpackt und einzeln per SHA-256 mit dem Archiv verglichen. Die älteren Belege oben beziehen sich weiterhin auf den damaligen Snapshot; ein vollständiger erneuter Audit aller bisherigen Gegner ist damit nicht behauptet.

- Englische Standardnamen aus [`strings.lua`](<../../../_scripts/scripts_23_10_2026/scripts/strings.lua>): Hound Batilisk, Blighted Hound Batilisk, Rock Master, Blighted Rock Master, Blighted Great Depths Worm, Shrouded Queen und Umbral Abomination. `shrouden.DisplayNameFn` kann abhängig von Charakter/Ausrüstung Tenebrau, The Other oder Shrouden anzeigen; die Konfiguration verwendet den Standardnamen Umbral Abomination.
- [`bat_boss.lua`](<../../../_scripts/scripts_23_10_2026/scripts/prefabs/bat_boss.lua>) und [`rocky_boss.lua`](<../../../_scripts/scripts_23_10_2026/scripts/prefabs/rocky_boss.lua>): gemeinsame Konstruktoren mit getrennten normalen/Schatten-Initialisierungen; Maxhealth wird serverseitig unmittelbar aus dem jeweiligen `<PREFAB>_HEALTH` gelesen. Der Batilisk-Klon in [`SGbat.lua`](<../../../_scripts/scripts_23_10_2026/scripts/stategraphs/SGbat.lua>) spawnt dasselbe Schattenprefab und übernimmt den Gesundheitsanteil. Schattenumwandlungen in [`commonstates.lua`](<../../../_scripts/scripts_23_10_2026/scripts/stategraphs/commonstates.lua>) erzeugen neue Schattenprefabs ohne Übernahme des alten Health-Componentschemas.
- [`worm_boss.lua`](<../../../_scripts/scripts_23_10_2026/scripts/prefabs/worm_boss.lua>): `shadow_master_postinit` überschreibt den anfänglichen normalen Wert mit `WORM_BOSS_SHADOW_HEALTH`; Enrage verwendet einen Prozentgrenzwert. Die Umwandlung in [`SGworm_boss_head.lua`](<../../../_scripts/scripts_23_10_2026/scripts/stategraphs/SGworm_boss_head.lua>) übernimmt über Prefab-OnSave/OnLoad die Körpersegmente, ausdrücklich keine Componentdaten. Die neue Einstellung gehört zum Hauptprefab, nicht separat zu Kopf/Schwanz/Segmenten.
- [`charlie_boss.lua`](<../../../_scripts/scripts_23_10_2026/scripts/prefabs/charlie_boss.lua>) und [`shrouden.lua`](<../../../_scripts/scripts_23_10_2026/scripts/prefabs/shrouden.lua>): direkte eigene Health-TUNING-Werte, interne Phasen anhand von Prozentwerten über [`healthtrigger.lua`](<../../../_scripts/scripts_23_10_2026/scripts/components/healthtrigger.lua>). [`SGcharlie_boss.lua`](<../../../_scripts/scripts_23_10_2026/scripts/stategraphs/SGcharlie_boss.lua>) erzeugt beim Übergang ein neues `shrouden` mit dessen eigener Maxhealth. Save/Load rekonstruiert interne Phasen anhand des Gesundheitsanteils; die geprüften PostPass-/Wake-Pfade setzen die Maxhealth nicht erneut.
- Die vorhandenen Listen reichen für alle sieben Ergänzungen aus. [`mainfunctions.lua`](<../../../_scripts/scripts_23_10_2026/scripts/mainfunctions.lua>) führt PrefabPostInit nach dem Prefabkonstruktor aus; damit greift der bestehende `save_maxhealth`-Hook. [`entityscript.lua`](<../../../_scripts/scripts_23_10_2026/scripts/entityscript.lua>) lädt Components vor Prefab-OnLoad; [`health.lua`](<../../../_scripts/scripts_23_10_2026/scripts/components/health.lua>) stellt gespeicherte Maxhealth vor aktueller Gesundheit wieder her. `SetMaxHealth` und anschließendes `SetPercent` bleiben unverändert. Für diese Gegner ist kein zusätzlicher Phasen-/TUNING-Wrapper erforderlich.

**Tatsächlich geprüft:** Lua-5.1-Syntax von `modmain.lua` und `modinfo.lua` außerhalb der Sandbox bestanden. Isolierter temporärer Lua-Prüflauf mit 1.198 Assertions bestanden: sieben neue Prefabzuordnungen, vierzehn neue Optionen, gleiche Namen/Werte in beiden Dateien, unveränderte bisherige Optionen/Zuordnungen/Werte; QuickSet-Modi 1–5 bei 1/3/6 Spielern, abweichende individuelle Endpunkte, Erhalt eines Gesundheitsanteils von 40 % auch bei wiederholter Berechnung und Registrierung der Maxhealth-Speicherung. Der Prüflauf verwendet World-/Health-Stubs und ist kein Vanilla- oder Engine-Laufzeittest. Modversion auf `1.1074` erhöht; Formel und bestehende Sonderbehandlungen unverändert.

**Weiterhin offen:** echte Spawnwerte und verwundete Gegner bei Join/Leave, Host/separater Client/Dedicated, Save/Load und Reconnect, Höhlen-/Shardwechsel, Schattenumwandlungen, Batilisk-Klon sowie der vollständige Bossübergang Shrouded Queen → Umbral Abomination im Spiel. Keine Spielinstanz gestartet und keine Laufzeitfreigabe erteilt.


## Ergänzung vom 21.11.2026: Hallowed Nights und Merm-König

Der Snapshot `_scripts/scripts_21_11_2026` enthält 4.109 Dateien, einzeln per SHA-256 gegen das installierte Archiv geprüft. Archiv-SHA-256 `733a0f7f97ace5a76aa5acee95405a6ec01697d93d844eeb4ecce7c001306980`.

- [pigman.lua](<../../../_scripts/scripts_21_11_2026/scripts/prefabs/pigman.lua>) und [bunnyman.lua](<../../../_scripts/scripts_21_11_2026/scripts/prefabs/bunnyman.lua>) wandeln geeignete Instanzen verzögert um. Bei [mermhouse.lua](<../../../_scripts/scripts_21_11_2026/scripts/prefabs/mermhouse.lua>) entscheidet der Hausstatus beim Spawn eines neuen Merms. Die drei Formen behalten ihre Basis-Prefabs und setzen serverseitig `franken`, `mummy` bzw. `vampire`. Nur diese drei Umwandlungen lesen den gemeinsamen Wert `HN_MONSTER_HEALTH`. Der Mod setzt ihn einmal pro Skalierung und verwendet für existierende Formen dieselbe Maximal-HP mit erhaltenem HP-Anteil.
- [merm.lua](<../../../_scripts/scripts_21_11_2026/scripts/prefabs/merm.lua>) berechnet die Werte abhängig von König, Wache und Lunar-Form. Der Mod ruft bei Spielerwechsel für gewöhnliche Merms und die bisherigen Merm-Varianten diese Vanilla-Funktion auf und stellt den HP-Anteil wieder her. Die Tuningwerte werden aus den beim Modstart erfassten Werten berechnet. Bereits laufende normale Regenerationstasks behalten die beim Spawn erhaltene Rate. Die König-Callbacks rufen die lokale Vanilla-Funktion unmittelbar auf. Der instanzbezogene Health-Setter schützt deshalb aktive Mermummys vor deren HP-Änderungen. Andere Vanilla-Folgen des Königwechsels wie Schaden und Größe bleiben bestehen.
- [entityscript.lua](<../../../_scripts/scripts_21_11_2026/scripts/entityscript.lua>) ruft das Prefab-`OnPreLoad` vor dem Component-Load auf. Außerhalb des Events wird bei gespeicherter Halloween-Form der HP-Anteil anhand des gespeicherten Maximums auf das normale Maximum übertragen. Alte Saves ohne Maximal-HP folgen dem Begrenzen auf das normale Maximum in [health.lua](<../../../_scripts/scripts_21_11_2026/scripts/components/health.lua>). Ein früherer Frankenswine mit gespeichertem Werepig-Timer behält den Vanilla-Ladepfad für [werebeast.lua](<../../../_scripts/scripts_21_11_2026/scripts/components/werebeast.lua>).

**Geprüft:** Lua-5.1-Syntax und 148 isolierte Lua-Prüfungen mit der Vanilla-Funktion `UpdateDamageAndHealth` und Test-Entities. Abgedeckt sind die Konfigurationswerte, QuickSet, individuelle und fehlende neue Konfigurationswerte, wiederholte Neuberechnung, Königsbonus, Guard und Lunar, HP-Anteile lebender Gegner, tote Merms, HP-Schutz für Mermummys sowie die Ladepfade mit und ohne aktives Event, mit älteren Saves und mit gespeichertem Werepig-Timer.

**Im Spiel offen:** tatsächliche Spawn- und Umwandlungswege, Königwechsel über Shards, Join/Leave mit verwundeten Gegnern, Host/separater Client/Dedicated, Reconnect und echtes Save/Load mit aktivem und deaktiviertem Event.


### Wiederverwendbare Formregeln

In [modmain.lua](<../../Automatic Health Adjust 764204839/modmain.lua>) verknüpft `shared_health_settings` einen vorhandenen Einstellungsnamen mit einem TUNING-Schlüssel und dem Prefab-Argument für `CUSTOMHEALTH_FN`. `health_forms` ordnet einem Basis-Prefab das aktive Flag und die Einstellung zu. Der optionale Ladepfad prüft dasselbe Flag in den Speicherdaten, mit einer Ausnahme für gespeicherte Werepigs. Über `transform_method` kann eine Form ihre Maximal-HP gegen weitere Setter-Aufrufe schützen. `fixed_ratio_base_keys` erfasst für ausgewählte Prefabs die Anfangswerte der vorhandenen Verhältnis-Liste. Im Spiel nutzt weiterhin nur `merm` diesen festen Bezug.

**Geprüft:** Lua-5.1-Syntax und 148 bestehende isolierte Prüfungen bestanden. Ein zweiter Lauf mit 163 Prüfungen registrierte zusätzlich eine gemeinsame Einstellung, zwei Testformen und einen weiteren festen TUNING-Bezug ausschließlich durch Tabelleneinträge im Speicher. Geprüft wurden die gemeinsame Skalierung, getrennte HP-Anteile, der optionale HP-Schutz und Ladepfad sowie die feste Bezugsgröße nach einer Änderung des laufenden TUNING-Werts. Die oben aufgeführten Spieltests bleiben offen.
