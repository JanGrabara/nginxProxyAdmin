local oldreq = require
local require = function(s)
    return oldreq("lua." .. s)
end
local File = require "file"

function printView()
    ngx.header["content-type"] = "text/html"

    local template = require "lib.template"

    local files = {}
    for _, file in ipairs(File.scandir "/etc/nginx/conf.d") do
        if file ~= "." and file ~= ".." then
            table.insert(files, {file = file, content = File.read_file("/etc/nginx/conf.d/" .. file)})
        end
    end
    template.render(File.read_file "/lua/view.html", {files = files, message = message})
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
            File.write_file(path, val)
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
    File.write_file("/etc/nginx/conf.d/" .. fileName, content)
    message = "added file" .. fileName
end

if (ngx.var.request_uri == "/command" and ngx.var.request_method == "POST") then
    os.execute("nginx -s reload")
end


if ngx.var.request_method ~= "GET" then
    ngx.redirect("/")
else
    printView()
end

