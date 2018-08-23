local fileModule = {}

function fileModule.read_file(path)
    local file = io.open(path, "r+b") -- r read mode and b binary mode
    if not file then
        return "nil"
    end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end

function fileModule.write_file(path, content)
    f = io.open(path, "w")
    f:write(content)
    f:close()
end

function fileModule.scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a "' .. directory .. '"')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

return fileModule