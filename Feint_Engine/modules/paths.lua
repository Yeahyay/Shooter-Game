local _, FEINT_ROOT = ...

local paths = {}

local private = {}
private.size = 1

setmetatable(paths, {
	__index = private,
})

if paths.Root == nil then
	paths.Root = FEINT_ROOT or "Feint_Engine."
end

function private.Add(name, path, file)
	local path = path or name
	assert(type(path) == "string", "needs a string")

	local newPath = nil

	-- if it's a file, no postfix
	local postfix = ""
	if file ~= "file" then
		postfix = "."
	end

	newPath = path .. postfix

	if not paths[name] then
		paths[name] = newPath

		private.size = private.size + 1
		if file == "file" then
			-- printf("Added file     path \"%s\" (%s)\n", name, newPath)
		else
			if external == "external" then
				-- printf("Added external path \"%s\" (%s)\n", name, newPath)
			else
				-- printf("Added Feint    path \"%s\" (%s)\n", name, newPath)
			end
		end
	else
		log("Path %s (%s) already exists.\n", newPath, newPath)
	end
end

function private.SlashDelimited(path)
	return path:gsub("%.", "/")
end

function private.Print()
	local min = 0
	for k, v in pairs(paths) do
		if k ~= "hidden" then --k ~= "size" and k ~= "PRINT" then
			min = math.max(min, k:len())
		end
	end
	min = min + 1
	-- printf("hidden\n")
	-- for k, v in pairs(paths.hidden) do
	-- 	printf("%-" .. min .. "s %s\n", k .. ",", v)
	-- end
	-- printf("main\n")
	local fmt = "%-" .. min .. "s %s\n"
	for k, v in pairs(paths) do
		if k ~= "hidden" then--k ~= "size" and k ~= "PRINT" then
			log(fmt, k .. ",", v)
		end
	end
end

return paths
