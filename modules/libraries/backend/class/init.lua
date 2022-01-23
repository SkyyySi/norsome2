-- A table with a build-in new()-method for creating instances.
-- Based on http://lua.org/pil/16.1.html
-- Note that the new()-method is effectively a constructor, so
-- if you need your own, you can copy the code and adjust it
-- to your needs instead.
local class = {
	-- Create a new instance of the class.
	new = function(self, object)
		object = object or {}
		setmetatable(object, self)
		self.__index = self
		return object
	end,

	-- For convenience, some functions from the standard library have been
	-- mapped here as well.
	-- Append to the end of the table.
	insert = function(self, item)
		table.insert(self, item)
	end,

	-- Sort the table.
	sort = function(self, item)
		table.sort(self, item)
	end,
}

return class:new()
