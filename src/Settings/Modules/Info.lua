--[[
    ★  ★  ★  ★  ★  ★  ★  ★  ★  ★  ★  ★  ★  ★  ★  ★

    HELLO! thanks for using my plugin

    FOR IT TO WORK, first replace the `WebhookURL` field down there with the url of your discord webhook

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
    info about your project

    please edit the fields with "REPLACEME" for the plugin to work properly. dont worry about the other fields like `TotalProjectTime` :P

    if you wanna test the plugin without posting to the webhook, change the `UseOutputInstead` option to `true`.
        thatll, like the name says, send all the messages to roblox studios output
            set it back to `false` once youre done
]]

local Info = {
    ProjectName = "REPLACEME",
    WebhookURL = "REPLACEME",
    UseOutputInstead = false,
    TotalProjectTimeAttribute = "TotalProjectTime",
}

---------------

export type Info = typeof(Info)

---------------

function Info.addToTotalProjectTime(time: number)
    local currentAmount = script:GetAttribute(Info.TotalProjectTimeAttribute) or 0

    script:SetAttribute(Info.TotalProjectTimeAttribute, currentAmount + time)
end

function Info.getTotalProjectTime()
    return script:GetAttribute(Info.TotalProjectTimeAttribute) or 0
end

---------------

return Info