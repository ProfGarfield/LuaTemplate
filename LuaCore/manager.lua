local manager = {}

local function correctVersion(table,version)
    -- if no version specified, any version is OK
    if not version then
        return true
    end
    -- if a version is specified, but no version provided,
    -- then the file is obsolete
    if version and not table.version then
        return false
    end
    -- otherwise, compare versions
    return table.version >= version
end

function manager.require(fileName,throwError,version,substitute)
    local sub = {}
    local metatable = {}
    setmetatable(sub,metatable)
    metatable.__index = function(_,key)
        error("The file with name "..fileName.." was not found.  Therefore, returning the value for key "..tostring(key).." is impossible.  Provide the file "..fileName.." and reload your game.")
    end
    substitute = substitute or sub
    local fileFound, table = pcall(require,fileName)
    if fileFound and correctVersion(table,version) then
        return table
    elseif fileFound then
        if throwError then
            error("manager.require: the file "..fileName.." was found, but it appears to be out of date.  The version is "..tostring(table.version or "from before versions were recorded").." but a version of at least "..tostring(version).." is required.")
        else
            print("WARNING: manager.require: the file "..fileName.." was found, but it appears to be out of date.  The version is "..tostring(table.version or "from before versions were recorded").." but a version of at least "..tostring(version).." is required.")
            return table
        end
    else
        if throwError then
            print("manager.require: the file "..fileName.." was not found.")
        else
            print("WARNING: manager.require: the file "..fileName.." was not found.  None of the functions it provides are available for use.")
            return table
        end
    end
end
