-- Client -> server request to clear the fertilizer layer of one field.
-- The server re-checks that the sender is an admin, the client-side check in the console command is only a convenience.

FertilizerStateCleanerEvent = {}
local FertilizerStateCleanerEvent_mt = Class(FertilizerStateCleanerEvent, Event)

InitEventClass(FertilizerStateCleanerEvent, "FertilizerStateCleanerEvent")

function FertilizerStateCleanerEvent.emptyNew()
    return Event.new(FertilizerStateCleanerEvent_mt)
end

function FertilizerStateCleanerEvent.new(fieldId)
    local self = FertilizerStateCleanerEvent.emptyNew()
    self.fieldId = fieldId
    return self
end

function FertilizerStateCleanerEvent:readStream(streamId, connection)
    self.fieldId = streamReadUInt16(streamId)
    self:run(connection)
end

function FertilizerStateCleanerEvent:writeStream(streamId, connection)
    streamWriteUInt16(streamId, self.fieldId)
end

function FertilizerStateCleanerEvent:run(connection)
    -- only the server handles requests, a client never receives this event
    if connection:getIsServer() then
        return
    end

    local user = g_currentMission.userManager:getUserByConnection(connection)
    if user == nil or not user:getIsMasterUser() then
        Logging.warning("[FertilizerStateCleaner] Rejected request for field %d from a non-admin connection.", self.fieldId)
        return
    end

    local success, message = FertilizerStateCleaner.clearField(self.fieldId)
    Logging.info("[FertilizerStateCleaner] %s", message)
end
