VehicleSort = {};
VehicleSort.eventName = {};

VehicleSort.ModName = g_currentModName;
VehicleSort.ModDirectory = g_currentModDirectory;
VehicleSort.Version = "1.0.0.0";


VehicleSort.debug = fileExists(VehicleSort.ModDirectory ..'debug');

print(string.format('VehicleSort v%s - DebugMode %s)', VehicleSort.Version, tostring(VehicleSort.debug)));

VehicleSort.bgTransDef = 0.8;
VehicleSort.txtSizeDef = 2;

VehicleSort.config = {
  {'showTrain', true},
  {'showCrane', false},
  {'showBrand', false},
  {'showHorsepower', true},
  {'showNames', true},
  {'showFillLevels', true},
  {'showPercentages', true},
  {'showEmpty', false},
  {'txtSize', VehicleSort.txtSizeDef},
  {'bgTrans', VehicleSort.bgTransDef},
  {'showSteerableImplements', true},
  {'showImplements', true},
  {'showHelp', true},
  {'saveStatus', true},
  {'showImg', true},
  {'showInfo', true}
};

VehicleSort.tColor = {}; -- text colours
VehicleSort.tColor.isParked 	= {0.5, 0.5, 0.5, 0.7};   -- grey
VehicleSort.tColor.locked 		= {1.0, 0.0, 0.0, 1.0};   -- red
VehicleSort.tColor.selected 	= {1.0, 0.5, 0.0, 1.0}; -- orange
VehicleSort.tColor.standard 	= {1.0, 1.0, 1.0, 1.0}; -- white
VehicleSort.tColor.hired 		= {0.0, 0.5, 1.0, 1.0}; 	-- blue
VehicleSort.tColor.followme 	= {0.92, 0.31, 0.69, 1.0}; 	-- light pink
VehicleSort.tColor.self  		= {0.0, 1.0, 0.0, 1.0}; -- green

VehicleSort.keyCon = 'VeExConfig';
VehicleSort.selectedConfigIndex = 1;
VehicleSort.selectedIndex = 1;
VehicleSort.selectedLock = false;
VehicleSort.showConfig = false;
VehicleSort.showSteerables = false;
VehicleSort.xmlAttrId = '#vsid';
VehicleSort.xmlAttrOrder = '#vsorder';
VehicleSort.xmlAttrParked = '#vsparked';
VehicleSort.Sorted = {};

addModEventListener(VehicleSort);

function VehicleSort:dp(val, fun, msg) -- debug mode, write to log
  if not VehicleSort.debug then
    return;
  end
  if msg == nil then
    msg = ' ';
  else
    msg = string.format(' msg = [%s] ', tostring(msg));
  end
  local pre = 'VehicleSort DEBUG:';
  if type(val) == 'table' then
    if #val > 0 then
      print(string.format('%s BEGIN Printing table data: (%s)%s(function = [%s()])', pre, tostring(val), msg, tostring(fun)));
      DebugUtil.printTableRecursively(val, '.', 0, 3);
      print(string.format('%s END Printing table data: (%s)%s(function = [%s()])', pre, tostring(val), msg, tostring(fun)));
    else
      print(string.format('%s Table is empty: (%s)%s(function = [%s()])', pre, tostring(val), msg, tostring(fun)));
    end
  else
    print(string.format('%s [%s]%s(function = [%s()])', pre, tostring(val), msg, tostring(fun)));
  end
end


function VehicleSort:prerequisitesPresent(specializations)
	return true;
end

function VehicleSort:loadMap(name)
	print("--- loading VehicleSort V".. VehicleSort.Version .. " | ModName " .. VehicleSort.ModName .. " ---");
	VehicleSort:initVS();
	VehicleSort:loadConfig();
end

function VehicleSort:onLoad(savegame)
	FSBaseMission.registerActionEvents = Utils.appendedFunction(FSBaseMission.registerActionEvents, VehicleSort.RegisterActionEvents);
end

function VehicleSort:onPostLoad(savegame)

	if savegame ~= nil then
		local xmlFile = savegame.xmlFile;
		local key = savegame.key..".vehicleSort";
		
		local orderId = getXMLInt(xmlFile, key.."#UserOrder");
		if orderId ~= nil then
			VehicleSort:dp(string.format('Loaded orderId {%d} for vehicleId {%d}', orderId, self.id), 'onPostLoad');
		end
		
		if self.spec_vehicleSort ~= nil then
			local specVS = self.spec_vehicleSort;
			specVS.id = self.id;
			if orderId ~= nil then
				specVS.orderId = orderId;
			end
		end
		
		--Check to avoid issues after a vehicle reset
		if VehicleSort.Sorted[orderId] ~= nil then
			if g_currentMission.vehicles[VehicleSort.Sorted[orderId]]['id'] ~= self.id then
				VehicleSort:dp('Sync required after vehicle reset');
				VehicleSort:SyncSorted();
			end
		end
	end
end

