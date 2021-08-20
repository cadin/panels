function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	if num >= 0 then return math.floor(num * mult + 0.5) / mult
	else return math.ceil(num * mult - 0.5) / mult end
end

function printError(error, message)
	if error then
		print("Panels: "..message)
		print("- "..error)
	end
end