# Examples

```lua

local floorCode = _("Array").populate(function() 
    local g = 0
    return function()
        if g < 30 then
            g = g + 1
            return g 
        end 
    end 
end)

local floorNum = _("Array").populate(function()
    local floor = -4 
    return function()
        if floor < (floorCode:count() - math.abs(-4)) then
            floor = floor + 1
            if floor < 0 then
                return 'B' .. math.abs(floor)
            elseif floor == 0 then
                return 'G'
            else
                return tostring(floor)
            end
        end
    end
end) --B3 thru 26

local direction = 0 --0 for stop 1 for up -1 for down
local currentFloor = 'G'

print(floorNum)
print(floorCode)

--3 m/s elevator

local actionList = _("Array").fromTable(io.read("*a", "*l")
                    :split("\n"))
                    :remove()
                    
-- Sort by descending order of destination floor
for i = 1, actionList:count() - 1 do
    for j = i + 1, actionList:count() do
        local _, f1, _ = table.unpack(actionList:get(i):split())
        local _, f2, _ = table.unpack(actionList:get(j):split())

        if tonumber(f1) < tonumber(f2) then
            local temp = actionList:get(i)
            actionList:replace(i, actionList:get(j))
            actionList:replace(j, temp)
        end
    end
end

print(actionList)

print("ELEVATOR IN OPERATION")
actionList:forEach(function(action) 
    local command, f, d = table.unpack(action:split())
    
    local function delayFor(duration)
        local start = os.clock()
        while (os.clock() - start) <= duration do --[[nothing]] end
    end 
        
    if direction == 0 then --if lift is stationary at start
        if command == "call" then
            if f == currentFloor then 
                --dont need to append to queue
                goto continue --call action completed
            else
                local currentFloorCode = floorCode:get(floorNum:indexOf(currentFloor))
                local callFloorCode = floorCode:get(floorNum:indexOf(f))
                
                local goingUp = coroutine.create(function()
                    print("==========")
                    while currentFloorCode < callFloorCode do
                        delayFor(0.005)
                        currentFloorCode = currentFloorCode + 1
                        currentFloor = floorNum:get(currentFloorCode)
                        print("Floor: "..currentFloor)
                    end
                    print("==========")
                end)
            
                local goingDown = coroutine.create(function()
                    print("==========")
                    while currentFloorCode > callFloorCode do 
                        delayFor(0.005)
                        currentFloorCode = currentFloorCode - 1
                        currentFloor = floorNum:get(currentFloorCode)
                        print("Floor:"..currentFloor)
                    end
                    print("==========")
                end)
            
                if currentFloorCode < callFloorCode then --it needs to go up
                    print("The lift is going up")
                    direction = 1
                    coroutine.resume(goingUp)
                    print('The lift is now at floor: ' .. currentFloor)
                    --check if the lift is at the top floor
                    if currentFloorCode == floorCode:count() then
                        direction = -1
                    end
                    
                else
                    print("The lift is now going down")
                    direction = -1
                    coroutine.resume(goingDown)
                    print("The lift is not at floor: "..currentFloor)
                    --check if the list at the bottom floor
                    if currentFloorCode == 1 then
                        direction = 1
                    end
                    
                    
                end
            end
        end
        if command == "press" then
            
        end
    end
    ::continue::
end)
```
