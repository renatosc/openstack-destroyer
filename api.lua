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


            if data == nil or type(data) ~= "table" then
                print("Data is not a valid JSON")
                showDownloadErroAlert()
                return

            end


            if data["errorCode"] == 4 then
                -- token expired move user to login screen
                native.setActivityIndicator( false )
                _G.USER.logout(true)

                return
            end
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



-- gets the number of active virtual machines
api.getVirtualMachines = function(onSuccess, onFail)

    local fakeData = '[{"id":"e0238ae9-cf84-448f-a379-6cee0f97f19c","name":"vmFake1","addresses":{"addresses":{"provider":[{"macAddr":"fa:16:3e:8b:30:aa","version":4,"addr":"203.0.113.107","type":"fixed"}]}},"links":[{"rel":"self","href":"http://localhost:8774/v2.1/servers/e0238ae9-cf84-448f-a379-6cee0f97f19c","type":null},{"rel":"bookmark","href":"http://localhost:8774/servers/e0238ae9-cf84-448f-a379-6cee0f97f19c","type":null}],"image":null,"flavor":{"id":"9b68c48f-6f8e-4b91-9d17-4067871ca54b","name":"small","ram":512,"vcpus":1,"disk":1,"ephemeral":1,"swap":300,"rxtxFactor":1.0,"disabled":false,"rxtxQuota":0,"rxtxCap":0,"links":[{"rel":"self","href":"http://localhost:8774/v2.1/flavors/9b68c48f-6f8e-4b91-9d17-4067871ca54b","type":null},{"rel":"bookmark","href":"http://localhost:8774/flavors/9b68c48f-6f8e-4b91-9d17-4067871ca54b","type":null}],"public":true},"accessIPv4":"","accessIPv6":"","configDrive":"","status":"ACTIVE","progress":0,"fault":null,"tenantId":"4048750e5ef040ce8741ba6398d811c9","userId":"882a0fec22b24368be005b34e2f296b0","keyName":null,"hostId":"038045d19f5dd976db501facee68f415de256bf411fbe523148a435f","updated":1512466485000,"created":1512466454000,"metadata":{},"securityGroups":[{"name":"default"}],"taskState":null,"powerState":"1","vmState":"active","host":"compute1","instanceName":"instance-00000001","hypervisorHostname":"compute1","diskConfig":"AUTO","availabilityZone":"nova","launchedAt":1512466485000,"terminatedAt":null,"osExtendedVolumesAttached":["91238116-799a-4ce0-bb9d-78daa69842fa"],"uuid":null,"adminPass":null,"imageId":null,"flavorId":"9b68c48f-6f8e-4b91-9d17-4067871ca54b"},{"id":"e0238ae9-cf84-448f-a379-6cee0f97f19c","name":"vmFake2","addresses":{"addresses":{"provider":[{"macAddr":"fa:16:3e:8b:30:aa","version":4,"addr":"203.0.113.107","type":"fixed"}]}},"links":[{"rel":"self","href":"http://localhost:8774/v2.1/servers/e0238ae9-cf84-448f-a379-6cee0f97f19c","type":null},{"rel":"bookmark","href":"http://localhost:8774/servers/e0238ae9-cf84-448f-a379-6cee0f97f19c","type":null}],"image":null,"flavor":{"id":"9b68c48f-6f8e-4b91-9d17-4067871ca54b","name":"small","ram":512,"vcpus":1,"disk":1,"ephemeral":1,"swap":300,"rxtxFactor":1.0,"disabled":false,"rxtxQuota":0,"rxtxCap":0,"links":[{"rel":"self","href":"http://localhost:8774/v2.1/flavors/9b68c48f-6f8e-4b91-9d17-4067871ca54b","type":null},{"rel":"bookmark","href":"http://localhost:8774/flavors/9b68c48f-6f8e-4b91-9d17-4067871ca54b","type":null}],"public":true},"accessIPv4":"","accessIPv6":"","configDrive":"","status":"ACTIVE","progress":0,"fault":null,"tenantId":"4048750e5ef040ce8741ba6398d811c9","userId":"882a0fec22b24368be005b34e2f296b0","keyName":null,"hostId":"038045d19f5dd976db501facee68f415de256bf411fbe523148a435f","updated":1512466485000,"created":1512466454000,"metadata":{},"securityGroups":[{"name":"default"}],"taskState":null,"powerState":"1","vmState":"active","host":"compute1","instanceName":"instance-00000001","hypervisorHostname":"compute1","diskConfig":"AUTO","availabilityZone":"nova","launchedAt":1512466485000,"terminatedAt":null,"osExtendedVolumesAttached":["91238116-799a-4ce0-bb9d-78daa69842fa"],"uuid":null,"adminPass":null,"imageId":null,"flavorId":"9b68c48f-6f8e-4b91-9d17-4067871ca54b"},{"id":"e0238ae9-cf84-448f-a379-6cee0f97f19c","name":"vmFake3","addresses":{"addresses":{"provider":[{"macAddr":"fa:16:3e:8b:30:aa","version":4,"addr":"203.0.113.107","type":"fixed"}]}},"links":[{"rel":"self","href":"http://localhost:8774/v2.1/servers/e0238ae9-cf84-448f-a379-6cee0f97f19c","type":null},{"rel":"bookmark","href":"http://localhost:8774/servers/e0238ae9-cf84-448f-a379-6cee0f97f19c","type":null}],"image":null,"flavor":{"id":"9b68c48f-6f8e-4b91-9d17-4067871ca54b","name":"small","ram":512,"vcpus":1,"disk":1,"ephemeral":1,"swap":300,"rxtxFactor":1.0,"disabled":false,"rxtxQuota":0,"rxtxCap":0,"links":[{"rel":"self","href":"http://localhost:8774/v2.1/flavors/9b68c48f-6f8e-4b91-9d17-4067871ca54b","type":null},{"rel":"bookmark","href":"http://localhost:8774/flavors/9b68c48f-6f8e-4b91-9d17-4067871ca54b","type":null}],"public":true},"accessIPv4":"","accessIPv6":"","configDrive":"","status":"ACTIVE","progress":0,"fault":null,"tenantId":"4048750e5ef040ce8741ba6398d811c9","userId":"882a0fec22b24368be005b34e2f296b0","keyName":null,"hostId":"038045d19f5dd976db501facee68f415de256bf411fbe523148a435f","updated":1512466485000,"created":1512466454000,"metadata":{},"securityGroups":[{"name":"default"}],"taskState":null,"powerState":"1","vmState":"active","host":"compute1","instanceName":"instance-00000001","hypervisorHostname":"compute1","diskConfig":"AUTO","availabilityZone":"nova","launchedAt":1512466485000,"terminatedAt":null,"osExtendedVolumesAttached":["91238116-799a-4ce0-bb9d-78daa69842fa"],"uuid":null,"adminPass":null,"imageId":null,"flavorId":"9b68c48f-6f8e-4b91-9d17-4067871ca54b"},{"id":"e0238ae9-cf84-448f-a379-6cee0f97f19c","name":"vm1","addresses":{"addresses":{"provider":[{"macAddr":"fa:16:3e:8b:30:aa","version":4,"addr":"203.0.113.107","type":"fixed"}]}},"links":[{"rel":"self","href":"http://localhost:8774/v2.1/servers/e0238ae9-cf84-448f-a379-6cee0f97f19c","type":null},{"rel":"bookmark","href":"http://localhost:8774/servers/e0238ae9-cf84-448f-a379-6cee0f97f19c","type":null}],"image":null,"flavor":{"id":"9b68c48f-6f8e-4b91-9d17-4067871ca54b","name":"small","ram":512,"vcpus":1,"disk":1,"ephemeral":1,"swap":300,"rxtxFactor":1.0,"disabled":false,"rxtxQuota":0,"rxtxCap":0,"links":[{"rel":"self","href":"http://localhost:8774/v2.1/flavors/9b68c48f-6f8e-4b91-9d17-4067871ca54b","type":null},{"rel":"bookmark","href":"http://localhost:8774/flavors/9b68c48f-6f8e-4b91-9d17-4067871ca54b","type":null}],"public":true},"accessIPv4":"","accessIPv6":"","configDrive":"","status":"ACTIVE","progress":0,"fault":null,"tenantId":"4048750e5ef040ce8741ba6398d811c9","userId":"882a0fec22b24368be005b34e2f296b0","keyName":null,"hostId":"038045d19f5dd976db501facee68f415de256bf411fbe523148a435f","updated":1512466485000,"created":1512466454000,"metadata":{},"securityGroups":[{"name":"default"}],"taskState":null,"powerState":"1","vmState":"active","host":"compute1","instanceName":"instance-00000001","hypervisorHostname":"compute1","diskConfig":"AUTO","availabilityZone":"nova","launchedAt":1512466485000,"terminatedAt":null,"osExtendedVolumesAttached":["91238116-799a-4ce0-bb9d-78daa69842fa"],"uuid":null,"adminPass":null,"imageId":null,"flavorId":"9b68c48f-6f8e-4b91-9d17-4067871ca54b"}]'
    local data = require("json").decode(fakeData)
    _G.STORAGE.saveVMs(data)

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


--TODO: Fix this function
api.createNewVirtualMachine = function(vmName, onSuccess, onFail)
    print("Calling API to TERMINATE VM with Id '" .. vmId .. "'")
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


-- gets the number of active virtual machines
api.terminateVirtualMachine = function(vmId, onSuccess, onFail)
    print("Calling API to TERMINATE VM with Id '" .. vmId .. "'")
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


return api