local bones = {
    "door_dside_f",
    "door_dside_r",
    "door_pside_f",
    "door_pside_r",
    "boot"
}

exports['qb-target']:AddTargetBone(bones, {
    options = {
        {
            type = "client",
            event = "police:client:PutPlayerInVehicle",
            icon = "fas fa-chevron-circle-left",
            label = "Place In Vehicle",
        },
        {
            type = "client",
            event = "police:client:SetPlayerOutVehicle",
            icon = "fas fa-chevron-circle-right",
            label = "Take Out Vehicle",
        },
        {
            type = "client",
            event = "qb-trunk:client:GetIn",
            icon = "fas fa-user-secret",
            label = "Get In Trunk",
        },
        {
            type = "client",
            event = "qb:flipvehicle", 
            icon = "fas fa-car",
            label = "Flip Vehicle",
        },
        {
            type = "client",
            event = "vehiclekeys:client:GiveKeys",
            icon = "fas fa-key", 
            label = "Give Keys",
        },
    },
distance = 4.0,
})

-- flip vehicle
RegisterNetEvent("qb:flipvehicle", function()
	local playerPed	= PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	local vehicle = nil
	if IsPedSittingInAnyVehicle(playerPed) then
        QBCore.Functions.Notify("Cannot flip while inside vehicle", "error")
		ClearPedTasks(playerPed)
		return
	end
	if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.5) then
		vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 3.5, 0, 71)
		SetVehicleModKit(vehicle, 0)
		if DoesEntityExist(vehicle) then
			QBCore.Functions.Progressbar("accepted_key", "Flipping Vehicle", 12000, false, true, {
				disableMovement = true,
				disableCarMovement = true,
				disableMouse = false,
				disableCombat = true,
			}, {
				task = "CODE_HUMAN_MEDIC_TEND_TO_DEAD"
			}, {}, {}, function() -- Done
				ClearPedTasks(playerPed)
				FreezeEntityPosition(playerPed, false)
				vehiclecoords = GetEntityCoords(vehicle)
				SetEntityCoords(vehicle, vehiclecoords.x+0.5, vehiclecoords.y+0.5, vehiclecoords.z+1)
				Wait(200)
				SetEntityRotation(vehicle, GetEntityRotation(PlayerPedId(), 2), 2)
				Wait(500)
				SetVehicleOnGroundProperly(vehicle)
                QBCore.Functions.Notify("Success! Vehicle Flipped", "success")
			end, function() -- Cancel

                QBCore.Functions.Notify("Vehicle flip failed!", "error")
				FreezeEntityPosition(playerPed, false)
				ClearPedTasks(playerPed)
			end)
		else
            QBCore.Functions.Notify("There is no vehicle nearby", "error")
		end
	else
        QBCore.Functions.Notify("There is no vehicle nearby", "error")
	end
end)

RegisterNetEvent('vehiclekeys:client:GiveKeys', function(target)
    local plate = QBCore.Functions.GetPlate(GetVehiclePedIsIn(PlayerPedId(), true))
    TriggerServerEvent('vehiclekeys:server:GiveVehicleKeys', plate, target)
end)
