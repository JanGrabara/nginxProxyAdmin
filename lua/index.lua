local name = ngx.var.arg_name or "Anonymous 123 o kurde"
ngx.say("Hello, ", name, "fajnie")

local open = io.open
local function read_file(path)
    local file = open(path, "r+b") -- r read mode and b binary mode
    if not file then
        return "nil"
    end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end

local function write_file(path, content)
    f = io.open(path, "w")
    f:write(content)
    f:close()
end
