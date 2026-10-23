# Show Me – Serverdaten im Hovertext

**Prüfart:** statische Ablaufanalyse; Architektur und wesentliche Pfade beschrieben; offene Spezialverträge unten. Keine Ingame-Funktionszusage. Alle Verzeichnisse: `Show Me (Serp) 732456848`.

## Einstieg und Abhängigkeiten

[Show Me (Serp) 732456848/modmain.lua — GetTestString](<../../Show Me (Serp) 732456848/modmain.lua>) (Zeile 1041) sammelt komponentenspezifische Hinweise; MY_DATA/MY_STRINGS bilden ein eigenes Anzeige-/Kodierungsschema. Clienthook liegt am Hoverer/Text. Zusätzliche Toggle-RPCs aktivieren Anzeigeoptionen. Mod-Erkennung und Sonderfalltabellen sind Integrationen, keine stabile Vanilla-Metadatenstruktur.

## Initialisierung, Interaktion und Serverwirkung

Client merkt Hoverziel und fragt bei Zielwechsel oder nach Warteintervall mit GUID und Entity an. Server bildet GetTestString(item,player) aus echten Components: Nahrungs-, Haltbarkeits-, Lebens-, Timer- und weiteren Spezialwerten. Er schreibt GUID plus kompakten Datenstring in player_classified. Client zerlegt Trennzeichen und Typkennungen, wählt Formatierungsfunktion und erweitert den normalen SetString-Text. Diese Reihenfolge erlaubt Serverwissen ohne Clientzugriff auf Gameplaycomponents.

## Replikation, UI, Speicherung und Wiederherstellung

[Show Me (Serp) 732456848/modmain.lua — net_showme_hint1](<../../Show Me (Serp) 732456848/modmain.lua>) (Zeile 2134) sitzt auf player_classified, dessen Eigentümersichtbarkeit vom Vanilla-Prefab kommt. Dirty kopiert net_string in lokalen Cache; Hoverer vergleicht Zielzuordnung. Hintstrings werden nicht gespeichert; nach Laden/Reconnect neu anfordern. LOCAL_STRING_CACHE ist im aktiven Code nur deklariert; ein wachsender Formatcache ist daraus nicht belegt. Auf dem Dedicated gibt es kein Hoverwidget.

## Cleanup und Lebensdauer

Widget- und Classified-Entities begrenzen Listenerlebensdauer. Zielwechsel muss alte Antwort verwerfen, leeres Ergebnis alte Informationen entfernen und entfernte Entity tolerieren. Caches sollten begrenzt sein; Native-Netstring-Budget ist kein Anlass beliebig große Beschreibungen einzufügen.

## Aktuelle Vanilla-Kette

[prefabs/player_common.lua — SetClassifiedTarget(inst)](<../../../_scripts/scripts_02_10_2026/scripts/prefabs/player_common.lua>) (Zeile 1016) → [components/inspectable.lua — GetDescription](<../../../_scripts/scripts_02_10_2026/scripts/components/inspectable.lua>) (Zeile 53) / [widgets/hoverer.lua — HoverText:OnUpdate](<../../../_scripts/scripts_02_10_2026/scripts/widgets/hoverer.lua>) (Zeile 38) → [networkclientrpc.lua — AddModRPCHandler](<../../../_scripts/scripts_02_10_2026/scripts/networkclientrpc.lua>) (Zeile 1834) → [components/edible.lua — GetHealth](<../../../_scripts/scripts_02_10_2026/scripts/components/edible.lua>) (Zeile 121) / [components/perishable.lua — GetPercent](<../../../_scripts/scripts_02_10_2026/scripts/components/perishable.lua>) (Zeile 3) / [components/timer.lua — GetTimeLeft](<../../../_scripts/scripts_02_10_2026/scripts/components/timer.lua>) (Zeile 20).

## Altlasten und konkrete Prüfgrenze

Die Hint-RPC prüft Componentexistenz, aber keine vollständige Typ-/Entfernungs-/Cooldownkette. Clientthrottling ist keine Servervalidierung; GUID und übergebene Entity können widersprechen. Keine neue allgemeine Stats-API aus kopierten Sonderformeln ableiten: Schaden/Temperatur verändern sich mit Charakter und Umgebung. Besonders kopierte edible-/combat-Formeln bei jedem Update neu auditieren; vollständige Genauigkeit jeder Sonderanzeige bleibt offen.

## Szenarien für die spätere Laufzeitabnahme

