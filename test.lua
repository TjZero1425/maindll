    local s, r = pcall(function()
        setthreadidentity(6)
        return Instance.new("Player")
    end)

    if s and string.find(r, "lacking capability") then
        warn("Noob")
    end
