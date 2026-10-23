# Home Base Bonus – cachebasierte Umgebungseffekte

**Prüfart:** statische Ablaufanalyse; Architektur und wesentliche Pfade beschrieben; offene Spezialverträge unten. Keine Ingame-Funktionszusage. Alle Verzeichnisse: `Home Base Bonus 738448215`.

## Einstieg und Abhängigkeiten

Konfiguration klassifiziert Bodentypen, Pflichtgebäude und Bonusarten. [Home Base Bonus 738448215/modmain.lua — CheckBase](<../../Home Base Bonus 738448215/modmain.lua>) (Zeile 279) sucht in base_range Structures/Licht/Wände; [Home Base Bonus 738448215/modmain.lua — UpdateorGet](<../../Home Base Bonus 738448215/modmain.lua>) (Zeile 441) ist der zentrale Cachezugriff. UI- und Netvar-Hooks liegen vor dem Serverreturn; tatsächliche Komponentenboni danach.

## Initialisierung, Interaktion und Serverwirkung

Gebäudesuche setzt Bedingungen für Science/Magic/Cookpot/Chest/Dryrack/Blitzableiter/Farm/Birdcage/Licht/Wände. Bodenprüfung entscheidet, ob dieser Basistest überhaupt nötig ist. Cache speichert Position/Tile, Basisstatus und Wärme mit Zeitstempel; updatePlayer/updateStructure/updateOther bestimmen Aktualisierung. Wiederholte Componenttasks rufen UpdateorGet und setzen/entfernen zugehörige Bodenboni. Eigenes Absorb-/Damage-/Period-Modifikatorsystem ergänzt ältere Komponentenfunktionen. Speed/Sanity/Temperature/Moisture benutzen die entsprechenden Werte/Wrapper; es ist kein einzelner globaler Buff.

## Replikation, UI, Speicherung und Wiederherstellung

Net_tinybyte überträgt Basisstatus fürs HUD; MRate-Netfloat dient Feuchtigkeitsdarstellung. GetIsWet-Wrapper liest Replica oder löst auf Clients Serveranfrage aus, die ein eigenes Wet-Tag berechnet. Cache ist pro Runtime und wird nicht gespeichert; nach Laden wird Umgebung aus neu geladenen Entities neu bestimmt. Daher keine stale Cachewerte als Savezustand behandeln. Tile/Builderkennung alter Farmplots umfasst moderne Farm Soil nicht automatisch.

## Cleanup und Lebensdauer

Cache enthält Entityschlüssel und wird bei MaxCache geleert; das begrenzt Wachstum, ersetzt aber keine gezielte Entnahme ungültiger Entities. Boden verlassen/Basis unvollständig: eigene Boni entfernen und Icon zurücksetzen. Neue Implementierung sollte pro Entity/Bonus Quelle+Schlüssel statt pauschalem Reset nutzen und Taskhandles besitzen.

## Aktuelle Vanilla-Kette

[components/locomotor.lua — SetExternalSpeedMultiplier](<../../../_scripts/scripts_02_10_2026/scripts/components/locomotor.lua>) (Zeile 490) → [components/combat.lua — externaldamagemultipliers](<../../../_scripts/scripts_02_10_2026/scripts/components/combat.lua>) (Zeile 65) / [components/health.lua — SetAbsorptionAmount](<../../../_scripts/scripts_02_10_2026/scripts/components/health.lua>) (Zeile 440) → [components/temperature.lua — GetInsulation](<../../../_scripts/scripts_02_10_2026/scripts/components/temperature.lua>) (Definitionszeile 254) / [components/moisture.lua — waterproofnessmodifiers](<../../../_scripts/scripts_02_10_2026/scripts/components/moisture.lua>) (Zeile 45) / [components/sanity.lua — custom_rate_fn](<../../../_scripts/scripts_02_10_2026/scripts/components/sanity.lua>) (Zeile 107). GetIsWet und Eventcleanup: [entityscript.lua — GetIsWet](<../../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 689) / [entityscript.lua — RemoveAllEventCallbacks](<../../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 1232).

## Altlasten und konkrete Prüfgrenze

Quellenspezifische Listen sind aktuell vorhanden, während die Mod teils eigene additive Tabellen benutzt: Semantik nicht automatisch durch aktuelle multiplicative Listen ersetzen. Native FindEntities-Kosten sind Lua-seitig nur über Aufruffrequenz/Radien bewertbar. Wetter/Sonderböden, mehrere Bonusmods und Cacheinvalidierung bleiben Integrationsgrenzen; daraus wird kein universelles Basis-Erkennungssystem abgeleitet.

## Szenarien für die spätere Laufzeitabnahme