Ziel schnell wechseln, leeres Hint, Entity löschen, hoher Lag, lange Texte/Übersetzungen. Nahrung mit Foodmemory, Rüstung mit Upgrade, Timerpause, private Container und Clientrelevanz. Save/Load/Reconnect/Shardwechsel und zweiter Spieler: nur eigene Anfrage/Antwort im eigenen Hovertext. Neue eng begrenzte Umsetzung: [Vorlage 10](../templates/10_query_ui/README.md).

Alle Szenarien sind **offen**. Für Dedicated-Server, separaten Client, Reconnect und Shardwechsel gelten zusätzlich die [allgemeinen Checklisten](../19_Checklisten.md). Statische Symbol-/Hashprüfung ersetzt diese Abnahme nicht. [Katalog](../16_Workspace_Mods.md) · [Abdeckungsmatrix](../21_Abdeckungsmatrix.md) · [Projektworkflow](../20_Projektworkflow.md).


## Dateiregister: Show Me (Serp) 732456848

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [modinfo.lua](<../../Show Me (Serp) 732456848/modinfo.lua>)
- [modmain.lua](<../../Show Me (Serp) 732456848/modmain.lua>)


## Erneute Prüfung: Hintprotokoll und Schätzwerte

Der Hintpfad in [`Show Me (Serp) 732456848/modmain.lua`](<../../Show Me (Serp) 732456848/modmain.lua>) sendet GUID+Entity, berechnet serverseitig Componentinformationen und schreibt einen GUID-markierten Hint auf player_classified. Der Hoverer zeigt nur zur Ziel-GUID passende Antworten. Serverprüfung von Entity/GUID/Entfernung/Berechtigung bleibt zusätzlich nötig. Die Clientdrossel begrenzt lediglich normalen Clientcode. Leere Antwort, verlorenes Ziel und verzögerte Antwort sind eigene Fälle.

MY_DATA.sym trennt Feldtypen mit Steuerzeichen und Parameter mit Kommas; Fremdtexte sind nicht automatisch escaped. LOCAL_STRING_CACHE ist nur deklariert: Daraus folgt kein wachsender aktiver Hintcache. GetTestString setzt is_admin zu Beginn jeder Hintberechnung zurück; daraus folgt kein Transfer des ersten Betrachters auf alle späteren Anfragen. last_user_talbe bleibt jedoch erhalten und wird erst bei nicht gefundener UserID neu geladen: geänderte Adminrechte einer bekannten UserID können veraltet bleiben. Anzeigeetikett ist kein Autorisierungsvertrag.

Verderbniszeit ist eine historische Nachberechnung. Das aktuelle [`components/perishable.lua`](<../../../_scripts/scripts_02_10_2026/scripts/components/perishable.lua>) übergibt dem Preserver den Gegenstand, nimmt Temperatur an der Besitzerposition, behandelt Pocketcontainer, unabhängigen Spoilerfaktor, ignorewentness und zusätzliche Acidrain-Abnahme. Show Mes Kopie bildet diese Kette nicht vollständig ab. Nullrate, negative Regeneration und Pause brauchen getrennte Darstellung; angezeigte Sekunden sind eine Schätzung.

CalcDamage liest einfache Damagewerte und berechnet Mountgrundwerte, verwendet im Ergebnis aber den Modifier des ursprünglichen Combat. Heute berücksichtigt [`components/combat.lua`](<../../../_scripts/scripts_02_10_2026/scripts/components/combat.lua>) weapon:GetDamage(attacker,target), Zieltypboni, Reittier/Sattel, PvP und Spezialschadentabellen. Planarschaden und Zielresistenzen sind nicht verlässlich aus nominalem Damage rekonstruiert. Neue UI ausdrücklich als Grundwert, Angriffsberechnung oder erwarteten Treffer kennzeichnen.

Felder verzweigen nach Components: Vitalwerte/Follower, Wachstum/Ernte/Kochen, Ausrüstung/Isolation, Foodmemory/Spices, Uses/Fuel/Perish, Timer und optionale Fremdmods. timer und worldsettingstimer besitzen verschiedene Verträge. Fehlendes Feld ist nicht automatisch Null. Classified und Hint entstehen nach Reconnect neu; kein eigener persistenter Tooltipzustand. Offen: stale/empty Reply, Adminwechsel, dynamische Waffen, Mount, Acidrain, private Container, Pocketcontainer, Fremdtexte und mehrere Tooltipmods.


Konkrete zusätzliche Funktionsdefinitionen: [Vertragsbelege](../27_Vertragsbelege.md). Die [Reviewmatrix](../REVIEW_MATRIX.json) trennt Einstiegssichtung und ausgewählte vertiefte Abläufe; weitere Featureänderungen benötigen einen eigenen aktuellen Audit.
