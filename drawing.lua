local DrawingLib = {}
DrawingLib.Fonts = {
	["UI"] = 0,
	["System"] = 1,
	["Flex"] = 2,
	["Monospace"] = 3
}

function DrawingLib.new(drawingType)
	drawingIndex += 1
if drawingType == "Line" then
    local lineObj = {
        From = Vector2.zero,
        To = Vector2.zero,
        Thickness = 1
    }

    for key, value in pairs(baseDrawingObj) do
        lineObj[key] = value
    end

    local lineFrame = Instance.new("Frame")
    lineFrame.Name = drawingIndex
    lineFrame.AnchorPoint = Vector2.one * 0.5
    lineFrame.BorderSizePixel = 0

    lineFrame.BackgroundColor3 = lineObj.Color
    lineFrame.Visible = lineObj.Visible
    lineFrame.ZIndex = lineObj.ZIndex
    lineFrame.BackgroundTransparency = convertTransparency(lineObj.Transparency)
    lineFrame.Size = UDim2.new()

    lineFrame.Parent = drawingUI
    local bs = table.create(0) -- Cache table
    table.insert(drawings, bs)

    local function updateLine()
        local direction = lineObj.To - lineObj.From
        local center = (lineObj.To + lineObj.From) / 2
        local distance = direction.Magnitude
        local theta = math.deg(math.atan2(direction.Y, direction.X))

        lineFrame.Position = UDim2.fromOffset(center.X, center.Y)
        lineFrame.Rotation = theta
        lineFrame.Size = UDim2.fromOffset(distance, lineObj.Thickness)
    end

    return setmetatable(bs, {
        __newindex = function(_, index, value)
            if lineObj[index] == nil then return end

            lineObj[index] = value
            if index == "From" or index == "To" or index == "Thickness" then
                updateLine()
            elseif index == "Visible" then
                lineFrame.Visible = value
            elseif index == "ZIndex" then
                lineFrame.ZIndex = value
            elseif index == "Transparency" then
                lineFrame.BackgroundTransparency = convertTransparency(value)
            elseif index == "Color" then
                lineFrame.BackgroundColor3 = value
            end
        end,
        __index = function(self, index)
            if index == "Remove" or index == "Destroy" then
                return function()
                    lineFrame:Destroy()
                    lineObj.Remove(self)
                    for k in pairs(bs) do
                        bs[k] = nil
                    end
                end
            end
            return lineObj[index]
        end
    })
	elseif drawingType == "Text" then
    local textObj = {
        Text = "",
        Font = DrawingLib.Fonts.UI,
        Size = 0,
        Position = Vector2.zero,
        Center = false,
        Outline = false,
        OutlineColor = Color3.new()
    }

    for key, value in pairs(baseDrawingObj) do
        textObj[key] = value
    end

    local textLabel = Instance.new("TextLabel")
    local uiStroke = Instance.new("UIStroke")
    
    textLabel.Name = drawingIndex
    textLabel.AnchorPoint = Vector2.one * 0.5
    textLabel.BorderSizePixel = 0
    textLabel.BackgroundTransparency = 1

    textLabel.Visible = textObj.Visible
    textLabel.TextColor3 = textObj.Color
    textLabel.TextTransparency = convertTransparency(textObj.Transparency)
    textLabel.ZIndex = textObj.ZIndex
    textLabel.FontFace = getFontFromIndex(textObj.Font)
    textLabel.TextSize = textObj.Size

    -- Function to update textLabel size and position
    local function updateTextLabel()
        local textBounds = textLabel.TextBounds
        local offset = textBounds / 2
        textLabel.Size = UDim2.fromOffset(textBounds.X, textBounds.Y)
        textLabel.Position = UDim2.fromOffset(textObj.Position.X + (textObj.Center and 0 or offset.X), textObj.Position.Y + offset.Y)
    end

    -- Connect to TextBounds property change
    textLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateTextLabel)

    uiStroke.Thickness = 1
    uiStroke.Enabled = textObj.Outline
    uiStroke.Color = textObj.OutlineColor

    textLabel.Parent = drawingUI
    uiStroke.Parent = textLabel
    
    local bs = table.create(0) -- Cache table
    table.insert(drawings, bs)

    return setmetatable(bs, {
        __newindex = function(_, index, value)
            if textObj[index] == nil then return end

            textObj[index] = value
            if index == "Text" then
                textLabel.Text = value
            elseif index == "Font" then
                textLabel.FontFace = getFontFromIndex(math.clamp(value, 0, 3))
            elseif index == "Size" then
                textLabel.TextSize = value
            elseif index == "Position" then
                updateTextLabel()
            elseif index == "Center" then
                local position = value and (camera.ViewportSize / 2) or textObj.Position
                textLabel.Position = UDim2.fromOffset(position.X, position.Y)
            elseif index == "Outline" then
                uiStroke.Enabled = value
            elseif index == "OutlineColor" then
                uiStroke.Color = value
            elseif index == "Visible" then
                textLabel.Visible = value
            elseif index == "ZIndex" then
                textLabel.ZIndex = value
            elseif index == "Transparency" then
                local transparency = convertTransparency(value)
                textLabel.TextTransparency = transparency
                uiStroke.Transparency = transparency
            elseif index == "Color" then
                textLabel.TextColor3 = value
            end
        end,
        __index = function(self, index)
            if index == "Remove" or index == "Destroy" then
                return function()
                    textLabel:Destroy()
                    textObj.Remove(self)
                    for k in pairs(bs) do
                        bs[k] = nil
                    end
                end
            elseif index == "TextBounds" then
                return textLabel.TextBounds
            end
            return textObj[index]
        end
    })
