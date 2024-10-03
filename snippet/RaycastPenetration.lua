local function getSize(part : BasePart, direction : Vector3)
	local normalizedDirection = direction.Unit
	local partSize = part.Size
	local partCFrame = part.CFrame
	local xAxis = partCFrame.RightVector * partSize.X / 2
	local yAxis = partCFrame.UpVector * partSize.Y / 2
	local zAxis = partCFrame.LookVector * partSize.Z / 2
	local xProjection = math.abs(xAxis:Dot(normalizedDirection))
	local yProjection = math.abs(yAxis:Dot(normalizedDirection))
	local zProjection = math.abs(zAxis:Dot(normalizedDirection))
	return xProjection + yProjection + zProjection
end

function RaycastPenetration(origin : Vector3, direction : Vector3, depth : number, ignoreList : {Instance}) : {BasePart}
	local parts = {}
	local list = ignoreList or {}
	local newOrigin = origin
	local curDepthRemaining = depth
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = list

	while curDepthRemaining > 0 do
		local Raycast = workspace:Raycast(newOrigin, direction * 1000, rayParams)
		if Raycast and Raycast.Instance and Raycast.Instance:IsA("BasePart") then
			local size = getSize(Raycast.Instance, direction)
			curDepthRemaining -= size*2
			print(size*2, curDepthRemaining)
			table.insert(parts, Raycast.Instance)
			table.insert(list, Raycast.Instance)
			rayParams.FilterDescendantsInstances = list
			newOrigin = Raycast.Position + direction.Unit * 0.01 -- Slight offset to avoid hitting the same part again
		else
			break
		end
	end

	return parts
end
