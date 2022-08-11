local text = require("text")

local function chooseUnitType(menuType,info)
    menuType = menuType or "selectFilter"
    info = info or {}
    if menuType == "selectFilter" then
        local menuText = "Choose a statistic to filter units by."
        local menuTable = {"Attack Value","Defense Value", }
        local choice = text.menu(menuTable,menuText,"Choose a Unit",true)
        if choice == 0 then
            -- selection cancelled
            return nil
        elseif choice == 1 then
            return chooseUnitType("statisticOptions",{filter="attack", filterName = "attack"})
        elseif choice == 2 then
            return chooseUnitType("statisticOptions",{filter="defense", filterName = "defense"})
        else
            error("selectFilter menu returned a choice of "..choice..", but that isn't supposed to happen.")
        end
    end
    if menuType == "statisticOptions" then
        local menuText = "Choose the range of "..info.filterName.." values you wish to consider."
        local menuTable = {"Choose a different unit statistic.",
            "0 to 3", "4 to 6", "7 to 9", "10 or more",}
        local choice = text.menu(menuTable,menuText,"Choose a Range",true)
        if choice == 0 then
            -- selection cancelled
            return nil
        elseif choice == 1 then
            return chooseUnitType("selectFilter",{})
        elseif choice == 2 then
            return chooseUnitType("filteredOptions",{filter=info.filter, filterName = info.filterName,
                filterMin = 0, filterMax = 3})
        elseif choice == 3 then
            return chooseUnitType("filteredOptions",{filter=info.filter, filterName = info.filterName,
                filterMin = 4, filterMax = 6})
        elseif choice == 4 then
            return chooseUnitType("filteredOptions",{filter=info.filter, filterName = info.filterName,
                filterMin = 7, filterMax = 9})
        elseif choice == 5 then
            return chooseUnitType("filteredOptions",{filter=info.filter, filterName = info.filterName,
                filterMin = 10, filterMax = 100})
        else
            error("statisticOptions menu returned a choice of "..choice..", but that isn't supposed to happen.")
        end
    end
    if menuType == "filteredOptions" then
        -- build menuTable
        local offset = 3
        local menuTable = {}
        menuTable[1] = "Choose a different Statistic"
        menuTable[2] = "Choose a different range"
        local menuText = "Showing unit types with "..info.filterName.." values between "..info.filterMin.." and "..info.filterMax.."."
        local filterKey = info.filter
        for unitTypeID = 0, civ.cosmic.numberOfUnitTypes-1 do
            local unitType = civ.getUnitType(unitTypeID)
            if unitType[filterKey] >= info.filterMin and unitType[filterKey] <= info.filterMax then
                menuTable[unitTypeID + offset] = unitType.name
            end
        end
        local choice = text.menu(menuTable,menuText,"Choose a Unit",true)
        if choice == 0 then
            -- selection cancelled
            return nil
        elseif choice == 1 then
            return chooseUnitType("selectFilter",{})
        elseif choice == 2 then
            return chooseUnitType("statisticOptions",{filter = info.filter, filterName = info.filterName})
        else
            local chosenUnit = civ.getUnitType(choice-offset)
            return chooseUnitType("confirmChoice",{filter = info.filter, filterName = info.filterName,
                filterMin = info.filterMin, filterMax = info.filterMax, selection = chosenUnit})
        end
    end
    if menuType == "confirmChoice" then
        local menuTable = {}
        local menuText = "Please confirm your selection of "..info.selection.name.."."
        menuTable[1] = "I wish to choose a different unit with "..info.filterName.." between "..info.filterMin.." and "..info.filterMax.."."
        menuTable[2] = "I wish to select a different "..info.filterName.." range."
        menuTable[3] = "I wish to select a different statistic."
        menuTable[4] = "Yes, "..info.selection.name.." is correct."
        local choice = text.menu(menuTable,menuText,"Confirmation", true)
        if choice == 0 then
            -- selection cancelled
            return nil
        elseif choice == 1 then
            return chooseUnitType("filteredOptions",{filter = info.filter, filterName = info.filterName,
                filterMin = info.filterMin, filterMax = info.filterMax,})
        elseif choice == 2 then
            return chooseUnitType("statisticOptions",{filter = info.filter, filterName = info.filterName})
        elseif choice == 3 then
            return chooseUnitType("selectFilter",{})
        elseif choice == 4 then
            return info.selection
        end
    end
end

local chosenUnit = chooseUnitType()

if chosenUnit then
    civ.ui.text("The Choice was:"..tostring(chosenUnit))
end
