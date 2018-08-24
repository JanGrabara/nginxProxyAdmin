

local session = require "lua.lib.resty.session".start()

return function(nxg)
    ngx.log(ngx.NOTICE, "")
    if not session.data.logedIn then
        ngx.redirect("/login")
        do return end
    end
end