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

function reverseTable(t) 
	for i = 1, math.floor(#t/2) do
	   local j = #t - i + 1
		t[i], t[j] = t[j], t[i]
	end
end