local api = {}

--------------------------------------------------------
-- customize your server info here
local apiURL = "http://localhost:8283/"




 -- converts a table from to a string format
local paramToString = function(paramsTable)
    local str = ""
    local i = 1

    for paramName,paramValue in pairs(paramsTable) do
        --print(paramName .. ": " .. paramValue)
        if i == 1 then
            str = paramName .. "=" .. paramValue
        else
            str = str .. "&" .. paramName .. "=" .. paramValue
        end
        i=i+1
    end

    return str
end


-- function that gets a JSON from a server
local function getJSON(endpoint, parameters, onCompleteDownload, method, onProgress, silentRequest )

    local method = method or "POST"

    local url = apiURL .. endpoint

    parameters = parameters or {}

    local function showDownloadErroAlert()
        native.setActivityIndicator( false )
         -- Handler that gets notified when the alert closes
            local function onComplete( event )
               if event.action == "clicked" then
                    local i = event.index
                    if i == 1 then
                        -- Retrying....
                        getJSON(endpoint, params, onCompleteDownload)
                        return
                    elseif i == 2 then
                        local composer = require "composer"
                        if composer.getSceneName( "current" ) ~= "scene-login" then
                            composer.gotoScene( "scene-login", {effect="slideLeft", time=400} )
                        end

                        return --native.requestExit()
                    end
                end
            end
            if silentRequest ~= true then
                BUTTONS_DISABLED = false
                local alert = native.showAlert( "Oopps", "Something went wrong trying to communicate with the server." , { "Try again", "I will try again later" }, onComplete )
            end

    end

    local function networkListener( event )
        print( "on networkListener - ", event.isError, event.status, event.phase,event.response )
        local result, data, errorMessage = false, nil, nil
        if ( event.isError  or (event.phase == "ended" and event.status ~= 200)) then
            print( "Network error! - ", event.isError, event.status, event.phase,event.response )
            native.setActivityIndicator( false )
            errorMessage = "Something went wrong trying to communicate with the server."

            return showDownloadErroAlert()


        elseif ( event.phase == "began" ) then
            if ( event.bytesEstimated <= 0 ) then
                print( "Download starting, size unknown" )
            else
                print( "Download starting, estimated size: " .. event.bytesEstimated )
            end

        elseif ( event.phase == "progress" ) then
            if ( event.bytesEstimated <= 0 ) then
                print( "Download progress: " .. event.bytesTransferred )
            else
                print( "Download progress: " .. event.bytesTransferred .. " of estimated: " .. event.bytesEstimated )
            end
            if onProgress then
                local percentComplete = nil
                if event.bytesTransferred and event.bytesEstimated and event.bytesEstimated > 0 then
                    percentComplete = event.bytesTransferred / event.bytesEstimated
                end
                onProgress(percentComplete)
            end

        elseif ( event.phase == "ended" ) then

            --print("Network ok. Now let's decode the JSON")
            local response = event.response  --:gsub("&#8211;", "-")  -- manually replacing a HTML code for its chair
            --print("response=", response)
            local data = require("json").decode(response)

            --print("data.success=", data.success)
            --print("data.success=", data[1].success)
            --print("result=", result)
            onCompleteDownload(data, event)
        end

    end


    local headers = {}
    local params = {}

    if method == "MULTIPART" then
        method = "POST"


        headers["Content-Type"] = "multipart/form-data; boundary=" .. parameters.boundary
        headers["Content-Length"] = #parameters.body

        params.body = parameters.body
        params.bodyType = "binary"
        params.progress = "upload"

    elseif method == "POST" then
        headers["Content-Type"] = "application/x-www-form-urlencoded"
        params.body = paramToString(parameters)
    else
        headers["Content-Type"] = "application/json"
        url = url .. "?" .. paramToString(parameters)
    end

    params.headers = headers
    params.timeout = 30
    if onProgress then
        params.progress = "upload"
    end

    print("url=", url)
    network.request( url, method, networkListener, params)


