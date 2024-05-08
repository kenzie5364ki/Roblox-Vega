local function Clone(ToClone)
	local Type = typeof(ToClone)

	if Type == "function" and (clonefunc or clonefunction) then
		return (clonefunc or clonefunction)(ToClone)
	elseif Type == "Instance" and (cloneref or clonerefrence) then
		return (cloneref or clonerefrence)(ToClone)
	elseif Type == "table" then
		local function deepcopy(orig, copies)
			copies = copies or {}
			local orig_type, copy = type(orig), nil

			if orig_type == 'table' then
				if copies[orig] then
					copy = copies[orig]
				else	
					copy = {}

					copies[orig] = copy

					for orig_key, orig_value in next, orig, nil do
						copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
					end

					setmetatable(copy, deepcopy((getrawmetatable or getmetatable)(orig), copies))
				end
			else
				copy = orig
			end

			return copy
		end

		return deepcopy(ToClone)
	else
		return ToClone
	end
end

local MarketplaceService = Clone(game:GetService("MarketplaceService"))
local TweenService = Clone(game:GetService("TweenService"))
local Camera = Clone(game:GetService("Workspace").CurrentCamera)

local Root = script
local Components = Root.Components

local Creator = require(Root.Creator)
local ElementsTable = require(Root.Elements)
local Acrylic = require(Root.Acrylic)
local Icons = require(Root.Icons)
local Themes = require(Root.Themes)

local NotificationModule = require(Components.Notification)

local SharedTable = ((typeof(shared) == "table") and shared) or ((typeof(_G) == "table") and _G) or ((typeof(getgenv) == "function" and typeof(getgenv()) == "table") and getgenv())
local New = Creator.New

local GUI = New("ScreenGui", {
	Name = "Fluent Renewed Base GUI"
})

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
	Utilities = {
		Themes = Themes,
		Shared = SharedTable
	},
	Connections = Creator.Signals,
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

function Library.Utilities:Truncate(number: number, decimals: number, round: boolean)
	local shift = 10 ^ (typeof(decimals) == "number" and math.max(decimals, 0) or 0)
	if round then
		return math.round(number * shift) // 1 / shift
	else
		return number * shift // 1 / shift
	end
end

function Library.Utilities:Round(Number: number, Factor: number)
	return Library.Utilities:Truncate(Number, Factor, true)
end

function Library.Utilities:GetIcon(Name: string)
	return Name ~= "SetIcon" and Icons[Name] or nil
end

function Library.Utilities:Prettify(ToPrettify: EnumItem | string | number)
	local Type = typeof(ToPrettify)

	if Type == "EnumItem" then
		return ToPrettify.Name:gsub("(%l)(%u)", "%1 %2")
	elseif Type == "string" then
		return ToPrettify:gsub("(%l)(%u)", "%1 %2")
	elseif Type == "number" then
		return Library.Utilities:Round(ToPrettify, 2)
	else
		return ToPrettify
	end
end

function Library.Utilities:Clone(...)
	return Clone(...)
end

local Elements = {}
Elements.__index = Elements
Elements.__namecall = function(Table, Key, ...)
	return Elements[Key](...)
end

for _, ElementComponent in next, ElementsTable do
	Elements[`Create{ElementComponent.__type}`] = function(self, Idx, Config)
		ElementComponent.Container = self.Container
		ElementComponent.Type = self.Type
		ElementComponent.ScrollFrame = self.ScrollFrame
		ElementComponent.Library = Library

		return ElementComponent:New(Idx, Config)
	end

	Elements[`Add{ElementComponent.__type}`] = Elements[`Create{ElementComponent.__type}`]
	Elements[ElementComponent.__type] = Elements[`Create{ElementComponent.__type}`]
end

Library.Elements = Elements

function Library:CreateWindow(Config)
	if Library.Window then
		return "You cannot create more than one window."
	end

	if not Config.Title then
		local Success, Game_Name = pcall(MarketplaceService.GetProductInfo, MarketplaceService, game.PlaceId)
		
		Config.Title = Success and Game_Name or "Fluent Renewed"
	end

	Library.MinimizeKey = Config.MinimizeKey or Enum.KeyCode.LeftControl
	Library.UseAcrylic = Config.Acrylic or false
	Library.Acrylic = Config.Acrylic or false
	Library.Theme = Config.Theme or "Dark"

	if Config.Acrylic then
		Acrylic.init()
	end

	local Window = require(Components.Window){
		Parent = GUI,
		Size = Config.Resize ~= true and Config.Size or UDim2.fromOffset(Library.Utilities:Resize(Config.Size.X.Offset, Config.Size.Y.Offset)),
		Title = Config.Title,
		SubTitle = Config.SubTitle,
		TabWidth = Config.TabWidth,
	}

	GUI.Name = `FluentRenewed_{Config.Title}`

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

if SharedTable then
	SharedTable.FluentRenewed = Library
end

return Library