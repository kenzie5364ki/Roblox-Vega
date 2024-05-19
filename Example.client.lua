local Main = require(game:GetService("ReplicatedStorage"):WaitForChild("MainModule"))

local Window = Main:CreateWindow{
    Title = `Fluent {Main.Version}`,
    SubTitle = "by Actual Master Oogway",
    TabWidth = 160,
    Size = UDim2.fromOffset(830, 525),
    Resize = true, -- Resize this ^ Size according to a 1920x1080 screen, good for mobile users but may look weird on some devices
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Vynixu",
    MinimizeKey = Enum.KeyCode.RightControl -- Used when theres no MinimizeKeybind
}

local Tabs = {
    Main = Window:CreateTab{
        Title = "Main",
        Icon = "circle-user-round"
    },
    Settings = Window:CreateTab{
        Title = "Settings",
        Icon = "settings"
    }
}

Tabs.Main:CreateParagraph({
    Title = "Paragraph",
    Content = "This is a paragraph.\nSecond line!"
})

Tabs.Main:CreateParagraph({
    Title = "Paragraph",
    Content = "This is a paragraph with a center alignment!",
    TitleAlignment = "Middle",
    ContentAlignment = Enum.TextXAlignment.Center
})


Tabs.Main:CreateButton({
    Title = "Button",
    Description = "Very important button",
    Callback = function()
        local D = Window:Dialog({
            Title = "Title",
            Content = "This is a dialog",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        Window:Dialog({
                            Title = "Another Dialog",
                            Content = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse mollis dolor eget erat mattis, id mollis mauris cursus. Proin ornare sollicitudin odio, id posuere diam luctus id.",
                            Buttons = { { Title = "Ok", Callback = function() print("Ok") end} }
                        })
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        print("Cancelled the dialog.")
                    end
                }
            }
        })
        print(D)
        D.Closed:Wait()
        print("Ok!!!")
    end
})

local Toggle = Tabs.Main:CreateToggle("Toggle", {Title = "Toggle", Default = false })

local Slider = Tabs.Main:CreateSlider("Slider", {
    Title = "Slider",
    Description = "This is a slider",
    Default = 2.0,
    Min = 0.0,
    Max = 15.5,
    Rounding = 1
})

print(Slider.Value)

Slider.Value = 4.5

print(Slider.Value)

local Dropdown = Tabs.Main:CreateDropdown("Dropdown", {
    Title = "Dropdown",
    Values = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"},
    Multi = false,
    Default = 1,
})

Dropdown:SetValue("four")

print(Dropdown.Value)

Dropdown.Value = 4.5
Dropdown.Values = {"fifteen", "sixteen", "seventeen", "eighteen", "nineteen", "twenty", "twentyone", "twentytwo", "twentythree", "twentyfour", "twentyfive", "twentysix", "twentyseven", "twentyeight"}

print(Dropdown.Value)

local MultiDropdown = Tabs.Main:CreateDropdown("MultiDropdown", {
    Title = "Dropdown",
    Description = "You can select multiple values.",
    Values = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"},
    Multi = true,
    Default = {"seven", "twelve"},
})

MultiDropdown:SetValue({
    three = true,
    five = true,
    seven = false
})

local MultiInstanceDropdown = Tabs.Main:CreateDropdown("MultiInstanceDropdown", {
    Title = "Instance Dropdown",
    Description = "You can select multiple values and any instance or any other value!",
    Values = {workspace, 5, Enum.JoinSource, Enum.MarketplaceBulkPurchasePromptStatus.Error},
    Multi = true,
    Default = {5},
})

local Colorpicker = Tabs.Main:CreateColorpicker("Colorpicker", {
    Title = "Colorpicker",
    Default = Color3.fromRGB(96, 205, 255)
})

local TColorpicker = Tabs.Main:CreateColorpicker("TransparencyColorpicker", {
    Title = "Colorpicker",
    Description = "but you can change the transparency.",
    Transparency = 0,
    Default = Color3.fromRGB(96, 205, 255)
})

local Keybind = Tabs.Main:CreateKeybind("Keybind", {
    Title = "KeyBind",
    Mode = "Hold",
    Default = "LeftControl",
    ChangedCallback = function(New)
        print("Keybind changed:", New)
    end
})

local Input = Tabs.Main:CreateInput("Input", {
    Title = "Input",
    Default = "Default",
    Numeric = false,
    Finished = false,
    Placeholder = "Placeholder text",
    Callback = function(Value)
        print("Input changed:", Value)
    end
})
    
Toggle:OnChanged(function()
    print("Toggle changed:", Main.Options["Toggle"].Value)
end)

Slider:OnChanged(function(Value)
    print("Slider changed:", Value)
end)

Dropdown:OnChanged(function(Value)
    print("Dropdown changed:", Value)
end)

MultiDropdown:OnChanged(function(Value)
    local Values = {}

    for Value, State in next, Value do
        table.insert(Values, Value)
    end

    print("Mutlidropdown changed:", table.concat(Values, ", "))
end)

MultiInstanceDropdown:OnChanged(function(Value)
    local Values = {}

    for Value, State in next, Value do
        table.insert(Values, typeof(Value))
    end

    print("Mutlidropdown with instance selection changed:", table.concat(Values, ", "))
end)

Colorpicker:OnChanged(function()
    print("Colorpicker changed:", TColorpicker.Value)
end)

TColorpicker:OnChanged(function()
    print(
        "TColorpicker changed:", TColorpicker.Value,
        "Transparency:", TColorpicker.Transparency
    )
end)

Tabs.Main:CreateButton{
    Title = "Really Really big Dropdown",
    Description = "",
    Callback = function()
        local Values = {}

        for i = 1, 1750 do
            Values[i] = i
        end

        Tabs.Main:CreateDropdown("Dropdown", {
            Title = "Big Dropdown",
            Values = Values,
            Multi = false,
            Default = 1,
        })
    end
}

task.spawn(function()
    while true do
        wait(1)
        local state = Keybind:GetState()
        if state then
            print("Keybind is being held down")
        end
        if Main.Unloaded then break end
    end
end)

local InterfaceSection = Tabs.Settings:CreateSection("Interface")

InterfaceSection:CreateDropdown("InterfaceTheme", {
    Title = "Theme",
    Description = "Changes the interface theme.",
    Values = Main.Themes,
    Default = Main.Theme,
    Callback = function(Value)
        Main:SetTheme(Value)
    end
})

if Main.UseAcrylic then
    InterfaceSection:CreateToggle("AcrylicToggle", {
        Title = "Acrylic",
        Description = "The blurred background requires graphic quality 8+",
        Default = Main.Acrylic,
        Callback = function(Value)
            Main:ToggleAcrylic(Value)
        end
    })
end

InterfaceSection:CreateToggle("TransparentToggle", {
    Title = "Transparency",
    Description = "Makes the interface transparent.",
    Default = Main.Transparency,
    Callback = function(Value)
        Main:ToggleTransparency(Value)
    end
})

InterfaceSection:CreateKeybind("MenuKeybind", { Title = "Minimize Bind", Default = "RightShift" })
Main.MinimizeKeybind = Main.Options.MenuKeybind 

Window:SelectTab(1)

Main:Notify({
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
})