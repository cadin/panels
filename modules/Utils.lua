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

function hasValue(tbl, value)
    for k, v in ipairs(tbl) do -- iterate table (for sequential tables only)
        if v == value or (type(v) == "table" and hasValue(v, value)) then -- Compare value from the table directly with the value we are looking for, otherwise if the value is table, check its content for this value.
            return true -- Found in this or nested table
        end
    end
    return false -- Not found
end