elseif drawingType == "Circle" then
    local circleObj = {
        Radius = 150,
        Position = Vector2.zero,
        Thickness = 0.7,
        Filled = false
    }

    for key, value in pairs(baseDrawingObj) do
        circleObj[key] = value
    end

    local circleFrame = Instance.new("Frame")
    local uiCorner = Instance.new("UICorner")
    local uiStroke = Instance.new("UIStroke")
    
    circleFrame.Name = drawingIndex
    circleFrame.AnchorPoint = Vector2.one * 0.5
    circleFrame.BorderSizePixel = 0
    circleFrame.BackgroundTransparency = circleObj.Filled and convertTransparency(circleObj.Transparency) or 1
    circleFrame.BackgroundColor3 = circleObj.Color
    circleFrame.Visible = circleObj.Visible
    circleFrame.ZIndex = circleObj.ZIndex
    circleFrame.Size = UDim2.fromOffset(circleObj.Radius * 2, circleObj.Radius * 2)

    uiCorner.CornerRadius = UDim.new(1, 0)
    uiStroke.Thickness = circleObj.Thickness
    uiStroke.Enabled = not circleObj.Filled
    uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    circleFrame.Parent = drawingUI
    uiCorner.Parent = circleFrame
    uiStroke.Parent = circleFrame

    local bs = table.create(0)
    table.insert(drawings, bs)

    return setmetatable(bs, {
        __newindex = function(_, index, value)
            if circleObj[index] == nil then return end

            circleObj[index] = value
            if index == "Radius" then
                circleFrame.Size = UDim2.fromOffset(value * 2, value * 2)
            elseif index == "Position" then
                circleFrame.Position = UDim2.fromOffset(value.X, value.Y)
            elseif index == "Thickness" then
                uiStroke.Thickness = math.clamp(value, 0.6, math.huge)
            elseif index == "Filled" then
                circleFrame.BackgroundTransparency = value and convertTransparency(circleObj.Transparency) or 1
                uiStroke.Enabled = not value
            elseif index == "Visible" then
                circleFrame.Visible = value
            elseif index == "ZIndex" then
                circleFrame.ZIndex = value
            elseif index == "Transparency" then
                local transparency = convertTransparency(value)
                circleFrame.BackgroundTransparency = circleObj.Filled and transparency or 1
                uiStroke.Transparency = transparency
            elseif index == "Color" then
                circleFrame.BackgroundColor3 = value
                uiStroke.Color = value
            end
        end,
        __index = function(self, index)
            if index == "Remove" or index == "Destroy" then
                return function()
                    circleFrame:Destroy()
                    circleObj.Remove(self)
                    for k in pairs(bs) do
                        bs[k] = nil
                    end
                end
            end
            return circleObj[index]
        end
    })

