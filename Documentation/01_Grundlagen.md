# 01 — Grundlagen und lokale Umgebung

## Maßgebliche Verzeichnisse

| Zweck | Lokaler Pfad |
|---|---|
| Workspace | `D:\CDesktopLink\Unterlagen\Mods\DST\Mods github` |
| Installation | `E:\ProgrammeE\Steam\steamapps\common\Don't Starve Together` |
| Aktuelles Archiv | `data\databundles\scripts.zip` unter der Installation |
| Geprüfte Scripts | `D:\CDesktopLink\Unterlagen\Mods\DST\_scripts\scripts_02_10_2026\scripts` |
| Mod Tools | `E:\ProgrammeE\Steam\steamapps\common\Don't Starve Mod Tools` |
| Lua-Compiler | `D:\CDesktopLink\Portable\lua\lua5_1_4_Win64_bin\luac5.1.exe` |
| Python | `D:\CDesktopLink\Portable\Python\WinPy64\python\python.exe` |

Der vom Nutzer genannte Snapshot enthält noch ein Unterverzeichnis `scripts`. Deshalb liegt `modutil.lua` nicht unmittelbar in `scripts_02_10_2026`. Die Mod Tools sind lokal vorhanden; ihr Betrieb wurde nicht getestet.

Vanilla-Dateien dienen zum Lesen. Eine Mod erweitert das Spiel aus ihrem eigenen Ordner. Direkte Änderungen an der Installation werden durch Updates überschrieben und geben anderen Spielern keinen passenden Mod-Stand.

## Minimales Projekt

    mein_mod/
        modinfo.lua
        modmain.lua
        modworldgenmain.lua       # nur für Weltgenerierung
        modservercreationmain.lua # nur für spezielle Frontend-Anpassungen
        scripts/
            prefabs/
            components/
            widgets/
        anim/
        images/
        sound/

`modinfo.lua` beschreibt die Mod; `modmain.lua` registriert Runtime-Erweiterungen; `PrefabFiles` listet Dateinamen ohne `.lua` aus `scripts/prefabs`. Ein Prefab-Dateiname und die darin zurückgegebenen Prefab-Namen müssen nicht identisch sein, sollen in einfachen Projekten aber zusammenpassen.

Der Loader fügt Mod-Scriptpfade zu `package.path` hinzu und registriert Assets sowie Prefabs. Ein Component-Modul muss die Component-Klasse zurückgeben. Asset-Dateien benötigen die zum Consumer passende Registrierung.

Belege: [mods.lua — function CreateEnvironment](<../../_scripts/scripts_02_10_2026/scripts/mods.lua>) (Zeile 297), [mods.lua — function ModWrangler:RegisterPrefabs](<../../_scripts/scripts_02_10_2026/scripts/mods.lua>) (Zeile 677), [mods.lua — package.path = MODS_ROOT](<../../_scripts/scripts_02_10_2026/scripts/mods.lua>) (Zeile 437).

## Metadaten und Mod-Typ

Die vorhandenen DST-Mods setzen `api_version = 10` und `dst_compatible = true`. Diese Metadaten sind keine Garantie, dass ältere APIs oder Inhalte mit dem aktuellen Spiel funktionieren. Wichtige Felder:

| Feld | Zweck |
|---|---|
| name, description, author, version | Anzeige, Zuordnung und veröffentlichter Stand |
| dst_compatible | Eignung für DST deklarieren |
| client_only_mod | Mod wird als lokale Client-Mod behandelt |
| all_clients_require_mod | Beitretende Clients müssen die Server-Mod besitzen |
| configuration_options | Konfigurationsoptionen mit name, options und default |
| priority | Ladepriorität; ersetzt keine Konfliktlösung |
| icon_atlas, icon | Darstellung in der Mod-Liste |
| mod_dependencies | Abhängigkeiten; genaue unterstützte Form im ModIndex prüfen |

Eine Änderung an rein serverseitiger Logik kann ohne Client-Mod auskommen. Eigene replizierte Daten, Prefabs, Assets, Actions oder UI verlangen eine Prüfung des Client-Vertrags; die entsprechenden Vorlagen setzen deshalb `all_clients_require_mod = true`. Eine reine HUD-Erweiterung setzt `client_only_mod = true`.

Belege: [mods.lua — client_only_mod](<../../_scripts/scripts_02_10_2026/scripts/mods.lua>) (Zeile 93), [mods.lua — all_clients_require_mod](<../../_scripts/scripts_02_10_2026/scripts/mods.lua>) (Zeile 159), [modindex.lua — mod_dependencies](<../../_scripts/scripts_02_10_2026/scripts/modindex.lua>) (Zeile 26), [Trash Can 1879090052/modinfo.lua — configuration_options](<../Trash Can 1879090052/modinfo.lua>) (Zeile 17).

## Lua-Grundlagen für diese Beispiele

Lua 5.1 kennt `local`, Tabellen, Funktionen und Closures. `obj:Method(x)` übergibt `obj` als erstes Argument; `obj.Method(obj, x)` ist die entsprechende Punktform. Nur `nil` und `false` sind falsch; auch `0` und leere Strings sind wahr. `pairs` liefert keine definierte Reihenfolge, `ipairs` endet am ersten fehlenden Arrayeintrag. Für Tabellen mit Löchern ist `#t` kein verlässlicher Elementzähler. `require` puffert Module über `package.loaded`. Variadische Rückgaben brauchen beim Zwischenspeichern eine explizite Anzahl, wenn `nil` erhalten bleiben soll.

In Lua 5.1 stehen `unpack`, `getfenv` und `setfenv` zur Verfügung. Neuere Lua-Syntax wie `goto`, `//` oder native Bitoperatoren gehört nicht in diese Vorlagen. Sprachquelle: [Lua-5.1-Handbuch](https://www.lua.org/manual/5.1/manual.html).

Neue Textdateien hier verwenden UTF-8 ohne BOM und CRLF. Bestehende Dateien können andere Kodierungen haben; vor Bearbeitungen Byteformat prüfen und erhalten.

## Konfiguration robust lesen

    local enabled = GetModConfigData("enabled")
    if enabled == nil then
        enabled = true
    end

`or true` würde auch ein ausdrücklich konfiguriertes `false` überschreiben. Datentyp und erlaubte Werte müssen zu `configuration_options` passen. Einstellungen vor teuren Hooks einmal lesen, wenn keine Laufzeitänderung vorgesehen ist.

Der Wrapper im Mod-Environment ergänzt automatisch den Mod-Namen. Der globale Aufruf verlangt ihn ausdrücklich. `get_local_config` unterscheidet lokale und Serverwerte; nicht ohne Prüfung vertauschen.

Beleg: [modutil.lua — function GetModConfigData](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 34), [modutil.lua — env.GetModConfigData](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 329).
