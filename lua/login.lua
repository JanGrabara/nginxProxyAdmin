
package.path = package.path .. ";/lua/lib/?.lua"

local route = require "resty.route".new()
local session = require "resty.session".start()
local cjson = require "cjson"
local File = require "lua.file"

function badRequest (self, message)
    ngx.status = ngx.HTTP_BAD_REQUEST
    self:json({ error = message })
end

function unotharized (self, message)
    ngx.status = ngx.HTTP_UNAUTHORIZED
    self:json({ error = message })
end



route:use(function(router)
    router.badRequest = badRequest
    router.unotharized = unotharized
    ngx.req.read_body()
    local data = ngx.req.get_body_data()
    if data ~= nil then
        router.body = cjson.decode(data)
    end
    router.yield()
end)

route:post "/api/login" (function(router)
    local body = router.body
    if(body == nil) then
        return router:badRequest("invalid credidentials")
    end
    if (body.secret == os.getenv("PASSWORD")) then
        session.data.logedIn = true
        session:save()
        router:json({ ok = true })
    else
        return router:badRequest("invalid credidentials")
    end
end)

route:post "=/api/logout" (function(router)
    session.data = nil
    session:save()
    router:json({ ok = true })
end)

route:use "/api/file" (function(router)
    if(not session.data.logedIn) then
        return router:unotharized("not loged in")
    else
        router:yield()
    end
end)

route:get "=/api/file" (function(router)
    local fileList = File.scandir "/etc/nginx/conf.d"
    router:json(File.scandir "/etc/nginx/conf.d")
end)

route:get "#/api/file/(%w+)" (function(router, name)
    local fileList = File.scandir "/etc/nginx/conf.d"
    local content = File.read_file("/etc/nginx/conf.d/" .. name)
    ngx.say("\"" .. content .. "\"")
end)


route:dispatch (ngx.var.request_uri, ngx.var.request_method)
