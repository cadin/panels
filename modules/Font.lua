Panels.Font = {
	NORMAL = playdate.graphics.font.kVariantNormal,
	BOLD = playdate.graphics.font.kVariantBold,
	ITALIC = playdate.graphics.font.kVariantItalic
}

local function clipExtension(path)
	if string.sub(path, -4) == ".fnt" then
		print("Panels: Don't include '.fnt' extension in font paths")
		print("- '" .. path .. "'")
		path = string.sub(path, 0, -5)
	end

	return path
end

local cache = {}
function Panels.Font.get(path)
	path = clipExtension(path)

	if cache[path] == nil then
		cache[path] = playdate.graphics.font.new(path)
	end
	return cache[path]
end

local function clipExtensions(paths)
	for key, value in pairs(paths) do
		paths[key] = clipExtension(value)
	end

	return paths
end

local families = {}
function Panels.Font.getFamily(paths)
	local key = paths[Panels.Font.NORMAL]
	if key == nil then key = paths[Panels.Font.BOLD] end
	if key == nil then key = paths[Panels.Font.ITALIC] end

	if families[key] == nil then
		clipExtensions(paths)
		cache[key] = playdate.graphics.font.newFamily(paths)
	end
	return cache[key]
end
