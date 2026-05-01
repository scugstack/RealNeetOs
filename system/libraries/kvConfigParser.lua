local parser = {}
local utils = loadLibrary("stringUtils")

function parser.parse(data)
    if type(data) ~= "string" then error("expected type string for data instead got: "..type(data),2) end
    local lines = utils.split(data,"\n")
    local values = {}
    for linenum,line in ipairs(lines) do
        if line:sub(1,1) ~= "#" then
            local _,num = line:gsub("%=","")
            if num > 1 then error("syntax error on line "..tostring(linenum)..": too many equal signs",2)
            elseif num == 1 then
                local name,value = table.unpack(utils.split(line,"%="))
                if name == nil or name:gsub(" ","") == "" then error("syntax error on line "..tostring(linenum)..": no name defined",2) end
                if value == nil or value:gsub(" ","") == "" then error("syntax error on line "..tostring(linenum)..": no name defined",2) end
                values[name] = value
            end
        end
    end
    return values
end

function parser.generateFrom(kv)
    if type(kv) ~= "table" then error("expected type string for kv instead got: "..type(kv),2) end
    local lines = {}
    for k,v in pairs(kv) do
        lines[#lines+1] = k..v
    end
    return table.concat(lines,"\n")
end

return parser