local fs = require(`@lune/fs`)
local process = require(`@lune/process`)
local BundleModel = require(`modules/BundleModel`)

local OutputName = `Fluent`

local FilePath = `Distribution/{OutputName}.luau`
local TemporaryMinifiedFile = `Distribution/TemporaryMinified.luau`
local Header = fs.readFile(`Build/header.luau`)

local function minify(text)
	fs.writeFile(TemporaryMinifiedFile, text)

    local result = process.spawn(`darklua`, {`process`, TemporaryMinifiedFile, TemporaryMinifiedFile, `--config`, `Build/darklua.json`})

	if result.ok then
		print(result.stdout)
	else
		print(result.stderr)
	end

	local value = fs.readFile(TemporaryMinifiedFile)

	fs.removeFile(TemporaryMinifiedFile)

	return value
end

local function buildmodule()
	local result = process.spawn(`rojo`, {`build`, `--output`, `Distribution/{OutputName}.rbxm`})

	if result.ok then
		print(result.stdout)
	else
		print(result.stderr)
	end
end

if not fs.isDir(`Distribution`) then
	fs.writeDir(`Distribution`)
end

buildmodule()

local SuccessfullyRead, Module = pcall(fs.readFile, `Distribution/{OutputName}.rbxm`)
if SuccessfullyRead then
	local ModuleCodegen = BundleModel(Module, false)

	fs.writeFile(FilePath, `{Header}\n\n{minify(ModuleCodegen)}`)
else
	fs.writeFile(FilePath, `{Header}\n--[[\nCould not read Distribution/{OutputName}.rbxm, {Module}\n--]]`)
	error(`--[[\nCould not read Distribution/{OutputName}.rbxm, {Module}\n--]]`, 1)
end