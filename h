getgenv().LocalSourceContainer = newcclosure(function(instance)
    if workspace.IsA(instance, "ModuleScript") then
        return true
    elseif workspace.IsA(instance, "Script") and instance.RunContext == Enum.RunContext.Client then
        return true
    elseif workspace.IsA(instance, "LocalScript") and (instance.RunContext == Enum.RunContext.Client or instance.RunContext == Enum.RunContext.Legacy) then
        return true
    end
    return false
end)

getgenv().getsenv = newcclosure(function(scriptInstance)
    assert(LocalSourceContainer(scriptInstance), "Invalid argument #1 to 'getsenv' (LocalSourceContainer expected)")

    if senv_cache[scriptInstance] then
        return senv_cache[scriptInstance]
    end

    for _, value in ipairs(getreg()) do
        if type(value) == "thread" then
            local threadEnv = gettenv(value)
            if threadEnv.script == scriptInstance then
                senv_cache[scriptInstance] = threadEnv
                return threadEnv
            end
        end
    end

    return nil
end)
