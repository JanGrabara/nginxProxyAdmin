package.path = package.path .. ";/lua/lib/?.lua"

local oldreq = require
local require = function(s)
    return oldreq("lua." .. s)
end

local template = require "lib.template"
local File = require "file"

local session = require "lib.resty.session".start()
require "checkLogin"()

function printView()
    ngx.header["content-type"] = "text/html"
    local files = {}
    for _, file in ipairs(File.scandir "/etc/nginx/conf.d") do
        if file ~= "." and file ~= ".." then
            table.insert(files, {file = file, content = File.read_file("/etc/nginx/conf.d/" .. file)})
        end
    end
    local message = session.data.message
    session.data.message = nil
    session:save()
    template.render(File.read_file "/lua/view.html", {files = files, message = message})
end

function runCommand(command)
    local f = io.popen(command)
    local msg = f:read("*a")
    f:close()
    return msg
end

function checkConfiguration()
    return runCommand("/usr/local/openresty/nginx/sbin/nginx -t 2>&1")
end

function sessionMessage(session, message)
    session.data.message = message
    session:save()
end

if (ngx.var.request_uri == "/editFile") then
    ngx.req.read_body()
    local args, err = ngx.req.get_post_args()

    if not args then
        return
    end
    for key, val in pairs(args) do
        path = "/etc/nginx/conf.d/" .. key
        File.write_file(path, val)
    end
    sessionMessage(session, checkConfiguration())
end

if (ngx.var.request_uri == "/addFile") then
    ngx.req.read_body()
    local args, err = ngx.req.get_post_args()

    if err == "truncated" then
        message = "error=truncated"
        return
    end

    if not args then
        message = "failed to get post args: " .. err
        return
    end
    local content
    local fileName
    for key, val in pairs(args) do
        if key == "file-name" then
            fileName = val
        end
        if key == "content" then
            content = val
        end
    end
    File.write_file("/etc/nginx/conf.d/" .. fileName, content)
    sessionMessage(session, checkConfiguration())
end

if (ngx.var.request_uri == "/deleteFile") then
    ngx.req.read_body()
    local args, err = ngx.req.get_post_args()

    File.delete("/etc/nginx/conf.d/" .. args["file-name"])
end

if (ngx.var.request_uri == "/command" and ngx.var.request_method == "POST") then
    sessionMessage(session, runCommand("/usr/local/openresty/nginx/sbin/nginx -s reload 2>&1"))
end

if ngx.var.request_method ~= "GET" then
    ngx.redirect("/")
else
    printView()
end
