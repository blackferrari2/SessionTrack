--[[
    ★  ★  ★  ★  ★  ★  ★  ★  ★  ★  ★  ★  ★  ★  ★  ★

    HELLO! thanks for using my plugin

    FOR IT TO WORK, first replace the `URL` field down there with the url of your discord webhook

    save and restart studio afterwards to apply the changes. Enjoy!
        (you can close this after youre done)


    ...........

    QnA:
        Reset/Delete settings?
            > delete/take out the `SessionTrack.PluginSettings` folder from ServerStorage and save and restart studio afterwards like normal.

        settings are GONE?
            > your settings mightve been outdated (check the output to confirm that and for more instructions). They werent deleted.


    ★  ★  ★  ★  ★  ★  ★  ★  ★  ★  ★  ★  ★  ★  ★  ★ 
]]

--[[
    webhook is the module used to send the plugin messages over to discord
    
    if you want the messages NOT to be sent to the webhook, but to the roblox studio output, change the `UseOutputInstead` field to true.
]]

local HttpService = game:GetService("HttpService")

local Webhook = {
    URL = "REPLACEME",
    UseOutputInstead = false,
}

---------------

export type Webhook = typeof(Webhook)

---------------

function Webhook.post(text: string?)
    if not text then
        return
    end

    if Webhook.UseOutputInstead then
        print(text)
        return
    end

    task.spawn(function()
        local data = HttpService:JSONEncode({
            content = text
        })
    
        HttpService:PostAsync(Webhook.URL, data)
    end)
end

---------------

return Webhook