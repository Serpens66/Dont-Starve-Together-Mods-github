# 20 – Einstieg für spätere Mod-Projekte

Dieses Kapitel ist der kurze Arbeitsstart für einen zukünftigen Assistenten oder Entwickler. Es führt gezielt zu geprüften Verträgen, statt die gesamte Sammlung für jede kleine Änderung neu zu lesen. Workspace-AGENTS.md und aktuelle Nutzeranweisungen gelten weiterhin vorrangig.

## Minimale Lesereihenfolge

1. Aktuelle Projektanforderung und Workspace-Anweisungen lesen. Ziel, Server-/Clientbedarf und vorhandenen Modstand erfassen.
2. [VALIDATION](VALIDATION.md) und Quellenstand im [Manifest](SOURCE_MANIFEST.json) prüfen. Statischer Erfolg ist keine Laufzeitfreigabe.
3. Passende Zeile der folgenden Tabelle auswählen, Kapitel und Vorlage lesen.
4. Den tatsächlichen Vanilla-Vertrag im aktuellen Scriptstand auditieren. Quellenhash und Kapitel helfen beim Finden; sie ersetzen diesen Audit nicht.
5. Eine kompakte Vertragsnotiz anlegen, dann erst implementieren. Offene fachliche Entscheidungen mit dem Nutzer klären.

## Auswahl nach Vorhaben

| Vorhaben | Zuerst lesen | Vanilla-Einstieg | Geeignetes Workspace-Beispiel | Vorlage |
|---|---|---|---|---|
| Existierenden Schaden/Wert ändern | [02](02_Ladeumgebungen_Hooks.md), [03](03_Prefabs_Components.md) | Zielprefab, Componentsetter, Hookzeitpunkt | More Explosive Range, Automatic Health Adjust | [01](templates/01_prefab_tweak/README.md) |
| Neues Item/Rezept | [06](06_Gegenstaende_Gebaeude_Container.md), [07](07_Crafting_Kochen.md), [12](12_Assets_Animation_Audio.md) | prefabs/spear.lua, recipe.lua, inventoryitem, equippable | Scythe als historischer Vergleich | [02](templates/02_item/README.md) |
| Eigener gespeicherter/replizierter Wert | [04](04_Multiplayer.md), [05](05_Persistenz.md) | entityscript, entityreplica, netvars, networkclientrpc | Food Queue | [03](templates/03_network_component/README.md) |
| Eigene Interaktion/Action | [08](08_Actions_Stategraphs.md), [04](04_Multiplayer.md) | componentactions, bufferedaction, beide Spieler-SGs | Repair Combine | [04](templates/04_action/README.md) |
| HUD/Text/Controller | [11](11_UI_Eingabe_Localisierung.md) | widgets/controls, widget, text, konkrete Inputkonsumenten | FinderMod, Home Base Bonus | [05](templates/05_client_ui/README.md) |
| Weltverteilung/Room | [10](10_Weltgenerierung.md) | map/level, storygen, graphnode, Zielroom | Increase Animals, Advanced World Generation | [06](templates/06_worldgen/README.md) |
| Container/Gebäude | [06](06_Gegenstaende_Gebaeude_Container.md), [05](05_Persistenz.md) | treasurechest, containers, container/replica | Trash Can mit dokumentierten Altlasten | [07](templates/07_container_building/README.md) |
| Kochen | [07](07_Crafting_Kochen.md), [28](28_Kochinhalte.md) | cooking, stewer, Produkt-Prefab und Cookbook | enges eigenes Rezept | [13](templates/13_cooked_food/README.md) |
| KI/Monster/Charakter | [09](09_Brains_Charaktere.md), [29](29_Kreaturen_Charaktere_Lebenszyklus.md), [08](08_Actions_Stategraphs.md) | ähnliches Prefab, Brain, SG, combat; player_common bei Spielern | Maxwell Shadows | [Abgegrenzte Fragmente](examples/README.md); eigene Assets erforderlich |
| Shard-/Weltwechsel | [04](04_Multiplayer.md), [05](05_Persistenz.md), [30](30_Multiplayer_Lebenszyklen.md) | playerspawner, player_common, shardnetworking | Teleportato/Adventure Mode als komplexer Sonderfall | Keine fertige Weltwechselvorlage |

Alle Modpfade und Einstiegsmodule stehen im [Katalog](16_Workspace_Mods.md). Die Benennung „historisch“ ist ein Warnsignal für einen neuen Vertragsvergleich, kein Verbot, den Code zu studieren.

## Gezielt suchen

PowerShell, aus dem Workspace; die folgenden Befehle sind lesend. Bei Aktualisierung den Pfad auf den verifizierten neuen Snapshot ändern.

```powershell
$dstScripts = 'D:\CDesktopLink\Unterlagen\Mods\DST\_scripts\scripts_02_10_2026\scripts'
rg -n 'SetDamage|OnSave|OnLoad' "$dstScripts\components\weapon.lua"
rg -n 'AddComponent\("weapon"\)|SetDamage' "$dstScripts\prefabs"
rg -n 'AddPrefabPostInit|AddComponentPostInit' 'More Explosive Range 763290344'
rg -n 'SetPristine|ismastersim' "$dstScripts\prefabs\spear.lua"
```

Definitionen danach vollständig im relevanten Zusammenhang lesen: Konstruktor → tatsächliche Aufrufer → späteres Prefabsetup → Clientsicht → Save/Load. Ein rg-Treffer ist kein abgeschlossener Audit. Quellenlinks nennen die Datei und das Symbol; Zeilen helfen beim Einstieg, können sich nach Updates verschieben.

