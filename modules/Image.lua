Panels.Image = { }

local cache = {}
function Panels.Image.get(path)
    local error = nil
	if cache[path] == nil then
		cache[path], error = playdate.graphics.image.new(path)
	end
	return cache[path], error
end

function Panels.Image.clearCache()
    cache = {}
end