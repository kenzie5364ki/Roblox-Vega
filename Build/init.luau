local fs = require("@lune/fs")
local process = require("@lune/process")
local BuildCodegen = require("modules/BuildCodegen")

local FilePath = "Distribution/Fluent.lua"
local TemporaryMinifiedFile = "Distribution/TemporaryMinified.lua"
local Header = fs.readFile("Build/header.luau")

local function minify(text)
	fs.writeFile(TemporaryMinifiedFile, text)

    process.spawn("darklua", {"process", TemporaryMinifiedFile, TemporaryMinifiedFile, "--config", "Build/darklua.json"})

	local value = fs.readFile(TemporaryMinifiedFile)

	fs.removeFile(TemporaryMinifiedFile)

	return value
end

local SuccessfullyRead, Module = pcall(fs.readFile, "Distribution/Fluent.rbxm")
if SuccessfullyRead then
	local ModuleCodegen = BuildCodegen(Module, false)

	fs.writeFile(FilePath, `{Header}\n\n{minify(ModuleCodegen)}\n`)
else
	fs.writeFile(FilePath, `{Header}\n--[[\nCould not read Distribution/Fluent.rbxm, {Module}\n--]]`)
	error(`--[[\nCould not read Distribution/Fluent.rbxm, {Module}\n--]]`, 1)
end