[API-Register](15_API_Register.md) für vorhandene Signaturen verwenden. Nicht aus dem Gedächtnis einen Hook erfinden. Das Manifest enthält eine maschinenlesbare API-Liste mit Signatur, Zeile, Kontext und Verwendung sowie Hashes referenzierter Quellen. Es enthält außerdem das vollständige Lua-Dateiinventar der 26 Mods, ausdrücklich ohne Behauptung einer vollständigen Zeilenprüfung.

## Projektbezogene Vertragsnotiz

Für ein neues Projekt eine eigene Datei im Projektordner erstellen und knapp ausfüllen:

```text
Ziel und bewusst begrenzter Funktionsumfang:
Modtyp und erforderliche Clientdateien:
Verifizierter Snapshot/Archivhash:
Vanilla: Datei + Symbol + Aufrufer + Initialisierung:
Serverzustand und Client-Schnittstelle:
Ausgewählter Hook und Reihenfolge:
Netvar-/RPC-/Action-Registrierung:
Save-Schema, Defaults, Migration und Referenzen:
Task-/Event-/Watcher-Cleanup:
Assets, Strings und benötigte Werkzeuge:
Workspace-Beispiel und berücksichtigte Altlasten:
Unbekannte Verträge / noch notwendiger Audit:
Geplante Tests und tatsächlich geprüfte Ergebnisse:
```

Nur projektrelevante Abschnitte ausfüllen. Die Notiz darf eine offene Enginefrage benennen; sie darf eine ungesicherte Annahme nicht als Vertrag darstellen. Nach einer Änderung müssen Dokumentation und Teststatus den endgültigen Code beschreiben, nicht einen verworfenen Entwurf.

## Wiederverwendung und Wartung

Vorlagen vollständig kopieren und alle Präfixe konsistent ändern. Zwei unveränderte Kopien derselben Vorlage können Prefab-, Component-, Action- oder RPC-Namen kollidieren lassen. Modinfoflags, Defaults und Readmetests ebenfalls an die tatsächliche Mod anpassen.

Für einen unbekannten nächsten Featurevertrag zunächst im Kapitel „Grenzen“/Audit nachsehen. Das spart die Suche nach einer hier nicht behaupteten fertigen Lösung, beispielsweise neue Soundbank, komplexer Tile oder fertige eigene Charaktergrafik; für Classified-/Charakter-Lebenszyklen zusätzlich Kapitel 29–30 lesen. Anschließend konkrete neue Quellen und Konsumenten verfolgen.

Nach Spielupdates [Archivvergleich](tools/audit_scripts.py), featurebezogenen Diff und [Checklisten](19_Checklisten.md) verwenden. Neue Erkenntnisse gezielt in Kapitel, Katalog, Audit und Manifest einarbeiten; vollständige Vanilla-Dateien oder fremde Tutorials nicht als Wissensersatz kopieren. Neue Quellenstände erst nach erneuter fachlicher Prüfung als gültig markieren.


## Einstieg für spätere Projekte und Agenten

1. In [Abdeckungsmatrix](21_Abdeckungsmatrix.md) ähnliche Mods wählen. Passende Fallstudie komplett lesen, besonders Abhängigkeiten/Altlasten. Eine historische Variante ist kein aktueller Vertrag.
2. [Praxismechanismen](23_Praxismechanismen.md) und [Auditnachweise](22_Vertiefungs_Audits.md) als Suchindex benutzen. Nicht das gesamte Nachschlagewerk blind in einen Kontext laden: für das Feature die genannten Definitionen und Aufrufer gezielt vollständig lesen.
3. Im neuen Projekt kurz notieren: gewünschtes Verhalten, Server-/Clientbesitz, persistente/abgeleitete/flüchtige Daten, Fremdmodabhängigkeit, Quelle+Symbol+Stand und offene Engineverträge. Vor Codeentscheidung Vanilla-Audit abschließen.
4. Engste [Vorlage](templates/README.md) kopieren und Namen eindeutig ersetzen; neue Grenzen/Tests im Projekt festhalten. Komplexe Systeme aus Fallstudien ableiten, nicht eine ungeprüfte universelle Reset-/Innenraum-/Automationstemplate erfinden.
5. Referenzprüfer hält Doku/Quellen/Syntax auseinander; dessen Ergebnis ist kein Mod-Laufzeittest. Zum Projektabschluss tatsächliche Host-/Client-/Dedicated-/Save-/Reconnect-/Shardtests mit Logs protokollieren. Nicht ausgeführte Tests bleiben offen.

Eine eigene Arbeitsnotiz pro Projekt sollte **Entscheidungen**, **Quellenkette**, **Datenmodell**, **Teststatus** und **Restgrenzen** enthalten. Neue gesicherte Erkenntnisse als kleine verlinkte Ergänzung zurück in diese Dokumentation übernehmen; geänderte Scriptstände nicht durch stilles Aktualisieren der Hashes verdecken.


## Ergänzende Vertragsprüfung vom 03.10.2026

[Aufgabenindex](25_Aufgabenindex.md) verbindet Vorhaben, Quellen und Vorlagen. [Prüfgrenzen](24_Statische_Vertragspruefung.md), [API-Quellenketten](26_Quellenketten_API.md), [Reviewmatrix aller 26 Mods](REVIEW_MATRIX.json) und [isolierte Tests](tests/README.md) unterscheiden Inventar, Quellverträge, Logikergebnisse und offene Engineabnahme.
