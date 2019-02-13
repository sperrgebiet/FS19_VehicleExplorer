VehicleStatus = {};


VehicleStatus.ModName = g_currentModName;
VehicleStatus.ModDirectory = g_currentModDirectory;
VehicleStatus.Version = "1.0.0.0";


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
		
		if self.spec_lights ~= nil then
			local lightsMask = Utils.getNoNil(getXMLInt(savegame.xmlFile, savegame.key .. ".vehicleStatus#lightsMask"), 0);
			VehicleSort:dp(string.format('lightsMask: {%s} for {%s} | savegame.key: {%s}', tostring(lightsMask), self.configFileName, savegame.key .. ".vehicleStatus#lightsMask"), 'VehicleStatus:onPostLoad');
			self:setLightsTypesMask(lightsMask);
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
	end
end

function VehicleStatus:getIsMotorStarted(vehObj)
	if vehObj.spec_motorized ~= nil and vehObj.getIsMotorStarted then
		return vehObj:getIsMotorStarted();
	end
end

function VehicleStatus:getIsTurnedOn(vehObj)
	if vehObj.spec_turnOnVehicle ~= nil and vehObj.getIsTurnedOn then
		return vehObj:getIsTurnedOn()
	end
end

function VehicleStatus:getIsLightTurnedOn(vehObj)
	if vehObj.spec_lights ~= nil and vehObj.getLightsTypesMask then
		if vehObj:getLightsTypesMask() > 0 then
			return true;
		else
			return false;
		end
	end
end

function VehicleStatus:getSpeedStr(vehObj)
	if vehObj.getLastSpeed ~= nil then
		return tostring(math.floor(vehObj:getLastSpeed())) .. " " .. "km/h";		--TODO: Change to the current measuring unit
	end
end

function VehicleStatus:RepairVehicleWithImplements(realId)
	veh = g_currentMission.vehicles[realId];
	if veh ~= nil then
		if veh.repairVehicle ~= nil then
			veh:repairVehicle(true);
			
			local implements = VehicleSort:getVehImplements(realId);
			for i = 1, #implements do
				local imp = implements[i];
				if imp ~= nil and imp.object ~= nil and imp.object.repairVehicle ~= nil then
					imp.object:repairVehicle(true);
				end
			end
		end
	end
end