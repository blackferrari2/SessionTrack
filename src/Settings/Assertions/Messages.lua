local packages = script.Parent.Parent.Parent.Parent.Packages
local baseModules = script.Parent.Parent.Modules

local t = require(packages.t)
local Messages = require(baseModules.Messages)

local MessagesAssertion = {}

---------------

local ASSERTFAIL_PREFIX = "[SessionTrack]: MESSAGES FAILED TO LOAD - "

local messageList = t.array(t.string)

local moduleInterface = t.interface({
    Start = messageList,
    SessionRecovered = messageList,
    Close = messageList,
    Pause = messageList,
    Resume = messageList,
    LineSeparators = messageList,
})

---------------

function MessagesAssertion.run(module: Messages.Messages): (boolean, string?)
    local success, errorMessage = moduleInterface(module)

    if not success then
        return success, ASSERTFAIL_PREFIX .. "the module isnt structured correctly. Did you mess with the .add() function? | " .. errorMessage
    end

    local message
    success, errorMessage = pcall(function()
        message = module.get(Messages.Start)
    end)

    if not success then
        return success, ASSERTFAIL_PREFIX .. errorMessage
    end

    success, errorMessage = t.optional(t.string)(message)

    if not success then
        return success, ASSERTFAIL_PREFIX .. "messages arent text for some reason. What did you DO? | " .. errorMessage
    end

    return true
end

---------------

return MessagesAssertion