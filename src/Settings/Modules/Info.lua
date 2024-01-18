--[[
    NOTE:

    SAVE AND RESTART STUDIO TO APPLY CHANGES.
]]

--[[
    info about your project

    all you should need to edit here is the project name, dont worry about the total time stuff!
]]

local Info = {
    ProjectName = "REPLACEME",
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