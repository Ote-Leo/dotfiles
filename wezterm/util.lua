local M = {}

---Insert every element from the `right` array into the `left` array.
---@param left any[] the array to be mutated
---@param right any[] the extra elements
---@return any[] left
M.extend = function(left, right)
	for _, value in pairs(right) do
		table.insert(left, value)
	end
	return left
end

return M
