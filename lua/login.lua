
package.path = package.path .. ";/lua/lib/?.lua"

local oldreq = require
local require = function(s)
    return oldreq("lua." .. s)
end

local session = require "lib.resty.session".start()

local template = require "lib.template"
local File = require "file"

if ngx.var.request_method == "GET" then
    template.render(File.read_file "/lua/login.html", {})
end

if ngx.var.request_method == "POST" then
    ngx.req.read_body()
    local args, err = ngx.req.get_post_args()

    if (args["login"] == "admin" and args["password"] == "admin") then
        session.data.logedIn = true
        session:save()
        ngx.redirect("/")
    else
        ngx.redirect("/login")
    end

end