elseif drawingType == "Square" then
    local squareObj = {
        Size = Vector2.zero,
        Position = Vector2.zero,
        Thickness = 0.7,
        Filled = false
    }

    for key, value in pairs(baseDrawingObj) do
        squareObj[key] = value
    end

    local squareFrame = Instance.new("Frame")
    local uiStroke = Instance.new("UIStroke")

    squareFrame.Name = drawingIndex
    squareFrame.BorderSizePixel = 0
    squareFrame.BackgroundTransparency = squareObj.Filled and convertTransparency(squareObj.Transparency) or 1
    squareFrame.BackgroundColor3 = squareObj.Color
    squareFrame.Visible = squareObj.Visible
    squareFrame.ZIndex = squareObj.ZIndex
    squareFrame.Size = UDim2.fromOffset(squareObj.Size.X, squareObj.Size.Y)

    uiStroke.Thickness = squareObj.Thickness
    uiStroke.Enabled = not squareObj.Filled
    uiStroke.LineJoinMode = Enum.LineJoinMode.Miter

    squareFrame.Parent = drawingUI
    uiStroke.Parent = squareFrame

    local bs = table.create(0)
    table.insert(drawings, bs)

    return setmetatable(bs, {
        __newindex = function(_, index, value)
            if squareObj[index] == nil then return end

            squareObj[index] = value
            if index == "Size" then
                squareFrame.Size = UDim2.fromOffset(value.X, value.Y)
            elseif index == "Position" then
                squareFrame.Position = UDim2.fromOffset(value.X, value.Y)
            elseif index == "Thickness" then
                uiStroke.Thickness = math.clamp(value, 0.6, math.huge)
            elseif index == "Filled" then
                squareFrame.BackgroundTransparency = value and convertTransparency(squareObj.Transparency) or 1
                uiStroke.Enabled = not value
            elseif index == "Visible" then
                squareFrame.Visible = value
            elseif index == "ZIndex" then
                squareFrame.ZIndex = value
            elseif index == "Transparency" then
                local transparency = convertTransparency(value)
                squareFrame.BackgroundTransparency = squareObj.Filled and transparency or 1
                uiStroke.Transparency = transparency
            elseif index == "Color" then
                squareFrame.BackgroundColor3 = value
                uiStroke.Color = value
            end
        end,
        __index = function(self, index)
            if index == "Remove" or index == "Destroy" then
                return function()
                    squareFrame:Destroy()
                    squareObj.Remove(self)
                    for k in pairs(bs) do
                        bs[k] = nil
                    end
                end
            end
            return squareObj[index]
        end
    })
	elseif drawingType == "Image" then
    local imageObj = {
        Data = "",
        DataURL = "rbxassetid://0",
        Size = Vector2.zero,
        Position = Vector2.zero
    }

    for key, value in pairs(baseDrawingObj) do
        imageObj[key] = value
    end

    local imageFrame = Instance.new("ImageLabel")
    imageFrame.Name = drawingIndex
    imageFrame.BorderSizePixel = 0
    imageFrame.ScaleType = Enum.ScaleType.Stretch
    imageFrame.BackgroundTransparency = 1
    imageFrame.Visible = imageObj.Visible
    imageFrame.ZIndex = imageObj.ZIndex
    imageFrame.ImageTransparency = convertTransparency(imageObj.Transparency)
    imageFrame.ImageColor3 = imageObj.Color
    imageFrame.Image = imageObj.DataURL
    imageFrame.Size = UDim2.fromOffset(imageObj.Size.X, imageObj.Size.Y)
    imageFrame.Position = UDim2.fromOffset(imageObj.Position.X, imageObj.Position.Y)

    imageFrame.Parent = drawingUI

    local bs = table.create(0)
    table.insert(drawings, bs)

    return setmetatable(bs, {
        __newindex = function(_, index, value)
            if imageObj[index] == nil then return end

            imageObj[index] = value
            if index == "Data" then
            --We can use it with getcustommasset
            elseif index == "DataURL" then
                imageFrame.Image = value
            elseif index == "Size" then
                imageFrame.Size = UDim2.fromOffset(value.X, value.Y)
            elseif index == "Position" then
                imageFrame.Position = UDim2.fromOffset(value.X, value.Y)
            elseif index == "Visible" then
                imageFrame.Visible = value
            elseif index == "ZIndex" then
                imageFrame.ZIndex = value
            elseif index == "Transparency" then
                imageFrame.ImageTransparency = convertTransparency(value)
            elseif index == "Color" then
                imageFrame.ImageColor3 = value
            end
        end,
        __index = function(self, index)
            if index == "Remove" or index == "Destroy" then
                return function()
                    imageFrame:Destroy()
                    imageObj.Remove(self)
                    for k in pairs(bs) do
                        bs[k] = nil
                    end
                end
            elseif index == "Data" then
                return nil --We can use it with getcustommasset
            end
            return imageObj[index]
        end
    })
	elseif drawingType == "Quad" then
    local quadObj = {
        PointA = Vector2.zero,
        PointB = Vector2.zero,
        PointC = Vector2.zero,
        PointD = Vector2.zero,
        Thickness = 1,
        Filled = false
    }

    for key, value in pairs(baseDrawingObj) do
        quadObj[key] = value
    end

    local _linePoints = {
        A = DrawingLib.new("Line"),
        B = DrawingLib.new("Line"),
        C = DrawingLib.new("Line"),
        D = DrawingLib.new("Line")
    }

    local bs = {}
    table.insert(drawings, bs)

    local function updateLines()
        _linePoints.A.From = quadObj.PointA
        _linePoints.A.To = quadObj.PointB
        _linePoints.B.From = quadObj.PointB
        _linePoints.B.To = quadObj.PointC
        _linePoints.C.From = quadObj.PointC
        _linePoints.C.To = quadObj.PointD
        _linePoints.D.From = quadObj.PointD
        _linePoints.D.To = quadObj.PointA
    end

    updateLines()

    return setmetatable(bs, {
        __newindex = function(_, index, value)
            if quadObj[index] == nil then return end

            quadObj[index] = value
            if index == "PointA" or index == "PointB" or index == "PointC" or index == "PointD" then
                updateLines()
            elseif index == "Thickness" or index == "Visible" or index == "Color" or index == "ZIndex" then
                for _, linePoint in pairs(_linePoints) do
                    linePoint[index] = value
                end
            elseif index == "Filled" then
			--I didnt make that
            end
        end,
        __index = function(self, index)
            if index == "Remove" or index == "Destroy" then
                return function()
                    for _, linePoint in pairs(_linePoints) do
                        linePoint:Destroy()
                    end
                    quadObj.Remove(self)
                    for k in pairs(bs) do
                        bs[k] = nil
                    end
                end
            end
            return quadObj[index]
        end
    })

