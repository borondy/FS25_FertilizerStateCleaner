-- Admin console command "clearFertilizerState [fieldId]".
-- Clears only the Fertilizer value from the spray type ground layer of one field.
-- The density map is only ever modified on the server.

FertilizerStateCleaner = {}

---Returns the field containing the given world position, or nil.
function FertilizerStateCleaner.getFieldAtPosition(x, z)
    for _, field in pairs(g_fieldManager:getFields()) do
        local points = field.polygonPoints
        local inside = false
        local j = #points
        for i = 1, #points do
            local xi, _, zi = getWorldTranslation(points[i])
            local xj, _, zj = getWorldTranslation(points[j])
            if (zi > z) ~= (zj > z) and x < (xj - xi) * (z - zi) / (zj - zi) + xi then
                inside = not inside
            end
            j = i
        end
        if inside then
            return field
        end
    end

    return nil
end

---Server only. Sets the Fertilizer spray type to none on the given field.
-- @return boolean success
-- @return string message
function FertilizerStateCleaner.clearField(fieldId)
    local field = g_fieldManager:getFieldById(fieldId)
    if field == nil then
        return false, string.format("Invalid field id %s", tostring(fieldId))
    end

    local mapId, firstChannel, numChannels = g_currentMission.fieldGroundSystem:getDensityMapData(FieldDensityMap.SPRAY_TYPE)
    local fertilizerValue = FieldSprayType.getValueByType(FieldSprayType.FERTILIZER)

    local modifier = DensityMapModifier.new(mapId, firstChannel, numChannels, g_terrainNode)
    field.densityMapPolygon:applyToModifier(modifier)

    local filter = DensityMapFilter.new(mapId, firstChannel, numChannels)
    filter:setValueCompareParams(DensityValueCompareType.EQUAL, fertilizerValue)

    modifier:executeSet(0, filter)

    return true, string.format("Cleared fertilizer from field %d", fieldId)
end

function FertilizerStateCleaner.consoleCommandClear(_, fieldIdStr)
    local mission = g_currentMission
    local isServer = mission:getIsServer()

    if not isServer and not mission.isMasterUser then
        return "Command not allowed"
    end

    local fieldId = tonumber(fieldIdStr)
    if fieldIdStr ~= nil then
        if fieldId == nil or g_fieldManager:getFieldById(fieldId) == nil then
            return "Invalid field id. Use: clearFertilizerState [fieldId]"
        end
    else
        if g_localPlayer == nil then
            return "No player position available, use: clearFertilizerState <fieldId>"
        end

        local x, _, z = g_localPlayer:getPosition()
        local field = FertilizerStateCleaner.getFieldAtPosition(x, z)
        if field == nil then
            return "Not standing on a field, use: clearFertilizerState <fieldId>"
        end

        fieldId = field:getId()
    end

    if isServer then
        local _, message = FertilizerStateCleaner.clearField(fieldId)
        return message
    end

    g_client:getServerConnection():sendEvent(FertilizerStateCleanerEvent.new(fieldId))

    return string.format("Requested fertilizer clear for field %d", fieldId)
end

addConsoleCommand("clearFertilizerState", "Clears the fertilizer layer from a field (admin only). Without argument uses the field under the player.", "consoleCommandClear", FertilizerStateCleaner, "[fieldId]")
