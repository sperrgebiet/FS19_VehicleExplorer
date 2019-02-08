VehicleSort = {};
VehicleSort.ModName = g_currentModName;
VehicleSort.Version = "0.0.0.1";

VehicleSort.eventName = {};
VehicleSort.showHelp = true;
VehicleSort.debug = true;

VehicleSort.bgTransDef = 0.8;
VehicleSort.txtSizeDef = 2;

VehicleSort.config = {
  {'showTrain', true},
  {'showCrane', false},
  {'showBrand', false},
  {'showType', false},
  {'showNames', true},
  {'showFillLevels', true},
  {'showPercentages', true},
  {'showEmpty', false},
  {'txtSize', VehicleSort.txtSizeDef},
  {'bgTrans', VehicleSort.bgTransDef}
};

VehicleSort.tColor = {}; -- text colours
VehicleSort.tColor.isParked 	= {0.5, 0.5, 0.5, 0.7};   -- grey
VehicleSort.tColor.locked 		= {1.0, 0.0, 0.0, 1.0};   -- red
VehicleSort.tColor.selected 	= {1.0, 0.5, 0.0, 1.0}; -- orange
VehicleSort.tColor.standard 	= {1.0, 1.0, 1.0, 1.0}; -- white
VehicleSort.tColor.hired 		= {0.0, 0.5, 1.0, 1.0}; 	-- blue
VehicleSort.tColor.followme 	= {0.92, 0.31, 0.69, 1.0}; 	-- light pink
VehicleSort.tColor.self  		= {0.0, 1.0, 0.0, 1.0}; -- green

VehicleSort.isInitialized = false;
VehicleSort.key = 'vs';
VehicleSort.keyCon = VehicleSort.key .. '.config';
VehicleSort.keyVeh = VehicleSort.key .. '.vehicle';
VehicleSort.selectedConfigIndex = 1;
VehicleSort.selectedIndex = 1;
VehicleSort.selectedLock = false;
VehicleSort.showConfig = false;
VehicleSort.showSteerables = false;
VehicleSort.xmlAttrId = '#vsid';
VehicleSort.xmlAttrMapId = '#mapid';
VehicleSort.xmlAttrOrder = '#vsorder';
VehicleSort.xmlAttrParked = '#vsparked';

addModEventListener(VehicleSort);

function VehicleSort:dp(val, fun, msg) -- debug mode, write to log
  if not VehicleSort.debug then
    return;
  end;
  if msg == nil then
    msg = ' ';
  else
    msg = string.format(' msg = [%s] ', tostring(msg));
  end;
  local pre = 'VehicleSort DEBUG:';
  if type(val) == 'table' then
    if #val > 0 then
      print(string.format('%s BEGIN Printing table data: (%s)%s(function = [%s()])', pre, tostring(val), msg, tostring(fun)));
      DebugUtil.printTableRecursively(val, '.', 0, 3);
      print(string.format('%s END Printing table data: (%s)%s(function = [%s()])', pre, tostring(val), msg, tostring(fun)));
    else
      print(string.format('%s Table is empty: (%s)%s(function = [%s()])', pre, tostring(val), msg, tostring(fun)));
    end;
  else
    print(string.format('%s [%s]%s(function = [%s()])', pre, tostring(val), msg, tostring(fun)));
  end;
end


function VehicleSort:prerequisitesPresent(specializations)
    return true;
end;


function VehicleSort:loadMap(name)
end;

function VehicleSort:onLoad(savegame)
	print("--- loading VehicleSort V".. VehicleSort.Version .. " | ModName " .. VehicleSort.ModName .. " ---")
    -- Only needed for action event for player
    --Player.registerActionEvents = Utils.appendedFunction(Player.registerActionEvents, VehicleSort.RegisterActionEvents);
	--Player.removeActionEvents = Utils.appendedFunction(Player.removeActionEvents, VehicleSort.removeActionEvents);				
	
	FSBaseMission.registerActionEvents = Utils.appendedFunction(FSBaseMission.registerActionEvents, VehicleSort.RegisterActionEvents);
	
	-- SaveSettings
	--FSBaseMission.saveSavegame = Utils.appendedFunction(FSBaseMission.saveSavegame, VehicleSort.saveVehicleOrder);
	
	if not VehicleSort:isTrain(self) then
		local specVS = self.spec_vehicleSort;
		specVS.id = VehicleSort:getUniqueId(VehicleSort.nextId);
		specVS.name = VehicleSort:getName(self, "Vehicle");
		specVS.brand = VehicleSort:getNameBrand(self);
		specVS.ps = math.ceil(self.spec_motorized.motor.peakMotorTorque / 0.0044);
	end
	
	VehicleSort:reset();
end;

function VehicleSort:postLoad(savegame)
	VehicleSort.loadSteerable();
end

