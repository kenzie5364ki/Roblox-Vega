local Themes = {
	Names = {
		"Dark",
		"Darker",
		"Light",
		"Aqua",
		"Amethyst",
		"Rose",
		"Honey"
	},
}

for _, Theme in next, script:GetChildren() do
	local Required = require(Theme)

	Themes[Required.Name] = Required
end

return Themes
