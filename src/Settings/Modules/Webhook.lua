--[[
    Webhook settings.
    
    For this plugin to work as intended, replace the `URL` field down there with the link to your discord webhook

    if you want the messages NOT to be sent to the webhook, but to the roblox studio output, change the `UseOutputInstead` field to true.
]]

local HttpService = game:GetService("HttpService")

local Webhook = {
    URL = "replaceme",
    UseOutputInstead = false,
}

---------------

local WARN_HTTP_ERROR = "[SessionTrack]: http request failed. Reason: %s"

---------------

function Webhook.post(text: string?)
    if not text then
        return
    end

    if Webhook.UseOutputInstead then
        print(text)
        return
    end

    local _, errorMessage = pcall(function()
        local data = HttpService:JSONEncode({
            content = text
        })
    
        HttpService:PostAsync(Webhook.URL, data)
    end)

    if errorMessage then
        warn(string.format(WARN_HTTP_ERROR, errorMessage))
    end
end

---------------

return Webhook