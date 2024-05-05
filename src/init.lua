local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = game:GetService("Workspace").CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Root = script
local Components = Root.Components

local Creator = require(Root.Creator)
local ElementsTable = require(Root.Elements)
local Acrylic = require(Root.Acrylic)
local Icons = require(Root.Icons)
local Themes = require(Root.Themes)

local NotificationModule = require(Components.Notification)

local New = Creator.New

local GUI = New("ScreenGui", {})

GUI.Parent = (function()
	local success, result = pcall(function()
		return (gethui or get_hidden_ui)()
	end)

	if success and result then
		return result
	end

	success, result = pcall(function()
		local coreGui = game:GetService("CoreGui")
		coreGui.Name = coreGui.Name
		return coreGui
	end)

	if success and result then
		return result
	end

	success, result = pcall(function()
		return (game:IsLoaded() or (game.Loaded:Wait() or true)) and game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	end)

	if success and result then
		return result
	end

	success, result = pcall(function()
		return game:GetService("StarterGui")
	end)

	if success and result then
		return result
	end

	return error("Seriously bad engine. Can't find a place to store the GUI. Robust code can't help this much incompetence.")
end)()

NotificationModule:Init(GUI)

local Library = {
	Version = "1.0.0",

	OpenFrames = {},
	Options = {},
	Themes = Themes.Names,

	Window = nil,
	WindowFrame = nil,
	Utilities = {},
	Connections = {},
	Unloaded = false,

	Theme = "Dark",
	DialogOpen = false,
	UseAcrylic = false,
	Acrylic = false,
	Transparency = true,
	MinimizeKeybind = nil,
	MinimizeKey = Enum.KeyCode.LeftControl,

	GUI = GUI
}

function Library:SafeCallback(Function, ...)
	if not Function then
		return
	end

	local Success, Event = pcall(Function, ...)
	if not Success then
		local _, i = Event:find(":%d+: ")

		if not i then
			return Library:Notify({
				Title = "Interface",
				Content = "Callback error",
				SubContent = Event,
				Duration = 5,
			})
		end

		return Library:Notify({
			Title = "Interface",
			Content = "Callback error",
			SubContent = Event:sub(i + 1),
			Duration = 5,
		})
	end
end

function Library.Utilities:Round(Number, Factor)
	if Factor == 0 then
		return math.floor(Number)
	end
	Number = tostring(Number)
	return Number:find("%.") and tonumber(Number:sub(1, Number:find("%.") + Factor)) or Number
end

function Library.Utilities:GetIcon(Name)
	return Name ~= "SetIcon" and Icons[Name] or nil
end

local Elements = {}
Elements.__index = Elements
Elements.__namecall = function(Table, Key, ...)
	return Elements[Key](...)
end

for _, ElementComponent in next, ElementsTable do
	Elements["Add"..ElementComponent.__type] = function(self, Idx, Config)
		ElementComponent.Container = self.Container
		ElementComponent.Type = self.Type
		ElementComponent.ScrollFrame = self.ScrollFrame
		ElementComponent.Library = Library

		return ElementComponent:New(Idx, Config)
	end

	Elements["Create"..ElementComponent.__type] = Elements["Add"..ElementComponent.__type]
end

Library.Elements = Elements

function Library:CreateWindow(Config)
	assert(Config.Title, "Window - Missing Title")

	if Library.Window then
		return "You cannot create more than one window."
	end

	Library.MinimizeKey = Config.MinimizeKey or Enum.KeyCode.LeftControl
	Library.UseAcrylic = Config.Acrylic or false
	Library.Acrylic = Config.Acrylic or false
	Library.Theme = Config.Theme or "Dark"
	if Config.Acrylic then
		Acrylic.init()
	end

	local Window = require(Components.Window)({
		Parent = GUI,
		Size = Config.Resize ~= true and Config.Size or UDim2.fromOffset(Library.Utilities:Resize(Config.Size.X.Offset, Config.Size.Y.Offset)),
		Title = Config.Title,
		SubTitle = Config.SubTitle,
		TabWidth = Config.TabWidth,
	})

	Library.Window = Window
	Library:SetTheme(Config.Theme)

	return Window
end

function Library:AddWindow(Config)
	return Library:CreateWindow(Config)
end

function Library:SetTheme(Value)
	if Library.Window and table.find(Library.Themes, Value) then
		Library.Theme = Value
		Creator.UpdateTheme()
	end
end

function Library:Destroy()
	if Library.Window then
		Library.Unloaded = true

		if typeof(Library.OnUnload) == "function" then
			Library:SafeCallback(Library.OnUnload, tick())
		end

		if Library.UseAcrylic then
			Library.Window.AcrylicPaint.Model:Destroy()
		end

		Creator.Disconnect()

		for i,v in next, Library.Connections do
			local type = typeof(v)

			if type == "RBXScriptConnection" and v.Connected then
				v:Disconnect()
			end
		end

		local info, tweenProps, doTween = TweenInfo.new(2 / 3, Enum.EasingStyle.Quint)

		local function IsA(obj, class)
			local isClass = obj:IsA(class)

			if isClass then
				doTween = true
			end

			return isClass
		end

		for i,v in next, Library.GUI:GetDescendants() do
			tweenProps, doTween = {}, false

			if IsA(v, "GuiObject") then
				doTween = true

				tweenProps.BackgroundTransparency = 1
			end

			if IsA(v, "ScrollingFrame") then
				tweenProps.ScrollBarImageTransparency = 1		
			end

			if IsA(v, "TextLabel") or IsA(v, "TextBox") then
				tweenProps.TextStrokeTransparency = 1
				tweenProps.TextTransparency = 1
			end

			if IsA(v, "UIStroke") then
				tweenProps.Transparency = 1
			end

			if IsA(v, "ImageLabel") or IsA(v, "ImageButton") then
				tweenProps.ImageTransparency = 1
			end

			if doTween then
				TweenService:Create(v, info, tweenProps):Play()
			end
		end

		task.delay(info.Time, function()
			Library.GUI:Destroy()

			if typeof(Library.PostUnload) == "function" then
				Library:SafeCallback(Library.PostUnload, tick())
			end
		end)
	end
end

function Library:ToggleAcrylic(Value)
	if Library.Window then
		if Library.UseAcrylic then
			Library.Acrylic = Value
			Library.Window.AcrylicPaint.Model.Transparency = Value and 0.98 or 1
			if Value then
				Acrylic.Enable()
			else
				Acrylic.Disable()
			end
		end
	end
end

function Library:ToggleTransparency(Value)
	if Library.Window then
		Library.Window.AcrylicPaint.Frame.Background.BackgroundTransparency = Value and 0.35 or 0
	end
end

function Library:Notify(Config)
	return NotificationModule:New(Config)
end

function Library.Utilities:Resize(x, y)
    local X, Y, CurrentSize = x / 1920, y / 1080, Camera.ViewportSize
    return CurrentSize.X * X, CurrentSize.Y * Y
end

if getgenv then
	getgenv().Fluent = Library
end

return Library