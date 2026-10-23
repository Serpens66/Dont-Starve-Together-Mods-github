# Abgegrenzte Lua-Fragmente

Diese beiden Dateien sind **keine eigenständig installierbaren Mods**. Der Syntaxprüfer prüft sie gemeinsam mit den Vorlagen. Neue Projekte benötigen vollständige Prefabs, Metadaten, Registrierung und Assets.

- [creature_brain.lua](creature_brain.lua): nur ein serverseitiger Wander-Brain mit bekannten Ortsdaten. Voraussetzungen, Einbau und Rabbit-Vergleich stehen in [Kapitel 29](../29_Kreaturen_Charaktere_Lebenszyklus.md). Kein Boss-, Combat- oder eigenes SGbeispiel.
- [character_callbacks.lua](character_callbacks.lua): gemeinsame Tags und Mastercallback mit validiertem versioniertem Datenfeld. Für MakePlayerCharacter, ausdrücklich nicht als späterer AddPrefabPostInit-Ersatz. Eigene Auswahl-/Körper-/Ghostassets fehlen. Gameplayzähler wird hier nicht erhöht oder repliziert.

Isolierte Tests betreffen nur eigene Datenvalidierung und Callbackrundlauf. Factory, BrainManager, SG, Physik, Netzwerk und UI werden dadurch nicht geprüft. Der [Prüfstatus](../VALIDATION.md) und die nicht durchgeführten Tests in Kapitel 29 bleiben maßgeblich.
