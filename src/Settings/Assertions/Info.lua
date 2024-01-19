local packages = script.Parent.Parent.Parent.Parent.Packages
local baseModules = script.Parent.Parent.Modules

local t = require(packages.t)
local Voyager = require(packages.Voyager)
local Info = require(baseModules.Info)

local InfoAssertion = {}

---------------

local ASSERTFAIL_PREFIX = "[SessionTrack]: INFO FAILED TO LOAD - "

local moduleInterface = t.interface({
    ProjectName = t.string,
    WebhookURL = t.string,
    UseOutputInstead = t.boolean,
    TotalProjectTimeAttribute = t.string,
})

---------------

function InfoAssertion.run(module: Info.Info): (boolean, string?)
    local success, errorMessage = moduleInterface(module)

    if not success then
        return success, ASSERTFAIL_PREFIX .. errorMessage
    end

    success, errorMessage = pcall(function()
        local webhook = Voyager.fromUrl(module.WebhookURL)
        local message, requestStatus = webhook:execute("Plugin is starting... (This is a check to see if the webhook actually works). Message will be deleted.", nil, false, true)

        if not requestStatus.success then
            error("Webhook fails to send messages. Proxy request status and code: " .. requestStatus.statusMessage .. " " .. requestStatus.statusCode)
        else
            webhook:deleteMessage(message.id)
        end
    end)

    if not success then
        return success, ASSERTFAIL_PREFIX .. errorMessage
    end

    local totalProjectTime
    success, errorMessage = pcall(function()
        totalProjectTime = module.getTotalProjectTime()
    end)

    if not success then
        return success, ASSERTFAIL_PREFIX .. "getTotalProjectTime is erroring. What?"
    end

    success, errorMessage = t.number(totalProjectTime)

    if not success then
        return success, ASSERTFAIL_PREFIX .. "getTotalProjectTime doesnt return a number. | " .. errorMessage
    end

    success, errorMessage = pcall(function()
        module.addToTotalProjectTime(1)
    end)

    if not success then
        return success, ASSERTFAIL_PREFIX .. errorMessage
    end

    local newTotalProjectTime = module.getTotalProjectTime()

    success, errorMessage = t.literal(totalProjectTime + 1)(newTotalProjectTime)

    if not success then
        return success, ASSERTFAIL_PREFIX .. "addToTotalProjectTime is inaccurate. You know what you did. Theres no way a normal person would get this error"
    end

    module.addToTotalProjectTime(-1)

    return true
end

---------------

return InfoAssertion