function VehicleSort:RegisterActionEvents()

	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'vsToggleList',self, VehicleSort.action_vsToggleList ,false ,true ,false ,true)
	if result then
		table.insert(VehicleSort.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = VehicleSort.showHelp;
    end

	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'vsLockListItem',self, VehicleSort.action_vsLockListItem ,false ,true ,false ,true)
	if result then
        table.insert(VehicleSort.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = VehicleSort.showHelp;
    end
	
	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'vsMoveCursorUp',self, VehicleSort.action_vsMoveCursorUp ,false ,true ,false ,true)
	if result then
        table.insert(VehicleSort.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = VehicleSort.showHelp;
    end
	
	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'vsMoveCursorDown',self, VehicleSort.action_vsMoveCursorDown ,false ,true ,false ,true)
	if result then
        table.insert(VehicleSort.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = VehicleSort.showHelp;
    end
	
	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'vsMoveCursorUpFast',self, VehicleSort.action_vsMoveCursorUpFast ,false ,true ,false ,true)
	if result then
        table.insert(VehicleSort.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = VehicleSort.showHelp;
    end
	
	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'vsMoveCursorDownFast',self, VehicleSort.action_vsMoveCursorDownFast ,false ,true ,false ,true)
	if result then
        table.insert(VehicleSort.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = VehicleSort.showHelp;
    end
	
	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'vsChangeVehicle',self, VehicleSort.action_vsChangeVehicle ,false ,true ,false ,true)
	if result then
        table.insert(VehicleSort.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = VehicleSort.showHelp;
    end
	
	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'vsShowConfig',self, VehicleSort.action_vsShowConfig ,false ,true ,false ,true)
	if result then
        table.insert(VehicleSort.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = VehicleSort.showHelp;
    end	
	
	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'vsTogglePark',self, VehicleSort.action_vsTogglePark ,false ,true ,false ,true)
	if result then
        table.insert(VehicleSort.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = VehicleSort.showHelp;
    end	
	

	--if VehicleSort.debug then
	--	print("--- VehicleSort Debug ... VehicleSort:registerActionEventsPlayer(VehicleSort.eventName)");
	--	DebugUtil.printTableRecursively(VehicleSort.eventName,"----",0,1)
	--end;	
end;

function VehicleSort:removeActionEvents()
	VehicleSort.eventName = {};
	if VehicleSort.debug then
		print("--- VehicleSort Debug ... VehicleSort:removeActionEventsPlayer(VehicleSort.eventName)");
		DebugUtil.printTableRecursively(VehicleSort.eventName,"----",0,1)
	end;
end;

function VehicleSort.registerEventListeners(vehicleType)
	local functionNames = {
		"onLoad"
		,"postLoad"
	};
	
	for _, functionName in ipairs(functionNames) do
		SpecializationUtil.registerEventListener(vehicleType, functionName, VehicleSort);
	end;
end;

function VehicleSort:mouseEvent(posX, posY, isDown, isUp, button)
end;

function VehicleSort:keyEvent(unicode, sym, modifier, isDown)
end;

function VehicleSort:update()
  if not VehicleSort.isInitialized  then
    VehicleSort:init();
    VehicleSort.isInitialized = true;
  end;
end;

function VehicleSort:draw()
	if g_server ~= nil and g_client ~= nil and g_dedicatedServerInfo ~= nil or not VehicleSort.isInitialized then --do not draw on dedicated server, or if hud is not displayed, or if VehicleSort is not initialized
		return;
	end;
	
	--VehicleSort:dp(string.format('showConfig [%s] & showSteerables [%s]', tostring(VehicleSort.showConfig), tostring(VehicleSort.showSteerables)));
  
	if VehicleSort.showConfig or VehicleSort.showSteerables then
		local dbgY = VehicleSort.dbgY;
		VehicleSort.bgY = nil;
		VehicleSort.bgW = nil;
		VehicleSort.bgH = nil;
		if VehicleSort.showConfig then
		  VehicleSort:drawConfig();
		else
		  VehicleSort:drawList();
		end;
		if VehicleSort.debug then
		  local t = {};
		  table.insert(t, string.format('bgX [%f]', VehicleSort.bgX));
		  table.insert(t, string.format('bgY [%f]', VehicleSort.bgY));
		  table.insert(t, string.format('bgW [%f]', VehicleSort.bgW));
		  table.insert(t, string.format('maxTxtW [%f]', VehicleSort.maxTxtW));
		  for k, v in ipairs(t) do
			VehicleSort.dbgY = VehicleSort.dbgY - VehicleSort.tPos.size - VehicleSort.tPos.spacing;
			renderText(VehicleSort.dbgX, VehicleSort.dbgY, VehicleSort.tPos.size, v);
		  end;
		  VehicleSort.dbgY = dbgY;
		end;
	end;
	
end;

function VehicleSort:saveSavegame()
	VehicleSort:saveVehicleOrder();
end;

function VehicleSort:delete()
end;

function VehicleSort:deleteMap()
	if VehicleSort.isInitialized then
		delete(VehicleSort.bg);
	end;
	VehicleSort:reset();
end;

-- Functions for actionEvents/inputBindings

function VehicleSort:action_vsToggleList(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("vsToggleList fires", "vsToggleList");
	if VehicleSort.showSteerables and not VehicleSort.showConfig then
      VehicleSort.showSteerables = false;
      VehicleSort.selectedLock = false;
    else
      VehicleSort.showSteerables = true;
      VehicleSort.showConfig = false;
    end;
    VehicleSort:saveVehicleOrder();
end;

function VehicleSort:action_vsLockListItem(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("vsLockListItem fires", "vsLockListItem");
	if VehicleSort.showSteerables then
		if not VehicleSort.selectedLock and VehicleSort.selectedIndex > 0 then
			VehicleSort.selectedLock = true;
		elseif VehicleSort.selectedLock then
			VehicleSort.selectedLock = false;
		end;
	elseif VehicleSort.showConfig then
		if VehicleSort.selectedConfigIndex == 9 then
			VehicleSort.config[VehicleSort.selectedConfigIndex][2] = VehicleSort.config[VehicleSort.selectedConfigIndex][2] + 1;
			if VehicleSort.config[VehicleSort.selectedConfigIndex][2] > 3 then
				VehicleSort.config[VehicleSort.selectedConfigIndex][2] = 1;
			end;
		elseif VehicleSort.selectedConfigIndex == 10 then
			VehicleSort.config[VehicleSort.selectedConfigIndex][2] = VehicleSort.config[VehicleSort.selectedConfigIndex][2] + 0.1;
			if VehicleSort.config[VehicleSort.selectedConfigIndex][2] > 1 then
				VehicleSort.config[VehicleSort.selectedConfigIndex][2] = 0.0;
			end;
		else
			VehicleSort.config[VehicleSort.selectedConfigIndex][2] = not VehicleSort.config[VehicleSort.selectedConfigIndex][2];
		end;
	end
end;

function VehicleSort:action_vsMoveCursorUp(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("action_vsMoveCursorUp fires", "action_vsMoveCursorUp");
	if VehicleSort.showSteerables then
		VehicleSort:moveUp(1);
	elseif VehicleSort.showConfig then
		VehicleSort:moveConfigUp();
	end
end;

function VehicleSort:action_vsMoveCursorDown(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("action_vsMoveCursorDown fires", "action_vsMoveCursorDown");
	if VehicleSort.showSteerables then
		VehicleSort:moveDown(1);
	elseif VehicleSort.showConfig then
		VehicleSort:moveConfigDown();
	end	
end;

function VehicleSort:action_vsMoveCursorUpFast(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("action_vsMoveCursorUpFast fires", "action_vsMoveCursorUpFast");
	if VehicleSort.showSteerables then 
		VehicleSort:moveUp(3);
	end	
end;

function VehicleSort:action_vsMoveCursorDownFast(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("action_vsMoveCursorDownFast fires", "action_vsMoveCursorDownFast");
	if VehicleSort.showSteerables then 
		VehicleSort:moveDown(3);
	end	
end;

function VehicleSort:action_vsChangeVehicle(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("action_vsChangeVehicle fires", "action_vsChangeVehicle");
	if VehicleSort.showSteerables then
		local selIndex = VehicleSort.selectedIndex;
		print("selIndex" .. selIndex);
		local selVeh = VehicleSort.userOrder[selIndex];
		local realId = selVeh.id;
		print("realId" .. realId);
		if not g_currentMission.vehicles[realId]:getIsControlled() then
			g_currentMission:requestToEnterVehicle(g_currentMission.vehicles[realId]);
		end;
	end
end;

function VehicleSort:action_vsShowConfig(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("action_vsShowConfig fires", "action_vsShowConfig");
	if VehicleSort.showSteerables and not VehicleSort.showConfig then
      VehicleSort.showSteerables = false;
    end;
    VehicleSort.showConfig = not VehicleSort.showConfig;
    VehicleSort:saveVehicleOrder();
end;

function VehicleSort:action_vsTogglePark(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("action_vsTogglePark fires", "action_vsTogglePark");
	if VehicleSort.showSteerables then
		VehicleSort:toggleParkState(VehicleSort.selectedIndex);
	end
end;


--
-- VehicleSort specific functions
--
function VehicleSort:calcPercentage(curVal, maxVal)
  local per = curVal / maxVal * 100;
  return (math.floor(per * 10)/10);
end

function VehicleSort:calcFillLevel(obj)
  local lvl = 0;
  local cap = 0;
  if obj ~= nil then
    if obj.getFillLevel ~= nil then
      lvl = lvl + obj:getFillLevel();
    end;
    if obj.getCapacity ~= nil then
      cap = cap + obj:getCapacity();
    end;
  end;
  return lvl, cap;
end

function VehicleSort:drawConfig()
  local cCount = #VehicleSort.config;
  local xPos = VehicleSort.tPos.x;
  local yPos = VehicleSort.tPos.y;
  setTextAlignment(VehicleSort.tPos.alignment);
  local size = VehicleSort:getTextSize();
  local y = yPos + size + VehicleSort.tPos.spacing + VehicleSort.tPos.yOffset;
  local txt = g_i18n.modEnvironments[VehicleSort.ModName].texts.configHeadline;
  local txtOn = g_i18n.modEnvironments[VehicleSort.ModName].texts.vs_on;
  local txtOff = g_i18n.modEnvironments[VehicleSort.ModName].texts.vs_off;
  local texts = {};
  table.insert(texts, {xPos, y, size + VehicleSort.tPos.sizeIncr, VehicleSort.tColor.standard, txt}); --heading
  VehicleSort.bgW = VehicleSort.tPos.columnWidth + VehicleSort.tPos.padSides + getTextWidth(size, txtOff);
  for i = 1, cCount do --loop through config values
    local clr = VehicleSort.tColor.standard;
    if i == VehicleSort.selectedConfigIndex then
      clr = VehicleSort.tColor.selected;
    end;
    local rText = g_i18n.modEnvironments[VehicleSort.ModName].texts[VehicleSort.config[i][1]];
    local state = VehicleSort.config[i][2];
    if i == 9 then
      state = string.format('%d', state);
    elseif i == 10 then
      state = string.format('%.1f', state);
    elseif state then
      state = txtOn;
    else
      state = txtOff;
    end;
    table.insert(texts, {xPos, yPos, size, clr, rText}); --config definition line
    table.insert(texts, {xPos + VehicleSort.tPos.columnWidth, yPos, size, clr, state}); --config value
    yPos = yPos - size - VehicleSort.tPos.spacing;
  end;
  VehicleSort.bgY = yPos;
  VehicleSort.bgH = (y - yPos) + size + VehicleSort.tPos.yOffset + VehicleSort.tPos.padHeight;
  if VehicleSort.bgY ~= nil and VehicleSort.bgW ~=nil and VehicleSort.bgH ~= nil then
    VehicleSort:renderBg(VehicleSort.bgY, VehicleSort.bgW, VehicleSort.bgH);
  end;
  setTextBold(false);
  for k, v in ipairs(texts) do
    setTextColor(unpack(v[4]))
    renderText(v[1], v[2], v[3], tostring(v[5]));
    if VehicleSort.debug and v[4] == VehicleSort.tColor.selected then
      VehicleSort.dbgY = VehicleSort.dbgY - VehicleSort.tPos.size - VehicleSort.tPos.spacing;
      renderText(VehicleSort.dbgX, VehicleSort.dbgY, VehicleSort.tPos.size, string.format('selected textWidth [%f] colWidth [%f]', getTextWidth(v[3], tostring(v[5])), VehicleSort.tPos.columnWidth));
    end;
  end;
  setTextColor(unpack(VehicleSort.tColor.standard));
end

function VehicleSort:drawList()
  vehList = VehicleSort:getVehicles();
  --VehicleSort:dp(vehList, 'drawList', 'vehList');
  
  local cnt = #vehList;
  if cnt == 0 then
    return;
  end;
  setTextBold(true); -- for width checks, to compensate for increased width when the line is bold
  local xPos = VehicleSort.tPos.x;
  local yPos = VehicleSort.tPos.y;
  local bgPos = yPos;
  setTextAlignment(VehicleSort.tPos.alignment);
  local size = VehicleSort.getTextSize();
  local y = yPos + size + VehicleSort.tPos.spacing + VehicleSort.tPos.yOffset;
  local txt = 'VehicleSort';
  local texts = {};
  local bold = false;
  local minBgW = 0;
  table.insert(texts, {xPos, y, size + VehicleSort.tPos.sizeIncr, bold, VehicleSort.tColor.standard, txt}); --heading
  VehicleSort.bgY = y - VehicleSort.tPos.spacing;
  VehicleSort.bgW = getTextWidth(size, txt) + VehicleSort.tPos.padSides;
  local chk = yPos + size + VehicleSort.tPos.spacing;

  for i = 1, cnt do --loop through lines to see if there will be multiple columns needed
    local veh = vehList[i];
    if not VehicleSort:isHidden(veh) then
      chk = chk - size - VehicleSort.tPos.spacing;
    end;
  end;

  local isMultiCol = chk < (size + VehicleSort.tPos.spacing + VehicleSort.tPos.padHeight);
  local addCol = false;
  local minY = ((4 * (size + VehicleSort.tPos.spacing)) + VehicleSort.tPos.padHeight);

  for i = 1, cnt do
    veh = vehList[i];
    if not VehicleSort:isHidden(veh) then
      if addCol then
        minBgW = VehicleSort.bgW;
        addCol = false;
        isMultiCol = true;
      end;
	  --VehicleSort:dp(veh, 'drawList()', 'Just before getTextColor');
      local clr = VehicleSort:getTextColor(i, veh);
      local t = VehicleSort:getFullVehicleName(i);
      txt = table.concat(t);
      local w = minBgW + getTextWidth(size, txt);
      local lns = {};
      local ind = #t;
      local ln = t[ind];
      while isMultiCol and (w >= VehicleSort.maxTxtW) and ind > 0 do -- wrap text wider than the column to additional lines if multi-column
        if getTextWidth(size, ln) >= VehicleSort.maxTxtW then
          table.insert(lns, 1, ln);
          ln = t[ind - 1];
        else
          if ind > 1 then
            if getTextWidth(size, t[ind - 1] .. ln) >= VehicleSort.maxTxtW then
              table.insert(lns, 1, ln);
              ln = t[ind - 1];
            else
              ln = t[ind - 1] .. ln;
            end;
          else
            table.insert(lns, 1, ln);
          end;
        end;
        table.remove(t, ind);
        ind = #t;
        txt = table.concat(t);
        w = minBgW + getTextWidth(size, txt);
      end;
	  --VehicleSort:dp(veh, 'drawList', 'Before check getIsControlled');
      bold = veh:getIsControlled() and (not g_currentMission.missionDynamicInfo.isMultiplayer or veh:getControllerName() == g_gameSettings.nickname);
      if string.len(txt) > 0 then
        table.insert(texts, {xPos, yPos, size, bold, clr, txt});
        yPos = yPos - size - VehicleSort.tPos.spacing;
        VehicleSort.bgW = math.max(VehicleSort.bgW, minBgW + getTextWidth(size, txt) + VehicleSort.tPos.padSides);
      end;
      VehicleSort.bgW = math.max(VehicleSort.bgW, w + VehicleSort.tPos.padSides);
      if #lns > 0 then -- add any wrapped lines to the text table
        for k, v in ipairs(lns) do
          if string.len(v) > 0 then
            local x = xPos + VehicleSort.tPos.spacing;
            table.insert(texts, {x, yPos, size, bold, clr, v});
            yPos = yPos - size - VehicleSort.tPos.spacing;
            VehicleSort.bgW = math.max(VehicleSort.bgW, minBgW + getTextWidth(size, v) + VehicleSort.tPos.padSides);
          end;
        end;
      end;
      bgPos = math.min(bgPos, yPos);
    end;
    if yPos < minY then -- getting near bottom of screen, start a new column
      yPos = VehicleSort.tPos.y;
      xPos = xPos + VehicleSort.bgW - minBgW;
      addCol = true;
    end;
  end;
  setTextBold(false);
  bgPos = bgPos - VehicleSort.tPos.spacing; -- bottom padding
  VehicleSort.bgY = bgPos;
  VehicleSort.bgH = (y - bgPos) + size + VehicleSort.tPos.sizeIncr + VehicleSort.tPos.yOffset + VehicleSort.tPos.spacing;
  if VehicleSort.bgY ~= nil and VehicleSort.bgW ~=nil and VehicleSort.bgH ~= nil then
    VehicleSort:renderBg(VehicleSort.bgY, VehicleSort.bgW, VehicleSort.bgH);
  end;
  for k, v in ipairs(texts) do
    --setTextBold(v[4]);
    setTextColor(unpack(v[5]));
    renderText(v[1], v[2], v[3], tostring(v[6])); -- x, y, size, txt
    if VehicleSort.debug and v[5] == VehicleSort.tColor.selected then
      VehicleSort.dbgY = VehicleSort.dbgY - VehicleSort.tPos.size - VehicleSort.tPos.spacing;
      renderText(VehicleSort.dbgX, VehicleSort.dbgY, VehicleSort.tPos.size, string.format('selected textWidth [%f] colWidth [%f]', getTextWidth(v[3], v[6]), VehicleSort.tPos.columnWidth));
    end;
  end;
  setTextBold(false);
  setTextColor(unpack(VehicleSort.tColor.standard));
end

function VehicleSort:getVehicles()
	local allveh = g_currentMission.vehicles
	local veh = {}
	
	for k, v in ipairs(allveh) do
		if v.spec_vehicleSort ~= nil then
			table.insert(veh, v);
		end;
	end;
	return veh;
end

function VehicleSort:getAttachment(obj, i)
  local val = '';
  if VehicleSort.config[3][2] then
    val = val .. string.format('%s ', obj:getFullName());
  else
	val = val .. string.format('%s ', obj:getName());
  end;
  
  return val;
end

function VehicleSort:getFillDisplay(obj)
  local ret = '';
  if VehicleSort.config[6][2] then -- Fill-Level-Display active?
    --local f, c = VehicleSort:calcFillLevel(obj);
    --if VehicleSort.config[8][2] or f > 0 then -- Empty should be shown or is not empty
    --  if c > 0 then -- Capacity more than zero
    --    if VehicleSort.config[7][2] then -- Display as percentage
    --      ret = string.format(' (%d%%)', VehicleSort:calcPercentage(f, c));
    --    else -- Display as amount of total capacity
    --      ret = string.format(' (%d/%d)', math.floor(f), c);
    --    end;
    --  end;
    --end;
	if obj.spec_fillUnit ~= nil then
		--ret = string.format(' (%d))', obj.getFillUnitFillLevelPercentage());
	end
  end;
  return ret;
end

function VehicleSort:getFullVehicleName(index)
  --VehicleSort:dp(index, 'getFullVehicleName', 'index');
  local VehList = VehicleSort:getVehicles();
  if index > #VehList then
    return nil;
  end;
  local nam = '';
  local ret = {};
  local fmt = '(%s) ';
  local veh = VehList[index];
  local con = veh.controllerName;
  
  --VehicleSort:dp(veh, 'getFullVehicleName', 'Variable veh');
  
  if not veh:getIsTabbable() then
    nam = '[P] '; -- Prefix for parked (not part of tab list) vehicles
  end;
  if veh.isHired then -- credit: Vehicle Groups Switcher mod
    nam = nam .. string.format(fmt, g_i18n.modEnvironments[VehicleSort.ModName].texts.hired);
  elseif (veh.getIsCourseplayDriving ~= nil and veh:getIsCourseplayDriving()) then -- CoursePlay mod
    nam = nam .. string.format(fmt, g_i18n.modEnvironments[VehicleSort.ModName].texts.courseplay);
  elseif (veh.modFM ~= nil and veh.modFM.FollowVehicleObj ~= nil) then
    nam = nam .. string.format(fmt, g_i18n.modEnvironments[VehicleSort.ModName].texts.followme);
  elseif veh.isControlled then
    if VehicleSort.config[5][2] and con ~= nil and con ~= 'Unknown' and con ~= '' then
      nam = nam .. string.format(fmt, con);
    end;
  end;

	if veh.spec_vehicleSort ~= nil then
		  if VehicleSort:isTrain(veh) then
			veh.spec_vehicleSort.name = g_i18n.modEnvironments[VehicleSort.ModName].texts.vs_train;
		  elseif VehicleSort:isCrane(veh) then
			veh.spec_vehicleSort.name = g_i18n.modEnvironments[VehicleSort.ModName].texts.vs_crane;
		  elseif VehicleSort.config[3][2] then -- Show brand
			nam = nam .. string.format('%s ', veh.spec_vehicleSort.brand);
		  else
		  --VehicleSort:dp(veh.spec_vehicleSort, 'getFullVehicleName', 'Table spec_vehicleSort');
		  nam = nam .. string.format('%s ', veh.spec_vehicleSort.name);
		  end;
	else
		nam = "TEST Unknown";
	end
		  
	-- Calculate PS
	if veh.spec_motorized ~= nil then
		local maxMotorTorque = veh.spec_motorized.motor.peakMotorTorque;
		local maxRpm = veh.spec_motorized.motor.maxRpm;
		local sPower = math.ceil(maxMotorTorque / 0.0044);
		
		if sPower ~= nil then
			nam = nam .. " (" .. sPower .. " PS) "
		end;
	end;
  
  if VehicleSort.config[4][2] then -- Show type
    if veh.typeDesc ~= nil then
      nam = nam .. string.format('[%s] ', veh.typeDesc);
    end;
  end;
  table.insert(ret, nam .. VehicleSort:getFillDisplay(veh));
  if not VehicleSort:isTrain(veh) and not VehicleSort:isCrane(veh) then
    local implements = veh:getAttachedImplements();
	local imp = implements[1];
	--VehicleSort:dp(imp, 'VehicleSort:getFullVehicleName', 'getAttachedImplements');
    if (imp ~= nil and imp.object ~= nil) then
      table.insert(ret, string.format('%s %s%s ', g_i18n.modEnvironments[VehicleSort.ModName].texts.with, VehicleSort:getAttachment(imp.object, 1), VehicleSort:getFillDisplay(imp.object)));
      imp = implements[2];
      if (imp ~= nil and imp.object ~= nil) then -- second attachment
        table.insert(ret, string.format('& %s%s ', VehicleSort:getAttachment(imp.object, 2), VehicleSort:getFillDisplay(imp.object)));
      end;
    end;
  end;
  return ret;
end

function VehicleSort:getName(obj, sFallback)
	nam = obj:getName();
	if nam == nil then
		nam = obj.typeName;
	end	
	if nam == nil or nam == '' then
		return sFallback;
	else
		return nam;
	end;
end

function VehicleSort:getNameBrand(obj)
	--return Utils.getNoNil(getXMLString(obj.xmlFile, 'vehicle.storeData.brand'), 'LIZARD');
	return obj:getFullName();
end

function VehicleSort:getOrder(saved)
  if g_dedicatedServerInfo ~= nil then -- dedicated server does not need to track user order
    return;
  end;
  local ordered = {};
  for k, v in ipairs(saved) do -- check saved vehicles and filter out any which no longer exist
    for sk, sv in ipairs(VehicleSort:getVehicles()) do
      if sv.spec_vehicleSort.id == v.id and not sv.isDeleted and (VehicleSort.resetID == 0 or (VehicleSort.resetID > 0 and VehicleSort.resetNewSteerableID == sv.id)) then
        sv:setIsTabbable(not v.isParked);
        table.insert(ordered, sv);
        VehicleSort:dp(string.format('Saved vehicle matched to existing vehicle id [%d], vsid [%d]', sv.id, v.id), 'VehicleSort:getOrder');
        break;
      end;
    end;
  end;
  local unsaved = {};
  for sk, sv in ipairs(VehicleSort:getVehicles()) do -- check vehicles for any not already saved
    local found = false;
    for k, v in ipairs(ordered) do
      if sv.spec_vehicleSort.id == v.spec_vehicleSort.id and not sv.isDeleted then
        found = true;
        break;
      end;
    end;
    if not found then
	table.insert(unsaved, sv);
    --VehicleSort:dp(string.format('Adding unsaved id [%d], vsid [%s]', sv.id, tostring(sv.spec_vehicleSort.id)), 'VehicleSort:getOrder'); --sv.spec_vehicleSort.id may be nil on client, but will get value from readStream
      
    end;
  end;
  for k, v in ipairs(unsaved) do
    table.insert(ordered, v);-- append unsaved vehicles
  end;
  if #ordered == VehicleSort:getVehicles() then
    --g_currentMission.vehicles = ordered;-- force steerables order and parked status to match saved
  else
    VehicleSort:dp(string.format('Number of steerables [%d] does not match number of ordered [%d], not setting steerables to ordered list.', #VehicleSort:getVehicles(), #ordered), 'VehicleSort:getOrder');
  end;
  local ret = {};
  for k, v in ipairs(ordered) do -- generate user order
    local t = {};
    t.id = v.id;
    t.isParked = not v:getIsTabbable();
    table.insert(ret, t);
    VehicleSort:dp(string.format('User order id [%d] isParked [%s]', t.id, tostring(t.isParked)), 'VehicleSort:getOrder');
  end;
  VehicleSort.saved = false;
  return ret;
end

function VehicleSort:getTextColor(ind, veh)
	--VehicleSort:dp(veh, 'getTextColor');
  if ind == VehicleSort.selectedIndex then
    if VehicleSort.selectedLock then
      return VehicleSort.tColor.locked;
    else
      return VehicleSort.tColor.selected;
    end;
  elseif not veh:getIsTabbable() then
    return VehicleSort.tColor.isParked;
  elseif veh.isControlled then
	return VehicleSort.tColor.self
  elseif veh.isHired then
	return VehicleSort.tColor.hired
  elseif (veh.modFM ~= nil and veh.modFM.FollowVehicleObj ~= nil) then
	return VehicleSort.tColor.followme
  else
    return VehicleSort.tColor.standard;
  end;
end

function VehicleSort:getTextSize()
  local val = tonumber(VehicleSort.config[9][2]);
  if val == nil or val < 1 or val > 3 then
    val = 2;
  end;
  if val == 1 then
    return VehicleSort.tPos.sizeSmall;
  elseif val == 3 then
    return VehicleSort.tPos.sizeBig;
  else
    VehicleSort.config[9][2] = 2;
    return VehicleSort.tPos.size;
  end;
end

function VehicleSort:getTrans(obj, val, key) -- some mods have xml that is formatted differently, so this function attempts to compensate 
  if val:sub(1, 6) == '$l10n_' then
    local str = val:sub(7);
    if g_i18n:hasText(str) then
      VehicleSort:dp(string.format('Found l10n value for [%s] via g_i18n', str), 'VehicleSort:getTrans');
      return g_i18n:getText(str);
    else
      str = Utils.getXMLI18N(obj.xmlFile, key, '', '', obj.customEnvironment, true); --TODO determine last param
      if str ~= nil and str ~= '' then
        VehicleSort:dp(string.format('Found translated value for xml path [%s] via getXMLI18N: [%s]', key, str), 'VehicleSort:getTrans');
        return str;
      end;
    end;
  end;
  return val;
end

function VehicleSort:getUniqueId(id)
  if id ~= nil then
    id = tonumber(id);
  else
    VehicleSort:dp('id was nil, setting to initial new id state of 1', 'VehicleSort:getUniqueId');
    id = 1;
  end;
  if id < 1 then
    VehicleSort:dp(string.format('id < 1: [%d], setting to 1', id), 'VehicleSort:getUniqueId');
    id = 1;
  end;
  if VehicleSort.ids == nil then
    VehicleSort.ids = {};
  end;
  while true do
    if VehicleSort:hasVal(VehicleSort.ids, id) then
      id = VehicleSort.nextId;
      VehicleSort.nextId = VehicleSort.nextId + 1;
    else
      table.insert(VehicleSort.ids, id);
      break;
    end;
  end;
  return tonumber(id);
end

function VehicleSort:hasVal(tbl, val)
  for k, v in pairs(tbl) do
    if v == val then
      return true;
    end;
  end;
  return false;
end

function VehicleSort:init()
  VehicleSort:dp('Start Init', 'VehicleSort:init');
  if g_dedicatedServerInfo ~= nil then -- Dedicated server does not need the initialization process
    VehicleSort:dp('Skipping undesired initialization on dedicated server.', 'VehicleSort:init');
    return;
  end;
  VehicleSort.dbgX = 0.01;
  VehicleSort.dbgY = 0.5;
  VehicleSort.tPos = {};
  -- g_currentMission.inGameMenu.hud
  VehicleSort.tPos.x = g_currentMission.inGameMenu.hud.topNotification.origX;  -- x Position of Textfield, originally hardcoded 0.3
  --VehicleSort.tPos.x = 0.3;
  VehicleSort.tPos.y = g_currentMission.inGameMenu.hud.topNotification.origY;  -- y Position of Textfield, originally hardcoded 0.9
  --VehicleSort.tPos.y = 0.9;
  VehicleSort.tPos.yOffset = g_currentMission.inGameMenu.hud.topNotification.titleOffsetY;  --* 1.5; -- y Position offset for headings, originally hardcoded 0.007
  --VehicleSort.tPos.yOffset = 0.007;
  VehicleSort.tPos.size = g_currentMission.inGameMenu.hud.topNotification.infoTextSize;  -- TextSize, originally hardcoded 0.018
  --VehicleSort.tPos.size = 0.018;
  VehicleSort.tPos.sizeBig = g_currentMission.inGameMenu.hud.topNotification.titleTextSize;
  --VehicleSort.tPos.sizeBig = 0.020;
  VehicleSort.tPos.sizeSmall = g_currentMission.inGameMenu.hud.gameInfoDisplay.timeScaleTextSize; -- smallest default hud text size
  --VehicleSort.tPos.sizeSmall = 0.010;
  VehicleSort.tPos.sizeIncr = g_currentMission.inGameMenu.hud.speedMeter.cruiseControlTextOffsetY; -- Text size increase for headings
  --VehicleSort.tPos.sizeIncr = 0.005;
  VehicleSort.tPos.spacing = g_currentMission.inGameMenu.hud.speedMeter.cruiseControlTextOffsetY;  -- Spacing between lines, originally hardcoded 0.005
  --VehicleSort.tPos.spacing = 0.005;
  VehicleSort.tPos.padHeight = 2 * VehicleSort.tPos.spacing;
  VehicleSort.tPos.padSides = VehicleSort.tPos.padHeight;
  VehicleSort.tPos.columnWidth = (((1 - VehicleSort.tPos.x) / 2) - VehicleSort.tPos.padSides);
  VehicleSort.tPos.alignment = RenderText.ALIGN_LEFT;  -- Text Alignment

  if g_seasons ~= nil then
    VehicleSort:dp('Seasons mod detected. Lowering VehicleSort display to below the seasons weather display to avoid overlap', 'VehicleSort:init');
    VehicleSort.tPos.y = VehicleSort.tPos.y - (6 * VehicleSort.tPos.size) - (6 * VehicleSort.tPos.spacing);
  end;
  VehicleSort:dp(VehicleSort.tPos, 'VehicleSort:init', 'tPos');
  VehicleSort.userPath = getUserProfileAppPath();
  VehicleSort.saveBasePath = VehicleSort.userPath .. 'vehicleSort/';
  if g_currentMission.missionDynamicInfo.serverAddress ~= nil then --multi-player game and player is not the host (dedi already handled above)
    VehicleSort.savePath = VehicleSort.saveBasePath .. g_currentMission.missionDynamicInfo.serverAddress .. '/';
  else
    VehicleSort.savePath = VehicleSort.saveBasePath .. 'savegame' .. g_careerScreen.selectedIndex .. '/';
  end;
  createFolder(VehicleSort.saveBasePath);
  createFolder(VehicleSort.savePath);
  VehicleSort.xmlFilename = VehicleSort.savePath .. 'v_order.xml';
  VehicleSort:loadVehicleOrder();
  VehicleSort.bg = createImageOverlay('dataS2/menu/blank.png'); --credit: Decker_MMIV, VehicleGroupsSwitcher mod
  VehicleSort.bgX = VehicleSort.tPos.x - VehicleSort.tPos.spacing;
  VehicleSort.maxTxtW = VehicleSort.tPos.columnWidth - VehicleSort.tPos.padSides;
  VehicleSort:dp(string.format('Initialized userPath [%s] saveBasePath [%s] savePath [%s]',
    tostring(VehicleSort.userPath),
    tostring(VehicleSort.saveBasePath),
    tostring(VehicleSort.savePath)), 'VehicleSort:init');
end

function VehicleSort:isCrane(veh)
  return veh.stationCraneId ~= nil;
end

function VehicleSort:isHidden(veh)
  return (VehicleSort:isTrain(veh) and not VehicleSort.config[1][2]) or (VehicleSort:isCrane(veh) and not VehicleSort.config[2][2]);
end

function VehicleSort:isTrain(veh)
  return veh.motorType ~= nil and veh.motorType == 'locomotive';
end

function VehicleSort:keyEvent(unicode, sym, modifier, isDown)	
end

function VehicleSort:loadMap(name)
  VehicleSort:reset();
end

function VehicleSort:loadVehicleOrder()
  if g_dedicatedServerInfo ~= nil then -- Dedicated server does not need to load user order
    VehicleSort:dp('Skipping undesired load from user xml file on dedicated server.', 'VehicleSort:loadVehicleOrder');
    return;
  end;
  local xml = 'VehicleSort.loadFile';
  
  if fileExists(VehicleSort.xmlFilename) then
    VehicleSort.saveFile = loadXMLFile(xml, VehicleSort.xmlFilename);
  else
    VehicleSort.saveFile = createXMLFile(xml, VehicleSort.xmlFilename, VehicleSort.key);
  end;
  local saved = {};
  
  if hasXMLProperty(VehicleSort.saveFile, VehicleSort.key) then
    VehicleSort:dp(string.format('Found key [%s]', VehicleSort.key), 'VehicleSort:loadVehicleOrder');
    local newMap = false;
    local mapKey = VehicleSort.key .. VehicleSort.xmlAttrMapId;
    if hasXMLProperty(VehicleSort.saveFile, mapKey) then
      if getXMLString(VehicleSort.saveFile, mapKey) ~= g_currentMission.missionInfo.mapId then
        newMap = true;
      end;
    end;
	
    if not newMap then
      local i = 1;
      while true do
        local k = string.format('%s.vehicle%d', VehicleSort.key, i);
        if not hasXMLProperty(VehicleSort.saveFile, k) then
          break;
        end;
        local t = {};
        t.id = getXMLInt(VehicleSort.saveFile, k .. VehicleSort.xmlAttrId);
        t.isParked = getXMLBool(VehicleSort.saveFile, k .. VehicleSort.xmlAttrParked);
        saved[i] = t;
        VehicleSort:dp(string.format('Loaded saved vehicle key [%s] vsid [%s] isParked [%s]', k, t.id, tostring(t.isParked)), 'VehicleSort:loadVehicleOrder');
        i = i + 1;
      end;
    end;
  end;

  VehicleSort.userOrder = VehicleSort:getOrder(saved);
  if hasXMLProperty(VehicleSort.saveFile, VehicleSort.keyCon) then

    VehicleSort:dp('Config file found.', 'VehicleSort:loadVehicleOrder');
    for i = 1, #VehicleSort.config do
      if i == 9 then
        local int = getXMLString(VehicleSort.saveFile, VehicleSort.keyCon .. '#' .. VehicleSort.config[i][1]); --a dev version had this as boolean, but then changed to int
        if tonumber(int) == nil or tonumber(int) <= 0 or tonumber(int) > 3 then
          int = VehicleSort.txtSizeDef;
        else
          int = math.floor(tonumber(int));
        end;
        VehicleSort.config[i][2] = int;
        VehicleSort:dp(string.format('txtSize value set to [%d]', int), 'VehicleSort:loadVehicleOrder');
      elseif i == 10 then
        local flt = getXMLString(VehicleSort.saveFile, VehicleSort.keyCon .. '#' .. VehicleSort.config[i][1]); --a dev version had this as boolean, but then changed to float
        if tonumber(flt) == nil or tonumber(flt) <= 0 or tonumber(flt) > 1 then
          flt = VehicleSort.bgTransDef;
        else
          flt = tonumber(string.format('%.1f', tonumber(flt)));
        end;
        VehicleSort.config[i][2] = flt;
        VehicleSort:dp(string.format('bgTrans value set to [%f]', flt), 'VehicleSort:loadVehicleOrder');
      else
        local b = getXMLBool(VehicleSort.saveFile, VehicleSort.keyCon .. '#' .. VehicleSort.config[i][1]);
        if b ~= nil then
          VehicleSort.config[i][2] = b;
        end;
      end;
    end;
  end;
end

function VehicleSort:mouseEvent(posX, posY, isDown, isUp, button)
end

function VehicleSort:moveDown(moveSpeed)
  if moveSpeed == nil then
	moveSpeed = 1;
  end;
  local oldIndex = VehicleSort.selectedIndex;
  VehicleSort.selectedIndex = VehicleSort.selectedIndex  + moveSpeed;
  if VehicleSort.selectedIndex > #VehicleSort:getVehicles() then
    VehicleSort.selectedIndex = 1;
  end;
  if VehicleSort:isHidden(g_currentMission.vehicles[VehicleSort.selectedIndex]) then
    VehicleSort:moveDown();
  end;
  if VehicleSort.selectedLock then
    VehicleSort:reSort(oldIndex, VehicleSort.selectedIndex);
  end;
end

function VehicleSort:moveUp(moveSpeed)
  if moveSpeed == nil then
	moveSpeed = 1;
  end;
  local oldIndex = VehicleSort.selectedIndex;
  VehicleSort.selectedIndex = VehicleSort.selectedIndex - moveSpeed;
  if VehicleSort.selectedIndex < 1 then
    VehicleSort.selectedIndex = #VehicleSort:getVehicles();
  end;
  if VehicleSort:isHidden(g_currentMission.vehicles[VehicleSort.selectedIndex]) then
    VehicleSort:moveUp();
  end;
  if VehicleSort.selectedLock then
    VehicleSort:reSort(oldIndex, VehicleSort.selectedIndex);
  end;
end

function VehicleSort:moveConfigDown()
	VehicleSort.selectedConfigIndex = VehicleSort.selectedConfigIndex + 1;
	if VehicleSort.selectedConfigIndex > #VehicleSort.config then
		VehicleSort.selectedConfigIndex = 1;
	end;
end

function VehicleSort:moveConfigUp()
	VehicleSort.selectedConfigIndex = VehicleSort.selectedConfigIndex - 1;
	if VehicleSort.selectedConfigIndex <= 0 then
		VehicleSort.selectedConfigIndex = #VehicleSort.config;
	end;
end

function VehicleSort:renderBg(y, w, h)
  setOverlayColor(VehicleSort.bg, 0, 0, 0, VehicleSort.config[10][2]);
  renderOverlay(VehicleSort.bg, VehicleSort.bgX, y, w, h); -- dark background
end

function VehicleSort:reset()
  VehicleSort.ids = {};
  VehicleSort.isInitialized = false;
  VehicleSort.nextId = 1;
  VehicleSort.resetID = 0;
  VehicleSort.userOrder = {};
end

function VehicleSort:resetFinish() --a reset took place, so revert the flags and align the new tab order with the user order
  VehicleSort:dp('Finishing reset vehicle sequence; setting resetID to 0 and setting userOrder to move reset vehicle tab order back to user order', 'VehicleSort:resetFinish');
  VehicleSort.resetAddHasRun = false;
  VehicleSort.resetRemHasRun = false;
  VehicleSort.resetID = 0;
  VehicleSort.resetNewSteerableID = 0;
  if g_dedicatedServerInfo == nil then
    VehicleSort.userOrder = VehicleSort:getOrder(VehicleSort.userOrder);
  end;
end

function VehicleSort:reSort(old, new)
  local v = g_currentMission.vehicles[old];
  local u = VehicleSort.userOrder[old];
  table.remove(g_currentMission.vehicles, old);
  table.remove(VehicleSort.userOrder, old);
  table.insert(g_currentMission.vehicles, new, v);
  table.insert(VehicleSort.userOrder, new, u);
  VehicleSort.saved = false;
end

function VehicleSort:saveVehicleOrder()
  if VehicleSort.saved then
    return;
  end;
  
  --Hans
--  if fileExists(VehicleSort.xmlFilename) then
--	local tmpFile = createXMLFile("tmpFile", VehicleSort.savePath .. "v_order.backup.xml", VehicleSort.key);
--	  setXMLString(tmpFile, VehicleSort.key .. VehicleSort.xmlAttrMapId, g_currentMission.missionInfo.mapId);
--	  for i = 1, #VehicleSort.config do
--		if i == 9 then
--		  setXMLString(tmpFile, VehicleSort.keyCon .. '#' .. VehicleSort.config[i][1], tostring(VehicleSort.config[i][2]));
--		elseif i == 10 then
--		  setXMLString(tmpFile, VehicleSort.keyCon .. '#' .. VehicleSort.config[i][1], string.format('%.1f', VehicleSort.config[i][2]));
--		else
--		  setXMLBool(tmpFile, VehicleSort.keyCon .. '#' .. VehicleSort.config[i][1], VehicleSort.config[i][2]);
--		end;
--	  end;
--	    for k, v in ipairs(VehicleSort.userOrder) do
--			setXMLInt(tmpFile, VehicleSort.keyVeh .. k .. VehicleSort.xmlAttrId, v.id);
--			setXMLBool(tmpFile, VehicleSort.keyVeh .. k .. VehicleSort.xmlAttrParked, v.isParked);
--		end;
--	saveXMLFile(tmpFile);
--  end;  
  
  VehicleSort.saveFile = createXMLFile('VehicleSort.saveFile', VehicleSort.xmlFilename, VehicleSort.key);
  setXMLString(VehicleSort.saveFile, VehicleSort.key .. VehicleSort.xmlAttrMapId, g_currentMission.missionInfo.mapId);
  for i = 1, #VehicleSort.config do
    if i == 9 then
      setXMLString(VehicleSort.saveFile, VehicleSort.keyCon .. '#' .. VehicleSort.config[i][1], tostring(VehicleSort.config[i][2]));
    elseif i == 10 then
      setXMLString(VehicleSort.saveFile, VehicleSort.keyCon .. '#' .. VehicleSort.config[i][1], string.format('%.1f', VehicleSort.config[i][2]));
    else
      setXMLBool(VehicleSort.saveFile, VehicleSort.keyCon .. '#' .. VehicleSort.config[i][1], VehicleSort.config[i][2]);
    end;
  end;
  for k, v in ipairs(VehicleSort.userOrder) do
	--Hans
	if k ~= nil and v.id ~= nil then
		VehicleSort:dp(string.format('Saving vehicle index [%d], vsid [%d], parked [%s]', k, v.id, tostring(v.isParked)), 'VehicleSort:saveVehicleOrder');
		setXMLInt(VehicleSort.saveFile, VehicleSort.keyVeh .. k .. VehicleSort.xmlAttrId, v.id);
		setXMLBool(VehicleSort.saveFile, VehicleSort.keyVeh .. k .. VehicleSort.xmlAttrParked, v.isParked);
	end;
  end;
  saveXMLFile(VehicleSort.saveFile);
  VehicleSort.saved = true;
  print("VehicleSort saved your custom order");
end

function VehicleSort:toggleParkState(index)
  local parked = not g_currentMission.vehicles[index]:getIsTabbable();
  if parked then
    g_currentMission.vehicles[index]:setIsTabbable(true);
    VehicleSort.userOrder[index].isParked = false;
  else
    g_currentMission.vehicles[index]:setIsTabbable(false);
    VehicleSort.userOrder[index].isParked = true;
  end;
  VehicleSort:dp(VehicleSort.userOrder[index].isParked, 'VehicleSort:toggleParkState');
  VehicleSort.saved = false;
end

--
-- Functions which extend existing default game functions
--

function VehicleSort.addVehicle(self, obj)
  if not obj.isSteerable then
    return;
  end;
  local exists = false;
  if g_dedicatedServerInfo == nil then
    for k, v in ipairs(VehicleSort.userOrder) do
      if v.id == obj.spec_vehicleSort.id then
        exists = true;
        if VehicleSort.resetID > 0 then
          VehicleSort:dp(string.format('Reset vehicle id [%d] exists', v.id), 'VehicleSort.addVehicle');
        end;
        break;
      end;
    end;
  end;
  if VehicleSort.resetID < 1 or (g_dedicatedServerInfo == nil and not exists) then
    local t = {};
    t.id = obj.spec_vehicleSort.id;
    t.isParked = not obj:getIsTabbable();
    table.insert(VehicleSort.userOrder, t);
    VehicleSort.saved = false;
    VehicleSort:dp(string.format('Steerable vehicle id [%d], vsid [%s] added.', obj.id, tostring(obj.spec_vehicleSort.id)), 'VehicleSort.addVehicle'); -- obj.spec_vehicleSort.id may be nil on MP connected client, but will get value from readStream
  else
    VehicleSort:dp(string.format('Not adding reset vehicle vsid [%d] VehicleSort.resetNewSteerableID [%d]', VehicleSort.resetID, VehicleSort.resetNewSteerableID), 'VehicleSort.addVehicle');
    if VehicleSort.resetRemHasRun then
		VehicleSort:resetFinish();
    else
		VehicleSort.resetAddHasRun = true;
    end;
  end;
end
FSBaseMission.addVehicle = Utils.appendedFunction(FSBaseMission.addVehicle, VehicleSort.addVehicle);

function VehicleSort.getSaveAttributesAndNodes(self, superFunc, nodeIdent)
  local attributes, nodes = superFunc();
  if self.spec_vehicleSort.id ~= nil then
    attributes = attributes .. string.format(' vsid="%d"', self.spec_vehicleSort.id);
    VehicleSort:dp(string.format('Saving attributes [%s]', attributes), 'VehicleSort.getSaveAttributesAndNodes');
  end;
  return attributes, nodes;
end
if g_server ~= nil then -- function only needed by the server, to save persistent IDs to the savegame file
  --Steerable.getSaveAttributesAndNodes = Utils.overwrittenFunction(Steerable.getSaveAttributesAndNodes, VehicleSort.getSaveAttributesAndNodes);
end;

function VehicleSort.loadAttachable(self, savegame)
  if self.spec_vehicleSort == nil then
    self.spec_vehicleSort = {};
  end;
  --self.spec_vehicleSort.brand = VehicleSort:getNameBrand(self);
  self.spec_vehicleSort.name = VehicleSort:getName(self, 'Attachable');
  VehicleSort:dp(string.format('Loaded attachable name [%s], brand [%s]', tostring(self.spec_vehicleSort.name), tostring(self.spec_vehicleSort.brand)), 'VehicleSort.loadAttachable');
end
if g_dedicatedServerInfo == nil then -- function only needed by players, as attachable objects do not need to be tracked by dedicated server
  --Attachable.postLoad = Utils.appendedFunction(Attachable.postLoad, VehicleSort.loadAttachable);
end;

function VehicleSort.loadSteerable(self, savegame)
  if self.spec_vehicleSort == nil then
    self.spec_vehicleSort = {};
  end;
  if g_dedicatedServerInfo == nil then
    if self.spec_vehicleSort.brand == nil then
      self.spec_vehicleSort.brand = VehicleSort:getNameBrand(self);
    end;
    if self.spec_vehicleSort.name == nil then
      self.spec_vehicleSort.name = VehicleSort:getName(self, 'Steerable');
    end;
  end;
  local dbg = 'Loaded steerable';
  if self.spec_vehicleSort.id == nil then
    if VehicleSort.resetID > 0 then
      self.spec_vehicleSort.id = VehicleSort.resetID;
      dbg = 'Processing reset of steerable to new';
      VehicleSort.resetNewSteerableID = self.id;
      if g_dedicatedServerInfo == nil then
        for k, v in ipairs(VehicleSort.userOrder) do
          if self.spec_vehicleSort.id == v.id then
            self:setIsTabbable(v.isParked);
            break;
          end;
        end;
      end;
    elseif g_currentMission:getIsServer() then -- MP client will get self.spec_vehicleSort.id from readStream
      if savegame == nil then -- newly acquired vehicle
        self.spec_vehicleSort.id = VehicleSort:getUniqueId(VehicleSort.nextId);
        dbg = 'Newly acquired vehicle';
      else -- existing vehicle
        local key = savegame.key .. VehicleSort.xmlAttrId;
        VehicleSort:dp(key, 'VehicleSort.loadSteerable', 'saved vehicle XML key');
        local id = getXMLInt(savegame.xmlFile, key);
        if not VehicleSort.isInitialized then
          dbg = 'Initial load of saved steerable';
          self.spec_vehicleSort.id = VehicleSort:getUniqueId(id);
        end;
      end;
    end;
  end;
  VehicleSort:dp(string.format('%s id [%d], vsid [%s], name [%s], brand [%s]', dbg, self.id, tostring(self.spec_vehicleSort.id), tostring(self.spec_vehicleSort.name), tostring(self.spec_vehicleSort.brand)), 'VehicleSort.loadSteerable');
end
--Steerable.postLoad  = Utils.appendedFunction(Steerable.postLoad, VehicleSort.loadSteerable);

function VehicleSort.readStream(self, streamId, connection)
  self.spec_vehicleSort.id = streamReadUInt16(streamId);
  VehicleSort:dp(string.format('Read self.spec_vehicleSort.id [%d]', self.spec_vehicleSort.id), 'VehicleSort.readStream');
end
--Steerable.readStream = Utils.appendedFunction(Steerable.readStream, VehicleSort.readStream);

function VehicleSort.removeVehicle(self, obj)
  if not obj.isSteerable then
    return;
  end;
  if VehicleSort.resetID < 1 then
    if g_dedicatedServerInfo ~= nil then
      return;
    end;										
    local ind = 0;
    local id = 0;
    local vsid = 0;
    for k, v in ipairs(VehicleSort.userOrder) do
      if v.id == obj.spec_vehicleSort.id then
        ind = k;
        id = obj.id;
        vsid = obj.spec_vehicleSort.id;
        break;
      end;
    end;
    if ind > 0 then
	  if VehicleSort.debug then
		VehicleSort:dp(string.format('Removing vehicle id [%d] vsid [%d] from VehicleSort.userOrder', id, vsid), 'VehicleSort.removeVehicle');
	  end;      
      table.remove(VehicleSort.userOrder, ind);
      VehicleSort.saved = false;
    else
      VehicleSort:dp('Error: Expected values for sold vehicle were not found.', 'VehicleSort.removeVehicle');
    end;
  else
    VehicleSort:dp(string.format('Not removing reset vehicle vsid [%d] from VehicleSort.userOrder', VehicleSort.resetID), 'VehicleSort.removeVehicle');
    if VehicleSort.resetAddHasRun then
      VehicleSort:resetFinish();
    else
      VehicleSort.resetRemHasRun = true;
    end;
  end;
end
FSBaseMission.removeVehicle = Utils.appendedFunction(FSBaseMission.removeVehicle, VehicleSort.removeVehicle);

function VehicleSort.resetRun(self, superFunc, connection)
  if self.vehicle ~= nil and self.vehicle.isSteerable then
    VehicleSort:dp(string.format('Steerable id [%d] vsid [%d] reset request', self.vehicle.id, self.vehicle.spec_vehicleSort.id), 'VehicleSort.resetRun');
    VehicleSort.resetID = self.vehicle.spec_vehicleSort.id;
    VehicleSort_Event:sendEvent(VehicleSort.resetID);
  end;
  return superFunc(self, connection);
end
if g_server ~= nil then -- function only needed by the server
  ResetVehicleEvent.run = Utils.overwrittenFunction(ResetVehicleEvent.run, VehicleSort.resetRun);
end;

function VehicleSort.setToolById(self, superFunc, toolId, noEventSend) --credit: Xentro, GameExtension
  if not VehicleSort.showSteerables and not VehicleSort.showConfig then
    superFunc(self, toolId, noEventSend);
  else
    superFunc(self, 0, true); --do not switch to chainsaws while VehicleSort is displayed
  end;
end;
if g_dedicatedServerInfo == nil then -- function only needed by players, as this relates to choosing chainsaws while VehicleSort is displayed
  Player.setToolById = Utils.overwrittenFunction(Player.setToolById, VehicleSort.setToolById);
end;

function VehicleSort.writeStream(self, streamId, connection)
  VehicleSort:dp(string.format('Writing self.spec_vehicleSort.id [%d]', self.spec_vehicleSort.id), 'VehicleSort.writeStream');
  streamWriteUInt16(streamId, self.spec_vehicleSort.id);
end
--Steerable.writeStream = Utils.appendedFunction(Steerable.writeStream, VehicleSort.writeStream);

function VehicleSort.zoomSmoothly(self, superFunc, offset)
  if not VehicleSort.showConfig and not VehicleSort.showSteerables then -- don't zoom camera when mouse wheel is used to scroll displayed list
    superFunc(self, offset);
  end;
end
if g_dedicatedServerInfo == nil then -- function only needed by players, as this relates to camera zooming while scrolling through vehicle list with mouse wheel
  VehicleCamera.zoomSmoothly = Utils.overwrittenFunction(VehicleCamera.zoomSmoothly, VehicleSort.zoomSmoothly);
end;

--
-- VehicleSort_Event: For notifying connected multi-player players of the persistent id of a reset steerable vehicle,
--                    so that VehicleSort can undo the change to the tab order by the game vehicle reset function, keeping
--                    reset vehicles tab order aligned with each player's set user order
--

VehicleSort_Event = {};
VehicleSort_Event_mt = Class(VehicleSort_Event, Event);
InitEventClass(VehicleSort_Event, 'VehicleSort_Event');

function VehicleSort_Event:emptyNew()
  local self = Event:new(VehicleSort_Event_mt);
  self.className = 'VehicleSort_Event';
  return self;
end;

function VehicleSort_Event:new(id)
  VehicleSort:dp(string.format('Reset ID [%d]', id), 'VehicleSort_Event:new');
  local self = VehicleSort_Event:emptyNew();
  self.resetID = id;
  VehicleSort.resetID = self.resetID;
  return self;
end;

function VehicleSort_Event:readStream(streamId, connection)
  self.resetID = streamReadUInt16(streamId);	
  VehicleSort:dp(string.format('self.resetID [%d]', self.resetID), 'VehicleSort_Event:readStream');
  VehicleSort.resetID = self.resetID;
  if not connection:getIsServer() then
    g_server:broadcastEvent(VehicleSort_Event:new(self.resetID), nil, connection);
  end;
end;

function VehicleSort_Event:sendEvent(id)
  if g_server ~= nil then
    VehicleSort:dp(string.format('id [%d]', id), 'VehicleSort_Event:sendEvent', 'g_server:broadcastEvent');
    g_server:broadcastEvent(VehicleSort_Event:new(id));
  else
    VehicleSort:dp(string.format('id [%d]', id), 'VehicleSort_Event:sendEvent', 'g_client:getServerConnection():sendEvent');
    g_client:getServerConnection():sendEvent(VehicleSort_Event:new(id));
  end;
end;

function VehicleSort_Event:writeStream(streamId, connection)
  VehicleSort:dp(string.format('self.id [%d]', self.resetID), 'VehicleSort_Event:writeStream');
  streamWriteUInt16(streamId, self.resetID);
end;

print(string.format('Script loaded: VehicleSort.lua (v%s)', VehicleSort.version));