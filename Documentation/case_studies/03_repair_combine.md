# Repair Combine – Auswahl, Action und Haltbarkeitsdaten

**Prüfart:** statische Ablaufanalyse; wesentlicher Ablauf beschrieben. Keine Ingame-Funktionszusage. Alle Verzeichnisse: `Repair Combine 767776640`.

## Einstieg und Abhängigkeiten

[Repair Combine 767776640/modmain.lua — AddPrefabPostInitAny](<../../Repair Combine 767776640/modmain.lua>) (Zeile 28) versieht passende serverseitige Gegenstände mit combinerepairable; Konfiguration unterscheidet finiteuses, armor, fueled und perishable. Manche fremden Prefabs werden ausgenommen. [Repair Combine 767776640/scripts/components/combinerepairable.lua — Repair](<../../Repair Combine 767776640/scripts/components/combinerepairable.lua>) (Zeile 2) enthält die eigentliche Mutation.

## Initialisierung, Interaktion und Serverwirkung

USEITEM findet ein gleichnamiges Ziel anhand Tags. Die serverseitige COMBINEREPAIR-Action delegiert mit doer und invobject an die Zielcomponent. Beide wilson-Stategraphs bekommen dolongaction, sodass der Client die Action darstellen und vorhersagen kann. Der Server bestimmt dann den tatsächlichen Erfolg; bloße Clientauswahl verbraucht nichts.

Repair führt komponentenspezifische Addition aus. Normalmodus summiert Prozentwerte plus Bonus; manche Waffen werden auf eine begrenzte Resthaltbarkeit eingeschränkt. Overmax verändert zusätzlich die Maximalgröße. Perishables berücksichtigen Stackgrößen und eine eigene Bonusberechnung. Bei erfolgreicher Änderung verbraucht Stackable:Get genau eine Einheit; sonst das Materialobjekt. Daher müssen Ziel und Quelle unabhängig geprüft werden, nicht nur gleiche Prefabnamen.

## Replikation, UI, Speicherung und Wiederherstellung

Tags ermöglichen Actionsammlung auf Clients, während Komponentenmutationen serverseitig bleiben. Wrapper speichern vergrößerte Maximalwerte zusätzlich zu aktuellen Werten und stellen sie vor dem bisherigen OnLoad wieder her. Vier Haltbarkeitssysteme haben unterschiedliche Vanilla-Saveformen; eine einheitliche Prozenttabelle wäre falsch. Der Stack-Split-Wrapper soll Perishtime übernehmen; Vanilla übernimmt beim Teilen bereits perishremainingtime, nicht automatisch jede modifizierte Maximalgröße.

## Cleanup und Lebensdauer

OnRemoveFromEntity entfernt das eigene Tag. Verbrauch der Materialentity ist der irreversible Teil der erfolgreichen Action. Callbackketten, ausgerüstete Items und Containerowner müssen bei Fehlern erhalten bleiben. Eigene Datenvariablen müssen lokal sein und Rückgaben einschließlich etwaiger Referenzen bewahrt werden.

## Aktuelle Vanilla-Kette

[componentactions.lua — USEITEM](<../../../_scripts/scripts_02_10_2026/scripts/componentactions.lua>) (Zeile 133) → [bufferedaction.lua — Do](<../../../_scripts/scripts_02_10_2026/scripts/bufferedaction.lua>) (Zeile 22) → [stategraphs/SGwilson.lua — dolongaction](<../../../_scripts/scripts_02_10_2026/scripts/stategraphs/SGwilson.lua>) (Zeile 961) / [stategraphs/SGwilson_client.lua — dolongaction](<../../../_scripts/scripts_02_10_2026/scripts/stategraphs/SGwilson_client.lua>) (Zeile 323) → [components/finiteuses.lua — SetPercent](<../../../_scripts/scripts_02_10_2026/scripts/components/finiteuses.lua>) (Zeile 120) / [components/armor.lua — SetCondition](<../../../_scripts/scripts_02_10_2026/scripts/components/armor.lua>) (Zeile 90) / [components/fueled.lua — SetPercent](<../../../_scripts/scripts_02_10_2026/scripts/components/fueled.lua>) (Zeile 255) / [components/perishable.lua — SetPercent](<../../../_scripts/scripts_02_10_2026/scripts/components/perishable.lua>) (Zeile 209) → [components/stackable.lua — function Stackable:Get](<../../../_scripts/scripts_02_10_2026/scripts/components/stackable.lua>) (Zeile 109). Save/Load in allen vier Komponenten gehört zum selben Audit.

## Altlasten und konkrete Prüfgrenze

OnSave-Wrapper verwenden stellenweise data ohne local; das ist geteilter Umgebungszustand. Originalreferenzen werden nicht durchgehend weitergereicht. Direkte Maximalfeldänderung kann zusätzliche Replica-/Callbackverträge übergehen. Reparieren, Stapeln und echte dauerhafte Aufwertung sind unterschiedliche Features: für neue Items lieber eigene versionierte Upgradecomponent mit gezielt abgeleiteten Maxima verwenden. Keine Behauptung allgemeiner Kompatibilität mit jedem fremden Haltbarkeitssystem.

