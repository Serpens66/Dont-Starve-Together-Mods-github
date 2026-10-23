# Ausrüstung mit eigenem Bonus

Eigenständiger Modordner: den gesamten Inhalt dieses Ordners einschließlich `scripts` in einen neuen lokalen Modordner kopieren; nicht nur modmain in eine andere Vorlage einfügen. Vanilla-Assets benötigen keine eigenen Exporte. Die Beispieldateien haben eindeutige Namen. Vor Integration Namen, Konfiguration, Ladeordnung und gleichzeitige andere Hooks prüfen.

## Dateien und Zuständigkeit

- `modinfo.lua`
- `modmain.lua`
- `scripts/prefabs/doc_bonus_spear.lua`

## Funktionsweise und Grenzen

Der Speer hat Basisschaden 20, 50 Anwendungen und einen serverseitigen Faktor 1,25 auf ausgehenden Kampfschaden des Trägers. Entityquelle plus eigener Schlüssel erlauben unabhängiges Entfernen; Unequip entfernt nur diesen Bonus. SourceModifierList entfernt Entityquellen außerdem bei onremove. Nach Laden rekonstruiert Equip den Bonus; Modifierlisten selbst werden nicht als Tabellen gespeichert. Kein Bewegungsbonus: dessen Client-Prediction ist ein eigener Vertrag. Berittene Angriffe und spezielle Damage-Typen benötigen zusätzliche Tests.

## Quellenkette des statischen Audits

[prefabs/spear.lua — onequip](<../../../../_scripts/scripts_02_10_2026/scripts/prefabs/spear.lua>) (Zeile 7) → [components/equippable.lua — function Equippable:Equip](<../../../../_scripts/scripts_02_10_2026/scripts/components/equippable.lua>) (Zeile 92) / [components/inventory.lua — function Inventory:Unequip](<../../../../_scripts/scripts_02_10_2026/scripts/components/inventory.lua>) (Zeile 1219) → [util/sourcemodifierlist.lua — SetModifier](<../../../../_scripts/scripts_02_10_2026/scripts/util/sourcemodifierlist.lua>) (Zeile 64) / [util/sourcemodifierlist.lua — RemoveModifier](<../../../../_scripts/scripts_02_10_2026/scripts/util/sourcemodifierlist.lua>) (Zeile 74) → [components/combat.lua — externaldamagemultipliers:Get()](<../../../../_scripts/scripts_02_10_2026/scripts/components/combat.lua>) (Zeile 915).

## Testprotokoll – offen, keine Spielinstanz gestartet

1. Host und Client: denselben Gegner ohne Rüstung mit normalem Trainingsspeer und Bonusspeer treffen; Standardfall 20 gegenüber 25 vor weiteren Faktoren. Anderen Faktor gleichzeitig setzen: Produkt prüfen.
2. Unequip, direkter Waffenwechsel, Fallenlassen, Diebstahl, Verbrauch der letzten Anwendung, Tod: Bonus verschwindet; fremder Faktor bleibt.
3. Dedicated, Reconnect und Save/Load mit ausgerüstetem Speer: Bonus genau einmal.
4. Höhlenwechsel mit ausgerüsteter Waffe sowie Reittier-/Sonderangriff testen; keine Aussage, dass alle Damagekanäle denselben Faktor verwenden.

Syntaxprüfung mit `luac5.1.exe -p` prüft weder Engine-Globals noch Assets, Prediction oder Multiplayer. Ergebnisse stehen im [Prüfbericht](../../VALIDATION.md). Für ein neues Projekt außerdem den [Workflow](../../20_Projektworkflow.md) und die [Checklisten](../../19_Checklisten.md) verwenden.


## Erneute statische Prüfung

Ladeumgebung, Registrierungen, Vanilla-Aufrufer, Rollen, Speicherung und Cleanup erneut geprüft. [Vorlagenmatrix](../../24_Statische_Vertragspruefung.md#zwölf-vorlagen-geprüfte-schnittstellen) benennt Sonderfälle und Grenzen. [Isolierte Tests](../../tests/README.md) gelten nur für die dort genannten Logikpfade, keine Laufzeitabnahme dieser Mod.
