local Icons = {
    Power = {
        On = "http://www.roblox.com/asset/?id=16008923978",
        Off = "http://www.roblox.com/asset/?id=16008923312",
        Recover = "http://www.roblox.com/asset/?id=16025418149",
    },

    Pause = {
        Paused = "http://www.roblox.com/asset/?id=16008921548",
        Unpaused = "http://www.roblox.com/asset/?id=16008922394",
    },

    Settings = "http://www.roblox.com/asset/?id=16008920257",
    Initialize = "http://www.roblox.com/asset/?id=16008985266",
    Delete = "http://www.roblox.com/asset/?id=14219067357",
    AssertionFailPage = "http://www.roblox.com/asset/?id=14219067357",
}

---------------

-- here because theres this weird bug where if you change the .Icon id to the same one its already using, the icon turns invisible
function Icons.switch(this: PluginToolbarButton, to: string)
    if this.Icon == to then
        return
    end

    this.Icon = to
end

---------------

return Icons