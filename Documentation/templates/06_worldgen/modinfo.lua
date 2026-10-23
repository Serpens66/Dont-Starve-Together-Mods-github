name = "Documentation - Forest Flowers"
description = "Blumengewicht in BGForest fuer neue Welten. Lehrvorlage."
author = "Documentation example"
version = "0.1.0"
api_version = 10
dst_compatible = true
client_only_mod = false
all_clients_require_mod = false
configuration_options = {
    {
        name = "flower_weight_multiplier",
        label = "Blumengewicht",
        options = {
            { description = "Original", data = 1 },
            { description = "Doppelt", data = 2 },
            { description = "Vierfach", data = 4 },
        },
        default = 2,
    },
}
