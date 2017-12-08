local storage = {}


storage._VMs = {}
storage._activeVMs = {}
storage._pausedVMs = {}


storage._images = {}
storage._imagesByOS = {}

storage._flavors = {} -- sorted from flavor with less RAM to higher RAM


storage._networks = {}

---------------------------------------------------
-- VM DATA

storage.saveVMs = function(dataVMs)
	local activeVMs, pausedVMs = {}, {}
	local VMs = {}
	for i, vm in ipairs(dataVMs) do
		vm.os = vm.image and vm.image.name
		VMs[vm.name] = vm
		--print("vm.name, vm.status=", vm.name, vm.status)
		if vm.status == "ACTIVE" then
			activeVMs[vm.name] = vm
		elseif vm.status == "PAUSED" then
			pausedVMs[vm.name] = vm
		end
	end
	storage._activeVMs = activeVMs
	storage._pausedVMs = pausedVMs
	storage._VMs = VMs
	--jp(pausedVMs)
end

storage.getActiveVMs = function()
	return storage._activeVMs or {}
end
storage.getPausedVMs = function()
	return storage._pausedVMs or {}
end

storage.getVMs = function()
	return storage._VMs or {}
end

storage.getVMSize = function()

end

---------------------------------------------------
-- IMAGES DATA

storage.saveImages = function(dataImages)
	storage._images = dataImages

	local imagesByOS = {}
	for _, img in ipairs(dataImages) do
		imagesByOS[img.name] = img
	end
	storage._imagesByOS = imagesByOS
end
storage.getImages = function() -- osName == linux or windows
	return storage._images or {}
end

storage.getImageForOS = function(osName) -- osName == linux or windows
	return storage._imagesByOS[osName]
end

storage.getRandomImageId = function()
	local images = storage.getImages()
	local numImages = #images
	if numImages > 0 then
		local index = math.random(1, numImages)
		return images[index].id
	end
end

---------------------------------------------------
-- FLAVOR DATA

storage.saveFlavors = function(dataFlavors)
	storage._flavorsIdToSize = {}
	local function compare( a, b )
	    return a.ram < b.ram  -- true means A comes before B
	end
	table.sort(dataFlavors, compare)
	for i,v in ipairs(storage._flavors) do
		storage._flavorsIdToSize[v.id] = i
	end

	storage._flavors = dataFlavors
end
storage.getFlavors = function() -- 1 = small, 2 = medium, 3 big
	return storage._flavors or {}
end
storage.getFlavorForSize = function(size) -- 1 = small, 2 = medium, 3 big
	return storage._flavors[size]
end

storage.getRandomFlavorId = function()
	local flavors = storage.getFlavors()
	local numFlavors = #flavors
	if numFlavors > 0 then
		local index = math.random(1, numFlavors)
		return flavors[index].id
	end
end



---------------------------------------------------
-- NETWORKS

storage.saveNetworks = function(dataNetworks)
	storage._networks = dataNetworks
end

storage.getNetworks = function()
	return storage._networks or {}
end


storage.getRandomNetworkId = function()
	local networks = storage.getNetworks(0)
	local numNetworks = #networks
	if numNetworks > 0 then
		local index = math.random(1, numNetworks)
		return networks[index].id
	end
end



return storage