function VehicleSort:RegisterActionEvents(isSelected, isOnActiveVehicle)

	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'vsToggleList',self, VehicleSort.action_vsToggleList ,false ,true ,false ,true)
	if result then
		table.insert(VehicleSort.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = VehicleSort.config[13][2];
    end

	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'vsLockListItem',self, VehicleSort.action_vsLockListItem ,false ,true ,false ,true)
	if result then
        table.insert(VehicleSort.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = VehicleSort.config[13][2];
    end
	
	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'vsMoveCursorUp',self, VehicleSort.action_vsMoveCursorUp ,false ,true ,false ,true)
	if result then
        table.insert(VehicleSort.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = VehicleSort.config[13][2];
    end
	
	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'vsMoveCursorDown',self, VehicleSort.action_vsMoveCursorDown ,false ,true ,false ,true)
	if result then
        table.insert(VehicleSort.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = VehicleSort.config[13][2];
    end
	
	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'vsMoveCursorUpFast',self, VehicleSort.action_vsMoveCursorUpFast ,false ,true ,false ,true)
	if result then
        table.insert(VehicleSort.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = VehicleSort.config[13][2];
    end
	
	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'vsMoveCursorDownFast',self, VehicleSort.action_vsMoveCursorDownFast ,false ,true ,false ,true)
	if result then
        table.insert(VehicleSort.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = VehicleSort.config[13][2];
    end
	
	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'vsChangeVehicle',self, VehicleSort.action_vsChangeVehicle ,false ,true ,false ,true)
	if result then
        table.insert(VehicleSort.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = VehicleSort.config[13][2];
    end
	
	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'vsShowConfig',self, VehicleSort.action_vsShowConfig ,false ,true ,false ,true)
	if result then
        table.insert(VehicleSort.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = VehicleSort.config[13][2];
    end	
	
	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'vsTogglePark',self, VehicleSort.action_vsTogglePark ,false ,true ,false ,true)
	if result then
        table.insert(VehicleSort.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = VehicleSort.config[13][2];
    end	

	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'vsRepair',self, VehicleSort.action_vsRepair ,false ,true ,false ,true)
	if result then
        table.insert(VehicleSort.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = VehicleSort.config[13][2];
    end

end

function VehicleSort:removeActionEvents()
	VehicleSort.eventName = {};
	if VehicleSort.debug then
		print("--- VehicleSort Debug ... VehicleSort:removeActionEventsPlayer(VehicleSort.eventName)");
		DebugUtil.printTableRecursively(VehicleSort.eventName,"----",0,1)
	end
end

function VehicleSort.registerEventListeners(vehicleType)
	local functionNames = {	"onLoad", "onPostLoad", "saveToXMLFile" };
	
	for _, functionName in ipairs(functionNames) do
		SpecializationUtil.registerEventListener(vehicleType, functionName, VehicleSort);
	end
end

function VehicleSort:keyEvent(unicode, sym, modifier, isDown)
end

function VehicleSort:mouseEvent(posX, posY, isDown, isUp, button)
	if VehicleSort:isActionAllowed() and ( isDown and button == Input.MOUSE_BUTTON_LEFT) then
		VehicleSort.action_vsChangeVehicle();
	end

	if VehicleSort:isActionAllowed() and ( isDown and button == Input.MOUSE_BUTTON_RIGHT) then
		VehicleSort.action_vsLockListItem();
	end

	if VehicleSort:isActionAllowed() and ( isDown and Input.isMouseButtonPressed(Input.MOUSE_BUTTON_WHEEL_UP)) then
		VehicleSort.action_vsMoveCursorUp();
	end
	
	if VehicleSort:isActionAllowed() and ( isDown and Input.isMouseButtonPressed(Input.MOUSE_BUTTON_WHEEL_DOWN)) then
		VehicleSort.action_vsMoveCursorDown();
	end	
end

function VehicleSort:saveToXMLFile(xmlFile, key)
	VehicleSort:dp(string.format('key {%s}', key), 'saveToXMLFile');
	if self.spec_vehicleSort ~= nil then
		if self.spec_vehicleSort.orderId ~= nil then
			setXMLInt(xmlFile, key.."#UserOrder", self.spec_vehicleSort.orderId);
		end
	end
end

function VehicleSort:draw()
	
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
		end
		if VehicleSort.debug then
		  local t = {};
		  table.insert(t, string.format('bgX [%f]', VehicleSort.bgX));
		  table.insert(t, string.format('bgY [%f]', VehicleSort.bgY));
		  table.insert(t, string.format('bgW [%f]', VehicleSort.bgW));
		  table.insert(t, string.format('maxTxtW [%f]', VehicleSort.maxTxtW));
		  for k, v in ipairs(t) do
			VehicleSort.dbgY = VehicleSort.dbgY - VehicleSort.tPos.size - VehicleSort.tPos.spacing;
			renderText(VehicleSort.dbgX, VehicleSort.dbgY, VehicleSort.tPos.size, v);
		  end
		  VehicleSort.dbgY = dbgY;
		end
	end
	
end

function VehicleSort:delete()
end

function VehicleSort:deleteMap()
end

-- Functions for actionEvents/inputBindings

function VehicleSort:action_vsToggleList(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("vsToggleList fires", "vsToggleList");
	if VehicleSort.showSteerables and not VehicleSort.showConfig then
		VehicleSort.showSteerables = false;
		VehicleSort.selectedLock = false;
	else
		VehicleSort.showSteerables = true;
		if VehicleSort.showConfig then
			VehicleSort.saveConfig();
		end
		VehicleSort.showConfig = false;
    end
end

function VehicleSort:action_vsLockListItem(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("vsLockListItem fires", "vsLockListItem");
	if VehicleSort.showSteerables then
		if not VehicleSort.selectedLock and VehicleSort.selectedIndex > 0 then
			VehicleSort.selectedLock = true;
		elseif VehicleSort.selectedLock then
			VehicleSort.selectedLock = false;
		end
	elseif VehicleSort.showConfig then
		if VehicleSort.selectedConfigIndex == 9 then
			VehicleSort.config[VehicleSort.selectedConfigIndex][2] = VehicleSort.config[VehicleSort.selectedConfigIndex][2] + 1;
			if VehicleSort.config[VehicleSort.selectedConfigIndex][2] > 3 then
				VehicleSort.config[VehicleSort.selectedConfigIndex][2] = 1;
			end
		elseif VehicleSort.selectedConfigIndex == 10 then
			VehicleSort.config[VehicleSort.selectedConfigIndex][2] = VehicleSort.config[VehicleSort.selectedConfigIndex][2] + 0.1;
			if VehicleSort.config[VehicleSort.selectedConfigIndex][2] > 1 then
				VehicleSort.config[VehicleSort.selectedConfigIndex][2] = 0.0;
			end
		else
			VehicleSort.config[VehicleSort.selectedConfigIndex][2] = not VehicleSort.config[VehicleSort.selectedConfigIndex][2];
		end
	end
end

function VehicleSort:action_vsMoveCursorUp(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("action_vsMoveCursorUp fires", "action_vsMoveCursorUp");
	if VehicleSort.showSteerables then
		VehicleSort:moveUp(1);
	elseif VehicleSort.showConfig then
		VehicleSort:moveConfigUp();
	end
end

function VehicleSort:action_vsMoveCursorDown(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("action_vsMoveCursorDown fires", "action_vsMoveCursorDown");
	if VehicleSort.showSteerables then
		VehicleSort:moveDown(1);
	elseif VehicleSort.showConfig then
		VehicleSort:moveConfigDown();
	end	
end

function VehicleSort:action_vsMoveCursorUpFast(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("action_vsMoveCursorUpFast fires", "action_vsMoveCursorUpFast");
	if VehicleSort.showSteerables then 
		VehicleSort:moveUp(3);
	end	
end

function VehicleSort:action_vsMoveCursorDownFast(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("action_vsMoveCursorDownFast fires", "action_vsMoveCursorDownFast");
	if VehicleSort.showSteerables then 
		VehicleSort:moveDown(3);
	end	
end

function VehicleSort:action_vsChangeVehicle(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("action_vsChangeVehicle fires", "action_vsChangeVehicle");
	if VehicleSort.showSteerables then
		local realVeh = g_currentMission.vehicles[VehicleSort.Sorted[VehicleSort.selectedIndex]];
		if not realVeh:getIsControlled() then
			g_currentMission:requestToEnterVehicle(realVeh);
		end
	end
end

function VehicleSort:action_vsShowConfig(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("action_vsShowConfig fires", "action_vsShowConfig");
	if VehicleSort.showSteerables and not VehicleSort.showConfig then
      VehicleSort.showSteerables = false;
    end
    VehicleSort.showConfig = not VehicleSort.showConfig;
	
	VehicleSort:saveConfig();
end

function VehicleSort:action_vsTogglePark(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("action_vsTogglePark fires", "action_vsTogglePark");
	if VehicleSort.showSteerables then
		VehicleSort:toggleParkState(VehicleSort.selectedIndex);
	end
end

function VehicleSort:action_vsRepair(actionName, keyStatus, arg3, arg4, arg5)
	VehicleSort:dp("action_vsRepair fires", "action_vsRepair");
	if VehicleSort.showSteerables then
		VehicleStatus:RepairVehicleWithImplements(VehicleSort.selectedIndex);
	end
end

--
-- VehicleSort specific functions
--
function VehicleSort:calcPercentage(curVal, maxVal)
	local per = curVal / maxVal * 100;
	return (math.floor(per * 10)/10);
end

function VehicleSort:drawConfig()
  local cCount = #VehicleSort.config;
  local xPos = VehicleSort.tPos.x;
  local yPos = VehicleSort.tPos.y;
  setTextAlignment(VehicleSort.tPos.alignmentL);
  local size = VehicleSort:getTextSize();
  local y = yPos + size + VehicleSort.tPos.spacing + VehicleSort.tPos.yOffset;
  local headingY = VehicleSort.tPos.y + size + (VehicleSort.tPos.padHeight * 6);
  local txt = g_i18n.modEnvironments[VehicleSort.ModName].texts.configHeadline;
  local txtOn = g_i18n.modEnvironments[VehicleSort.ModName].texts.vs_on;
  local txtOff = g_i18n.modEnvironments[VehicleSort.ModName].texts.vs_off;
  local texts = {};
  VehicleSort.bgW = VehicleSort.tPos.columnWidth + VehicleSort.tPos.padSides + getTextWidth(size, txtOff);
  table.insert(texts, {xPos + VehicleSort.tPos.padSides - (VehicleSort.bgW / 2), headingY, size + VehicleSort.tPos.sizeIncr, VehicleSort.tColor.standard, txt}); --heading
  for i = 1, cCount do --loop through config values
    local clr = VehicleSort.tColor.standard;
    if i == VehicleSort.selectedConfigIndex then
      clr = VehicleSort.tColor.selected;
    end
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
    end
    table.insert(texts, {xPos - (VehicleSort.bgW / 2) + VehicleSort.tPos.padSides, yPos, size, clr, rText}); --config definition line
    table.insert(texts, {xPos - (VehicleSort.bgW / 2) + VehicleSort.tPos.columnWidth, yPos, size, clr, state}); --config value
    yPos = yPos - size - VehicleSort.tPos.spacing;
  end
  
  VehicleSort.bgY = yPos;
  VehicleSort.bgH = (y - yPos) + size + VehicleSort.tPos.yOffset + VehicleSort.tPos.padHeight;
  if VehicleSort.bgY ~= nil and VehicleSort.bgW ~=nil and VehicleSort.bgH ~= nil then
    VehicleSort:renderBg(VehicleSort.bgX, VehicleSort.bgY, VehicleSort.bgW, VehicleSort.bgH);
  end;  

  setTextBold(false);
  for k, v in ipairs(texts) do
    setTextColor(unpack(v[4]))
    renderText(v[1], v[2], v[3], tostring(v[5]));
    if VehicleSort.debug and v[4] == VehicleSort.tColor.selected then
      VehicleSort.dbgY = VehicleSort.dbgY - VehicleSort.tPos.size - VehicleSort.tPos.spacing;
      renderText(VehicleSort.dbgX, VehicleSort.dbgY, VehicleSort.tPos.size, string.format('selected textWidth [%f] colWidth [%f]', getTextWidth(v[3], tostring(v[5])), VehicleSort.tPos.columnWidth));
    end
  end
  setTextColor(unpack(VehicleSort.tColor.standard));
end

function VehicleSort:drawList()
  VehicleSort.Sorted = VehicleSort:getOrderedVehicles();
   
  --VehicleSort:dp(vehList, 'drawList', 'vehList');
  
  local cnt = #VehicleSort.Sorted;
  if cnt == 0 then
    return;
  end
  setTextBold(true); -- for width checks, to compensate for increased width when the line is bold
  local yPos = VehicleSort.tPos.y;
  local bgPosY = yPos;
  setTextAlignment(VehicleSort.tPos.alignmentC);
  local size = VehicleSort.getTextSize();
  --local y = yPos + size + VehicleSort.tPos.spacing + VehicleSort.tPos.yOffset;
  local y = VehicleSort.tPos.y;
  local txt = g_i18n.modEnvironments[VehicleSort.ModName].texts.vs_title;
  local texts = {};
  local bold = false;
  local minBgW = 0;
  VehicleSort.bgY = y - VehicleSort.tPos.spacing;
  VehicleSort.bgW = getTextWidth(size, txt) + VehicleSort.tPos.padSides;		--Background width will be dynamically adjusted later on. Just a value to get started with
  --VehicleSort.bgW = 0.25;
  
  local headingY = VehicleSort.tPos.y + size + (VehicleSort.tPos.padHeight * 6);
  table.insert(texts, {0, headingY, size + VehicleSort.tPos.sizeIncr, bold, VehicleSort.tColor.standard, txt}); --heading
  
  --Just used to figure out if we'll have multiple columns, hence we've to loop through the amount of vehicles to get the total height of the table
  local chk = yPos + size + VehicleSort.tPos.spacing;

	for i = 1, cnt do --loop through lines to see if there will be multiple columns needed
		if not VehicleSort:isHidden(VehicleSort.Sorted[i]) then
			chk = chk - size - VehicleSort.tPos.spacing;
		end
	end

	--Min distance to the bottom of the screen
	local minY = ((4 * (size + VehicleSort.tPos.spacing)) + VehicleSort.tPos.padHeight);
	local isMultiCol = chk < minY;
	local colNum = 1;			--For multiple columns this counter gets increased
	--VehicleSort:dp(string.format('chk {%f} | check for chk {%f} | minY {%f}', chk, size + VehicleSort.tPos.spacing + VehicleSort.tPos.padHeight, minY));
	
	for i = 1, cnt do
		local realId = VehicleSort.Sorted[i];
		if not VehicleSort:isHidden(realId) then

			local clr = VehicleSort:getTextColor(i, realId);
			local t = VehicleSort:getFullVehicleName(realId);
			txt = table.concat(t);
			local w = getTextWidth(size, txt);
			local lns = {};
			local ind = #t;
			local ln = t[ind];
			while (w >= VehicleSort.maxTxtW) and ind > 0 do -- wrap text wider than the column to additional lines if multi-column
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
						end
					else
						table.insert(lns, 1, ln);
					end
				end
				table.remove(t, ind);
				ind = #t;
				txt = table.concat(t);
				w = getTextWidth(size, txt);
			end
			
			bold = VehicleSort:isControlled(realId) and (not g_currentMission.missionDynamicInfo.isMultiplayer or VehicleSort:getControllerName(realId) == g_gameSettings.nickname);
			
			if string.len(txt) > 0 then
				table.insert(texts, {colNum, yPos, size, bold, clr, txt});
				yPos = yPos - size - VehicleSort.tPos.spacing;
			end
			-- To find our proper background width and the position of the columns we've to keep track of the longest text
			VehicleSort.bgW = math.max(VehicleSort.bgW, w + VehicleSort.tPos.padSides);
			if #lns > 0 then -- add any wrapped lines to the text table
				for k, v in ipairs(lns) do
					if string.len(v) > 0 then
						table.insert(texts, {colNum, yPos, size, bold, clr, v});
						yPos = yPos - size - VehicleSort.tPos.spacing;
						VehicleSort.bgW = math.max(VehicleSort.bgW, getTextWidth(size, v) + VehicleSort.tPos.padSides);
					end
				end
			end
			-- We don't want our background go further than necessary
			bgPosY = math.min(bgPosY, yPos);
		end
		
		if yPos < minY then -- getting near bottom of screen, start a new column
			yPos = VehicleSort.tPos.y;
			colNum = colNum + 1;
		end
	end

	setTextBold(false);

	--Drawing our background
	bgPosY = bgPosY - VehicleSort.tPos.spacing; -- bottom padding

	VehicleSort.bgY = bgPosY;
	VehicleSort.bgH = (y - bgPosY) + size + VehicleSort.tPos.sizeIncr + VehicleSort.tPos.yOffset + VehicleSort.tPos.spacing;
	VehicleSort.bgW = VehicleSort.bgW * colNum;
	if VehicleSort.bgY ~= nil and VehicleSort.bgW ~=nil and VehicleSort.bgH ~= nil then
		VehicleSort:renderBg(VehicleSort.bgX, VehicleSort.bgY, VehicleSort.bgW, VehicleSort.bgH);
	end

	--We've to calculate our X based on each column.
	local tblColWidth = VehicleSort.bgW / colNum;
	local colX = {};
	colX[0] = VehicleSort.tPos.x;
	if colNum == 2 then
		colX[1] = VehicleSort.tPos.x - (tblColWidth / 2);
		colX[2] = VehicleSort.tPos.x + (tblColWidth / 2);
	elseif colNum == 3 then
		colX[1] = VehicleSort.tPos.x - tblColWidth;
		colX[2] = VehicleSort.tPos.x;
		colX[3] = VehicleSort.tPos.x + tblColWidth;
	else
		--We just support 3 columsn. So this case is primarily for one column and as a 'catch all' which won't work but I don't care for now
		colX[1] = VehicleSort.tPos.x;
	end	
	
	--VehicleSort:dp(colX, 'drawList');
	
	for k, v in ipairs(texts) do
		if type(v[4]) == 'boolean' then
			setTextBold(v[4]);
		end
		setTextColor(unpack(v[5]));
		local storColNum = v[1];
		--VehicleSort:dp(storColNum, 'drawList', 'storcolNum');
		renderText(colX[storColNum], v[2], v[3], tostring(v[6])); -- x, y, size, txt

		if VehicleSort.debug and v[5] == VehicleSort.tColor.selected then
			VehicleSort.dbgY = VehicleSort.dbgY - VehicleSort.tPos.size - VehicleSort.tPos.spacing;
			renderText(VehicleSort.dbgX, VehicleSort.dbgY, VehicleSort.tPos.size, string.format('selected textWidth [%f] colWidth [%f]', getTextWidth(v[3], v[6]), VehicleSort.tPos.columnWidth));

			--local testX = 0.75;
			--local testY = 0.75;
			--local testS = 0.013;
			--renderText(testX, testY, testS, string.format('X {%f} | Y {%f} | S {%f}', testX, testY, testS));
		end
	end

	setTextBold(false);
	setTextColor(unpack(VehicleSort.tColor.standard));
  
	if VehicleSort.config[15][2] then
		VehicleSort:drawStoreImage(VehicleSort.Sorted[VehicleSort.selectedIndex]);
	end

	if VehicleSort.config[16][2] then
		VehicleSort:drawInfobox(VehicleSort.Sorted[VehicleSort.selectedIndex])
	end
  
end

function VehicleSort:getVehicles()
	local allveh = g_currentMission.vehicles
	local veh = {}
	
	for k, v in ipairs(allveh) do
		if v.spec_vehicleSort ~= nil then
			v.spec_vehicleSort.realId = k;
			table.insert(veh, v);
		end
	end
	return veh;
end

function VehicleSort:getVehImplements(realId)
	if g_currentMission.vehicles[realId].getAttachedImplements ~= nil then
		return g_currentMission.vehicles[realId]:getAttachedImplements();
	else
		return nil;
	end
end

function VehicleSort:getAttachment(obj)
	local val = '';
	if VehicleSort.config[3][2] then
		--val = val .. string.format('%s ', obj:getFullName());
		local brand = VehicleSort:getAttachmentBrand(obj);
		if brand ~= nil then
			val = val .. string.format('%s %s', brand, obj:getName());
		else
			val = val .. string.format('%s ', obj:getName());
		end
	else
		val = val .. string.format('%s ', obj:getName());
	end
  
	return val;
end

function VehicleSort:getAttachmentBrand(obj)
    local storeItem = g_storeManager:getItemByXMLFilename(obj.configFileName);
    if storeItem ~= nil then
        local brand = g_brandManager:getBrandByIndex(storeItem.brandIndex);
        if brand ~= nil then
            return brand.title;
		else
			return 'Lizard';
        end
    end
end

function VehicleSort:getFillLevel(obj)
	local fillLevel = 0;
	local cap = 0;
	local fillType = "";
	if obj.getFillLevelInformation ~= nil then
		local fillLevelTable = {};
		obj:getFillLevelInformation(fillLevelTable);
		
		for _,fillLevelVehicle in pairs(fillLevelTable) do
			fillLevel = fillLevelVehicle.fillLevel;
			cap = fillLevelVehicle.capacity;
			fillType = g_fillTypeManager.fillTypes[fillLevelVehicle.fillType]['title'];
			--VehicleSort:dp(string.format('FillLevel - realId {%f} - fillLevel {%f} - capacity {%f}', realId, fillLevel, cap), 'getFillLevel');
			--VehicleSort:dp(string.format('fillType {%s} - fillTypeIndex {%s} - filltypeTitle {%s}', fillLevelVehicle.fillType, fillTypeIndex, fillType));			
		end
		
		return fillLevel, cap, fillType;
	end
end

function VehicleSort:getFillDisplay(obj, infoBox)
	local ret = '';
	if VehicleSort.config[6][2] or infoBox then -- Fill-Level-Display active?
		local f, c, t = VehicleSort:getFillLevel(obj);
		
		if not infoBox then t = ""; end;	-- we use the same method for the list and the infobox. But the fillType should just be visible in the infobox
		
		if VehicleSort.config[8][2] or f > 0 then -- Empty should be shown or is not empty
			if c > 0 then -- Capacity more than zero
				if VehicleSort.config[7][2] then -- Display as percentage
					ret = string.format(' (%d %%) %s', VehicleSort:calcPercentage(f, c), t);
				else -- Display as amount of total capacity
					ret = string.format(' (%d/%d) %s', math.floor(f), c, t);
				end
			end
		end
	end
	
	return ret;
end

function VehicleSort:getFullVehicleName(realId)
	local nam = '';
	local ret = {};
	local fmt = '(%s) ';
  
	if VehicleSort:isParked(realId) then
		nam = '[P] '; -- Prefix for parked (not part of tab list) vehicles
	end
	if (g_currentMission.vehicles[realId].getIsCourseplayDriving ~= nil and g_currentMission.vehicles[realId]:getIsCourseplayDriving()) then -- CoursePlay
		nam = nam .. string.format(fmt, g_i18n.modEnvironments[VehicleSort.ModName].texts.courseplay);
	elseif VehicleSort:isHired(realId) then -- credit: Vehicle Groups Switcher mod
		nam = nam .. string.format(fmt, g_i18n.modEnvironments[VehicleSort.ModName].texts.hired);
	--elseif (veh.modFM ~= nil and veh.modFM.FollowVehicleObj ~= nil) then
	--	nam = nam .. string.format(fmt, g_i18n.modEnvironments[VehicleSort.ModName].texts.followme);
	elseif VehicleSort:isControlled(realId) then
		local con = VehicleSort:getControllerName(realId);
			if VehicleSort.config[5][2] and con ~= nil and con ~= 'Unknown' and con ~= '' then
				nam = nam .. string.format(fmt, con);
			end
	end


	if VehicleSort:isTrain(realId) then
		nam = nam .. VehicleSort:getName(realId, string.format('%s', g_i18n.modEnvironments[VehicleSort.ModName].texts.vs_train));
	elseif VehicleSort:isCrane(realId) then
		nam = nam .. string.format('%s', g_i18n.modEnvironments[VehicleSort.ModName].texts.vs_crane);
	elseif VehicleSort.config[3][2] then -- Show brand
		nam = nam .. string.format('%s ', VehicleSort:getNameBrand(realId));
	else
	  --VehicleSort:dp(veh.spec_vehicleSort, 'getFullVehicleName', 'Table spec_vehicleSort');
	  nam = nam .. string.format('%s ', VehicleSort:getName(realId));
	end
		  
	if VehicleSort.config[4][2] then
		local horsePower = VehicleSort:getHorsePower(realId);
		if horsePower ~= nil then
			nam = nam .. " (" .. horsePower .. string.format(' %s) ', g_i18n.modEnvironments[VehicleSort.ModName].texts.horsePower);
		end
	end

	table.insert(ret, nam .. VehicleSort:getFillDisplay(g_currentMission.vehicles[realId]));

	if not VehicleSort:isTrain(realId) and not VehicleSort:isCrane(realId) and VehicleSort.config[12][2] then
		local implements = VehicleSort:getVehImplements(realId);
		local imp = implements[1];
		--VehicleSort:dp(imp, 'VehicleSort:getFullVehicleName', 'getAttachedImplements');
		if (imp ~= nil and imp.object ~= nil) then
			table.insert(ret, string.format('%s %s%s ', g_i18n.modEnvironments[VehicleSort.ModName].texts.with, VehicleSort:getAttachment(imp.object), VehicleSort:getFillDisplay(imp.object)));
			imp = implements[2];
			if (imp ~= nil and imp.object ~= nil) then -- second attachment
				table.insert(ret, string.format('& %s%s ', VehicleSort:getAttachment(imp.object), VehicleSort:getFillDisplay(imp.object)));
			end
		end
	end
	return ret;
end

function VehicleSort:getName(realId, sFallback)
	nam = g_currentMission.vehicles[realId]:getName();
	if nam == nil then
		nam = obj.typeName;
	end	
	if nam == nil or nam == '' then
		return sFallback;
	else
		return nam;
	end
end

function VehicleSort:getNameBrand(realId)
	--return Utils.getNoNil(getXMLString(obj.xmlFile, 'vehicle.storeData.brand'), 'LIZARD');
	return g_currentMission.vehicles[realId]:getFullName();
end

function VehicleSort:getOrderedVehicles()
	local ordered = {};
	local unordered = {};
	local orderedToOrder = {};
	local vehList = VehicleSort:getVehicles();
  
	for _, veh in pairs(vehList) do
		if veh.spec_vehicleSort.orderId ~= nil then
			table.insert(orderedToOrder, {orderId=veh.spec_vehicleSort.orderId, realId=veh.spec_vehicleSort.realId} );
		else
			table.insert(unordered, veh.spec_vehicleSort.realId);
		end
	end
	
	-- Now order our temp table based on the actual orderId
	table.sort(orderedToOrder, function(a,b) return a['orderId'] < b['orderId'] end)
	-- And to avoid any holes in the order or dups we'll just add them to a new ordered table
	for _, v in ipairs(orderedToOrder) do
		table.insert(ordered, v['realId']);
	end
	
	local cntOrdered = #ordered;
	
	if unordered ~= nil then
		for _, v in pairs(unordered) do
			table.insert(ordered, v);
		end
	end
	
	-- We might have to reorder the list in case we've missing entries or completely new vehicles
	if #vehList ~= cntOrdered or #unordered ~= 0 then
		VehicleSort:dp(string.format('Reshuffle of vehicles required. #vehList {%d} - cntOrdered {%d} - #unordered {%d}', #vehList, cntOrdered, #unordered));
		ordered = VehicleSort:reshuffleVehicles(ordered);
	end
	
	VehicleSort:SyncSorted();
	return ordered;

end

function VehicleSort:reshuffleVehicles(list)
	local newList = {};
	local i = 1;
	for k, v in ipairs(list) do
		table.insert(newList, v);
		if k ~= i then
			g_currentMission.vehicles[v]['spec_vehicleSort']['orderId'] = i;
		end
		i = i + 1;
	end

	return newList;
end

function VehicleSort:getTextColor(ind, realId)
	--VehicleSort:dp(veh, 'getTextColor');
  if ind == VehicleSort.selectedIndex then
    if VehicleSort.selectedLock then
      return VehicleSort.tColor.locked;
    else
      return VehicleSort.tColor.selected;
    end
  elseif VehicleSort:isParked(realId) then
    return VehicleSort.tColor.isParked;
  elseif VehicleSort:isControlled(realId) then
	return VehicleSort.tColor.self
  elseif VehicleSort:isHired(realId) then
	return VehicleSort.tColor.hired
-- FollowMe is not out there yet
--  elseif (veh.modFM ~= nil and veh.modFM.FollowVehicleObj ~= nil) then
--	return VehicleSort.tColor.followme
  else
    return VehicleSort.tColor.standard;
  end
end

function VehicleSort:getTextSize()
  local val = tonumber(VehicleSort.config[9][2]);
  if val == nil or val < 1 or val > 3 then
    val = 2;
  end
  if val == 1 then
    return VehicleSort.tPos.sizeSmall;
  elseif val == 3 then
    return VehicleSort.tPos.sizeBig;
  else
    VehicleSort.config[9][2] = 2;
    return VehicleSort.tPos.size;
  end
end

function VehicleSort:getHorsePower(realId)
	local veh = g_currentMission.vehicles[realId];
	if veh.spec_motorized ~= nil then
		local maxMotorTorque = veh.spec_motorized.motor.peakMotorTorque;
		local maxRpm = veh.spec_motorized.motor.maxRpm;
		return math.ceil(maxMotorTorque / 0.0044);
	end
end

function VehicleSort:getControllerName(realId)
	if not VehicleSort:isHired(realId) then
		if g_currentMission.vehicles[realId].getControllerName ~= nil then
			return g_currentMission.vehicles[realId]:getControllerName();
		end
	end
end

function VehicleSort:initVS()
  VehicleSort:dp('Start Init', 'VehicleSort:init');
  if g_dedicatedServerInfo ~= nil then -- Dedicated server does not need the initialization process
    VehicleSort:dp('Skipping undesired initialization on dedicated server.', 'VehicleSort:init');
    return;
  end
  VehicleSort.dbgX = 0.01;
  VehicleSort.dbgY = 0.5;
  VehicleSort.tPos = {};
  -- g_currentMission.inGameMenu.hud
  --VehicleSort.tPos.x = g_currentMission.inGameMenu.hud.topNotification.origX;  -- x Position of Textfield, originally hardcoded 0.3
  VehicleSort.tPos.x = 0.5;
  VehicleSort.tPos.center = 0.5;
  VehicleSort.tPos.y = g_currentMission.inGameMenu.hud.topNotification.origY + g_currentMission.inGameMenu.hud.topNotification.infoOffsetY;  -- y Position of Textfield, originally hardcoded 0.9
  --VehicleSort.tPos.y = 0.9;
  VehicleSort.tPos.yOffset = g_currentMission.inGameMenu.hud.topNotification.infoOffsetY;  --* 1.5; -- y Position offset for headings, originally hardcoded 0.007
  --VehicleSort.tPos.yOffset = 0.007;
  VehicleSort.tPos.size = g_currentMission.inGameMenu.hud.topNotification.infoTextSize;  -- TextSize, originally hardcoded 0.018
  --VehicleSort.tPos.size = 0.018;
  VehicleSort.tPos.sizeBig = VehicleSort.tPos.size + 0.002;
  VehicleSort.tPos.sizeSmall = VehicleSort.tPos.size - 0.002;
  VehicleSort.tPos.sizeIncr = g_currentMission.inGameMenu.hud.speedMeter.cruiseControlTextOffsetY; -- Text size increase for headings
  --VehicleSort.tPos.sizeIncr = 0.005;
  VehicleSort.tPos.spacing = g_currentMission.inGameMenu.hud.speedMeter.cruiseControlTextOffsetY;  -- Spacing between lines, originally hardcoded 0.005
  --VehicleSort.tPos.spacing = 0.005;
  VehicleSort.tPos.padHeight = VehicleSort.tPos.spacing;
  VehicleSort.tPos.padSides = VehicleSort.tPos.padHeight;
  VehicleSort.tPos.columnWidth = (((1 - VehicleSort.tPos.x) / 2) - VehicleSort.tPos.padSides);
  VehicleSort.tPos.alignmentL = RenderText.ALIGN_LEFT;  -- Text Alignment
  VehicleSort.tPos.alignmentC = RenderText.ALIGN_CENTER;  -- Text Alignment
  VehicleSort.tPos.alignmentR = RenderText.ALIGN_RIGHT;  -- Text Alignment
  
  if g_seasons ~= nil then
    VehicleSort:dp('Seasons mod detected. Lowering VehicleSort display to below the seasons weather display to avoid overlap', 'VehicleSort:init');
    VehicleSort.tPos.y = VehicleSort.tPos.y - (6 * VehicleSort.tPos.size) - (6 * VehicleSort.tPos.spacing);
  end
  VehicleSort:dp(VehicleSort.tPos, 'VehicleSort:init', 'tPos');
  VehicleSort.userPath = getUserProfileAppPath();
  VehicleSort.saveBasePath = VehicleSort.userPath .. 'modsSettings/VehicleExplorer/';
  if g_currentMission.missionDynamicInfo.serverAddress ~= nil then --multi-player game and player is not the host (dedi already handled above)
    VehicleSort.savePath = VehicleSort.saveBasePath .. g_currentMission.missionDynamicInfo.serverAddress .. '/';
  else
    VehicleSort.savePath = VehicleSort.saveBasePath .. 'savegame' .. g_careerScreen.selectedIndex .. '/';
  end
  createFolder(VehicleSort.userPath .. 'modsSettings/');
  createFolder(VehicleSort.saveBasePath);
  createFolder(VehicleSort.savePath);
  VehicleSort.xmlFilename = VehicleSort.savePath .. 'VeExConfig.xml';
  VehicleSort.bg = createImageOverlay('dataS2/menu/blank.png'); --credit: Decker_MMIV, VehicleGroupsSwitcher mod
  VehicleSort.bgX = 0.5;
  VehicleSort.maxTxtW = VehicleSort.tPos.columnWidth - VehicleSort.tPos.padSides;
  
  VehicleSort:dp(string.format('Initialized userPath [%s] saveBasePath [%s] savePath [%s]',
    tostring(VehicleSort.userPath),
    tostring(VehicleSort.saveBasePath),
    tostring(VehicleSort.savePath)), 'VehicleSort:init');
end

function VehicleSort:isCrane(realId)
	-- No idea if this part still works, need a station crane first
	return  g_currentMission.vehicles[realId]['stationCraneId'] ~= nil;
end

function VehicleSort:isHidden(realId)
	return (VehicleSort:isTrain(realId) and not VehicleSort.config[1][2]) or (VehicleSort:isCrane(realId) and not VehicleSort.config[2][2]) or (VehicleSort:isSteerableImplement(realId) and not VehicleSort.config[11][2]);
end

function VehicleSort:isTrain(realId)
	--VehicleSort:dp(string.format('realId {%d}', realId), 'isTrain');
	return g_currentMission.vehicles[realId]['typeName'] == 'locomotive';
end

function VehicleSort:isSteerableImplement(realId)
	return g_currentMission.vehicles[realId]['spec_attachable'] ~= nil;
end

function VehicleSort:isControlled(realId)
	if not VehicleSort:isHired(realId) and g_currentMission.vehicles[realId].getIsControlled ~= nil then
		return g_currentMission.vehicles[realId]:getIsControlled(); 
	end
end

function VehicleSort:isParked(realId)
	return not g_currentMission.vehicles[realId]:getIsTabbable();
end

-- ToDo
function VehicleSort:isHired(realId)
	if g_currentMission.vehicles[realId].spec_aiVehicle ~= nil then
		return g_currentMission.vehicles[realId].spec_aiVehicle.isActive;
	end
end

function VehicleSort:loadConfig()
	if fileExists(VehicleSort.xmlFilename) then
		VehicleSort.saveFile = loadXMLFile('VehicleSort.loadFile', VehicleSort.xmlFilename);

		if hasXMLProperty(VehicleSort.saveFile, VehicleSort.keyCon) then

			VehicleSort:dp('Config file found.', 'VehicleSort:loadConfig');
			for i = 1, #VehicleSort.config do
				if i == 9 then
					local int = getXMLString(VehicleSort.saveFile, VehicleSort.keyCon .. '.' .. VehicleSort.config[i][1]); --a dev version had this as boolean, but then changed to int
					if tonumber(int) == nil or tonumber(int) <= 0 or tonumber(int) > 3 then
						int = VehicleSort.txtSizeDef;
					else
						int = math.floor(tonumber(int));
					end
					VehicleSort.config[i][2] = int;
					VehicleSort:dp(string.format('txtSize value set to [%d]', int), 'VehicleSort:loadConfig');
				elseif i == 10 then
					local flt = getXMLString(VehicleSort.saveFile, VehicleSort.keyCon .. '.' .. VehicleSort.config[i][1]); --a dev version had this as boolean, but then changed to float
					if tonumber(flt) == nil or tonumber(flt) <= 0 or tonumber(flt) > 1 then
						flt = VehicleSort.bgTransDef;
					else
						flt = tonumber(string.format('%.1f', tonumber(flt)));
					end
					VehicleSort.config[i][2] = flt;
					VehicleSort:dp(string.format('bgTrans value set to [%f]', flt), 'VehicleSort:loadConfig');
				else
					local b = getXMLBool(VehicleSort.saveFile, VehicleSort.keyCon .. '.' .. VehicleSort.config[i][1]);
					if b ~= nil then
						VehicleSort.config[i][2] = b;
					end
				end
			end
			print("VeExConfig loaded");
		end
	end
end

function VehicleSort:moveDown(moveSpeed)
	if moveSpeed == nil then
		moveSpeed = 1;
	end
	local oldIndex = VehicleSort.selectedIndex;
	VehicleSort.selectedIndex = VehicleSort.selectedIndex + moveSpeed;
	if VehicleSort.selectedIndex > #VehicleSort.Sorted then
		VehicleSort.selectedIndex = 1;
	end
	if VehicleSort:isHidden(VehicleSort.Sorted[VehicleSort.selectedIndex]) then
		VehicleSort:moveDown();
	end
	if VehicleSort.selectedLock then
		VehicleSort:reSort(oldIndex, VehicleSort.selectedIndex);
	end
end

function VehicleSort:moveUp(moveSpeed)
	if moveSpeed == nil then
		moveSpeed = 1;
	end
	local oldIndex = VehicleSort.selectedIndex;
	VehicleSort.selectedIndex = VehicleSort.selectedIndex - moveSpeed;
	if VehicleSort.selectedIndex < 1 then
		VehicleSort.selectedIndex = #VehicleSort.Sorted;
	end
	if VehicleSort:isHidden(VehicleSort.Sorted[VehicleSort.selectedIndex]) then
		VehicleSort:moveUp();
	end
	if VehicleSort.selectedLock then
		VehicleSort:reSort(oldIndex, VehicleSort.selectedIndex);
	end
end

function VehicleSort:moveConfigDown()
	VehicleSort.selectedConfigIndex = VehicleSort.selectedConfigIndex + 1;
	if VehicleSort.selectedConfigIndex > #VehicleSort.config then
		VehicleSort.selectedConfigIndex = 1;
	end
end

function VehicleSort:moveConfigUp()
	VehicleSort.selectedConfigIndex = VehicleSort.selectedConfigIndex - 1;
	if VehicleSort.selectedConfigIndex <= 0 then
		VehicleSort.selectedConfigIndex = #VehicleSort.config;
	end
end

function VehicleSort:renderBg(x, y, w, h)
  setOverlayColor(VehicleSort.bg, 0, 0, 0, VehicleSort.config[10][2]);
  renderOverlay(VehicleSort.bg, x - w / 2, y, w, h);
end

function VehicleSort:reSort(old, new)
	VehicleSort:dp(string.format('reSort old {%d} - new {%d}', old, new), 'reSort()');
	local u = VehicleSort.Sorted[old];
	table.remove(VehicleSort.Sorted, old);
	table.insert(VehicleSort.Sorted, new, u);
	VehicleSort:SyncSorted();
end

function VehicleSort:SyncSorted()
	for k, v in ipairs(VehicleSort.Sorted) do
		if g_currentMission.vehicles[v] ~= nil then
			if g_currentMission.vehicles[v]['spec_vehicleSort'] ~= nil then
				if g_currentMission.vehicles[v]['spec_vehicleSort']['id'] ~= g_currentMission.vehicles[v]['id'] then
					g_currentMission.vehicles[v]['spec_vehicleSort']['orderId'] = nil;
				else
					g_currentMission.vehicles[v]['spec_vehicleSort']['orderId'] = k;
				end
			end
		end
	end
end

function VehicleSort:toggleParkState(selectedIndex)
	local realId = VehicleSort.Sorted[selectedIndex];
	local parked = not g_currentMission.vehicles[realId]:getIsTabbable();
	if parked then
		g_currentMission.vehicles[realId]:setIsTabbable(true);
	else
		g_currentMission.vehicles[realId]:setIsTabbable(false);
	end
	VehicleSort:dp(string.format('realId {%d} - parked {%s}', realId, tostring(parked)), 'VehicleSort:toggleParkState');
end

function VehicleSort:saveConfig()
	VehicleSort.saveFile = createXMLFile('VehicleSort.saveFile', VehicleSort.xmlFilename, VehicleSort.keyCon);
	for i = 1, #VehicleSort.config do
		if i == 9 then
			setXMLString(VehicleSort.saveFile, VehicleSort.keyCon .. '.' .. tostring(VehicleSort.config[i][1]), tostring(VehicleSort.config[i][2]));
		elseif i == 10 then
			setXMLString(VehicleSort.saveFile, VehicleSort.keyCon .. '.' .. tostring(VehicleSort.config[i][1]), string.format('%.1f', VehicleSort.config[i][2]));
		else
			setXMLBool(VehicleSort.saveFile, VehicleSort.keyCon .. '.' .. tostring(VehicleSort.config[i][1]), VehicleSort.config[i][2]);
		end
	end
	saveXMLFile(VehicleSort.saveFile);

  print("VehicleSort config saved");
end

function VehicleSort:drawStoreImage(realId)
	local imgFileName = VehicleSort:getStoreImageByConf(g_currentMission.vehicles[realId]['configFileName']);
	--VehicleSort:dp(string.format('configFileName {%s}', configFileName));
	--VehicleSort:dp(storeItem, 'drawStoreImage');

	local storeImage = createImageOverlay(imgFileName);
	if storeImage > 0 then
		local storeImgX, storeImgY = getNormalizedScreenValues(128, 128)
		local imgX = 0.5 - VehicleSort.bgW / 2 - storeImgX;
		local imgY = 1 - storeImgY;
		renderOverlay(storeImage, imgX, imgY, storeImgX, storeImgY)
		
		if (g_currentMission.vehicles[realId].getAttachedImplements ~= nil) and (imgFileName ~= VehicleSort.ModDirectory .. 'img/train.dds') then
			local impList = g_currentMission.vehicles[realId]:getAttachedImplements();
			for i = 1, 5 do
				local imp = impList[i];
				if imp ~= nil and imp.object ~= nil then
					local imgFileName = VehicleSort:getStoreImageByConf(imp.object.configFileName);
					local storeImage = createImageOverlay(imgFileName);
					if storeImage > 0 then
						local imgY = 1 - (storeImgY * (i + 1) );
						renderOverlay(storeImage, imgX, imgY, storeImgX, storeImgY)
					end
				end
			end
		end
	end
end

function VehicleSort:getStoreImageByConf(confFile)
	local storeItem = g_storeManager.xmlFilenameToItem[string.lower(confFile)];
	if storeItem ~= nil then
		local imgFileName = storeItem.imageFilename;
		--if imgFileName == 'data/vehicles/train/locomotive01/store_locomotive01.png' or imgFileName == 'data/vehicles/train/locomotive04/store_locomotive04.png' then
		if string.find(imgFileName, 'locomotive') then
			imgFileName = VehicleSort.ModDirectory .. 'img/train.dds';
		end
		return imgFileName;
	end
end

function VehicleSort:drawInfobox(realId)
	if realId ~= nil then
	
		local textTable = VehicleSort:getInfoTexts(realId);
	
		setTextAlignment(VehicleSort.tPos.alignmentR);
		setTextColor(unpack(VehicleSort.tColor.standard));
		local txtSize = VehicleSort.tPos.sizeSmall;
		local imgWidth, _ = getNormalizedScreenValues(128,128);
		if not VehicleSort.config[15][2] then				-- If there is no icture we can move more right
			imgWidth = 0.01;
		end
		local infoX = 0.5 - VehicleSort.bgW / 2 - imgWidth;
		local infoY = 1 - txtSize - (VehicleSort.tPos.spacing * 8);
		local txtY = infoY - VehicleSort.tPos.spacing;
		local txtWidth = getTextWidth(txtSize, "Info");
		
		local texts = {};
		for _, t in ipairs(textTable) do
			local tWidth = getTextWidth(txtSize, t);
			renderText(infoX, txtY, txtSize, tostring(t));
			txtY = txtY - txtSize - VehicleSort.tPos.spacing;
			txtWidth = math.max(txtWidth, tWidth);
		end
		
		setTextAlignment(VehicleSort.tPos.alignmentL);		
		
		local bgW = txtWidth;
		local bgH = (txtSize * #textTable) + (VehicleSort.tPos.spacing * #textTable);
		local bgX = infoX - bgW;
		local bgY = infoY;
		--VehicleSort:renderBg(bgX, bgY, bgW, bgH); --Lets skip the background for now
	end
end

function VehicleSort:getInfoTexts(realId)
	local veh = g_currentMission.vehicles[realId];
	
	if veh ~= nil then
		local texts = {};
		local line = "";
		
		if (veh.getIsCourseplayDriving ~= nil and veh:getIsCourseplayDriving()) then
			line = g_i18n.modEnvironments[VehicleSort.ModName].texts.cp_course .. ": " .. veh.cp.currentCourseName;
			table.insert(texts, line);
		end
		
		if VehicleSort:isHired(realId) then
			line = g_i18n.modEnvironments[VehicleSort.ModName].texts.helper .. ": " .. VehicleSort:getControllerName(realId);
			table.insert(texts, line);
		end		

		-- Some spacing
		table.insert(texts, " ");		
		
		-- Get vehicle wear
		if veh.getWearTotalAmount ~= nil then
			line = g_i18n.modEnvironments[VehicleSort.ModName].texts.wear .. ": " .. VehicleSort:calcPercentage(veh:getWearTotalAmount(), 1) .. " %";
			table.insert(texts, line);

			local impWear = VehicleSort:getVehImplementsWear(realId);
			if #impWear > 0 then
				for _, v in pairs(impWear) do
					table.insert(texts, v);
				end
			end
		end
		
		-- Some spacing
		table.insert(texts, " ");	
		
		-- Get vehicle filllevel
		
		if string.len(VehicleSort:getFillDisplay(veh, true)) > 1 then
			line = g_i18n.modEnvironments[VehicleSort.ModName].texts.fillLevel .. ":" .. VehicleSort:getFillDisplay(veh, true);
			table.insert(texts, line);
		end
		
		local impFill = VehicleSort:getVehImplementsFillInfobox(realId);
		if #impFill > 0 then
			for _, v in pairs(impFill) do
				table.insert(texts, v);
			end
		end
		
		-- Some spacing
		table.insert(texts, " ");
		
		-- Speed
		line = g_i18n.modEnvironments[VehicleSort.ModName].texts.speed .. ": " .. VehicleStatus:getSpeedStr(veh);
		table.insert(texts, line);
		
		-- Motor on/TurnedOn, Lights
		if VehicleStatus:getIsMotorStarted(veh) then
			line = g_i18n.modEnvironments[VehicleSort.ModName].texts.motor .. ": " .. g_i18n.modEnvironments[VehicleSort.ModName].texts.vs_on;
		else
			line = g_i18n.modEnvironments[VehicleSort.ModName].texts.motor .. ": " .. g_i18n.modEnvironments[VehicleSort.ModName].texts.vs_off;
		end
		table.insert(texts, line);
		
		if VehicleStatus:getIsTurnedOn(veh) then
			line = g_i18n.modEnvironments[VehicleSort.ModName].texts.turnedOn .. ": " .. g_i18n.modEnvironments[VehicleSort.ModName].texts.vs_on;
		else
			line = g_i18n.modEnvironments[VehicleSort.ModName].texts.turnedOn .. ": " .. g_i18n.modEnvironments[VehicleSort.ModName].texts.vs_off;
		end
		table.insert(texts, line);		
		
		if VehicleStatus:getIsLightTurnedOn(veh) then
			line = g_i18n.modEnvironments[VehicleSort.ModName].texts.lights .. ": " .. g_i18n.modEnvironments[VehicleSort.ModName].texts.vs_on;
		else
			line = g_i18n.modEnvironments[VehicleSort.ModName].texts.lights .. ": " .. g_i18n.modEnvironments[VehicleSort.ModName].texts.vs_off;
		end
		table.insert(texts, line);
		
		-- Is on Field?
		
		return texts;
	end
end

function VehicleSort:getVehImplementsWear(realId)
	local texts = {};
	local line = "";

	local implements = VehicleSort:getVehImplements(realId);
	
	for i = 1, #implements do
		local imp = implements[i];
		
		if (imp ~= nil and imp.object ~= nil and imp.object.getWearTotalAmount ~= nil) then
			line = g_i18n.modEnvironments[VehicleSort.ModName].texts.wear .. " (" .. string.gsub(VehicleSort:getAttachment(imp.object), "%s$", "") .. "): " .. VehicleSort:calcPercentage(imp.object:getWearTotalAmount(), 1) .. " %";
			table.insert(texts, line);
		end
	end

	return texts;
end

function VehicleSort:getVehImplementsFillInfobox(realId)
	local texts = {};
	local line = "";

	local implements = VehicleSort:getVehImplements(realId);
	
	for i = 1, #implements do
		local imp = implements[i];
		
		if imp ~= nil and imp.object ~= nil and (string.len(VehicleSort:getFillDisplay(imp.object)) > 1) then
			line = g_i18n.modEnvironments[VehicleSort.ModName].texts.fillLevel .. " (" .. string.gsub(VehicleSort:getAttachment(imp.object), "%s$", "") .. "): " .. VehicleSort:getFillDisplay(imp.object, true);
			table.insert(texts, line);
		end
	end

	return texts;	
end

function VehicleSort:isActionAllowed()
	if g_currentMission.inGameMenu.isOpen or g_currentMission.shopMenu.isOpen then
		return false;
	elseif VehicleSort.showConfig or VehicleSort.showSteerables then
		return true;
	end
end

--
-- Extends default game functions
-- This is required to block the camera zoom & handtool selection while drawlist or drawconfig is open
--
function VehicleSort.onInputCycleHandTool(self, superFunc, _, _, direction)
	if not VehicleSort.showSteerables and not VehicleSort.showConfig then
		superFunc(self, _, _, direction);
	end
end

function VehicleSort.zoomSmoothly(self, superFunc, offset)
	if not VehicleSort.showConfig and not VehicleSort.showSteerables then -- don't zoom camera when mouse wheel is used to scroll displayed list
		superFunc(self, offset);
	end
end

-- I think it's convinient to have the moveup/down fast keys on KEY_1 and KEY_2, but that conflicts with the cruisecontrol
function VehicleSort.setCruiseControlMaxSpeed(self, superFunc, speed)
	if not VehicleSort.showConfig and not VehicleSort.showSteerables then
		superFunc(self, speed);
	end
end

if g_dedicatedServerInfo == nil then
  VehicleCamera.zoomSmoothly = Utils.overwrittenFunction(VehicleCamera.zoomSmoothly, VehicleSort.zoomSmoothly);
  Player.onInputCycleHandTool = Utils.overwrittenFunction(Player.onInputCycleHandTool, VehicleSort.onInputCycleHandTool);
  Drivable.setCruiseControlMaxSpeed = Utils.overwrittenFunction(Drivable.setCruiseControlMaxSpeed, VehicleSort.setCruiseControlMaxSpeed);
end