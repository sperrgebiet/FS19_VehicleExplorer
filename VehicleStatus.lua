VehicleStatus = {};


VehicleStatus.ModName = g_currentModName;
VehicleStatus.ModDirectory = g_currentModDirectory;
VehicleStatus.Version = "0.9.0.9";


VehicleStatus.debug = fileExists(VehicleStatus.ModDirectory ..'debug');

print(string.format('VehicleStatus v%s - DebugMode %s)', VehicleStatus.Version, tostring(VehicleStatus.debug)));

function VehicleStatus.prerequisitesPresent(specializations)
	return true;
end

function VehicleStatus.registerEventListeners(vehicleType)
	local functionNames = {	"onLoad", "onPostLoad", "saveToXMLFile" };
	
	for _, functionName in ipairs(functionNames) do
		SpecializationUtil.registerEventListener(vehicleType, functionName, VehicleStatus);
	end
end

function VehicleStatus:onLoad(savegame)
end;

function VehicleStatus:onPostLoad(savegame)
	if VehicleSort.config[14][2] and savegame ~= nil then
		if self.spec_motorized ~= nil then
			local motorTurnedOn = Utils.getNoNil(getXMLBool(savegame.xmlFile, savegame.key .. ".vehicleStatus#isMotorStarted"), false);
			VehicleSort:dp(string.format('motorTurnedOn: {%s} for {%s} | savegame.key: {%s}', tostring(motorTurnedOn), self.configFileName, savegame.key .. ".vehicleStatus#isMotorStarted"), 'VehicleStatus:onPostLoad');
			if motorTurnedOn then
				self:startMotor();
			end
		end
		
		if self.spec_turnOnVehicle ~= nil then
			local isTurnedOn = Utils.getNoNil(getXMLBool(savegame.xmlFile, savegame.key .. ".vehicleStatus#isTurnedOn"), false);
			VehicleSort:dp(string.format('isTurnedOn: {%s} for {%s} | savegame.key: {%s}', tostring(isTurnedOn), self.configFileName, savegame.key .. ".vehicleStatus#isTurnedOn"), 'VehicleStatus:onPostLoad');
			if isTurnedOn then
				self:setIsTurnedOn(isTurnedOn);
			end
		end
		
		if self.spec_lights ~= nil and self.spec_enterable ~= nil then
			local lightsMask = Utils.getNoNil(getXMLInt(savegame.xmlFile, savegame.key .. ".vehicleStatus#lightsMask"), 0);
			VehicleSort:dp(string.format('lightsMask: {%s} for {%s} | savegame.key: {%s}', tostring(lightsMask), self.configFileName, savegame.key .. ".vehicleStatus#lightsMask"), 'VehicleStatus:onPostLoad');
			if lightsMask > 0 then
				self:setLightsTypesMask(lightsMask, true);
			end

			local beaconsOn = Utils.getNoNil(getXMLBool(savegame.xmlFile, savegame.key .. ".vehicleStatus#beaconsOn"), false);
			VehicleSort:dp(string.format('beaconsOn: {%s} for {%s} | savegame.key: {%s}', tostring(beaconsOn), self.configFileName, savegame.key .. ".vehicleStatus#beaconsOn"), 'VehicleStatus:onPostLoad');
			if beaconsOn then
				self:setBeaconLightsVisibility(beaconsOn, true);
			end

			local turnLightsState = Utils.getNoNil(getXMLInt(savegame.xmlFile, savegame.key .. ".vehicleStatus#turnLightsState"), 0);
			VehicleSort:dp(string.format('turnLightsState: {%s} for {%s} | savegame.key: {%s}', tostring(turnLightsState), self.configFileName, savegame.key .. ".vehicleStatus#turnLightsState"), 'VehicleStatus:onPostLoad');
			if turnLightsState > 0 then
				self:setTurnLightState(turnLightsState, true);
			end
			
			local brakeLightsOn = Utils.getNoNil(getXMLBool(savegame.xmlFile, savegame.key .. ".vehicleStatus#brakeLightsOn"), false);
			VehicleSort:dp(string.format('brakeLightsOn: {%s} for {%s} | savegame.key: {%s}', tostring(brakeLightsOn), self.configFileName, savegame.key .. ".vehicleStatus#brakeLightsOn"), 'VehicleStatus:onPostLoad');
			if brakeLightsOn then
				self:setBrakeLightsVisibility(brakeLightsOn, true);
			end
		end		
	end
