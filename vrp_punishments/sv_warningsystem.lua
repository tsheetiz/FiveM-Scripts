AddEventHandler('chatMessage', function(player, color, message)
	user_id = vRP.getUserId(player)
    if message:sub(1, 13) == '/showwarnings' then
		local permID =  tonumber(message:sub(14, 20))
		if permID ~= nil then
			if vRP.hasPermission(user_id,"player.kick") then
				cmgwarningstables = getCMGWarnings(permID,player)
				TriggerClientEvent("CMG:showWarningsOfUser",player,cmgwarningstables)
			end
		end
    end
	CancelEvent()
end)
	
function getCMGWarnings(user_id,source) 
	cmgwarningstables = exports['GHMattiMySQL']:QueryResult("SELECT * FROM cmg_warnings WHERE user_id = @uid", {uid = user_id})
	for warningID,warningTable in pairs(cmgwarningstables) do
		date = warningTable["warning_date"]
		newdate = tonumber(date) / 1000
		newdate = os.date('%Y-%m-%d', newdate)
		warningTable["warning_date"] = newdate
	end
	return cmgwarningstables
end

RegisterServerEvent("CMG:refreshWarningSystem")
AddEventHandler("CMG:refreshWarningSystem",function()
	local source = source
	local user_id = vRP.getUserId(source)
	cmgwarningstables = getCMGWarnings(user_id,source)
	TriggerClientEvent("CMG:recievedRefreshedWarningData",source,cmgwarningstables)
end)

RegisterServerEvent("CMG:warnPlayer")
AddEventHandler("CMG:warnPlayer",function(target_id,adminName,warningReason)
	local source = source
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"player.kick") then
		warning = "Warning"
		warningDate = getCurrentDate()
		exports['GHMattiMySQL']:QueryAsync("INSERT INTO cmg_warnings (`warning_id`, `user_id`, `warning_type`, `duration`, `admin`, `warning_date`, `reason`) VALUES (NULL, @user_id, @warning_type, 0, @admin, @warning_date,@reason);", {user_id = target_id,warning_type = warning, admin = adminName, warning_date = warningDate, reason = warningReason}, function() end)
	else
		vRPclient.notify(player,{"~r~no perms to warn player"})
	end
end)

function saveKickLog(target_id,adminName,warningReason)
	warning = "Kick"
	warningDate = getCurrentDate()
	exports['GHMattiMySQL']:QueryAsync("INSERT INTO cmg_warnings (`warning_id`, `user_id`, `warning_type`, `duration`, `admin`, `warning_date`, `reason`) VALUES (NULL, @user_id, @warning_type, 0, @admin, @warning_date,@reason);", {user_id = target_id,warning_type = warning, admin = adminName, warning_date = warningDate, reason = warningReason}, function() end)
end

function saveBanLog(target_id,adminName,warningReason,warning_duration)
	warning = "Ban"
	warningDate = getCurrentDate()
	exports['GHMattiMySQL']:QueryAsync("INSERT INTO cmg_warnings (`warning_id`, `user_id`, `warning_type`, `duration`, `admin`, `warning_date`, `reason`) VALUES (NULL, @user_id, @warning_type, @duration, @admin, @warning_date,@reason);", {user_id = target_id,warning_type = warning, admin = adminName, duration = warning_duration, warning_date = warningDate, reason = warningReason}, function() end)
end


function getCurrentDate()
	date = os.date("%Y/%m/%d")
	return date
end
