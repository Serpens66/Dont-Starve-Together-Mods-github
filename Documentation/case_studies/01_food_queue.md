# Food Queue – vom Essen bis zum HUD

**Prüfart:** statische Ablaufanalyse; wesentlicher Ablauf beschrieben. Keine Ingame-Funktionszusage. Alle Verzeichnisse: `Food Queue 2843201996`.

## Einstieg und Abhängigkeiten

[Food Queue 2843201996/modmain.lua — AddReplicableComponent](<../../Food Queue 2843201996/modmain.lua>) (Zeile 2) registriert _foodbuffer; Konfiguration erzeugt sechs Multiplikatoren, Ausschlüsse und Favoritenregeln. Die UI benötigt foodbuffer-Assets. Insight ist optional und besitzt einen externen Descriptorvertrag, kein Vanilla-API.

## Initialisierung, Interaktion und Serverwirkung

PlayerPostInit prüft eater, Modcharakter-Option und vorhandenes foodmemory. Je Konfiguration wird foodmemory entfernt. Ein vorhandener custom_stats_mod_fn verhindert die Installation des eigenen Systems: die Mod beansprucht den Callback exklusiv. Die neue Component setzt den Nahrungsmodifier. Dieser liest die bisherige Queue und ändert health/hunger/sanity. Erst nach angewandten Deltas löst eater oneat aus; der Listener prüft das Lebensmittel und schiebt es in die Queue. Favoriten können vom Malus ausgenommen sein.

[Food Queue 2843201996/scripts/components/_foodbuffer.lua — AddToBuffer](<../../Food Queue 2843201996/scripts/components/_foodbuffer.lua>) (Zeile 94) ist daher eine Änderung für **zukünftige** Mahlzeiten. Die Schwellenprüfung verwendet die im Code abgefragten Grundwerte; sie ist keine Anzeige des tatsächlich beim Spieler angekommenen Deltas. Eine Mahlzeit an voller Gesundheit kann trotzdem als Mahlzeit registriert werden.

## Replikation, UI, Speicherung und Wiederherstellung

Die Component speichert den Buffer; Konfiguration und Multiplikatoren entstehen beim Start neu. [Food Queue 2843201996/scripts/components/_foodbuffer_replica.lua — net_string](<../../Food Queue 2843201996/scripts/components/_foodbuffer_replica.lua>) (Zeile 6) erzeugt sechs Felder. Serveränderungen schreiben sie; Getter lesen Strings. Der Inventorybar-Hook hängt das Widget verzögert an. [Food Queue 2843201996/scripts/widgets/foodbuffer.lua — OnUpdate](<../../Food Queue 2843201996/scripts/widgets/foodbuffer.lua>) (Zeile 76) liest den Zustand regelmäßig und aktualisiert IngredientUI-Symbole. Laden muss Componentdaten und ihre replizierte Darstellung konsistent wiederherstellen; late join darf nicht auf ein einmaliges lokales oneat warten.

## Cleanup und Lebensdauer

Entityeigene Events/Tasks enden beim Entfernen. Widget-Update endet mit dem Widget. Callbackbesitz ist zusätzlich zu prüfen, wenn die Component während des Spiels ersetzt/entfernt werden soll: ein installierter eater-Callback darf keine abgelöste Component weiter verwenden.

## Aktuelle Vanilla-Kette

[components/eater.lua — function Eater:Eat](<../../../_scripts/scripts_02_10_2026/scripts/components/eater.lua>) (Zeile 230) → [components/edible.lua — GetHunger](<../../../_scripts/scripts_02_10_2026/scripts/components/edible.lua>) (Zeile 96) / [components/foodmemory.lua — GetFoodMultiplier](<../../../_scripts/scripts_02_10_2026/scripts/components/foodmemory.lua>) (Zeile 53) → custom_stats_mod_fn → DoDelta → oneat → RememberFood. [entityscript.lua — ReplicateComponent](<../../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 599) / [entityscript.lua — SetPersistData](<../../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 1954) erklären Komponenten-Lebensdauer und Laden.

## Altlasten und konkrete Prüfgrenze

Widget UpdatePosition greift auf hudscale zu, ohne lokale Definition in dieser Datei. Ob ein fremder/globaler Wert existiert, ist eine Integrationsfrage; im isolierten Beispiel ist dieser Zugriff nicht abgesichert. Ferner boolean false versus String "false" prüfen: die Replica serialisiert Daten als Strings, der Widgettest j~=false ist kein Test auf den String. Keine bestätigte Ingame-Fehlermeldung. Für eine neue Implementierung Platzhalter explizit kodieren, Getter normalisieren und Dirty-Events statt Framepolling erwägen.

## Szenarien für die spätere Laufzeitabnahme

Frisches Profil: sechs unterschiedliche Gerichte, dann eines wiederholen, Favorit/Ausschluss/Schwelle testen. Queue halbvoll speichern/laden; Client später verbinden. Foodmemory Everyone und Warly mit beiden Ladeordnungen prüfen. HUD skalieren, Controller benutzen, Inventar öffnen/schließen, Tod und Höhlenwechsel. Neue Alternative: [persistente Historie](../templates/08_food_history/README.md).

