local kvParser = loadLibrary("kvConfigParser")
local function newEnviorment()
    local env = {}
    local vars = {}
    if _G.env then
        vars = _G.env.getKV()
    end
    function env.getKV()
        return vars
    end

    function env.set(key,value)
        if type(key) ~= "string" then error("expected type string for key instead got: "..type(key),2) end
        vars[key] = value
    end

    function env.get(key)
        if type(key) ~= "string" then error("expected type string for key instead got: "..type(key),2) end
        return vars[key]
    end

    function env.fork()
        local newenv = newEnviorment()
        return setmetatable({env=newenv},{__index=_G})
    end

    function env.substituteInString(str)
        for k,v in pairs(vars or {}) do
            k = ("$"..tostring(k)):gsub("[%(%)%>%%%+%_%*%?%[%^%$]","%%%1")
            v = tostring(v):gsub("[%(%)%>%%%+%_%*%?%[%^%$]","%%%1")
            str = str:gsub(k,v)
        end
        return str
    end
    return env
end
_G.env = newEnviorment()

if fs.exists("system:/initial.env") then
    local handle = fs.open("system:/initial.env","r")
    local kv = kvParser.parse(handle.read("a"))
    handle.close()
    for k,v in pairs(kv) do
        env.set(k,v)
    end
end