## Szenarien für die spätere Laufzeitabnahme

Je finiteuses/armor/fueled/perishable ein fast leeres, halbes und volles Paar; unterschiedliche Prefabs und eigene Quelle/Ziel ablehnen. Overmax aus/an, Stackgrößen 1/10 und ausgerüstete Quelle. Clientunterbrechung der langen Action darf kein Material vernichten. Nach Save/Load aktueller und maximaler Wert identisch; Stack teilen/mergen und erneut speichern. Dedicated sowie Migration des aufgewerteten Items. Eine neue Action beginnt mit [Vorlage 04](../templates/04_action/README.md).

Alle Szenarien sind **offen**. Für Dedicated-Server, separaten Client, Reconnect und Shardwechsel gelten zusätzlich die [allgemeinen Checklisten](../19_Checklisten.md). Statische Symbol-/Hashprüfung ersetzt diese Abnahme nicht. [Katalog](../16_Workspace_Mods.md) · [Abdeckungsmatrix](../21_Abdeckungsmatrix.md) · [Projektworkflow](../20_Projektworkflow.md).


## Rechenregeln und ein weiterer statischer Befund

Im Normalmodus gilt für finiteuses `max(min(pZiel+pQuelle+Bonus,maxweapon),0.01)`; armor/fueled beginnen mit `max(pZiel+pQuelle+Bonus,0.01)` und überlassen die obere Begrenzung ihrem Setter. Perishable verwendet `pZiel+pQuelle/StackgrößeZiel+Bonus`, nur wenn beide Items auch equippable besitzen. Es ist also keine allgemeine Frischeaddition für beliebige Nahrung.

Overmax-finiteuses/fueled addieren absolute Restmengen, multiplizieren mit 1+Bonus, runden auf und setzen Maximalgröße auf das Maximum der vorhandenen Maxima und neuen Restmenge. Perishable teilt nur den Quellrest durch Zielstackgröße. **Armor weicht ab:** das math.max verwendet repair_item.components.armor.condition statt dessen maxcondition. Bei bereits unterschiedlich aufgewerteten Rüstungen kann der größere Quell-Maximalwert deshalb verloren gehen. Das ist der konkrete gelesene Ausdruck, kein bestätigter Ingamefehler.

Besondere Bonusconfigzahlen kodieren Zufallsmodi: 0,05 → 0..5 Prozent, 0,1 → 0..10, -0,05 → -5..0, -0,15 → -5..10, -0,55 → -5..5. Andere Werte werden ebenfalls durch100 geteilt. Neue Configs sollten explizite Modusnamen und eine getrennte numerische Bonusgröße benutzen, damit solche Sentinels nicht als normale Dezimalprozente missverstanden werden.


## Dateiregister: Repair Combine 767776640

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [modinfo.lua](<../../Repair Combine 767776640/modinfo.lua>)
- [modmain.lua](<../../Repair Combine 767776640/modmain.lua>)
- [scripts/components/combinerepairable.lua](<../../Repair Combine 767776640/scripts/components/combinerepairable.lua>)


## Erneute Prüfung: Zweigpriorität und Verbrauch

Repair entscheidet per elseif: finiteuses vor armor vor fueled vor equippable-perishable. Ein Item mit mehreren Haltbarkeitscomponents erhält also nicht alle Werte gleichzeitig. Normalmodus addiert Prozent+Bonus; Overmax addiert absolute Werte und verändert Maxima. Der armor-Overmaxzweig benutzt als einen Maxvergleich material.condition statt material.maxcondition; das entspricht keiner allgemeinen Vereinigung beider Maxima. Perishable teilt den Materialanteil durch Zielstackgröße. Bonus-Sonderzahlen wählen Zufallsintervalle, die erst danach durch 100 geteilt werden; nicht mit einem direkten Faktor gleicher Zahl gleichsetzen.

Nach erfolgreicher Mutation wird eine Materialstackeinheit bzw. das Materialentity entfernt. Die Reparaturcomponent erhält doer, verwendet ihn aber nicht für eine eigene allgemeine Eigentümer-/Abstandsprüfung. UI-Mount-/Heavy-Lifting-Prüfungen sind keine solche Serverprüfung. Ähnliche Mods zusätzlich Ziel≠Material, aktuelle Gültigkeit, erlaubte Component, Besitz und notwendige Actionreichweite am autoritativen Weg festlegen. Bei Savewrappern alle Rückgaben/Referenzen erhalten und private Daten lokal halten. Tests müssen jedes System, Doppelcomponents, Stack, Overmax und beschädigtes Material getrennt erfassen.


Konkrete zusätzliche Funktionsdefinitionen: [Vertragsbelege](../27_Vertragsbelege.md). Die [Reviewmatrix](../REVIEW_MATRIX.json) trennt Einstiegssichtung und ausgewählte vertiefte Abläufe; weitere Featureänderungen benötigen einen eigenen aktuellen Audit.
