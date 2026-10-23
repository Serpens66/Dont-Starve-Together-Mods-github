name = "Documentation - Spear Tweak"
description = "Konfigurierbarer Schaden fuer vorhandene Speere. Lehrvorlage."
author = "Documentation example"
version = "0.1.0"
api_version = 10
dst_compatible = true
client_only_mod = false
all_clients_require_mod = false
configuration_options = {
    {
        name = "damage_multiplier",
        label = "Schadensfaktor",
        options = {
            { description = "Original", data = 1 },
            { description = "125%", data = 1.25 },
            { description = "150%", data = 1.5 },
        },
        default = 1.25,
    },
}
