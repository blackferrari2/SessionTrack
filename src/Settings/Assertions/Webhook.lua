local packages = script.Parent.Parent.Parent.Parent.Packages
local baseModules = script.Parent.Parent.Modules

local t = require(packages.t)
local Webhook = require(baseModules.Webhook)

local WebhookAssertion = {}

---------------

local ASSERTFAIL_PREFIX = "[SessionTrack]: WEBHOOK FAILED TO LOAD - "

local moduleInterface = t.interface({
    URL = t.string,
    UseOutputInstead = t.boolean,
})

---------------

function WebhookAssertion.run(module: Webhook.Webhook): (boolean, string?)
    local success, errorMessage = moduleInterface(module)

    if not success then
        return success, ASSERTFAIL_PREFIX .. errorMessage
    end

    success, errorMessage = pcall(function()
        module.post("Plugin is starting... (This is a check to see if the webhook actually works)")
    end)

    if not success then
        return success, ASSERTFAIL_PREFIX .. "webhook fails to post. Did you setup the URL? | " .. errorMessage
    end

    return true
end

---------------

return WebhookAssertion