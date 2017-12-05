local storage = {}


storage._VMs = {}
storage._activeVMs = {}

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



return storage