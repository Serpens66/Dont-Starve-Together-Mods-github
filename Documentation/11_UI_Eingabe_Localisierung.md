# 11 — UI, Eingabe, Controller und Lokalisierung

## Widgets erweitern

Widgets besitzen eine Klasse, Eltern-/Kindbeziehungen und eine lokale Entity. Controls baut HUD-Bereiche wie topleft_root und bottom_root auf. Ein AddClassPostConstruct-Callback erhält die fertig konstruierte Klasseinstanz; darüber ein eigenes Kind an einen passenden Root hängen.

Die [Client-UI-Vorlage](templates/05_client_ui/README.md) hängt einen Text an Controls.topleft_root. Sie benötigt nur eine lokale Client-Mod und keinen RPC. Gemeinsam genutzte Server-Mods mit UI sollten UI-Module auf Dedicated Server nicht unnötig laden.

Belege: [widgets/controls.lua — self.topleft_root](<../../_scripts/scripts_02_10_2026/scripts/widgets/controls.lua>) (Zeile 111), [widgets/widget.lua — self.children =](<../../_scripts/scripts_02_10_2026/scripts/widgets/widget.lua>) (Zeile 3), [widgets/text.lua — local Text = Class](<../../_scripts/scripts_02_10_2026/scripts/widgets/text.lua>) (Zeile 3), [modutil.lua — local function DoAddClassPostConstruct](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 153).

## Aktualisierung und Lebensdauer

Initialanzeige aus dem aktuellen Zustand erzeugen, danach Events/Dirty-Events für Änderungen verwenden. Clientdarstellung aus Replicas lesen. Ein HUD kann bei Charakter-/Weltwechsel neu erzeugt werden; globale Widget-Referenzen dürfen nicht unbegrenzt auf alte Instanzen zeigen.

Widget.inst.DoPeriodicTask und DoTaskInTime werden von UpdateWhilePaused standardmäßig auf StaticUpdate-Tasks umgestellt. Für gameplayabhängige Anzeigen gegebenenfalls Sim-Tasks beziehungsweise UpdateWhilePaused(false) prüfen. Die Wahl beeinflusst Pausenverhalten und ist keine bloße Performance-Option.

Beleg: [widgets/widget.lua — function Widget:UpdateWhilePaused](<../../_scripts/scripts_02_10_2026/scripts/widgets/widget.lua>) (Zeile 34).

## Eingabe und Controller

Globale KeyDownHandler sind lokale Eingabeereignisse. Vor einer Spielaktion prüfen, ob der Spieler aktiv ist und kein Chat-/Menüfokus die Eingabe benötigt. Einen Handler nicht pro HUD-Neuaufbau mehrfach registrieren.

Input:AddKeyDownHandler gibt ein EventHandler-Objekt zurück. `handler:Remove()` entfernt es aus seinem EventProcessor. Der KeyDown-Callback erhält keine Entity und keinen Keyparameter; Input:OnRawKey übergibt den Key als Ereignisschlüssel, nicht als Callbackargument. AddKeyHandler hingegen erhält key und down. Entity-ListenForEvent und Inputhandler haben unterschiedliche Rückbauverträge.

    local handler = GLOBAL.TheInput:AddKeyDownHandler(GLOBAL.KEY_F6, function()
        -- Fokus und aktuellen Spieler prüfen, dann lokale Funktion ausführen.
    end)
    -- Im definierten Rückbaupfad des Eigentümers:
    handler:Remove()

Widget:Kill entfernt den Widgetbaum und seine Entity, aber nicht pauschal alle extern registrierten Inputhandler. Deshalb Cleanup an den tatsächlichen Eigentümer binden und seine Referenz nach Entfernung freigeben. Das Beispiel oben ist der Registrierungs-/Remove-Vertrag, keine bereits eingebundene Fokuslogik.

Belege: [events.lua — function EventHandler:Remove](<../../_scripts/scripts_02_10_2026/scripts/events.lua>) (Zeile 7), [events.lua — function EventProcessor:AddEventHandler](<../../_scripts/scripts_02_10_2026/scripts/events.lua>) (Zeile 17), [input.lua — function Input:OnRawKey](<../../_scripts/scripts_02_10_2026/scripts/input.lua>) (Zeile 186), [widgets/widget.lua — function Widget:Kill()](<../../_scripts/scripts_02_10_2026/scripts/widgets/widget.lua>) (Zeile 325).

Controller-Interaktion verwendet Controls und Fokusnavigation. Mausereignisse allein ergeben keine bedienbare Controller-UI. Eigene Buttons benötigen OnControl-Verhalten und Fokusverbindungen; statische Beschriftungen sollten keine Eingabe abfangen. Die UI-Vorlage setzt SetClickable(false).

Eine UI, die Gameplay anfordert, sendet eine validierte Action/RPC; sie mutiert keine fehlende Server-Component. SetModHUDFocus gibt eine modbezogene Fokusmeldung an das HUD weiter und benötigt einen aktiven Spieler mit HUD.

Belege: [input.lua — AddKeyDownHandler](<../../_scripts/scripts_02_10_2026/scripts/input.lua>) (Zeile 123), [widgets/button.lua — function Button:OnControl](<../../_scripts/scripts_02_10_2026/scripts/widgets/button.lua>) (Zeile 56), [widgets/widget.lua — function Widget:OnMouseButton](<../../_scripts/scripts_02_10_2026/scripts/widgets/widget.lua>) (Zeile 56), [modutil.lua — env.SetModHUDFocus](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 919).

## Texte

Typische Pfade:

    STRINGS.NAMES.MY_MOD_ITEM
    STRINGS.RECIPE_DESC.MY_MOD_ITEM
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.MY_MOD_ITEM
    STRINGS.ACTIONS.MY_MOD_ACTION

AddAction setzt STRINGS.ACTIONS selbst. Eigene UI-Texte in einem eindeutig benannten Unterverzeichnis bündeln. Character-Inspect-Texte können GENERIC-Fallback und besondere Varianten besitzen; den konkreten inspectable-/Speech-Verbraucher prüfen.

Die Vorlagen verwenden eigene deutsche Texte und ASCII-Lua-Dateien mit Dezimal-Escapes für Umlaute. Die Dokumentation selbst ist UTF-8. Eigene Übersetzungen können zentral über Konfiguration oder das PO-System bereitgestellt werden. Translator.LoadPOFile verarbeitet Kontextpfade; verschiedene gleiche Ausgangssätze sollen nicht ungewollt dieselbe Übersetzung erzwingen.

Belege: [modutil.lua — STRINGS.ACTIONS](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 473), [translator.lua — function Translator:LoadPOFile](<../../_scripts/scripts_02_10_2026/scripts/translator.lua>) (Zeile 67).

## Prüffälle

Auflösung und UI-Skalierung variieren, lange Texte und Umlaute prüfen, HUD nach Reconnect/Höhlenwechsel wiederherstellen. Maus, Tastatur und Controller unterscheiden. Bei datenabhängigen Anzeigen Anfangswert, fehlende Replica, verspätete Klassifizierung und Dirty-Updates testen.


## Vertiefung mit Workspace-Beispielen

Die dazugehörigen konkreten Abläufe, Daten-/Cleanupentscheidungen und Altlasten sind im [Praxismechanismen-Kapitel](23_Praxismechanismen.md) erklärt. Über die [Abdeckungsmatrix](21_Abdeckungsmatrix.md) zu passenden Fallstudien und eigenständigen Vorlagen navigieren; Grenzen komplexer Systeme stehen ausdrücklich dort.