Bodentyp wechseln, Gebäude entfernen, Radiusgrenze betreten/verlassen; Icon/Speed/Schaden/Regenisolierung zeitnah konsistent. Zwei Spieler auf unterschiedlichen Böden, Cache nach Save/Load leer, Höhlen mit anderen Strukturen, Client-Reconnect. Dedicatedprofil: Suchanzahl und Gesamtkosten messen. Fremden Modifier setzen und Basis verlassen: fremder Wert bleibt.

Alle Szenarien sind **offen**. Für Dedicated-Server, separaten Client, Reconnect und Shardwechsel gelten zusätzlich die [allgemeinen Checklisten](../19_Checklisten.md). Statische Symbol-/Hashprüfung ersetzt diese Abnahme nicht. [Katalog](../16_Workspace_Mods.md) · [Abdeckungsmatrix](../21_Abdeckungsmatrix.md) · [Projektworkflow](../20_Projektworkflow.md).


## Dateiregister: Home Base Bonus 738448215

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [customsettings.lua](<../../Home Base Bonus 738448215/customsettings.lua>)
- [insight_descriptors/HBB_prefabdescriptor.lua](<../../Home Base Bonus 738448215/insight_descriptors/HBB_prefabdescriptor.lua>)
- [modinfo.lua](<../../Home Base Bonus 738448215/modinfo.lua>)
- [modmain.lua](<../../Home Base Bonus 738448215/modmain.lua>)


## Erneute Prüfung: unterschiedliche Bonusrechnungen und Rückbau

[`Home Base Bonus 738448215/modmain.lua`](<../../Home Base Bonus 738448215/modmain.lua>) hat mehrere Rechenmodelle. Health führt eigene Absorptionsschlüssel und addiert/subtrahiert am rohen Absorptionswert. Combat bildet 1+Summe(Boni), skaliert Grundschaden ohne flachen Damagebonus und erhält die Spezialschaden-Rückgabe. Speed nutzt vorhandene externe Modifier mit Quelle/Key; Sanity verkettet die Customfunktion; Isolation und Moisture sind eigene Wrapper. Das ist keine einheitliche SourceModifierList-Architektur.

Aktuelle Gegenstücke: [`components/combat.lua`](<../../../_scripts/scripts_02_10_2026/scripts/components/combat.lua>) CalcDamage, [`components/health.lua`](<../../../_scripts/scripts_02_10_2026/scripts/components/health.lua>), [`util/sourcemodifierlist.lua`](<../../../_scripts/scripts_02_10_2026/scripts/util/sourcemodifierlist.lua>). Pro Eigenschaft tatsächliche Kombinationsart wählen. Ein Rohwertbonus kann beim Rückbau einen inzwischen fremd ersetzten Wert verändern. Quellenmodifier werden mit gleicher Quelle/Key gezielt entfernt; Defaultmultiplikatoren werden multipliziert. Auf Reittieren ist der Damagebesitzer nicht immer der Spieler.

`CheckBase` sucht Strukturen/Lichter/Wände und zählt mit elseif, also nicht jede passende Kategorie gleichzeitig. Alte slow_farmplot/fast_farmplot-Namen decken moderne Farmgebäude nicht vollständig ab. Die frühe „Basis vorhanden“-Rückgabe prüft die vier Anforderungen Insulation/Speed/Rainproof/Sanity, nicht zusätzlich Damage/Absorb. Nur letztere Anforderungen sind daher ein eigener Sonderfall.

Die Registrierung des Temperaturewrappers wiederholt den Summer-Checker dreimal statt die Sommerbodenoptionen unabhängig zu prüfen. Ausschließlich Summerwood/-carpet ohne Winterbonus muss separat geprüft werden. Aktuelle GetInsulation in [`components/temperature.lua`](<../../../_scripts/scripts_02_10_2026/scripts/components/temperature.lua>) berücksichtigt Ausrüstung, Jahreszeit und weitere Quellen; keine universelle einzelne Isolationszahl.

Der Positions-/Zeitcache enthält abgeleitete Umgebungsdaten, keine gespeicherten Spielerfortschritte; sein Limit leert die Tabelle. Boden-, Bau- und Wetterwechsel benötigen Neumessung. Der GetIsWet-Clientpfad fragt Entities per RPC ab; Transportgrenzen ersetzen weder Entfernung noch Berechtigung/Geschäftsbudget. Nach Load Basis neu messen, eigene Quellen installieren und beim Verlassen gezielt entfernen. Offen: Grounditems gegenüber getragenen Items, Feuer/Regen, fremde Rohwertänderungen, Clientprediction und Gebäudeabbau im Cache.


Konkrete zusätzliche Funktionsdefinitionen: [Vertragsbelege](../27_Vertragsbelege.md). Die [Reviewmatrix](../REVIEW_MATRIX.json) trennt Einstiegssichtung und ausgewählte vertiefte Abläufe; weitere Featureänderungen benötigen einen eigenen aktuellen Audit.