end

function VehicleStatus:saveToXMLFile(xmlFile, key)
	if VehicleSort.config[14][2] then
		if VehicleStatus:getIsMotorStarted(self) then
			setXMLBool(xmlFile, key .. '#isMotorStarted', VehicleStatus:getIsMotorStarted(self));
		end
		
		if VehicleStatus:getIsTurnedOn(self) then
			setXMLBool(xmlFile, key .. '#isTurnedOn', VehicleStatus:getIsTurnedOn(self));
		end
		
		if VehicleStatus:getIsLightTurnedOn(self) then
			setXMLInt(xmlFile, key .. '#lightsMask', self:getLightsTypesMask());
		end

		if VehicleStatus:getBeaconLightsVisibility(self) then
			setXMLBool(xmlFile, key .. '#beaconsOn', VehicleStatus:getBeaconLightsVisibility(self));
		end

		if VehicleStatus:getTurnLightState(self) > 0 then
			setXMLInt(xmlFile, key .. '#turnLightsState', VehicleStatus:getTurnLightState(self));
		end

		if VehicleStatus:getIsBrakeLightsOn(self) then
			setXMLBool(xmlFile, key .. '#brakeLightsOn', VehicleStatus:getIsBrakeLightsOn(self));
		end	
		
	end
end

function VehicleStatus:getIsMotorStarted(vehObj)
	if vehObj.spec_motorized ~= nil and vehObj.getIsMotorStarted ~= nil then
		return vehObj:getIsMotorStarted();
	end
end

function VehicleStatus:getIsTurnedOn(vehObj)
	if vehObj.spec_turnOnVehicle ~= nil and vehObj.getIsTurnedOn ~= nil then
		return vehObj:getIsTurnedOn()
	end
end

function VehicleStatus:getIsLightTurnedOn(vehObj)
	if vehObj.spec_lights ~= nil and vehObj.getLightsTypesMask ~= nil then
		if vehObj:getLightsTypesMask() > 0 then
			return true;
		else
			return false;
		end
	end
end

function VehicleStatus:getBeaconLightsVisibility(vehObj)
	if vehObj.spec_lights ~= nil and vehObj.getBeaconLightsVisibility ~= nil then
		return vehObj:getBeaconLightsVisibility()
	end
end

function VehicleStatus:getTurnLightState(vehObj)
	if vehObj.spec_lights ~= nil and vehObj.getTurnLightState ~= nil then
		return vehObj:getTurnLightState()
	else
		return 0;
	end
end

function VehicleStatus:getIsBrakeLightsOn(vehObj)
	if vehObj.spec_lights ~= nil and vehObj.spec_lights.brakeLightsVisibility ~= nil then
		return vehObj.spec_lights.brakeLightsVisibility;
	end
end

function VehicleStatus:getSpeedStr(vehObj)
	if vehObj.getLastSpeed ~= nil then
		return tostring(math.floor(vehObj:getLastSpeed())) .. " " .. "km/h";		--TODO: Change to the current measuring unit
	end
end

function VehicleStatus:RepairVehicleWithImplements(realId)
	veh = g_currentMission.vehicles[realId];
	VehicleSort:dp(string.format('realId {%s} for configFileName {%s}', realId, veh.configFileName), 'VehicleStatus:RepairVehicleWithImplements');
	if veh ~= nil then
		if veh.repairVehicle ~= nil then
			veh:repairVehicle(true);
			VehicleSort:dp(string.format('Repaired vehicle realId {%s} - configFileName {%s}', tostring(realId), veh.configFileName), 'VehicleStatus:RepairVehicleWithImplements');
			local implements = VehicleSort:getVehImplements(realId);
			if implements ~= nil then
				for i = 1, #implements do
					local imp = implements[i];
					if imp ~= nil and imp.object ~= nil and imp.object.repairVehicle ~= nil then
						imp.object:repairVehicle(true);
						VehicleSort:dp(string.format('Repaired implement configFileName {%s}', tostring(imp.object.configFileName)), 'VehicleStatus:RepairVehicleWithImplements');
					end
				end
			end
		end
	end
