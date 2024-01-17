--[[
    info about your project

    all you should need to edit here is the project name, dont worry about the total time stuff!
]]

local Info = {
    ProjectName = "test",
    TotalProjectTimeAttribute = "TotalProjectTime",
}

---------------

function Info.addToTotalProjectTime(time: number)
    local currentAmount = script:GetAttribute(Info.TotalProjectTimeAttribute) or 0

    script:SetAttribute(Info.TotalProjectTimeAttribute, currentAmount + time)
end

---------------

return Info