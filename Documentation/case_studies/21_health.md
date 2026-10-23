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
