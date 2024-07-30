return (function ()
	local Flipper = {}

	for i,v in next, script:GetChildren() do
		if not v.Name:find(".spec") then
			task.spawn(function()
				Flipper[v.Name] = require(v)
			end)
		end
	end

	return Flipper
end)()