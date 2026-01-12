-- getting the children of the sets
local function getLeft()
	return Geometry.Sets.ToLeft:GetChildren()
end

local function getRight()
	return Geometry.Sets.ToRight:GetChildren()
end

-- obtaining random functions
local function RandomLeft()
	local model = LeftSets[math.random(1, #LeftSets)]
	local Clone = model:Clone()
	Clone.Parent = SetsDefault.leftClone

	for _, obj in ipairs(Clone:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.CFrame = obj.CFrame + Vector3.new(0, 50, 0)
		end
	end
end

local function RandomRight()
	local model = RightSets[math.random(1, #RightSets)]
	local Clone = model:Clone()
	Clone.Parent = SetsDefault.rightClone

	for _, obj in ipairs(Clone:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.CFrame = obj.CFrame + Vector3.new(0, 50, 0)
		end
	end
end

-- call a left set
RandomLeft()

-- call a right set
RandomRight()
