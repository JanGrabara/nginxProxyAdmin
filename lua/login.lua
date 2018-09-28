
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


function filePath(fileName)
    return "/etc/nginx/conf.d/" .. ngx.unescape_uri(fileName)
end

route:get "#/api/file/(.+)" (function(router, name)
    local content = File.read_file(filePath(name))
    ngx.say(content)
end)

route:put "#/api/file/(.+)" (function(router, name)
    File.write_file(filePath(name), router.body.content)
    router:json({ ok = true })
end)

route:delete "#/api/file/(.+)" (function(router, name)
    File.delete(filePath(name))
    router:json({ ok = true })
end)


route:dispatch (ngx.var.request_uri, ngx.var.request_method)
