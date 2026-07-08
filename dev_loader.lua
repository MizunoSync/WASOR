if isfile and readfile and loadstring then
    if isfile("WASOR/init.lua") then
        local success, err = pcall(function()
            loadstring(readfile("WASOR/init.lua"))()
        end)
        if not success then
            warn("[WASOR Dev Loader] Error running init.lua: " .. tostring(err))
        end
    else
        warn("[WASOR Dev Loader] init.lua not found! Make sure 'WASOR' is inside your workspace folder.")
    end
else
    warn("[WASOR Dev Loader] Executor does not support standard file operations (isfile, readfile, loadstring).")
end