end


function VehicleStatus:CleanVehicleWithImplements(realId)
	veh = g_currentMission.vehicles[realId];
	VehicleSort:dp(string.format('realId {%s} for configFileName {%s}', realId, veh.configFileName), 'VehicleStatus:CleanVehicleWithImplements');
	if veh ~= nil then
		if veh.spec_washable ~= nil then
			VehicleStatus:setDirtOnObject(veh, 0)
			VehicleSort:dp(string.format('Cleaned vehicle realId {%s} - configFileName {%s}', tostring(realId), veh.configFileName), 'VehicleStatus:CleanVehicleWithImplements');
			local implements = VehicleSort:getVehImplements(realId);
			if implements ~= nil then
				for i = 1, #implements do
					local imp = implements[i];
					if imp ~= nil and imp.object ~= nil and imp.object.spec_washable ~= nil then
						VehicleStatus:setDirtOnObject(imp.object, 0)
						VehicleSort:dp(string.format('Cleaned implement configFileName {%s}', tostring(imp.object.configFileName)), 'VehicleStatus:CleanVehicleWithImplements');
					end
				end
			end
		end
	end
end

function VehicleStatus:getVehImplementsDamage(realId)
	local texts = {};
	local line = "";

	local implements = VehicleSort:getVehImplements(realId);
	if implements ~= nil then
	
		for i = 1, #implements do
			local imp = implements[i];
			
			if (imp ~= nil and imp.object ~= nil and imp.object.getVehicleDamage ~= nil) then
				line = g_i18n.modEnvironments[VehicleSort.ModName].texts.damage .. " (" .. string.gsub(VehicleSort:getAttachment(imp.object), "%s$", "") .. "): " .. VehicleSort:calcPercentage(imp.object:getVehicleDamage(), 1) .. " %";
				table.insert(texts, line);
			end
		end
		
		return texts;
	else
		return nil;
	end
end

function VehicleStatus:getDirtPercForObject(obj)
	if obj ~= nil then
		if obj.spec_washable ~= nil then
			local nodeCount = 0;
			local dirtAmount = 0;
			for _, node in pairs(obj.spec_washable.washableNodes) do
				dirtAmount = dirtAmount + node.dirtAmount;
				nodeCount = nodeCount + 1;
			end
			-- Total dirt should be combined dirt / nodecount
			return VehicleSort:calcPercentage(dirtAmount / nodeCount, 1);
		else
			return nil;
		end
	else
		return nil;
	end
end

function VehicleStatus:getVehImplementsDirt(realId)
	local texts = {};
	local line = "";

	local implements = VehicleSort:getVehImplements(realId);
	if implements ~= nil then
	
		for i = 1, #implements do
			local imp = implements[i];
			
			if (imp ~= nil and imp.object ~= nil and VehicleStatus:getDirtPercForObject(imp.object) ~= nil) then
				line = g_i18n.modEnvironments[VehicleSort.ModName].texts.dirt .. " (" .. string.gsub(VehicleSort:getAttachment(imp.object), "%s$", "") .. "): " .. VehicleStatus:getDirtPercForObject(imp.object) .. " %";
				table.insert(texts, line);
			end
		end
		
		return texts;
	else
		return nil;
	end
end

function VehicleStatus:setDirtOnObject(obj, dirt)
	if obj.spec_washable ~= nil then
		for _, node in pairs(obj.spec_washable.washableNodes) do
			Washable:setNodeDirtAmount(node, dirt, force);
		end
		return true;
	else
		return nil;
	end
end