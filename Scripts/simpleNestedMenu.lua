local text = require("text")

local function smallNestedMenu(menuType)
    menuType = menuType or "menu1" -- menu1 is the default menu
    if menuType == "menu1" then
        local menuText = "You are in Menu 1"
        local menuTable = {"Go to Menu 2","Go to Menu 3"}
        local choice = text.menu(menuTable,menuText,"Sample Nested Menu")
        if choice == 1 then
            return smallNestedMenu("menu2")
        elseif choice == 2 then
            return smallNestedMenu("menu3")
        end
    end
    if menuType == "menu2" then
        local menuText = "You are in Menu 2"
        local menuTable = {"Go to Menu 1","Close menu"}
        local choice = text.menu(menuTable,menuText,"Sample Nested Menu")
        if choice == 1 then
            return smallNestedMenu("menu1")
        elseif choice == 2 then
            return 
        end
    end
    if menuType == "menu3" then
        local menuText = "You are in Menu 3"
        local menuTable = {"Go to Menu 1","Close menu"}
        local choice = text.menu(menuTable,menuText,"Sample Nested Menu")
        if choice == 1 then
            return smallNestedMenu("menu1")
        elseif choice == 2 then
            return 
        end
    end
end

smallNestedMenu()

