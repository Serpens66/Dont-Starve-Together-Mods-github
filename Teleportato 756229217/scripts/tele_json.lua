local TeleJson = {}

local FORMAT_VERSION = 1
local FORMAT_MARKER = "__teleportato_typed_json"
local TABLE_MARKER = "__teleportato_lua_table"

local function IsSupportedScalar(value_type)
    return value_type == "nil"
        or value_type == "string"
        or value_type == "number"
        or value_type == "boolean"
end

local function PackForJSON(value, active_tables, path)
    local value_type = type(value)

    if value_type ~= "table" then
        if IsSupportedScalar(value_type) then
            return value
        end

        error("TeleJson cannot encode "..value_type.." at "..path)
    end

    active_tables = active_tables or {}
    if active_tables[value] then
        error("TeleJson cannot encode a cyclic table at "..path)
    end
    active_tables[value] = true

    -- Store keys as values so JSON cannot silently turn numeric or boolean keys into strings.
    local entries = {}
    for key, child_value in pairs(value) do
        local key_type = type(key)
        if key_type ~= "string" and key_type ~= "number" and key_type ~= "boolean" then
            error("TeleJson cannot encode a "..key_type.." table key at "..path)
        end

        table.insert(entries, {
            key_type = key_type,
            key = key,
            value = PackForJSON(child_value, active_tables, path.."["..tostring(key).."]"),
        })
    end

    active_tables[value] = nil

    return {
        [TABLE_MARKER] = true,
        entries = entries,
    }
end

local function UnpackFromJSON(value, path)
    local value_type = type(value)

    if value_type ~= "table" then
        if IsSupportedScalar(value_type) then
            return value
        end

        error("TeleJson cannot decode "..value_type.." at "..path)
    end

    if value[TABLE_MARKER] ~= true or type(value.entries) ~= "table" then
        error("TeleJson found an invalid packed table at "..path)
    end

    local unpacked = {}
    for index, entry in ipairs(value.entries) do
        if type(entry) ~= "table"
            or (entry.key_type ~= "string" and entry.key_type ~= "number" and entry.key_type ~= "boolean")
            or type(entry.key) ~= entry.key_type then
            error("TeleJson found an invalid table entry at "..path.."["..tostring(index).."]")
        end

        unpacked[entry.key] = UnpackFromJSON(entry.value, path.."["..tostring(entry.key).."]")
    end

    return unpacked
end

function TeleJson.PackForJSON(value)
    return PackForJSON(value, nil, "$payload")
end

function TeleJson.UnpackFromJSON(value)
    return UnpackFromJSON(value, "$payload")
end

function TeleJson.Encode(value)
    return json.encode({
        [FORMAT_MARKER] = FORMAT_VERSION,
        payload = TeleJson.PackForJSON(value),
    })
end

function TeleJson.Decode(encoded_string)
    local decoded = json.decode(encoded_string)

    if type(decoded) == "table" and decoded[FORMAT_MARKER] ~= nil then
        if decoded[FORMAT_MARKER] ~= FORMAT_VERSION then
            error("TeleJson does not support format version "..tostring(decoded[FORMAT_MARKER]))
        end

        return TeleJson.UnpackFromJSON(decoded.payload), false
    end

    -- Unmarked data was written by older Teleportato versions using json.encode directly.
    return decoded, true
end

TeleJson.FORMAT_VERSION = FORMAT_VERSION

return TeleJson
