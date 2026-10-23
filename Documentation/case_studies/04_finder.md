# FinderMod – private Suche und öffentliche Markierung

**Prüfart:** statische Ablaufanalyse; wesentlicher Ablauf beschrieben. Keine Ingame-Funktionszusage. Alle Verzeichnisse: `FinderMod 786654500`.

## Einstieg und Abhängigkeiten

[FinderMod 786654500/modmain.lua — init(inst)](<../../FinderMod 786654500/modmain.lua>) (Zeile 209) legt pro Spieler 50 net_entity-Felder an. newactiveitem und IngredientUI-Focus bilden zwei Auslöser; Craft Pot ist eine zusätzliche externe Integration. Die Clientoption active schaltet die Darstellung ab.

## Initialisierung, Interaktion und Serverwirkung

Client leert bestehende Highlights und sendet prefab/source/unhighlighten/highlighten. Host ruft die Serverfunktion direkt; separater Client benutzt RPC. [FinderMod 786654500/modmain.lua — ServerRPCFunction](<../../FinderMod 786654500/modmain.lua>) (Zeile 97) sucht innerhalb 20 Einheiten gültige sichtbare _container, schließt Spieler/INLIMBO/FX usw. aus und prüft container:Has(prefab,1). Passende Container werden in freie Netfelder gelegt. CraftPot-Markierung verwendet einen Tag am Container, damit ein bestimmter Schließpfad selektiv zurücksetzt.

## Replikation, UI, Speicherung und Wiederherstellung

Dirty-Handler des lokalen Spielers fügt highlight hinzu und setzt ApplyColour/UnHighlight-Wrapper. Diese addieren Farbe temporär und stellen Ausgangswerte wieder her. Unhighlight stellt Overrides zurück und ruft die Vanilla-Methode. Suchergebnisse sind flüchtig: kein OnSave für die 50 Felder. Reconnect benötigt eine neue Suche. Die Netfelder am Spieler sind keine owner-targeted Classified-Geheimhaltung; die Clientbedingung begrenzt Anzeige, nicht prinzipiell Verteilung.

## Cleanup und Lebensdauer

Reset läuft Client-Unhighlight → Server nil → Server neue Entitywerte → Client Dirty. Entfernte Container können ungültig werden; alle Highlightpfade müssen das verkraften. CraftPot-Tag ist pro Container statt pro Sucher und kann sich zwischen mehreren Spielern beeinflussen. Focusverlust setzt zurück; Entfernen von Widgets/Spielern muss ebenfalls Farbe entfernen.

## Aktuelle Vanilla-Kette

[components/container.lua — function Container:Has](<../../../_scripts/scripts_02_10_2026/scripts/components/container.lua>) (Zeile 826) → [networkclientrpc.lua — AddModRPCHandler](<../../../_scripts/scripts_02_10_2026/scripts/networkclientrpc.lua>) (Zeile 1834) → [components/highlight.lua — ApplyColour](<../../../_scripts/scripts_02_10_2026/scripts/components/highlight.lua>) (Zeile 22) / [components/highlight.lua — UnHighlight](<../../../_scripts/scripts_02_10_2026/scripts/components/highlight.lua>) (Zeile 119) → [entityscript.lua — DoTaskInTime](<../../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 1522). Hier ist der letzte Parameter eine Funktion, kein bereits ausgeführter Handler.

## Altlasten und konkrete Prüfgrenze

RegisterListeners verwendet DoTaskInTime(0,OnDirtyEventSearchedChest(inst,i)): der Handler wird sofort ausgewertet, sein Rückgabewert als Taskcallback übergeben. Das ist ein konkreter statischer Vertragsverstoß. RPC-Argumente sind außerdem unzureichend typisiert/begrenzt; Radius allein verhindert keine Anfrageflut. Für neue Mods Anfragebudget, feste erlaubte Präfabs/Quellen und Existenzprüfungen hinzufügen. Entity-Netwerte benötigen Sichtbarkeit/Relevanz, eine GUID allein erzeugt keine Cliententity.

## Szenarien für die spätere Laufzeitabnahme

Zwei Spieler suchen gleichzeitig unterschiedliche Gegenstände; 0/1/50/>50 passende Behälter. Container entfernen während Suche, Focus verlieren, Craft Pot schließen, Reconnect und Höhlenwechsel. Ungültige RPCwerte und Anfrageflut. Neues engeres Kommunikationsbeispiel: [Abfrage-UI](../templates/10_query_ui/README.md).

Alle Szenarien sind **offen**. Für Dedicated-Server, separaten Client, Reconnect und Shardwechsel gelten zusätzlich die [allgemeinen Checklisten](../19_Checklisten.md). Statische Symbol-/Hashprüfung ersetzt diese Abnahme nicht. [Katalog](../16_Workspace_Mods.md) · [Abdeckungsmatrix](../21_Abdeckungsmatrix.md) · [Projektworkflow](../20_Projektworkflow.md).


## Dateiregister: FinderMod 786654500

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [modinfo.lua](<../../FinderMod 786654500/modinfo.lua>)
- [modmain.lua](<../../FinderMod 786654500/modmain.lua>)


## Erneute Prüfung: Umgebungszugriff und Mehrspielersicht

ServerRPCFunction verwendet TheSim unqualifiziert, obwohl der Einstieg nur _G=GLOBAL definiert und der normale CreateEnvironment-Vertrag kein TheSim bereitstellt. Der spätere RPCaufruf ändert die Closureumgebung nicht. Für neuen Code explizit _G.TheSim verwenden. Das ist zusätzlich zum fehlerhaften bereits ausgeführten DoTaskcallback zu prüfen.

Die 50 Netentityfelder sind öffentliche Spielerfelder, keine private Classifiedantwort. Suchlimit und Clientoption begrenzen nicht prinzipiell die Verteilung. CraftPot-Tag/Highlighsource liegen pro Container, nicht pro Sucher; zwei Sucher können Reset-/Highlightzustand beeinflussen. Ein eigenes System Suchergebnisse pro Spieler isolieren, Quelle als Enum validieren, Anzahl/Budget begrenzen und Ownership der Highlightwrapper prüfen. Entfernte/nicht relevante Container dürfen keine sichtbare gültige Antwort voraussetzen. Stand entspricht einer erklärten historischen Architektur, keiner nachgewiesenen heutigen Funktionsfreigabe.


Konkrete zusätzliche Funktionsdefinitionen: [Vertragsbelege](../27_Vertragsbelege.md). Die [Reviewmatrix](../REVIEW_MATRIX.json) trennt Einstiegssichtung und ausgewählte vertiefte Abläufe; weitere Featureänderungen benötigen einen eigenen aktuellen Audit.
