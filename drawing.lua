local textService = cloneref(game:GetService("TextService"));
local drawing = {
    Fonts = {
        UI = 0,
        System = 1,
        Plex = 2,
        Monospace = 3
    }
};
local function createFramer(className, properties, children)
	local inst = getrenv().Instance.new(className);
	for i, v in properties do
		if i ~= "Parent" then
			inst[i] = v;
		end
	end
	if children then
		for i, v in children do
			v.Parent = inst;
		end
	end
	inst.Parent = properties.Parent;
	return inst;
end

do
    local drawingDirectory = createFramer("ScreenGui", {
        DisplayOrder = 15,
        IgnoreGuiInset = true,
        Name = "drawingDirectory",
        Parent = gethui(),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    });
	
	local function updatePosition(frame, from, to, thickness)
		local central = (from + to) / 2;
		local offset = to - from;
		frame.Position = getrenv().UDim2.fromOffset(central.X, central.Y);
		frame.Rotation = getrenv().math.atan2(offset.Y, offset.X) * 180 / getrenv().math.pi;
		frame.Size = getrenv().UDim2.fromOffset(offset.Magnitude, thickness);
	end

    local itemCounter = 0;
    local cache = {};

    local classes = {};
    do
        local line = {};

        function line.new()
            itemCounter = itemCounter + 1;
            local id = itemCounter;

            local newLine = getrenv().setmetatable({
                _id = id,
                __OBJECT_EXISTS = true,
                _properties = {
                    Color = getrenv().Color3.new(),
                    From = getrenv().Vector2.new(),
                    Thickness = 1,
                    To = getrenv().Vector2.new(),
                    Transparency = 1,
                    Visible = false,
                    ZIndex = 0
                },
                _frame = createFramer("Frame", {
                    Name = id,
                    AnchorPoint = getrenv().Vector2.new(0.5, 0.5),
                    BackgroundColor3 = getrenv().Color3.new(),
                    BorderSizePixel = 0,
                    Parent = drawingDirectory,
                    Position = getrenv().UDim2.new(),
                    Size = getrenv().UDim2.new(),
                    Visible = false,
                    ZIndex = 0
                })
            }, line);

            cache[id] = newLine;
            return newLine;
        end

        function line:__index(k)
			local prop = self._properties[k];
			if prop ~= nil then
				return prop;
			end
			return line[k];
        end

        function line:__newindex(k, v)
            if self.__OBJECT_EXISTS == true then
                local props = self._properties;
				if props[k] == nil or props[k] == v or typeof(props[k]) ~= typeof(v) then
					return;
				end
                props[k] = v;
                if k == "Color" then
                    self._frame.BackgroundColor3 = v;
                elseif k == "From" then
                    self:_updatePosition();
                elseif k == "Thickness" then
                    self._frame.Size = getrenv().UDim2.fromOffset(self._frame.AbsoluteSize.X, getrenv().math.max(v, 1));
                elseif k == "To" then
                    self:_updatePosition();
                elseif k == "Transparency" then
                    self._frame.BackgroundTransparency = getrenv().math.clamp(1 - v, 0, 1);
                elseif k == "Visible" then
                    self._frame.Visible = v;
                elseif k == "ZIndex" then
                    self._frame.ZIndex = v;
                end
            end
        end
		
		function line:__iter()
            return next, self._properties;
        end
		
		function line:__tostring()
			return "Drawing";
		end

        function line:Destroy()
			cache[self._id] = nil;
            self.__OBJECT_EXISTS = false;
            game.Destroy(self._frame);
        end

        function line:_updatePosition()
			local props = self._properties;
			updatePosition(self._frame, props.From, props.To, props.Thickness);
        end

        line.Remove = line.Destroy;
        classes.Line = line;
    end
    
    do
        local circle = {};

        function circle.new()
            itemCounter = itemCounter + 1;
            local id = itemCounter;

            local newCircle = getrenv().setmetatable({
                _id = id,
                __OBJECT_EXISTS = true,
                _properties = {
                    Color = getrenv().Color3.new(),
                    Filled = false,
					NumSides = 0,
                    Position = getrenv().Vector2.new(),
                    Radius = 0,
                    Thickness = 1,
                    Transparency = 1,
                    Visible = false,
                    ZIndex = 0
                },
                _frame = createFramer("Frame", {
                    Name = id,
                    AnchorPoint = getrenv().Vector2.new(0.5, 0.5),
                    BackgroundColor3 = getrenv().Color3.new(),
					BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = drawingDirectory,
                    Position = getrenv().UDim2.new(),
                    Size = getrenv().UDim2.new(),
                    Visible = false,
                    ZIndex = 0
                }, {
                    createFramer("UICorner", {
                        Name = "_corner",
                        CornerRadius = getrenv().UDim.new(1, 0)
                    }),
                    createFramer("UIStroke", {
                        Name = "_stroke",
                        Color = getrenv().Color3.new(),
                        Thickness = 1
                    })
                })
            }, circle);

            cache[id] = newCircle;
            return newCircle;
        end

        function circle:__index(k)
			local prop = self._properties[k];
			if prop ~= nil then
				return prop;
			end
			return circle[k];
        end

        function circle:__newindex(k, v)
            if self.__OBJECT_EXISTS == true then
				local props = self._properties;
				if props[k] == nil or props[k] == v or typeof(props[k]) ~= typeof(v) then
					return;
				end
				props[k] = v;
                if k == "Color" then
                    self._frame.BackgroundColor3 = v;
                    self._frame._stroke.Color = v;
                elseif k == "Filled" then
                    self._frame.BackgroundTransparency = v and 1 - props.Transparency or 1;
                elseif k == "Position" then
                    self._frame.Position = getrenv().UDim2.fromOffset(v.X, v.Y);
                elseif k == "Radius" then
					self:_updateRadius();
                elseif k == "Thickness" then
                    self._frame._stroke.Thickness = getrenv().math.max(v, 1);
					self:_updateRadius();
                elseif k == "Transparency" then
					self._frame._stroke.Transparency = 1 - v;
					if props.Filled then
						self._frame.BackgroundTransparency = 1 - v;
					end
                elseif k == "Visible" then
                    self._frame.Visible = v;
                elseif k == "ZIndex" then
                    self._frame.ZIndex = v;
                end
            end
        end
		
		function circle:__iter()
            return next, self._properties;
        end
		
		function circle:__tostring()
			return "Drawing";
		end

        function circle:Destroy()
			cache[self._id] = nil;
            self.__OBJECT_EXISTS = false;
            game.Destroy(self._frame);
        end
		
		function circle:_updateRadius()
			local props = self._properties;
			local diameter = (props.Radius * 2) - (props.Thickness * 2);
			self._frame.Size = getrenv().UDim2.fromOffset(diameter, diameter);
		end

        circle.Remove = circle.Destroy;
        classes.Circle = circle;
    end

	do
		local enumToFont = {
			[drawing.Fonts.UI] = Font.new("rbxasset://fonts/families/Arial.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
			[drawing.Fonts.System] = Font.new("rbxasset://fonts/families/HighwayGothic.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
			[drawing.Fonts.Plex] = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
			[drawing.Fonts.Monospace] = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		};

		local text = {};
		
		function text.new()
			itemCounter = itemCounter + 1;
            local id = itemCounter;

            local newText = getrenv().setmetatable({
                _id = id,
                __OBJECT_EXISTS = true,
                _properties = {
					Center = false,
					Color = getrenv().Color3.new(),
					Font = 0,
					Outline = false,
					OutlineColor = getrenv().Color3.new(),
					Position = getrenv().Vector2.new(),
					Size = 12,
					Text = "",
					TextBounds = getrenv().Vector2.new(),
					Transparency = 1,
					Visible = false,
					ZIndex = 0
                },
                _frame = createFramer("TextLabel", {
					Name = id,
					BackgroundTransparency = 1,
					FontFace = enumToFont[0],
                    Parent = drawingDirectory,
                    Position = getrenv().UDim2.new(),
                    Size = getrenv().UDim2.new(),
					Text = "",
					TextColor3 = getrenv().Color3.new(),
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
                    Visible = false,
                    ZIndex = 0
				}, {
					createFramer("UIStroke", {
						Name = "_stroke",
						Color = getrenv().Color3.new(),
						Enabled = false,
						Thickness = 1
					})
				})
            }, text);

            cache[id] = newText;
            return newText;
		end

		function text:__index(k)
			local prop = self._properties[k];
			if prop ~= nil then
				return prop;
			end
			return text[k];
        end

        function text:__newindex(k, v)
            if self.__OBJECT_EXISTS == true then
                local props = self._properties;
				if k == "TextBounds" or props[k] == nil or props[k] == v or typeof(props[k]) ~= typeof(v) then
					return;
				end
				props[k] = v;
				if k == "Center" then
					self._frame.TextXAlignment = v and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left;
				elseif k == "Color" then
					self._frame.TextColor3 = v;
				elseif k == "Font" then
					self._frame.FontFace = enumToFont[v];
					self:_updateTextBounds();
				elseif k == "Outline" then
					self._frame._stroke.Enabled = v;
				elseif k == "OutlineColor" then
					self._frame._stroke.Color = v;
				elseif k == "Position" then
					self._frame.Position = getrenv().UDim2.fromOffset(v.X, v.Y);
				elseif k == "Size" then
					self._frame.TextSize = v;
					self:_updateTextBounds();
				elseif k == "Text" then
					self._frame.Text = v;
					self:_updateTextBounds();
				elseif k == "Transparency" then
					self._frame.TextTransparency = 1 - v;
					self._frame._stroke.Transparency = 1 - v;
				elseif k == "Visible" then
					self._frame.Visible = v;
				elseif k == "ZIndex" then
					self._frame.ZIndex = v;
				end
            end
        end
		
		function text:__iter()
            return next, self._properties;
        end
		
		function text:__tostring()
			return "Drawing";
		end

        function text:Destroy()
			cache[self._id] = nil;
            self.__OBJECT_EXISTS = false;
            game.Destroy(self._frame);
        end

		function text:_updateTextBounds()
			local props = self._properties;
			props.TextBounds = textService.GetTextBoundsAsync(textService, createFramer("GetTextBoundsParams", {
				Text = props.Text,
				Size = props.Size,
				Font = enumToFont[props.Font],
				Width = getrenv().math.huge
			}));
		end

		text.Remove = text.Destroy;
		classes.Text = text;
	end
	do
		local square = {};

		function square.new()
			itemCounter = itemCounter + 1;
			local id = itemCounter;

			local newSquare = getrenv().setmetatable({
                _id = id,
                __OBJECT_EXISTS = true,
				_properties = {
					Color = getrenv().Color3.new(),
					Filled = false,
					Position = getrenv().Vector2.new(),
					Size = getrenv().Vector2.new(),
					Thickness = 1,
					Transparency = 1,
					Visible = false,
					ZIndex = 0
				},
				_frame = createFramer("Frame", {
					BackgroundColor3 = getrenv().Color3.new(),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Parent = drawingDirectory,
                    Position = getrenv().UDim2.new(),
                    Size = getrenv().UDim2.new(),
                    Visible = false,
                    ZIndex = 0
				}, {
					createFramer("UIStroke", {
						Name = "_stroke",
						Color = getrenv().Color3.new(),
						Thickness = 1
					})
				})
			}, square);
			
			cache[id] = newSquare;
			return newSquare;
		end

		function square:__index(k)
			local prop = self._properties[k];
			if prop ~= nil then
				return prop;
			end
			return square[k];
        end

        function square:__newindex(k, v)
            if self.__OBJECT_EXISTS == true then
				local props = self._properties;
				if props[k] == nil or props[k] == v or typeof(props[k]) ~= typeof(v) then
					return;
				end
				props[k] = v;
				if k == "Color" then
					self._frame.BackgroundColor3 = v;
					self._frame._stroke.Color = v;
				elseif k == "Filled" then
					self._frame.BackgroundTransparency = v and 1 - props.Transparency or 1;
				elseif k == "Position" then
					self:_updateScale();
				elseif k == "Size" then
					self:_updateScale();
				elseif k == "Thickness" then
					self._frame._stroke.Thickness = v;
					self:_updateScale();
				elseif k == "Transparency" then
					self._frame._stroke.Transparency = 1 - v;
					if props.Filled then
						self._frame.BackgroundTransparency = 1 - v;
					end
				elseif k == "Visible" then
					self._frame.Visible = v;
				elseif k == "ZIndex" then
					self._frame.ZIndex = v;
				end
            end
        end
		
		function square:__iter()
            return next, self._properties;
        end
		
		function square:__tostring()
			return "Drawing";
		end

        function square:Destroy()
			cache[self._id] = nil;
            self.__OBJECT_EXISTS = false;
            game.Destroy(self._frame);
        end

		function square:_updateScale()
			local props = self._properties;
			self._frame.Position = getrenv().UDim2.fromOffset(props.Position.X + props.Thickness, props.Position.Y + props.Thickness);
			self._frame.Size = getrenv().UDim2.fromOffset(props.Size.X - props.Thickness * 2, props.Size.Y - props.Thickness * 2);
		end

		square.Remove = square.Destroy;
		classes.Square = square;
	end

          
do
		local image = {};

		function image.new()
			itemCounter = itemCounter + 1;
			local id = itemCounter;

			local newImage = getrenv().setmetatable({
				_id = id,
				_imageId = 0,
				__OBJECT_EXISTS = true,
				_properties = {
					Color = getrenv().Color3.new(1, 1, 1),
					Data = "",
					Position = getrenv().Vector2.new(),
					Rounding = 0,
					Size = getrenv().Vector2.new(),
					Transparency = 1,
					Uri = "",
					Visible = false,
					ZIndex = 0
				},
				_frame = createFramer("ImageLabel", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Image = "",
					ImageColor3 = getrenv().Color3.new(1, 1, 1),
					Parent = drawingDirectory,
                    Position = getrenv().UDim2.new(),
                    Size = getrenv().UDim2.new(),
                    Visible = false,
                    ZIndex = 0
				}, {
					createFramer("UICorner", {
						Name = "_corner",
						CornerRadius = getrenv().UDim.new()
					})
				})
			}, image);
			
			cache[id] = newImage;
			return newImage;
		end

		function image:__index(k)
			getrenv().assert(k ~= "Data", getrenv().string.format("Attempt to read writeonly property '%s'", k));
			if k == "Loaded" then
				return self._frame.IsLoaded;
			end
			local prop = self._properties[k];
			if prop ~= nil then
				return prop;
			end
			return image[k];
		end

		function image:__newindex(k, v)
			if self.__OBJECT_EXISTS == true then
				local props = self._properties;
				if props[k] == nil or props[k] == v or typeof(props[k]) ~= typeof(v) then
					return;
				end
				props[k] = v;
				if k == "Color" then
					self._frame.ImageColor3 = v;
				elseif k == "Data" then
					self:_newImage(v);
				elseif k == "Position" then
					self._frame.Position = getrenv().UDim2.fromOffset(v.X, v.Y);
				elseif k == "Rounding" then
					self._frame._corner.CornerRadius = getrenv().UDim.new(0, v);
				elseif k == "Size" then
					self._frame.Size = getrenv().UDim2.fromOffset(v.X, v.Y);
				elseif k == "Transparency" then
					self._frame.ImageTransparency = 1 - v;
				elseif k == "Uri" then
					self:_newImage(v, true);
				elseif k == "Visible" then
					self._frame.Visible = v;
				elseif k == "ZIndex" then
					self._frame.ZIndex = v;
				end
			end
		end
		
		function image:__iter()
            return next, self._properties;
        end
		
		function image:__tostring()
			return "Drawing";
		end

		function image:Destroy()
			cache[self._id] = nil;
			self.__OBJECT_EXISTS = false;
			game.Destroy(self._frame);
		end

		function image:_newImage(data, isUri)
			getrenv().task.spawn(function() -- this is fucked but u can't yield in a metamethod
				self._imageId = self._imageId + 1;
				local path = getrenv().string.format("%s-%s.png", self._id, self._imageId);
				if isUri then
					local newData;
					while newData == nil do
						local success, res = pcall(game.HttpGet, game, data, true);
						if success then
							newData = res;
						elseif string.find(string.lower(res), "too many requests") then
							task.wait(3);
						else
							error(res, 2);
							return;
						end
					end
					self._properties.Data = data;
				else
					self._properties.Uri = "";
				end
			--	self._frame.Image = _writecustomasset(path);
			end);
		end

		image.Remove = image.Destroy;
		classes.Image = image;
	end

	do
		local triangle = {};

		function triangle.new()
			itemCounter = itemCounter + 1;
			local id = itemCounter;

			local newTriangle = getrenv().setmetatable({
				_id = id,
				__OBJECT_EXISTS = true,
				_properties = {
					Color = getrenv().Color3.new(),
					Filled = false,
					PointA = getrenv().Vector2.new(),
					PointB = getrenv().Vector2.new(),
					PointC = getrenv().Vector2.new(),
					Thickness = 1,
					Transparency = 1,
					Visible = false,
					ZIndex = 0
				},
				_frame = createFramer("Frame", {
					BackgroundTransparency = 1,
					Parent = drawingDirectory,
					Size = getrenv().UDim2.new(1, 0, 1, 0),
					Visible = false,
					ZIndex = 0
				}, {
					createFramer("Frame", {
						Name = "_line1",
						AnchorPoint = getrenv().Vector2.new(0.5, 0.5),
						BackgroundColor3 = getrenv().Color3.new(),
						BorderSizePixel = 0,
						Position = getrenv().UDim2.new(),
						Size = getrenv().UDim2.new(),
						ZIndex = 0
					}),
					createFramer("Frame", {
						Name = "_line2",
						AnchorPoint = getrenv().Vector2.new(0.5, 0.5),
						BackgroundColor3 = getrenv().Color3.new(),
						BorderSizePixel = 0,
						Position = getrenv().UDim2.new(),
						Size = getrenv().UDim2.new(),
						ZIndex = 0
					}),
					createFramer("Frame", {
						Name = "_line3",
						AnchorPoint = getrenv().Vector2.new(0.5, 0.5),
						BackgroundColor3 = getrenv().Color3.new(),
						BorderSizePixel = 0,
						Position = getrenv().UDim2.new(),
						Size = getrenv().UDim2.new(),
						ZIndex = 0
					})
				})
			}, triangle);
			
			cache[id] = newTriangle;
			return newTriangle;
		end

		function triangle:__index(k)
			local prop = self._properties[k];
			if prop ~= nil then
				return prop;
			end
			return triangle[k];
		end

		function triangle:__newindex(k, v)
			if self.__OBJECT_EXISTS == true then
				local props, frame = self._properties, self._frame;
				if props[k] == nil or props[k] == v or typeof(props[k]) ~= typeof(v) then
					return;
				end
				props[k] = v;
				if k == "Color" then
					frame._line1.BackgroundColor3 = v;
					frame._line2.BackgroundColor3 = v;
					frame._line3.BackgroundColor3 = v;
				elseif k == "Filled" then
					-- TODO
				elseif k == "PointA" then
					self:_updateVertices({
						{ frame._line1, props.PointA, props.PointB },
						{ frame._line3, props.PointC, props.PointA }
					});
					if props.Filled then
						self:_calculateFill();
					end
				elseif k == "PointB" then
					self:_updateVertices({
						{ frame._line1, props.PointA, props.PointB },
						{ frame._line2, props.PointB, props.PointC }
					});
					if props.Filled then
						self:_calculateFill();
					end
				elseif k == "PointC" then
					self:_updateVertices({
						{ frame._line2, props.PointB, props.PointC },
						{ frame._line3, props.PointC, props.PointA }
					});
					if props.Filled then
						self:_calculateFill();
					end
				elseif k == "Thickness" then
					local thickness = getrenv().math.max(v, 1);
                    frame._line1.Size = getrenv().UDim2.fromOffset(frame._line1.AbsoluteSize.X, thickness);
                    frame._line2.Size = getrenv().UDim2.fromOffset(frame._line2.AbsoluteSize.X, thickness);
                    frame._line3.Size = getrenv().UDim2.fromOffset(frame._line3.AbsoluteSize.X, thickness);
				elseif k == "Transparency" then
					frame._line1.BackgroundTransparency = 1 - v;
					frame._line2.BackgroundTransparency = 1 - v;
					frame._line3.BackgroundTransparency = 1 - v;
				elseif k == "Visible" then
					self._frame.Visible = v;
				elseif k == "ZIndex" then
					self._frame.ZIndex = v;
				end
			end
		end
		
		function triangle:__iter()
            return next, self._properties;
        end
		
		function triangle:__tostring()
			return "Drawing";
		end

		function triangle:Destroy()
			cache[self._id] = nil;
            self.__OBJECT_EXISTS = false;
            game.Destroy(self._frame);
		end

		function triangle:_updateVertices(vertices)
			local thickness = self._properties.Thickness;
			for i, v in vertices do
				updatePosition(v[1], v[2], v[3], thickness);
			end
		end

		function triangle:_calculateFill()
		
		end

		triangle.Remove = triangle.Destroy;
		classes.Triangle = triangle;
	end
	
	do
		local quad = {};
		
		function quad.new()
			itemCounter = itemCounter + 1;
			local id = itemCounter;
			
			local newQuad = getrenv().setmetatable({
				_id = id,
				__OBJECT_EXISTS = true,
				_properties = {
					Color = getrenv().Color3.new(),
					Filled = false,
					PointA = getrenv().Vector2.new(),
					PointB = getrenv().Vector2.new(),
					PointC = getrenv().Vector2.new(),
					PointD = getrenv().Vector2.new(),
					Thickness = 1,
					Transparency = 1,
					Visible = false,
					ZIndex = 0
				},
				_frame = createFramer("Frame", {
					BackgroundTransparency = 1,
					Parent = drawingDirectory,
					Size = getrenv().UDim2.new(1, 0, 1, 0),
					Visible = false,
					ZIndex = 0
				}, {
					createFramer("Frame", {
						Name = "_line1",
						AnchorPoint = getrenv().Vector2.new(0.5, 0.5),
						BackgroundColor3 = getrenv().Color3.new(),
						BorderSizePixel = 0,
						Position = getrenv().UDim2.new(),
						Size = getrenv().UDim2.new(),
						ZIndex = 0
					}),
					createFramer("Frame", {
						Name = "_line2",
						AnchorPoint = getrenv().Vector2.new(0.5, 0.5),
						BackgroundColor3 = getrenv().Color3.new(),
						BorderSizePixel = 0,
						Position = getrenv().UDim2.new(),
						Size = getrenv().UDim2.new(),
						ZIndex = 0
					}),
					createFramer("Frame", {
						Name = "_line3",
						AnchorPoint = getrenv().Vector2.new(0.5, 0.5),
						BackgroundColor3 = getrenv().Color3.new(),
						BorderSizePixel = 0,
						Position = getrenv().UDim2.new(),
						Size = getrenv().UDim2.new(),
						ZIndex = 0
					}),
					createFramer("Frame", {
						Name = "_line4",
						AnchorPoint = getrenv().Vector2.new(0.5, 0.5),
						BackgroundColor3 = getrenv().Color3.new(),
						BorderSizePixel = 0,
						Position = getrenv().UDim2.new(),
						Size = getrenv().UDim2.new(),
						ZIndex = 0
					})
				})
			}, quad);
			
			cache[id] = newQuad;
			return newQuad;
		end
		
		function quad:__index(k)
			local prop = self._properties[k];
			if prop ~= nil then
				return prop;
			end
			return quad[k];
		end

		function quad:__newindex(k, v)
			if self.__OBJECT_EXISTS == true then
				local props, frame = self._properties, self._frame;
				if props[k] == nil or props[k] == v or typeof(props[k]) ~= typeof(v) then
					return;
				end
				props[k] = v;
				if k == "Color" then
					frame._line1.BackgroundColor3 = v;
					frame._line2.BackgroundColor3 = v;
					frame._line3.BackgroundColor3 = v;
					frame._line4.BackgroundColor3 = v;
				elseif k == "Filled" then
					-- TODO
				elseif k == "PointA" then
					self:_updateVertices({
						{ frame._line1, props.PointA, props.PointB },
						{ frame._line4, props.PointD, props.PointA }
					});
					if props.Filled then
						self:_calculateFill();
					end
				elseif k == "PointB" then
					self:_updateVertices({
						{ frame._line1, props.PointA, props.PointB },
						{ frame._line2, props.PointB, props.PointC }
					});
					if props.Filled then
						self:_calculateFill();
					end
				elseif k == "PointC" then
					self:_updateVertices({
						{ frame._line2, props.PointB, props.PointC },
						{ frame._line3, props.PointC, props.PointD }
					});
					if props.Filled then
						self:_calculateFill();
					end
				elseif k == "PointD" then
					self:_updateVertices({
						{ frame._line3, props.PointC, props.PointD },
						{ frame._line4, props.PointD, props.PointA }
					});
					if props.Filled then
						self:_calculateFill();
					end
				elseif k == "Thickness" then
					local thickness = getrenv().math.max(v, 1);
                    frame._line1.Size = getrenv().UDim2.fromOffset(frame._line1.AbsoluteSize.X, thickness);
                    frame._line2.Size = getrenv().UDim2.fromOffset(frame._line2.AbsoluteSize.X, thickness);
                    frame._line3.Size = getrenv().UDim2.fromOffset(frame._line3.AbsoluteSize.X, thickness);
                    frame._line4.Size = getrenv().UDim2.fromOffset(frame._line3.AbsoluteSize.X, thickness);
				elseif k == "Transparency" then
					frame._line1.BackgroundTransparency = 1 - v;
					frame._line2.BackgroundTransparency = 1 - v;
					frame._line3.BackgroundTransparency = 1 - v;
					frame._line4.BackgroundTransparency = 1 - v;
				elseif k == "Visible" then
					self._frame.Visible = v;
				elseif k == "ZIndex" then
					self._frame.ZIndex = v;
				end
			end
		end
	
		function quad:__iter()
            return next, self._properties;
        end
		
		function quad:__tostring()
			return "Drawing";
		end
	
		function quad:Destroy()
			cache[self._id] = nil;
			self.__OBJECT_EXISTS = false;
			game.Destroy(self._frame);
		end
		
		function quad:_updateVertices(vertices)
			local thickness = self._properties.Thickness;
			for i, v in vertices do
				updatePosition(v[1], v[2], v[3], thickness);
			end
		end

		function quad:_calculateFill()
		
		end
		
		quad.Remove = quad.Destroy;
		classes.Quad = quad;
	end

    drawing.new = newcclosure(function(x)
        return getrenv().assert(classes[x], getrenv().string.format("Invalid drawing type '%s'", x)).new();
    end);

    drawing.clear = newcclosure(function()
        for i, v in cache do
			if v.__OBJECT_EXISTS then
				v:Destroy();
			end
        end
    end);

	drawing.cache = cache;
end

setreadonly(drawing, true);
setreadonly(drawing.Fonts, true);
getgenv().Drawing = drawing;
getgenv().cleardrawcache = drawing.clear;

getgenv()["cleardrawcache"] = drawing.clear
getgenv()["clear_draw_cache"] = drawing.clear
getgenv()["ClearDrawCache"] = drawing.clear

local function isrenderobj(inst)
    for _, v in pairs(drawing.cache) do
        if v == inst and type(v) == "table" then
            return true
        end
    end
    return false
end

getgenv()["isrenderobj"] = isrenderobj
getgenv()["is_render_obj"] = isrenderobj
getgenv()["IsRenderObj"] = isrenderobj

local function setrenderproperty(drawingObject, property, value)
	assert(isrenderobj(drawingObject), string.format("invalid argument #1 to 'setrenderproperty' (Drawing expected, got %s)", typeof(drawingObject)));
    local success, err = pcall(function()
        drawingObject[property] = value
    end)
    if not success then
        warn("Failed to set property: " .. property .. " | Error: " .. err)
    end
end

local function getrenderproperty(drawingObject, property)
	assert(isrenderobj(drawingObject), string.format("invalid argument #1 to 'getrenderproperty' (Drawing expected, got %s)", typeof(drawingObject)));
    local success, value = pcall(function()
        return drawingObject[property]
    end)
    if not success then
        warn("Failed to get property: " .. property)
        return nil
    end
    return value
end

getgenv()["getrenderproperty"] = getrenderproperty
getgenv()["get_render_property"] = getrenderproperty
getgenv()["GetRenderProperty"] = getrenderproperty

getgenv()["setrenderproperty"] = setrenderproperty
getgenv()["set_render_property"] = setrenderproperty
getgenv()["SetRenderProperty"] = setrenderproperty
