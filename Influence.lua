local function LevelUp()
	if currval > maxval then
		currval = currval - maxval
		return currval
	else
		return currval
	end
end