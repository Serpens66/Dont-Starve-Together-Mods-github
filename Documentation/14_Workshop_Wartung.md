# 14 — Installation, Workshop und Wartung

## Lokales Testen

Jede Vorlage wird als kompletter eigener Ordner in das mods-Verzeichnis der Installation kopiert und dort aktiviert. Die Beispiele unter Documentation werden vom Spiel nicht automatisch gefunden. Alternativ kann eine bewusst eingerichtete Verzeichnisverknüpfung den Entwicklungsordner bereitstellen; vorhandene Mod-Ordner nicht überschreiben.

Client-UI als Client-Mod aktivieren; die Gameplay-/Netzwerkvorlagen als Server-Mod. Beim dedizierten Betrieb Installation/Download und Aktivierung unterscheiden: dedicated_server_mods_setup.lua bereitet Workshop-Downloads vor; modoverrides.lua bestimmt Aktivierung und Optionen im jeweiligen Shard.

Belege: [mods.lua — function ModWrangler:LoadServerModsFile](<../../_scripts/scripts_02_10_2026/scripts/mods.lua>) (Zeile 361), [modindex.lua — function ModIndex:ApplyEnabledOverrides](<../../_scripts/scripts_02_10_2026/scripts/modindex.lua>) (Zeile 419).

## Dedizierte Konfiguration als Beispiel

    -- dedicated_server_mods_setup.lua
    ServerModSetup("WORKSHOP_ID")

    -- modoverrides.lua; aktivierter Shard
    return {
        ["workshop-WORKSHOP_ID"] = {
            enabled = true,
            configuration_options = { enabled = true },
        },
    }

WORKSHOP_ID durch die echte ID ersetzen. Die Optionsnamen müssen aus der jeweiligen Mod stammen. Oberflächen- und Höhlen-Shard passend konfigurieren; eine Netvar-Mod darf nicht nur auf einem beteiligten Server-/Client-Pfad vorhanden sein.

## Veröffentlichung

Der lokale ModUploader.exe ist vorhanden. Die konkrete Oberfläche und Anmeldung wurden nicht gestartet; keine Workshop-ID wurde angelegt. Vor Upload modinfo, Beschreibung, Versionsnummer, benötigte Clients, Abhängigkeiten und Inhalt kontrollieren. Nur benötigte Runtime-Dateien veröffentlichen; Entwicklungsartefakte und Testkopien anhand des tatsächlichen Uploadumfangs ausschließen.

Die [Klei-Modding-Richtlinien](https://support.klei.com/hc/en-us/articles/360029555992-Modding-Don-t-Starve-and-Don-t-Starve-Together) verlangen für öffentliche Mods einen funktionierenden vollständigen Stand mit Beschreibung und Bildern. Fremde Arbeiten benötigen die entsprechende Erlaubnis und Attribution; Entitlement-Umgehung ist ausgeschlossen. Erlaubnisdetails und Credits dokumentieren. Diese Sammlung selbst veröffentlicht nichts.

## Ablauf nach Spielupdates

1. Archivmetadaten und SHA-256 prüfen; [audit_scripts.py](tools/audit_scripts.py) vergleicht Dateiinhalte.
2. Falls der Snapshot abweicht, scripts.zip in einen neuen datierten Ordner unter _scripts entpacken. Bestehende geprüfte Snapshots erhalten; nötige Dateisystemberechtigung beachten.
3. Tatsächlich verwendete Vanilla-Dateien und deren Aufrufer diffen, nicht nur Prefab-Namen vergleichen.
4. API-Verfügbarkeit, Konstruktion, Replikation und Save-/Load-Verträge erneut prüfen.
5. Dokumentation, Quellenmanifest und Vorlagen gemeinsam aktualisieren; Referenzprüfer ausführen.
6. Laufzeitmatrix auf neuer Testwelt und Kopie eines alten Saves ausführen.
7. Ergebnis und erforderliche Datenmigration im Changelog festhalten.

Dateidaten alleine beweisen Aktualität nicht. Der initiale Vergleich dieser Sammlung prüfte alle 4.044 Archivdateien inhaltlich. Der Manifest-Hash gehört zum geprüften Stand, nicht zu einer dauerhaft garantierten neuesten Internetversion.

## Rollback und Kommunikation

Vor schemaändernden Updates Testwelt/Saves sichern. Rollback darf keine unbekannten Prefabs oder neuere Save-Daten ohne Erklärung zurücklassen. Nutzer erhalten klare Angaben zu Multiplayer-Anforderungen, unterstützten Modi, Migrationsschritten und bekannten Konflikten. Eine unveränderte api_version ist kein Ersatz für Update-Tests.
