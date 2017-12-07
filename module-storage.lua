local storage = {}


storage._VMs = {}
storage._activeVMs = {}


storage._images = {}
storage._imagesByOS = {}

storage._flavors = {} -- sorted from flavor with less RAM to higher RAM


storage._networks = {}

---------------------------------------------------
-- VM DATA

storage.saveVMs = function(dataVMs)
	local activeVMs = {}
	local VMs = {}
	for _, vm in ipairs(dataVMs) do
		VMs[vm.name] = vm
		if vm.status == "ACTIVE" then
			activeVMs[vm.name] = vm
		end
	end
	storage._activeVMs = activeVMs
	storage._VMs = VMs
end

storage.getActiveVMs = function()
	return storage._activeVMs or {}
end



---------------------------------------------------
-- IMAGES DATA

storage.saveImages = function(dataImages)
	storage._images = dataImages

	local imagesByOS = {}
	for _, img in ipairs(dataImages) do
		imagesByOS[img.metaData.os] = img
	end
	storage._imagesByOS = imagesByOS
end
storage.getImageForOS = function(osName) -- osName == linux or windows
	return storage._imagesByOS[osName]
end


---------------------------------------------------
-- FLAVOR DATA

storage.saveFlavors = function(dataFlavors)
	storage._flavors = dataFlavors
	local function compare( a, b )
	    return a.ram < b.ram  -- true means A comes before B
	end
	table.sort(storage._flavors, compare)
end
storage.getFlavorForSize = function(size) -- 1 = small, 2 = medium, 3 big
	return storage._flavors[size]
end


---------------------------------------------------
-- NETWORKS

storage.saveNetworks = function(dataNetworks)
	storage._networks = dataNetworks
end




return storage