elseif drawingType == "Triangle" then
    local triangleObj = {
        PointA = Vector2.zero,
        PointB = Vector2.zero,
        PointC = Vector2.zero,
        Thickness = 1,
        Filled = false
    }

    for key, value in pairs(baseDrawingObj) do
        triangleObj[key] = value
    end

    local _linePoints = {
        A = DrawingLib.new("Line"),
        B = DrawingLib.new("Line"),
        C = DrawingLib.new("Line")
    }

    local bs = {}
    table.insert(drawings, bs)

    local function updateLines()
        _linePoints.A.From = triangleObj.PointA
        _linePoints.A.To = triangleObj.PointB
        _linePoints.B.From = triangleObj.PointB
        _linePoints.B.To = triangleObj.PointC
        _linePoints.C.From = triangleObj.PointC
        _linePoints.C.To = triangleObj.PointA
    end

    updateLines()

    return setmetatable(bs, {
        __newindex = function(_, index, value)
            if triangleObj[index] == nil then return end

            triangleObj[index] = value
            if index == "PointA" or index == "PointB" or index == "PointC" then
                updateLines()
            elseif index == "Thickness" or index == "Visible" or index == "Color" or index == "ZIndex" then
                for _, linePoint in pairs(_linePoints) do
                    linePoint[index] = value
                end
            elseif index == "Filled" then
                -- Placeholder for future functionality
            end
        end,
        __index = function(self, index)
            if index == "Remove" or index == "Destroy" then
                return function()
                    for _, linePoint in pairs(_linePoints) do
                        linePoint:Destroy()
                    end
                    triangleObj.Remove(self)
                    for k in pairs(bs) do
                        bs[k] = nil
                    end
                end
            end
            return triangleObj[index]
        end
    })
end
end

getgenv()["Drawing"] = DrawingLib
getgenv()["Drawing"]["Fonts"] = {
    ['UI'] = 0,
    ['System'] = 1,
    ['Plex'] = 2,
    ['Monospace'] = 3
}

getgenv()["cleardrawcache"] = newcclosure(function()
    for _, v in pairs(Drawings) do
        v:Remove()
    end
    table.clear(drawings)
end)

getgenv()["clear_draw_cache"] = cleardrawcache
getgenv()["ClearDrawCache"] = cleardrawcache

getgenv()["isrenderobj"] = newcclosure(function(Inst)
    for _, v in pairs(drawings) do
        if v == Inst and type(v) == "table" then
            return true
        end
    end
    return false
end)

getgenv()["is_render_obj"] = isrenderobj
getgenv()["IsRenderObj"] = isrenderobj

getgenv()["getrenderproperty"] = newcclosure(function(a, b)
    return a[b]
end)

getgenv()["get_render_property"] = getrenderproperty
getgenv()["GetRenderProperty"] = getrenderproperty

getgenv()["setrenderproperty"] = newcclosure(function(a, b, c)
    local success, err = pcall(function()
        a[b] = c
    end)
    if not success and err then warn(err) end
end)

getgenv()["set_render_property"] = getrenderproperty
getgenv()["SetRenderProperty"] = setrenderproperty
