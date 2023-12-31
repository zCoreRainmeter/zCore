RepHotkeyArray = {[[Do not replace]], 'Space', 'Enter', 'Tab', 'BackSpace', 'Delete'}

function Set(hotkey, useWin, repHotkeyIndex)
    if hotkey ~= nil then
        local isSend = tonumber(SKIN:GetVariable('Arg.1'))
        -- print(hotkey, useWin, repHotkeyIndex, isSend)
        local SecNum = SKIN:GetVariable('Arg.Index')
        -- --------------------------------- Use win -------------------------------- --
        if useWin == 1 then
            hotkey = '#' .. hotkey
        end
        -- -------------------------------- RepHotkey ------------------------------- --
        if repHotkeyIndex ~= 1 then
            hotkey = hotkey:gsub('%a', '')
            if isSend then
                hotkey = hotkey .. '{' .. RepHotkeyArray[repHotkeyIndex] .. '}'
            else
                hotkey = hotkey .. RepHotkeyArray[repHotkeyIndex]
            end 
        end
        -- ------------------------------ match replace ----------------------------- --
        local matchArray = { '%#', '%!', '%^', '%+' }
        local replaceArray = { 'Win ', 'Alt ', 'Ctrl ', 'Shift ' }
        -- ------------------------------------ - ----------------------------------- --
        local hotkeyString = hotkey
        for i = 1, #matchArray do
            hotkeyString = hotkeyString:gsub(matchArray[i], replaceArray[i])
            hotkeyString = hotkeyString:gsub('[{}]', '')
            hotkeyString = hotkeyString:gsub('%s%a$', ' '.. hotkey:sub(-1):upper())
        end
        -- ---------------------------------- save ---------------------------------- --
        local saveLocation = [[#SKINSPATH##Skin.Name#\@Resources\Actions\HotKeys.ini]]
        -- print(hotkeyString, hotkey)
        SKIN:Bang('[!WriteKeyvalue Variables Key' .. SecNum .. ' "' .. hotkey .. '" "' .. saveLocation .. '"][!WriteKeyvalue Variables Key' .. SecNum .. 'InString "' .. hotkeyString .. '" "' .. saveLocation .. '"][!UpdateMeasure Auto_Refresh:M "#JaxCore\\Main"][!Refresh "#JaxCore\\Main"]')
    end
    SKIN:Bang('[!DeactivateConfig]')
end

function Start()
    local bang = ''
    local winbool = 0
    local rephotkey = RepHotkeyArray[1]
    local currentKey = SKIN:ReplaceVariables('[#Key[#Arg.Index]]')
    local isSend = tonumber(SKIN:GetVariable('Arg.1'))
    if isSend then
        currentKey = currentKey:gsub('[{}]', '')
    end
    if currentKey:find('#') then
        currentKey = currentKey:gsub('#', '')
        winbool = 1
    end
    for i = 1, #RepHotkeyArray do
        if currentKey:find(RepHotkeyArray[i]) then
            currentKey = currentKey:gsub(RepHotkeyArray[i], '')
            rephotkey = RepHotkeyArray[i]
            if not currentKey:match('%a') then
                currentKey = currentKey .. 's'
            end
        end
    end

    local saveLocation = [[#@#Actions\\AHKCacheVariables.inc]]
    bang = bang .. '[!WriteKeyvalue Variables CurrentKey "' .. currentKey .. '" "' .. saveLocation .. '"]'
    bang = bang .. '[!WriteKeyvalue Variables WinBool "' .. winbool .. '" "' .. saveLocation .. '"]'
    bang = bang .. '[!WriteKeyvalue Variables RepHotkey "' .. rephotkey .. '" "' .. saveLocation .. '"]'
    bang = bang .. '[!WriteKeyvalue Variables RMPATH "#PROGRAMPATH#Rainmeter.exe" "' .. saveLocation .. '"]'
    bang = bang .. '[!WriteKeyvalue Variables Config "#CURRENTCONFIG#" "' .. saveLocation .. '"]'
    bang = bang .. '["#@#Actions\\AHKv1.exe" "#@#Actions\\Hotkey.AHK"]'
    SKIN:Bang(bang)
end
