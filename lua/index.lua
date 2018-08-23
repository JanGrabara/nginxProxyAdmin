local oldreq = require
local require = function(s)
    return oldreq("lua.lib." .. s)
end

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

function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a "' .. directory .. '"')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

ngx.req.read_body()
local args, err = ngx.req.get_post_args()

if err == "truncated" then
-- one can choose to ignore or reject the current request here
end

if not args then
    ngx.say("failed to get post args: ", err)
    return
end
for key, val in pairs(args) do
    if type(val) == "table" then
    else
        path = "/etc/nginx/conf.d/" .. key
        write_file(path, val)
    end
end

ngx.header["content-type"] = "text/html"

local template = require "template"

local files = {}
for _, file in ipairs(scandir "/etc/nginx/conf.d") do
    if file ~= "." and file ~= ".." then
        table.insert(files, {file = file, content = read_file("/etc/nginx/conf.d/" .. file)})
    end
end
template.render(read_file "/lua/view.html", {files = files})
