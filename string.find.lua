-- fix implenmenatation to string.find

setreadonly(string, false)
local original_find = string.find
function string.find(subject, pattern, ...)
    if type(subject) ~= "string" then
        subject = tostring(subject)
    end
    if type(pattern) ~= "string" then
        error("Invalid argument #2 to 'find' (string expected, got " .. type(pattern) .. ")", 2)
    end
    local success, result1, result2 = pcall(original_find, subject, pattern, ...)
    if not success then
        error("Error in string.find: " .. result1, 2)
    end
    return result1, result2
end
setreadonly(string, true)
