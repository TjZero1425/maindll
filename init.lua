getgenv().islocalsourcecontainer = newcclosure(function(inst: LuaSourceContainer): boolean
    if isA(inst, "ModuleScript") then
        return true;
    elseif isA(inst, "Script") and inst.RunContext == Enum.RunContext.Client then
        return true;
    elseif isA(inst, "LocalScript") and (inst.RunContext == Enum.RunContext.Client or inst.RunContext == Enum.RunContext.Legacy) then
        return true;
    end
    return false;
end);

local cache = {}

getgenv().getsenv = newcclosure(function(scr)
    assert(islocalsourcecontainer(scr), "invalid argument #1 to 'getsenv' (LocalSourceContainer expected)");

    if cache[scr] then
        return cache[scr]
        end

        for i, v in getreg() do
            if type(v) == "thread" then
                local tenv = gettenv(v);
    if tenv.script == scr then
        cache[scr] = tenv
        return tenv;
    end
        end
        end
        end);