end





----------------------------------------
-- BASIC INFORMATION

api.getImages = function(onSuccess, onFail)

    local fakeData = '[{"id":"2f1e4d6c-64b5-4ccd-9527-169114a21706","status":"ACTIVE","name":"cirros","progress":100,"minRam":0,"minDisk":0,"created":1512464418000,"updated":1512641650000,"size":13267968,"links":[{"rel":"self","href":"http://localhost:8774/v2.1/images/2f1e4d6c-64b5-4ccd-9527-169114a21706","type":null},{"rel":"bookmark","href":"http://localhost:8774/images/2f1e4d6c-64b5-4ccd-9527-169114a21706","type":null},{"rel":"alternate","href":"http://controller:9292/images/2f1e4d6c-64b5-4ccd-9527-169114a21706","type":"application/vnd.openstack.image"}],"metaData":{"os":"linux","description":"linux"},"snapshot":false}]'
    local data = require("json").decode(fakeData)
    _G.STORAGE.saveImages(data)

    if onSuccess then
        onSuccess()
    end

    if true then return end

    local params = {}
    params["type"] = "image"

    getJSON("os/list",
        params,
        function(data)
            local success = data.errorCode == nil
            print("sucess=", success)
            if success then

                _G.STORAGE.saveImages(data)

                if onSuccess then
                    onSuccess(data)
                end
            else

                if onFail then
                    onFail(data.errorMessage, data.errorCode)
                end
            end

        end,
        "GET",  -- method
        nil,     -- onProgress
        true)    -- silentRequest
end


api.getFlavors = function(onSuccess, onFail)

    local fakeData = '[{"id":"8eaef415-fdde-443a-8d37-f10bd43519b4","name":"medium","ram":1024,"vcpus":1,"disk":1,"ephemeral":1,"swap":300,"rxtxFactor":1.0,"disabled":false,"rxtxQuota":0,"rxtxCap":0,"links":[{"rel":"self","href":"http://localhost:8774/v2.1/flavors/8eaef415-fdde-443a-8d37-f10bd43519b4","type":null},{"rel":"bookmark","href":"http://localhost:8774/flavors/8eaef415-fdde-443a-8d37-f10bd43519b4","type":null}],"public":true},{"id":"9b68c48f-6f8e-4b91-9d17-4067871ca54b","name":"small","ram":512,"vcpus":1,"disk":1,"ephemeral":1,"swap":300,"rxtxFactor":1.0,"disabled":false,"rxtxQuota":0,"rxtxCap":0,"links":[{"rel":"self","href":"http://localhost:8774/v2.1/flavors/9b68c48f-6f8e-4b91-9d17-4067871ca54b","type":null},{"rel":"bookmark","href":"http://localhost:8774/flavors/9b68c48f-6f8e-4b91-9d17-4067871ca54b","type":null}],"public":true}]'
    local data = require("json").decode(fakeData)
    _G.STORAGE.saveFlavors(data)

    if onSuccess then
        onSuccess()
    end

    if true then return end

    local params = {}
    params["type"] = "flavor"

    getJSON("os/list",
        params,
        function(data)
            local success = data.errorCode == nil
            print("sucess=", success)
            if success then

                _G.STORAGE.saveFlavors(data)

                if onSuccess then
                    onSuccess(data)
                end
            else

                if onFail then
                    onFail(data.errorMessage, data.errorCode)
                end
            end

        end,
        "GET",  -- method
        nil,     -- onProgress
        true)    -- silentRequest
end

