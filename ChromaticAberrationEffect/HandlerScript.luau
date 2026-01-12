for i, v in script.Parent.Views:GetChildren() do
	local scr = script.Effect:Clone()
	scr.Parent = v
	scr.Enabled = true
end
