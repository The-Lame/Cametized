local RunService = game:GetService("RunService")
local Players    = game:GetService("Players")
local Lighting   = game:GetService("Lighting")

-- view

local view = script.Parent

local Cam = Instance.new("Camera")
Cam.Parent = view
view.CurrentCamera = Cam

local playerCam = workspace.CurrentCamera

-- match lighting

view.Ambient        = Lighting.Ambient
view.LightColor     = Lighting.OutdoorAmbient
view.LightDirection = Lighting:GetSunDirection()

local ABERRATION_STRENGTH = 1.6

-- plauyer cache

local playerCharacters = {}

local function registerCharacter(char)
	playerCharacters[char] = true
end

local function unregisterCharacter(char)
	playerCharacters[char] = nil
end

for _, plr in ipairs(Players:GetPlayers()) do
	if plr.Character then
		registerCharacter(plr.Character)
	end
	plr.CharacterAdded:Connect(registerCharacter)
	plr.CharacterRemoving:Connect(unregisterCharacter)
end

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(registerCharacter)
	plr.CharacterRemoving:Connect(unregisterCharacter)
end)

local function isPlayerCharacterDescendant(inst)
	local cur = inst
	while cur do
		if playerCharacters[cur] then
			return true
		end
		cur = cur.Parent
	end
	return false
end

local movingObjs     = {}
local allObjs        = {}
local humanoidModels = {}

local function smoothPart(part)
	part.FrontSurface  = Enum.SurfaceType.Smooth
	part.BackSurface   = Enum.SurfaceType.Smooth
	part.TopSurface    = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.LeftSurface   = Enum.SurfaceType.Smooth
	part.RightSurface  = Enum.SurfaceType.Smooth
	part.CastShadow    = false
end

local function addObj(original, model)
	if not original:IsA("BasePart") or original.Transparency >= 1 then
		return
	end
	original.Transparency = 0 -- dont set this to 1 please bro

	local clone = original:Clone()
	smoothPart(clone)

	clone.Material     = Enum.Material.Neon
	clone.Color        = Color3.fromRGB(255,255,255)
	clone.Transparency = 0.1
	clone.Reflectance  = 0
	clone.Size += Vector3.new(0.1,0.1,0.1)

	for _, d in ipairs(clone:GetChildren()) do
		if not (d:IsA("Texture") or d:IsA("Decal") or d:IsA("SpecialMesh")) then
			d:Destroy()
		end
	end

	clone.Parent = model or view.Workspace
	allObjs[original] = clone

	if not original.Anchored or original:GetAttribute("ChromaticAberration") then
		movingObjs[original] = clone
	end
end

local function getHumanoidModel(humanoid)
	if Players:GetPlayerFromCharacter(humanoid.Parent) then
		return nil
	end

	local model = humanoidModels[humanoid]
	if model then
		return model
	end

	model = Instance.new("Model")
	model.Name = humanoid.Parent.Name .. "_View"
	model.Parent = view.Workspace

	humanoidModels[humanoid] = model
	return model
end

local function newObj(v)
	if v:IsA("Terrain") then return end
	if isPlayerCharacterDescendant(v) then return end

	local parent = v.Parent
	local humanoid = parent and parent:FindFirstChildOfClass("Humanoid")
	local model = humanoid and getHumanoidModel(humanoid)

	if v:IsA("BasePart") then
		addObj(v, model)
	elseif model and (v:IsA("Clothing") or v:IsA("CharacterMesh")) then
		v:Clone().Parent = model
	end
end

for _, v in ipairs(workspace:GetDescendants()) do
	if v:IsA("BasePart")
		or v:IsA("Clothing")
		or v:IsA("CharacterMesh") then
		newObj(v)
	end
end

local CAMERA_BACK_OFFSET = -0.25
local POSITION_LERP = 0.12
local ROTATION_LERP = 0.10

local effectCFrame = playerCam.CFrame

RunService.RenderStepped:Connect(function()
	local baseCF = playerCam.CFrame
	local targetCF = baseCF + baseCF.LookVector * CAMERA_BACK_OFFSET

	local pos = effectCFrame.Position:Lerp(
		targetCF.Position,
		POSITION_LERP
	)

	local rot = effectCFrame.Rotation:Lerp(
		targetCF.Rotation,
		ROTATION_LERP
	)

	effectCFrame = CFrame.new(pos) * rot

	Cam.CFrame = effectCFrame
	Cam.FieldOfView = playerCam.FieldOfView

	for original, clone in pairs(movingObjs) do
		if original.Parent then
			clone.CFrame = original.CFrame

			local t = math.clamp(
				original.Transparency / ABERRATION_STRENGTH,
				0, 1
			)

			clone.Transparency = t
			clone.LocalTransparencyModifier = math.clamp(
				original.LocalTransparencyModifier / ABERRATION_STRENGTH,
				0, 1
			)
		end
	end
end)

workspace.DescendantAdded:Connect(newObj)

workspace.DescendantRemoving:Connect(function(removing)
	local clone = allObjs[removing]
	if clone then
		clone:Destroy()
		allObjs[removing] = nil
		movingObjs[removing] = nil
	end
end)