api.getNetworks = function(onSuccess, onFail)

    local fakeData = '[{"status":"ACTIVE","subnets":["e9722e8a-0f31-44f4-96a9-62dc4e61ae94"],"neutronSubnets":[{"id":"e9722e8a-0f31-44f4-96a9-62dc4e61ae94","name":"provider","networkId":"81152ac4-0aa6-4bf3-b6b9-b9374ae26747","tenantId":"4048750e5ef040ce8741ba6398d811c9","dnsNames":["8.8.4.4"],"hostRoutes":[],"ipVersion":"V4","gateway":"203.0.113.1","cidr":"203.0.113.0/24","ipv6AddressMode":null,"ipv6RaMode":null,"dhcpenabled":true,"allocationPools":[{"start":"203.0.113.101","end":"203.0.113.200"}]}],"name":"provider","providerPhyNet":"provider","adminStateUp":true,"tenantId":"4048750e5ef040ce8741ba6398d811c9","networkType":"FLAT","routerExternal":true,"id":"81152ac4-0aa6-4bf3-b6b9-b9374ae26747","shared":true,"providerSegID":null,"availabilityZoneHints":[],"availabilityZones":["nova"],"mtu":1500},{"status":"ACTIVE","subnets":["bf692cb2-fd62-4a40-9e42-523c6631c509"],"neutronSubnets":[{"id":"bf692cb2-fd62-4a40-9e42-523c6631c509","name":"selfservice","networkId":"a4d0d1c4-cea5-4674-b48b-56c01ba9c804","tenantId":"2fd69c6c5fe54c95836fc95795107b18","dnsNames":["8.8.4.4"],"hostRoutes":[],"ipVersion":"V4","gateway":"172.16.1.1","cidr":"172.16.1.0/24","ipv6AddressMode":null,"ipv6RaMode":null,"dhcpenabled":true,"allocationPools":[{"start":"172.16.1.2","end":"172.16.1.254"}]}],"name":"selfservice","providerPhyNet":null,"adminStateUp":true,"tenantId":"2fd69c6c5fe54c95836fc95795107b18","networkType":"VXLAN","routerExternal":false,"id":"a4d0d1c4-cea5-4674-b48b-56c01ba9c804","shared":false,"providerSegID":"14","availabilityZoneHints":[],"availabilityZones":["nova"],"mtu":1450}]'
    local data = require("json").decode(fakeData)
    _G.STORAGE.saveNetworks(data)

    if onSuccess then
        onSuccess()
    end

    if true then return end

    local params = {}
    params["type"] = "network"

    getJSON("os/list",
        params,
        function(data)
            local success = data.errorCode == nil
            print("sucess=", success)
            if success then

                _G.STORAGE.saveNetworks(data)

                if onSuccess then
                    onSuccess(data)
                end
            else

                if onFail then
                    onFail(data.errorMessage, data.errorCode)
                end
            end

        end,
        "GET",  -- method
        nil,     -- onProgress
        true)    -- silentRequest
end


----------------------------------------
-- VIRTUAL MACHINES

