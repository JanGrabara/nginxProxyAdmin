local oldreq = require
local require = function(s)
    return oldreq("lua.lib." .. s)
end

local function read_file(path)
    local file = io.open(path, "r+b") -- r read mode and b binary mode
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


function printView()
    ngx.header["content-type"] = "text/html"

    local template = require "template"

    local files = {}
    for _, file in ipairs(scandir "/etc/nginx/conf.d") do
        if file ~= "." and file ~= ".." then
            table.insert(files, {file = file, content = read_file("/etc/nginx/conf.d/" .. file)})
        end
    end
    template.render(read_file "/lua/view.html", {files = files, message = message})
end

local message = ""

if (ngx.var.request_uri == "/editFile") then
    ngx.req.read_body()
    local args, err = ngx.req.get_post_args()
    if err == "truncated" then
        message = "error=truncated"
        return
    -- one can choose to ignore or reject the current request here
    end

    if not args then
        message = "failed to get post args: " .. err
        return
    end
    for key, val in pairs(args) do
            path = "/etc/nginx/conf.d/" .. key
            write_file(path, val)
            message = message .. ";edited file" .. key
    end
end

if (ngx.var.request_uri == "/addFile") then
    ngx.req.read_body()
    local args, err = ngx.req.get_post_args()

    if err == "truncated" then
        message = "error=truncated"
    end

    if not args then
        message = "failed to get post args: " .. err
        return
    end
    local content
    local fileName
    for key, val in pairs(args) do
        if key == "file-name" then fileName = val end
        if key == "content" then content = val end
    end
    write_file("/etc/nginx/conf.d/" .. fileName, content)
    message = "added file" .. fileName
end

if ngx.var.request_method ~= "GET" then
    ngx.redirect("/")
else
    printView()
end

