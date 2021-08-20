Panels.Font = { }

local cache = {}
function Panels.Font.get(path)
	if cache[path] == nil then
		cache[path] = playdate.graphics.font.new(path)
	end
	return cache[path]
end