-- gets the number of active virtual machines
api.getVirtualMachines = function(onSuccess, onFail)

    local fakeData = '[{"id":"ea0de94d-5b93-49c6-b5a4-7dde80791c7c","name":"vm2","addresses":{"addresses":{"provider":[{"macAddr":"fa:16:3e:58:91:29","version":4,"addr":"203.0.113.112","type":"fixed"}]}},"links":[{"rel":"self","href":"http://localhost:8774/v2.1/servers/ea0de94d-5b93-49c6-b5a4-7dde80791c7c","type":null},{"rel":"bookmark","href":"http://localhost:8774/servers/ea0de94d-5b93-49c6-b5a4-7dde80791c7c","type":null}],"image":{"id":"2f1e4d6c-64b5-4ccd-9527-169114a21706","status":"ACTIVE","name":"cirros","progress":100,"minRam":0,"minDisk":0,"created":1512464418000,"updated":1512641650000,"size":13267968,"links":[{"rel":"self","href":"http://localhost:8774/v2.1/images/2f1e4d6c-64b5-4ccd-9527-169114a21706","type":null},{"rel":"bookmark","href":"http://localhost:8774/images/2f1e4d6c-64b5-4ccd-9527-169114a21706","type":null},{"rel":"alternate","href":"http://controller:9292/images/2f1e4d6c-64b5-4ccd-9527-169114a21706","type":"application/vnd.openstack.image"}],"metaData":{"os":"linux","description":"linux"},"snapshot":false},"flavor":{"id":"8eaef415-fdde-443a-8d37-f10bd43519b4","name":"medium","ram":1024,"vcpus":1,"disk":1,"ephemeral":1,"swap":300,"rxtxFactor":1.0,"disabled":false,"rxtxQuota":0,"rxtxCap":0,"links":[{"rel":"self","href":"http://localhost:8774/v2.1/flavors/8eaef415-fdde-443a-8d37-f10bd43519b4","type":null},{"rel":"bookmark","href":"http://localhost:8774/flavors/8eaef415-fdde-443a-8d37-f10bd43519b4","type":null}],"public":true},"accessIPv4":"","accessIPv6":"","configDrive":"","status":"ACTIVE","progress":0,"fault":null,"tenantId":"4048750e5ef040ce8741ba6398d811c9","userId":"882a0fec22b24368be005b34e2f296b0","keyName":null,"hostId":"038045d19f5dd976db501facee68f415de256bf411fbe523148a435f","updated":1512641823000,"created":1512641804000,"metadata":{},"securityGroups":[{"name":"default"}],"taskState":null,"powerState":"1","vmState":"active","host":"compute1","instanceName":"instance-00000004","hypervisorHostname":"compute1","diskConfig":"AUTO","availabilityZone":"nova","launchedAt":1512641823000,"terminatedAt":null,"osExtendedVolumesAttached":[],"uuid":null,"adminPass":null,"imageId":"2f1e4d6c-64b5-4ccd-9527-169114a21706","flavorId":"8eaef415-fdde-443a-8d37-f10bd43519b4"},{"id":"e0238ae9-cf84-448f-a379-6cee0f97f19c","name":"vm1","addresses":{"addresses":{"provider":[{"macAddr":"fa:16:3e:8b:30:aa","version":4,"addr":"203.0.113.107","type":"fixed"}]}},"links":[{"rel":"self","href":"http://localhost:8774/v2.1/servers/e0238ae9-cf84-448f-a379-6cee0f97f19c","type":null},{"rel":"bookmark","href":"http://localhost:8774/servers/e0238ae9-cf84-448f-a379-6cee0f97f19c","type":null}],"image":null,"flavor":{"id":"9b68c48f-6f8e-4b91-9d17-4067871ca54b","name":"small","ram":512,"vcpus":1,"disk":1,"ephemeral":1,"swap":300,"rxtxFactor":1.0,"disabled":false,"rxtxQuota":0,"rxtxCap":0,"links":[{"rel":"self","href":"http://localhost:8774/v2.1/flavors/9b68c48f-6f8e-4b91-9d17-4067871ca54b","type":null},{"rel":"bookmark","href":"http://localhost:8774/flavors/9b68c48f-6f8e-4b91-9d17-4067871ca54b","type":null}],"public":true},"accessIPv4":"","accessIPv6":"","configDrive":"","status":"ACTIVE","progress":0,"fault":null,"tenantId":"4048750e5ef040ce8741ba6398d811c9","userId":"882a0fec22b24368be005b34e2f296b0","keyName":null,"hostId":"038045d19f5dd976db501facee68f415de256bf411fbe523148a435f","updated":1512642393000,"created":1512466454000,"metadata":{},"securityGroups":[{"name":"default"}],"taskState":null,"powerState":"1","vmState":"active","host":"compute1","instanceName":"instance-00000001","hypervisorHostname":"compute1","diskConfig":"AUTO","availabilityZone":"nova","launchedAt":1512466485000,"terminatedAt":null,"osExtendedVolumesAttached":["91238116-799a-4ce0-bb9d-78daa69842fa"],"uuid":null,"adminPass":null,"imageId":null,"flavorId":"9b68c48f-6f8e-4b91-9d17-4067871ca54b"}]'
    local data = require("json").decode(fakeData)
    _G.STORAGE.saveVMs(data)

    if onSuccess then
        onSuccess()
    end

    if true then return end

    local params = {}
    params["type"] = "server"

    getJSON("os/list",
        params,
        function(data)
            local success = data.errorCode == nil
            print("sucess=", success)
            if success then

                _G.STORAGE.saveVMs(data)

                if onSuccess then
                    onSuccess(data)
                end
            else

                if onFail then
                    onFail(data.errorMessage, data.errorCode)
                end
            end

        end,
        "GET",  -- method
        nil,     -- onProgress
        true)    -- silentRequest
