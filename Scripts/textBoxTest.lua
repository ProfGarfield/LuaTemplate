local text = require("text")

local message254 = ""
for i=1,254 do
    if i%50 ~= 0 then
        message254 = message254..tostring(i%10)
    else
        message254 = message254.." "
    end
end

local function simpleMenu(message,title)
    local dialog = civ.ui.createDialog()
    dialog.title = title
    dialog:addText(message)
    dialog:addOption("Yes",0)
    dialog:addOption("No",1)
    dialog:show()
end

simpleMenu(message254,"254")

--local menuTable = {"Yes","No"}
--text.menu(menuTable,message254,"254")
--
--local message255 = message254.."5"
--text.menu(menuTable,message255,"255")
--local message256 = message255.."6"
--text.menu(menuTable,message256,"256")



