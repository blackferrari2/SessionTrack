local packages = script.Parent.Parent.Parent.Parent.Packages
local baseModules = script.Parent.Parent.Modules

local t = require(packages.t)
local Checkpoints = require(baseModules.Checkpoints)

local CheckpointsAssertion = {}

---------------

local ASSERTFAIL_PREFIX = "[SessionTrack]: CHECKPOINTS FAILED TO LOAD - "

local checkpointInterface = t.interface({
    author = t.string,
    message = t.string,
})

local moduleInterface = t.interface({
    IntervalSeconds = t.numberMin(60),
})

---------------

function CheckpointsAssertion.run(module: Checkpoints.Checkpoints): (boolean, string?)
    local success, errorMessage = moduleInterface(module)

    if not success then
        return success, ASSERTFAIL_PREFIX .. errorMessage
    end

    for _, checkpoint in ipairs(module) do
        success, errorMessage = checkpointInterface(checkpoint)

        if not success then
            return success, ASSERTFAIL_PREFIX .. "checkpoints arent structured correctly. Did you mess with the .add() function? | " .. errorMessage
        end
    end

    local checkpoint
    success, errorMessage = pcall(function()
        checkpoint = module.get()
    end)

    if not success then
        return success, ASSERTFAIL_PREFIX .. errorMessage
    end

    success, errorMessage = t.optional(t.string)(checkpoint)

    if not success then
        return success, ASSERTFAIL_PREFIX .. "checkpoints.get() dont return text for some reason. What did you DO? | " .. errorMessage
    end

    return true
end

---------------

return CheckpointsAssertion