end



api.createNewVirtualMachine = function(vmName, imageId, flavorId, networkId, onSuccess, onFail)
    print("Calling API to TERMINATE VM with Name '" .. tostring(vmName) .. "'")
    timer.performWithDelay(1000, function()
        if onSuccess then
            onSuccess({id="e0238ae9-cf84-448f-a379-6cee0f97f19c", status="ACTIVE", name ="vmFake1"})
        end
    end)

    if true then return end



    local params = {}
    params["type"] = "server"
    params["name"] = vmName
    params["image"] = imageId
    params["flavor"] = flavorId
    params["network"] = networkId


    getJSON("os/create",
        params,
        function(data)
            local success = data.errorCode == nil
            print("sucess=", success)
            if success then

                _G.STORAGE.saveVMs(data)

                if onSuccess then
                    onSuccess(data)
                end
            else

                if onFail then
                    onFail(data.errorMessage, data.errorCode)
                end
            end

        end,
        "GET",  -- method
        nil,     -- onProgress
        true)    -- silentRequest
end




-- gets the number of active virtual machines
api.terminateVirtualMachine = function(vmId, onSuccess, onFail)
    print("Calling API to TERMINATE VM with Id '" .. tostring(vmId) .. "'")
    timer.performWithDelay(1000, function()
        onSuccess()
    end)

    if true then return end



    local params = {}
    params["type"] = "server"
    params["id"] = vmId

    getJSON("os/del",
        params,
        function(data)
            local success = data.errorCode == nil
            print("sucess=", success)
            if success then

                _G.STORAGE.saveVMs(data)

                if onSuccess then
                    onSuccess(data)
                end
            else

                if onFail then
                    onFail(data.errorMessage, data.errorCode)
                end
            end

        end,
        "GET",  -- method
        nil,     -- onProgress
        true)    -- silentRequest
end


-- pause a virtual machines
api.pauseVirtualMachine = function(vmId, onSuccess, onFail)
    print("Calling API to pauseVirtualMachine VM with Id '" .. tostring(vmId) .. "'")
    timer.performWithDelay(1000, function()
        onSuccess()
    end)

    if true then return end


    local params = {}
    params["type"] = "server"
    params["action"] = "PAUSE"
    params["id"] = vmId

    getJSON("os/op",
        params,
        function(data, event)
            local success = event.response == 200
            print("sucess=", success)
            if success then
                if onSuccess then
                    onSuccess()
                end
            else
                if onFail then
                    onFail()
                end
            end

        end,
        "GET",  -- method
        nil,     -- onProgress
        true)    -- silentRequest
end

-- pause a virtual machines
api.startVirtualMachine = function(vmId, onSuccess, onFail)
    print("Calling API to startVirtualMachine VM with Id '" .. tostring(vmId) .. "'")
    timer.performWithDelay(1000, function()
        onSuccess()
    end)

    if true then return end


    local params = {}
    params["type"] = "server"
    params["action"] = "START"
    params["id"] = vmId

    getJSON("os/op",
        params,
        function(data, event)
            local success = event.response == 200
            print("sucess=", success)
            if success then
                if onSuccess then
                    onSuccess()
                end
            else
                if onFail then
                    onFail()
                end
            end

        end,
        "GET",  -- method
        nil,     -- onProgress
        true)    -- silentRequest
end


return api