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
    local files = {}
    local pfile = io.popen('ls "' .. directory .. '"')
    for fileName in pfile:lines() do
        table.insert( files, fileName )
    end
    pfile:close()
    return files
end

function fileModule.delete(path)
    os.remove(path)
end

return fileModule