Alle Szenarien sind **offen**. Für Dedicated-Server, separaten Client, Reconnect und Shardwechsel gelten zusätzlich die [allgemeinen Checklisten](../19_Checklisten.md). Statische Symbol-/Hashprüfung ersetzt diese Abnahme nicht. [Katalog](../16_Workspace_Mods.md) · [Abdeckungsmatrix](../21_Abdeckungsmatrix.md) · [Projektworkflow](../20_Projektworkflow.md).


## Konkretes Queue-Datenmodell und optionale Integration

[Food Queue 2843201996/scripts/components/_foodbuffer.lua — GetBaseFood](<../../Food Queue 2843201996/scripts/components/_foodbuffer.lua>) (Zeile 34) kann per Konfiguration Spicedfood auf basename normalisieren, ungekochte Varianten über Cookbook:RemoveCookedFromName ableiten und Samen zusammenfassen. Preparedfood wird beim cooked-/seed-Zweig ausgenommen. Der Buffer startet mit sechs boolean-false-Platzhaltern. AddToBuffer entfernt einen bereits vorhandenen Eintrag, entfernt bei voller Länge den ältesten Index1 und hängt den aktuellen Basisnamen hinten an. Neueste Mahlzeit ist damit am rechten/letzten Ende; die neue Historienvorlage verwendet ausdrücklich die umgekehrte MRU-Reihenfolge.

GetMultiplier benutzt `multipliers[#multipliers - #buffer + index]`, bei fehlendem Faktor 0,1, bei unbekanntem Essen1. IsProtected prüft normalisierten Namen gegen disabled/favorites. Oneat nimmt das Essen nur auf, wenn NoCheaseValue deaktiviert ist oder mindestens einer der drei edible-Getter mit eater=nil die Schwelle erreicht. Diese Getter können Verderb/Spice berücksichtigen; "Grundwert" bedeutet hier gerade nicht schlicht das rohe hungervalue-Feld.

OnLoad übernimmt buffer und schreibt anschließend Replica; anfängliche leere Netstrings und false-Platzhalter müssen im Widget robust behandelt werden. Insight wird per AddSimPostInit angebunden, bewahrt dessen Describe-Rückgaben über Insight.env.pack/vararg und erweitert alt_description. Für neue Integrationen diese externen Helper voraussetzen/prüfen, nicht durch Vanilla-unpack mit möglicherweise verlorenen nil-Rückgaben ersetzen.


## Dateiregister: Food Queue 2843201996

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [modinfo.lua](<../../Food Queue 2843201996/modinfo.lua>)
- [modmain.lua](<../../Food Queue 2843201996/modmain.lua>)
- [scripts/components/_foodbuffer.lua](<../../Food Queue 2843201996/scripts/components/_foodbuffer.lua>)
- [scripts/components/_foodbuffer_replica.lua](<../../Food Queue 2843201996/scripts/components/_foodbuffer_replica.lua>)
- [scripts/widgets/foodbuffer.lua](<../../Food Queue 2843201996/scripts/widgets/foodbuffer.lua>)


## Erneute Prüfung: Normalisierung, Queuegröße und Load

Der aktive _foodbuffer normalisiert Spices über spicedfoods.basename, gekochte Nichtpreparedfoods über Cookbook und ggf. Samen. Das ist keine allgemeine Aliasregistry für fremde Rezepte. Queuefolge ist älteste zuerst, neues Essen hinten; erneutes Essen entfernt seinen alten Eintrag. GetMultiplier benutzt die Position relativ zur konfigurierten Multiplikatorlänge. Eigene MRU-Vorlage 08 hält dagegen neueste zuerst; beide Datenformate nicht austauschen.

Replica hat exakt sechs Netstrings. SetBuffer schreibt nur übergebene Positionen und setzt fehlende Positionen nicht allgemein leer. Unvalidierter Load kann größere oder verkürzte Queue enthalten; alte Clientwerte/fehlende _buffer-Indizes sind deshalb explizite Migrationsfälle. Die aktuelle Konfiguration baut sechs Werte auf; neue frei variable Queuelänge erfordert ein neues Replikationsformat. oneat zählt anhand ursprünglicher edible-Werte, nicht tatsächlich angekommenem Healthdelta. Buff-/Foodmemory-/Stackeatorder ist weiter durch eater vorgegeben. Neues Loadformat auf Typ, Länge, erlaubte Namen und Platzhalter prüfen und anschließend alle sechs Clientpositionen konsistent schreiben. Kein vorhandener Modcode wurde geändert.


Konkrete zusätzliche Funktionsdefinitionen: [Vertragsbelege](../27_Vertragsbelege.md). Die [Reviewmatrix](../REVIEW_MATRIX.json) trennt Einstiegssichtung und ausgewählte vertiefte Abläufe; weitere Featureänderungen benötigen einen eigenen aktuellen Audit.
