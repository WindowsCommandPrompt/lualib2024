--Li Zhe Yun 2024

table.forEach = function(t, callbackfn)
  for k, v in pairs(t) do if type(k)=="number" then callbackfn(v) end end
end

table.join = function(t, delim)
  delim = delim or ""
  local fullString = ""
  table.forEach(t, function(i) fullString = fullString .. delim .. tostring(i) end)
  return fullString
end 

table.containsKey = function(t, elem) 
  --only search within the array part of the table
  for k, _ in pairs(t) do
    if k == elem then return true end
  end 
  return false
end

table.contains = function(t, elem)
  for k, v in pairs(t) do 
    if v == elem then return true end 
  end 
  return false
end

string.get = function(sample, index)
  if index > sample:len() or index < -(sample:len()) or index == 0 then 
    error("Index out of bounds for string length: " .. string.len(sample))
  elseif index >= -(sample:len()) and index <= -1 then 
    return sample:sub(index, index)
  else 
    return sample:sub(index, index)
  end
end

string.findAllMultiple = function(sample, ...)
  local vararg = {...}
  local results = { }
  for i=1, #vararg do
    table.insert(results, sample:findAll(vararg[i]))
  end 
  return results
end

string.findAll = function(sample, str)
  local matches = { }
  local start, finish = 1, 1 
  repeat 
    start, finish = sample:find(str, finish)
    if start then 
      local match = sample:sub(start, finish)
      table.insert(matches, { 
          match = match,
          start = start, 
          finish = finish
      })
      finish = finish + 1
    end
  until not start
  return matches
end 

string.split = function(sample, regex) --split functions does not accept plain strings. 
  regex = regex or " "
  local portions = { }
  local allMatches = sample:findAll(regex) 
  local marker = 1
  if #allMatches > 0 then
    for i=1, #allMatches+1 do 
      if i == 1 then 
        table.insert(portions, sample:sub(1, allMatches[i].start-1))
        marker = allMatches[i]
      elseif i > 1 and i < #allMatches + 1 then 
        table.insert(portions, sample:sub(marker.finish+1, allMatches[i].start-1)) 
        marker = allMatches[i]
      else 
        table.insert(portions, sample:sub(marker.finish+1, #sample))
      end
    end 
  else 
    table.insert(portions, sample)
  end
  return portions
end

string.contains = function(sample, str)
  for i=1, sample:len() do
    if sample:sub(i, i+str:len()-1)==str then
      return true
    end
  end
  return false
end 

string.removeAll = function(sample, target, start, finish)
  local newString = ""
  start = start or 1
  finish = finish or sample:len()
  for i=start, finish do
    if not target == sample:get(i) then --exclude character from string
      newString = newString .. sample:get(i)
    end
  end
  return newString
end

table.mapElementCount = function(t)
  local count = 0
  for k, v in pairs(t) do 
    if type(k) ~= "number" then
      count = count + 1
    end
  end
  return count
end

string.toCharTable = function(sample) 
    local t = { }
    for i=1, sample:len() do 
        table.insert(t, sample:get(i))
    end
    return t
end

string.containsOneOf = function(sample, list)     
    --[[ 
        Can be used in the following example to parse the following syntax
        'if a == { 'a' or 'b' } then'
    ]]
    assert(type(sample)=="string", "Sample string must be of type 'string', not " .. TypeOf(sample))
    assert(type(list) == "table", "Sample string must be of type 'table', not " .. type(list))
    if type(list) == "table" then 
        --Do table iteration
        for _, v in pairs(list) do 
            if sample:contains(v) then return true end 
        end 
    end 
    return false 
end 

string.locate = function(sample, str)
    local start = -1
    local j = 0
    for i=0, sample:len()-1 do
        if start == -1 and sample:get(i) == str:get(j) then 
            --set anchor
            start = i
            if j == str:len() - 1 then 
                return {
                    begin = start,
                    finish = i
                } 
            end
            j = j + 1
        elseif start ~= -1 and str:get(j) == sample:get(i) then 
            if j == str:len() - 1 then 
                return {
                    begin = start,
                    finish = i
                } 
            end 
            j = j + 1
        else
            start = -1
        end 
    end 
    return nil
end  

string.reverse = function(sample)   
    local newString = ""
    for i=sample:len(),1,-1 do
        newString = newString .. sample:get(i)
    end 
    return newString
end 

local function TRUNCATE_FLOATING_POINT(d, precision)
    return tonumber(string.format(string.format("%s", string.format("%%.%df", precision)), d))
end

local _               = _G

local LUA_VERSION_NUMBER = tonumber(_VERSION:gsub("Lua ", ""):match("%d+%.%d+"))

--Keep track of type names
_["types"]            = { }
local abs             = math.abs

function FinalizeTable(t)
    assert(type(t) == "table", "The argument must be of type table, not: " .. type(t))
    local proxy = { }
    --copy data from t into proxy table
    for k, v in pairs(t) do
        proxy[k] = v
    end 
    --prevent key insertions and array insertions, prevent overriding of functions in table class after proxy table is returned 
    setmetatable(proxy, { 
        --Create rules for the table
        __index = function(self, k)
            return rawget(self, k)
        end,
        __newindex = function(self, k, v)
            error("Unsupported operation exception. Cannot update value")
        end
    })
    setmetatable(table, {
        __newindex = function(tab, k, v) --tab refers to t, not table.
            if not tab[k] then 
                rawset(tab, k, v)
            end
        end,
        insert = function(tab, v)
            if tab == t then 
                error("Unsupported operation exception. Cannot update value")
            end 
        end,
        remove = function(tab, v)
            if tab == t then 
                error("Unsupported operation exception. Cannot remove value from the table")
            end 
        end,
        pack = function(tab, v)
            if tab == t then 
                error("Unsupported operation exception. Cannot transfer values from one table to another") 
            end 
        end
    })
    return proxy --Return proxy table instead of t
end

function GenerateClassNameComplete()
    local index = 1
    while true do
        if not debug.getinfo(index, "n").name  then break end
        index = index + 1
    end
    local constructName = ""
    for i = index-1, 3, -1 do
        constructName = constructName .. '.' .. debug.getinfo(i, 'n').name
    end
    local fullName = constructName:sub(2, #constructName)
    return fullName
end

--Keep track of class types 
function AssignClassName(t, name, super)
    assert(type(t) == "table", "The argument must be of type table, not: " .. type(t))
    assert(type(name)=="string" or type(name)=="nil", "The type of the class must be expressed in the form of a string")
    name = name or GenerateClassNameComplete()
    assert(type(super)=="string" or type(super)=="nil", "The type of the superclass must be expressed in the form of a string")
    --finalize the metatable so that the class 
    local existingMetaTables = getmetatable(t)
    local transfer = { }
    if existingMetaTables then --Check for nil
        for k, v in pairs(existingMetaTables) do 
            transfer[k] = v
        end 
    end 
    transfer["config"] = { 
        __name__ = name,
        __super__ = load(string.format("return %s", super))() or table --All types can be traced back to the table.
    }
    FinalizeTable(transfer["config"])
    --make transfer[config] a readonly field and can only be read in the TypeOf method
    local function MakeConstant(name, t)
        
    end 
    MakeConstant('transfer["config"]', transfer["config"]) 
    setmetatable(t, transfer)
    return t
end 

setmetatable(_["types"], { 
    __index = function(self, k)
        if type(k) == "function" then
            print(debug.getinfo(k, "n").name)
            rawset(_["types"], k, FinalizeTable({ 
                __name__ = "<anonymous function>"
            }))
        else 
            --_["types"] does not accept non-function values as key in this context. 
            error("Sorry, only functions allowed in this context")
        end
    end
})

--ready for typechecking
--[[ 
    function A()
        local instance = { }
        AssignClassName(instance)
        return instance
    end 

    TypeOf(A)   --> should give u 'A' just by passing the function object instead of calling the function.
]] 
function TypeOf(obj)
    if type(obj) == "table" then
        local types = getmetatable(obj)
        if types then 
            return types["config"].__name__
        else 
            return "table"
        end 
    elseif type(obj) == "function" then    
        local allTypes = _["types"]
        for k, v in pairs(allTypes) do
            if k == obj then 
                return v.__name__
            end
        end
        local target = _["types"][obj]
        --repeat for loop
        for k, v in pairs(allTypes) do
            if k == obj then 
                return v.__name__
            end
        end
    else 
        return type(obj)
    end 
end

function TypeOfA(obj)
    local fullType = TypeOf(obj)
    local fullTypeTokens = fullType:split('%.')
    local trueType = fullTypeTokens[#fullTypeTokens]
    return trueType
end

function super(cls)  --Create reference to superclass
    return getmetatable(cls)["config"].__super__()
end

--make static methods callable without calling Array function
setmetatable(_, { 
    __call = function(self, k)
        assert(getmetatable(_G[k]()).__static, "NO STATIC METHODS FOUND!")
        return getmetatable(_G[k]()).__static
    end
})

--enable load static methods
function LoadStatic(target)
    _[TypeOfA(target())] = target
end

--=================================================================================
--Ensure that debug module is NOT nil when this file is executed
assert(debug, "Cannot run this file because the debug module has been set to 'nil'")
--Ensure that string module is NOT nil when this file is executed
assert(string, "Cannot run this file because the string module has been set to 'nil'")
--Ensure that io module is NOT nil when this file is executed
assert(io, "Cannot run this file because the io module has been set to 'nil'")
--Ensure that os module is NOT nil when this file is executed
assert(os, "Cannot run this file because the os module has been set to 'nil'")
--Ensure that table module is NOT nil when this file is executed
assert(table, "Cannot run this file because the table module has been set to 'nil'")

--Assert all built-in modules in lua are of type 'table' 
assert(TypeOf(debug)=="table", "Cannot run this file because the debug module is no longer a table")
assert(TypeOf(string)=="table", "Cannot run this file because the string module is no longer a table")
assert(TypeOf(table)=="table", "Cannot run this file because the table module is no longer a table")
assert(TypeOf(io)=="table", "Cannot run this file because the table io is no longer a table")
assert(TypeOf(os)=="table", "Cannot run this file because the table os is no longer a table")

--Check if contents of built-in modules have been modified
--=================================================================================

function FixedArray(size, ...)
    local vararg = {...}
    assert(TypeOf(size)=="number" or TypeOf(size)=="nil", "The type of the first parameter must be of type number")
    local function Node(item, nextNode)
        local component = {
            item = item,
            next = nextNode
        }
        AssignClassName(component)
        return component
    end 
    local arrayInstance = {  --fixed array instance length
        head = nil, 
        count = function(self)
            local length = 0
            if self.head ~= nil then 
                local currentNode = self.head
                length = length + 1
                while currentNode.next ~= nil do 
                    currentNode = currentNode.next
                    length = length + 1
                end
            end 
            return length
        end,
        set = function(self, index, value)
            local maximumIndex = self:count()
            if index >= 1 and index <= maximumIndex then
                local currentNode = self.head
                if index == 1 then 
                    currentNode.item = value
                else 
                    local pointer = 1
                    while currentNode.next ~= nil and pointer < index do
                        currentNode = currentNode.next 
                        pointer = pointer + 1
                        if pointer == index then 
                            break
                        end
                    end
                    --arrived at the target node
                    currentNode.item = value
                end
                return self
            else 
                error(string.format("Index out of bounds for fixed array length %d with given index %d", maximumIndex, index))
            end
        end,
        toString = function(self)
            local function HandleNestedArraysOrTable(self, item)
                local starting = ""
                if TypeOf(item) == "Array" then
                    local isAllNonArrayOrTable = true
                    for i=1, item:count() do 
                        if TypeOf(item:get(i))=="FixedArray" or TypeOf(item:get(i))=="table" then
                            isAllNonArrayOrTable = false 
                            break
                        end
                    end
                    if isAllNonArrayOrTable then 
                        starting = starting .. item:toString()
                    else 
                        starting = starting .. '['
                        --So long as not table append it to starting
                        for i=1, item:count() do 
                            if TypeOf(item:get(i))=="FixedArray" or TypeOf(item:get(i))=="table" then
                                starting = starting .. HandleNestedArraysOrTable(self, item:get(i))
                            else
                                starting = starting .. item:get(i)
                            end 
                            --Determine is comma is needed 
                            if i ~= item:count() then 
                                starting = starting .. ','
                            end 
                        end 
                        starting = starting .. ']'
                    end 
                elseif TypeOf(item) == "table" then 
                
                end 
                return starting
            end
            local header = "["
            if self.head ~= nil then
                local currentNode = self.head
                if TypeOf(currentNode.item) == "table" or TypeOf(currentNode.item) == "FixedArray" then 
                    header = header .. HandleNestedArraysOrTable(self, currentNode.item) 
                else 
                    header = header .. currentNode.item
                end 
                while currentNode.next ~= nil do
                    currentNode = currentNode.next
                    if TypeOf(currentNode.item) == "table" or TypeOf(currentNode.item) == "FixedArray" then 
                        header = header .. ", " .. HandleNestedArraysOrTable(self, currentNode.item) 
                    else
                        header = header .. ", " .. currentNode.item
                    end 
                end 
            end 
            header = header .. "]"
            return header
        end
    }
    setmetatable(arrayInstance, { 
        __index = function(self, k)
            --I mean obviously you would be indexing the array using integers, right?
            if TypeOf(k) ~= "string" then
                assert(TypeOf(k)=="number", "You should be using integers to index an array, not: " .. TypeOf(k))
                
            end
        end,
        __tostring = function(self)
            return self:toString()
        end
    })
    local function Initialize(length)
        local expr = 'Node(0'
        local times = 1
        while times < length do
            expr = expr .. ',' .. 'Node(0'
            times = times + 1
        end
        expr = expr .. ',' .. 'nil'
        local formatStringForClosingBrackets = "%s"
        local params = "')'"
        times = 1
        while times < length do 
            formatStringForClosingBrackets = formatStringForClosingBrackets .. "%s"
            params = params .. ',' .. "')'"
            times = times + 1
        end
        expr = expr .. load("return "..string.format("string.format(\"%s\", %s)", formatStringForClosingBrackets, params))()
        arrayInstance.head = load([[ 
            local function Node(item, nextNode)
                local component = {
                    item = item,
                    next = nextNode
                }
                AssignClassName(component)
                return component
            end
            return 
        ]]..expr)()
    end
    --perform initialization of FixedArray if size is specified
    if size then
        Initialize(size)
    end 
    AssignClassName(arrayInstance)
    return arrayInstance
end

--[[ TODO: 
string.contains, string.containsOneOf, string.locate, string.get, string.findAll and string.split will be moved into StringExtension. 
]] 
function StringExtension(str)
    assert(TypeOf(str)=="string", "Only accepts string as the parameter, supplied parameter was: " .. TypeOf(str))
    local instance = { 
        sample = str,
        split = function(self, regex)
            local portions = { }
            local allMatches = self.sample:findAll(regex)
            local marker = 1
            for i=1,#allMatches+1 do
                if i == 1 then
                    table.insert(portions, self.sample:sub(1, allMatches[i].start-1))
                    marker = allMatches[i]
                elseif i > 1 and i < #allMatches+1 then
                    table.insert(portions, self.sample:sub(marker.finish+1, allMatches[i].start-1))
                    marker = allMatches[i]
                else 
                   table.insert(portions, self.sample:sub(marker.finish+1, #sample-1))
                end
            end
            return portions
        end,
        findAll = function(self, str)
            local matches = { }
            local start, finish = 1, 1
            repeat
              start, finish = self.sample:find(str, finish)
              if start then
                local match = self.sample:sub(start, finish)
                table.insert(matches, FinalizeTable({ 
                    match = match,
                    start = start,
                    finish = finish
                }))
                finish = finish + 1  
              end
            until not start
            return matches
        end,
        get = function(sample, index)
            if index > string.len(sample) or index < -string.len(sample) or index == 0 then
                error("Index out of bounds for string length: " .. string.len(sample))
            elseif index >= -string.len(sample) and index <= -1 then
                return string.sub(sample, index, index)
            else
                return string.sub(sample, index-1, index)
            end
        end,
        locate = function(self, str)
             local start = -1
                local j = 0
                for i=0, self.sample:len()-1 do
                    if start == -1 and self.sample:get(i) == str:get(j) then 
                        --set anchor
                        start = i
                        if j == str:len() - 1 then 
                            return {
                                begin = start,
                                finish = i
                            } 
                        end
                        j = j + 1
                    elseif start ~= -1 and str:get(j) == self.sample:get(i) then 
                        if j == str:len() - 1 then 
                            return {
                                begin = start,
                                finish = i
                            } 
                        end 
                        j = j + 1
                    else
                        start = -1
                    end 
                end 
                return nil
        end,
        containsOneOf = function(self, list)     
            --[[ 
                Can be used in the following example to parse the following syntax
                'if a == { 'a' or 'b' } then'
            ]]
            assert(TypeOf(self.sample)=="string", "Sample string must be of type 'string', not " .. TypeOf(self.sample))
            assert(TypeOf(list)=="Array" or TypeOf(list) == "table", "Sample string must be of type 'table' or 'Array', not " .. TypeOf(list))
            if type(list) == "table" then 
                --Do table iteration
                for _, v in pairs(list) do 
                    if self:contains(v) then return true end 
                end 
            else 
                list.forEach(function(i) 
                    if self:contains(i) then return true end
                end) 
            end 
            return false 
        end,
        contains = function(self, str)
            --returns boolean
            assert(TypeOf(self.sample)=="string", "Sample string must be of type 'string', not " .. TypeOf(self.sample))
            assert(TypeOf(str)=="string", "Search string must be of type 'string', not " .. TypeOf(str))
            for i = 0, string.len(self.sample) - 1 do
                if string.get(str, 0) == string.get(self.sample, i) and string.sub(self.sample, i+1, i + string.len(str)) == str then
                    return true
                end
            end
            return false
        end,
        length = function(self)
            return self.sample:len()   --string.len(self.sample)
        end, 
        toCharArray = function(self) --Convert string to a character array
            --Returns a fixed array
            local fixedArray = FixedArray(self:length())
            --copy character from string at index position into the fixedArray
            for i=1,fixedArray:count() do
                fixedArray:set(i, self:get(i))
            end
            return fixedArray
        end,
        sub = function(self, start, stop)   --inherit from string class
            return super(self).sub(self.sample, start, stop)
        end,
        lower = function(self)
            return super(self).lower(self.sample)
        end,
        upper = function(self)
            return super(self).upper(self.sample)
        end,
        reverse = function(self)
            return super(self).reverse(self.sample)
        end,
        find = function(self, target, start, finish)
            return super(self).find(self.sample, target, start, finish)
        end,
        gsub = function(self, target, replace)
            return super(self).gsub(self.sample, target, replace)
        end
    }
    setmetatable(instance, { 
        __mul = function(self, multiplier)
            if TypeOf(multiplier)=="number" then
                local template = ""
                for i=1,multiplier do
                    template = template .. self.sample
                end
                return template
            end
        end,
        __static = FinalizeTable({ --All static methods for StringExtension class
            format = function(placeHolder, ...)

                --static reference to superclass
                --return super(StringExtension(str)).format(placeHolder, ...)
            end
        }),
        __concat = function(self, str)  --lua makes it impossible for u to append 'nil' to a string. Now u can
            getmetatable(self)["config"].__super__()
                
        end,
        __tostring = function(self)
            return self.sample
        end
    })
    AssignClassName(instance, GenerateClassNameComplete(), "string") --inherits from 'string'
    return instance
end

function Array(...)
    --if initLength is specified then this array is not growable
    local function Node(item, nextNode)
        local component = {
            item = item,
            next = nextNode
        }
        return component
    end 
    local head = nil
    --Start
    local arrayInstance = {
        head = nil,
        count = function(self)  --Return the length of the array
            local currentNode = head
            local length = 0
            while currentNode ~= nil do
                length = length + 1
                currentNode = currentNode.next 
            end 
            return length
        end,
        reverse = function(self)
            local prevNode = nil
            local currentNode = head
            while currentNode ~= nil do
                local nextNode = currentNode.next
                currentNode.next = prevNode
                prevNode = currentNode
                currentNode = nextNode
            end
            head = prevNode
            return self
        end, 
        insertAt = function(self, index, value)
          if index > self:count() then
            --add a bunch of 'nils'
            repeat 
              self:add(nil)
            until self:count() == index - 1
            self:add(value)
          else 
            --if the specified index is less than self:count()
            local currentNode = head
            if index == 0 then 
              --create a new node
              local newNode = Node(value, head)
              head = newNode
            else
              local count = 1
              repeat
                currentNode = currentNode.next
                count = count + 1
              until currentNode.next == nil or count == index
              local prevNode = head
              repeat
                prevNode = prevNode.next
              until prevNode.next == currentNode
              local newNode = Node(value, currentNode)
              prevNode.next = newNode
            end
          end
          return self
        end,
        replace = function(self, index, value)
          if index >= 1 and index <= self:count() then 
            local currentNode = head
            if index == 1 then
              currentNode.item = value
              return self
            end 
            local count = 1
            repeat
              currentNode = currentNode.next
              count = count + 1
            until currentNode.next == nil or count == index
            currentNode.item = value 
          else 
            error("Index is out of bounds")
          end 
          return self
        end,
        add = function(self, elem)   --Add element into the add of the array
            if head == nil then
                head = Node(elem, nil)
            else
                local currentNode = head
                while currentNode.next ~= nil do
                    currentNode = currentNode.next
                end
                currentNode.next = Node(elem, nil)
            end
            return self
        end,
        pop = function(self)   --pop first element in the array
            if head ~= nil then
                head = head.next
            end 
            return self
        end,
        push = function(self, item)    --insert item at the start of the array
            local newNode = Node(item, head)
            head = newNode
            return self
        end,
        remove = function(self, elem)  --pop last element in the array
            if head ~= nil then
              local currentNode = head
              if elem then
                  --Find the first instance of the element and then removes it
                  if elem == head.item then
                      self:pop()
                  else 
                      while currentNode.next ~= nil do
                        currentNode = currentNode.next
                        if currentNode.item == elem then 
                          break
                        end 
                      end 
                      --Reached the affected node named 'currentNode'
                      if currentNode.next == nil then
                          --Just remove the last node as usual
                          self:remove()
                      else
                          local auxNode = head
                          while auxNode.next ~= currentNode do
                              auxNode = auxNode.next
                          end
                          auxNode.next = currentNode.next
                          --currentNode will be marked for deletion by the lua compiler
                      end 
                  end 
              else 
                  if self:count() > 1 then
                    while currentNode.next ~= nil do 
                        currentNode = currentNode.next
                    end 
                    --currentNode at the end of the linked list
                    local auxNode = head
                    while auxNode.next ~= currentNode do
                        auxNode = auxNode.next
                    end 
                    auxNode.next = nil 
                  elseif self:count() == 1 then 
                    head = nil 
                  end 
              end
          end 
          return self
        end,
        isEmpty = function(self)  --Check if the array is empty or not
            return not head
        end, 
        peek = function(self)  --Return the first item in the array
            return head.item
        end, 
        indexOf = function(self, elem)   --Return the index of the items in the list
            local currentNode = head
            local index = 0
            if head.item == elem or head == nil then 
                return index
            else 
                while currentNode.next ~= nil and currentNode.item ~= elem do
                    currentNode = currentNode.next
                    index = index + 1
                end 
                return index
            end 
        end, 
        get = function(self, index)  --Get item at the specified index
            if index >= 1 and index <= self:count() then 
                local currentNode = head
                if index == 1 then 
                    return currentNode.item 
                else 
                    local currentIndex = 1
                    while currentNode.next ~= nil and currentIndex < index do
                        currentIndex = currentIndex + 1
                        currentNode = currentNode.next 
                    end 
                    return currentNode.item
                end 
            else 
                error("Index out of bounds for length: " .. self:count() .. ". Given: " .. index)
            end 
        end,
        forEach = function(self, callbackfn)   --Loops through each element in the list
            if head ~= nil then
                local currentNode = head
                callbackfn(currentNode.item)
                while currentNode.next ~= nil do
                    currentNode = currentNode.next
                    callbackfn(currentNode.item)
                end 
            end 
        end,
        subList = function(self, start, stop)
            if start >= 1 and stop <= self:count() then
                local newArray = Array()
                for i=start, stop do
                    newArray:add(self:get(i))
                end 
                return newArray
            else 
                error("Index out of bounds. Given:\n start: " .. start .. "\n stop: " .. stop .. "\n for list of length: " .. self:count())
            end 
        end,
        indexOfRange = function(self, subList)
            local startIndex = nil
            local endIndex = nil
            local sublistLength = subList:count()
            local selfLength = self:count()

            for i = 1, selfLength - sublistLength + 1 do
                local match = true

                for j = 1, sublistLength do
                    if self:get(i + j - 1) ~= subList:get(j) then
                        match = false
                        break
                    end
                end

                if match then
                    startIndex = i
                    endIndex = i + sublistLength - 1
                    break
                end
            end

            return { 
                start = startIndex, 
                finish = endIndex 
            }
        end, 
        contains = function(self, item)
 -- Checks whether sublist exists within the list
            if TypeOfA(sublist) == "Array" then
                local sublistLength = sublist:count()
                if sublistLength == 0 then
                    return true  -- Empty sublist always exists in any list
                end
                local listLength = self:count()
                for i=1,listLength do
                    if TypeOfA(self:get(i)) == "Array" then
                        if self:get(i):count() ~= sublistLength then 
                            goto continue
                        end
                        for j=1, sublistLength do
                            if self:get(i):get(j) ~= sublist:get(j) then
                                goto continue
                            end
                        end
                        return true
                    end 
                    ::continue::
                end
                return false
            else 
                if head ~= nil then
                    local currentNode = head
                    while currentNode ~= nil do
                        -- Check if the current node matches the sublist
                        local match = true
                        local sublistNode = sublist.head
                        local currentNodeToCheck = currentNode

                        while sublistNode ~= nil and currentNodeToCheck ~= nil do
                            if currentNodeToCheck.item ~= sublistNode.item then
                                match = false
                                break
                            end
                            sublistNode = sublistNode.next
                            currentNodeToCheck = currentNodeToCheck.next
                        end

                        if match and sublistNode == nil then
                            return true
                        end

                        currentNode = currentNode.next
                    end
                end
                return false
            end 
        end,
        toString = function(self)  --Return the array in a string representation
            local function HandleNestedArraysOrTable(self, item)
                local starting = ""
                if TypeOf(item):contains("Array") or TypeOf(item):contains("DoublyLinkedList") then
                    local isAllNonArrayOrTable = true
                    for i=1, item:count() do 
                        if TypeOf(item:get(i)):contains("Array") or TypeOf(item:get(i)):contains("DoublyLinkedList") or TypeOf(item:get(i))=="table" then
                            isAllNonArrayOrTable = false 
                            break
                        end
                    end
                    if isAllNonArrayOrTable then 
                        starting = starting .. item:toString()
                    else 
                        starting = starting .. '['
                        --So long as not table append it to starting
                        for i=1, item:count() do 
                            if TypeOf(item:get(i)):contains("Array") or TypeOf(item:get(i)):contains("DoublyLinkedList") or TypeOf(item:get(i))=="table" then
                                starting = starting .. HandleNestedArraysOrTable(self, item:get(i))
                            else
                                if Array("number", "string", "boolean", "function", "thread", "userdata"):contains(TypeOf(item:get(i))) then
                                    starting = starting .. item:get(i)
                                else 
                                    starting = starting .. "nil"
                                end
                            end 
                            --Determine is comma is needed 
                            if i ~= item:count() then 
                                starting = starting .. ','
                            end 
                        end 
                        starting = starting .. ']'
                    end 
                elseif TypeOf(item) == "table" then 
                
                end 
                return starting
            end
            local header = "["
            if head ~= nil then
                local currentNode = head
                if TypeOf(currentNode.item) == "table" or TypeOf(currentNode.item):contains("Array") or TypeOf(currentNode.item):contains("DoublyLinkedList") then 
                    header = header .. HandleNestedArraysOrTable(self, currentNode.item) 
                else 
                    if Array("number", "string", "boolean", "function", "thread", "userdata"):contains(TypeOf(currentNode.item)) then
                        header = header .. currentNode.item
                    else
                        header = header .. "nil"
                    end
                end 
                while currentNode.next ~= nil do
                    currentNode = currentNode.next
                    if TypeOf(currentNode.item) == "table" or TypeOf(currentNode.item):contains("Array") or TypeOf(currentNode.item):contains("DoublyLinkedList") then 
                        header = header .. ", " .. HandleNestedArraysOrTable(self, currentNode.item) 
                    else
                        if Array("number", "string", "boolean", "function", "thread", "userdata"):contains(TypeOf(currentNode.item)) then
                            header = header .. ", " .. currentNode.item
                        else
                            header = header .. ", " .. "nil"
                        end
                    end 
                end 
            end 
            header = header .. "]"
            return header
        end,
        toFixedArray = function(self)
            --Once the array is converted into a fixed array, the contents with the array cannot be modified anymore.
            local fixedArrayCallString = "FixedArray(nil"
            if head ~= nil then
                local currentNode = head
                fixedArrayCallString = fixedArrayCallString .. string.format(",%s", currentNode.item)
                while currentNode.next ~= nil do
                    currentNode = currentNode.next
                    fixedArrayCallString = fixedArrayCallString .. string.format(",%s", currentNode.item)
                end 
                fixedArrayCallString = fixedArrayCallString .. ")"
            else
                fixedArrayCallString = fixedArrayCallString .. ")"
            end 
            return load(string.format("return %s", fixedArrayCallString))()
        end,
        filter = function(self, predicate) 
            local newArray = Array() --to be copied to
            self:forEach(function(item) 
                assert(TypeOf(predicate(item))=="boolean", "Predicates must return a boolean")
                if predicate(item) then
                    newArray:add(item)
                end 
            end)
            return newArray
        end, 
        flatten = function(self)
            local tokenStack = Array()
            local charArray = _("Array").fromTable(self:toString():toCharTable())
            local nestCount = 0
            charArray:forEach(function(token)
                if charArray:isEmpty() and token == '[' then
                    charArray:push(token)
                end
                if token == ']' and not charArray:isEmpty() and charArray:peek() == '[' then
                    charArray:pop()
                    nestCount = nestCount + 1
                end
            end)
            local chunk = load((function() 
                local placeholderVariables = { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z' }
                local forLoops = [[local array = Array() 
]]
                for i=1, nestCount do
                    forLoops = forLoops .. string.format("for %s=1, %d do \n\t ", placeholderVariables[i], 3) 
                end
                forLoops = forLoops .. '\n' .. string.rep("\t", nestCount) .. "array:add(self" .. (function() 
                    local gets = ""
                    for i=1, nestCount do
                        gets = gets .. ":get(" .. placeholderVariables[i] .. ")"
                    end 
                    return gets
                end)() .. ")"
                for i = nestCount, 1, -1 do
                    forLoops = forLoops .. '\n' .. string.rep("\t", i-1) .. "end"
                end
                forLoops = forLoops .. "\n"
                forLoops = forLoops .. "return array"
                return forLoops
            end)(), "flattenArrayChunk", "t", { self = self, Array = Array })
            local outArray = chunk() -- Execute the loaded function to capture the changes to 'array'
            return outArray
        end, 
        reduce = function(self, collector, bifunction)
            assert(debug.getinfo(bifunction, "Sunfl").nparams==2, "Bifunction must have exactly 2 parameters. Given: " .. debug.getinfo(bifunction, "Sunfl").nparams)
            self:forEach(function(item) 
                collector = bifunction(collector,item)
            end)
            return collector
        end,
        map = function(self, mappingFunction)
            local newArray = Array() --to be mapped to
            self:forEach(function(item) 
                local mappingResult = mappingFunction(item)
                assert(TypeOf(mappingResult)~="nil", "Must return a type")
                newArray:add(mappingResult)
            end)
            return newArray
        end,
        --use pcall for this function (recommended)
        sum = function(self)
            local total = 0
            local currentNode = head
            local currentIndex = 1
            if TypeOf(currentNode.item)=="number" then
                total = total + currentNode.item
                currentIndex = currentIndex + 1
            end
            while currentNode.next ~= nil do
                currentNode = currentNode.next
                currentIndex = currentIndex + 1
                if TypeOf(currentNode.item)=="number" then 
                    total = total + currentNode.item
                else 
                    error("A non-number is detected in the array! Failed to perform sum. Erroneous item index: " .. i .. " which is of type: " .. TypeOfA(currentNode.item))
                end 
            end 
            return total
        end,
        min = function(self)
            --all elements in the array must be of type number
            local minimum = 0
            local currentNode = head
            local currentIndex = 1
            if TypeOf(currentNode.item)=="number" then
                minimum = currentNode.item
                currentIndex = currentIndex + 1
            end
            while currentNode.next ~= nil do
                currentNode = currentNode.next
                if TypeOfA(currentNode.item) == "number" then
                    if currentNode.item < minimum then
                        minimum = currentNode.item
                    end 
                else
                    error("Failed to get max. Non-number value found.")
                end 
            end
        end, 
        max = function(self)
            --all elements in the array must be of type number
            local maximum = 0
            local currentIndex = 0
            if not self:isEmpty() then
                local currentNode = head 
                if TypeOfA(currentNode.item) == "number" then
                    maximum = currentNode.item
                else 
                    error("Failed to get max. Non-number value found.") 
                end
                while currentNode.next ~= nil do
                    currentNode = currentNode.next
                    if TypeOfA(currentNode.item) == "number" then
                        if currentNode.item > maximum then
                            maximum = currentNode.item
                        end 
                    else
                        error("Failed to get max. Non-number value found.")
                    end
                end 
                return maximum
            else 
                return maximum 
            end 
        end, 
        indexOfAll = function(self, item)
            local indices = Array()
            if not self:isEmpty() then
                for i=1, self:count() do
                    if self:get(i) == item then
                        indices:add(i)
                    end 
                end 
            end 
            return indices
        end, 
        removeAt = function(self, index)
            if not self:isEmpty() then
                local currentNode = head
                if index == 1 then
                    self:pop()
                elseif index == self:count() then
                    self:remove() 
                else 
                    local traversals = 1
                    while traversals < index do
                        currentNode = currentNode.next
                    end  
                    local auxNode = head
                    while auxNode.next ~= currentNode do 
                        auxNode = auxNode.next
                    end 
                    auxNode.next = currentNode.next
                end 
            end 
            return self 
        end, 
        isSorted = function(self, ascending)
            ascending = ascending or true
            local first = self:get(1)
            for i = 2, self:count() do
                if self:get(i) < first then
                    return false
                end
                first = self:get(i)
            end
            return true
        end, 
        sort = function(self, ascending)
            --if strings or other data types use radix sort 
            --if numbers use selection sort
            ascending = ascending or true
            local allTypes = self
                :map(function(item) return TypeOfA(item) end)
                :reduce({ }, function(a, b) 
                    a[b] = Array()
                    return a 
                end)
            --utilize __lt metamethod, and it must not be nil otherwise the sorting will fail.
            for k, v in pairs(allTypes) do
                self:forEach(function(item) 
                    if TypeOfA(item) == k then
                        v:add(item)
                    end
                end) 
            end
            for t, v in pairs(allTypes) do
                if t == "number" then
                    local start = 1
                    local stop = v:count()
                    
                    local function repeatSort(v, start, stop)
                        if start >= stop then
                            return
                        end

                        local smallest = v:get(start)
                        local largest = v:get(start)

                        for i = start, stop do
                            local value = v:get(i)
                            if value < smallest then
                                smallest = value
                            elseif value > largest then
                                largest = value
                            end
                        end

                        local indexToReplaceSmallestArray = Array()
                        local indexToReplaceLargestArray = Array()

                        for i = start, stop do
                            if v:get(i) == smallest then
                                indexToReplaceSmallestArray:add(i)
                                
                            end
                            if v:get(i) == largest then
                                indexToReplaceLargestArray:add(i)
                            end
                        end
                        
                        if indexToReplaceSmallestArray:count() == 1 then
                            local originalStartValue = v:get(start)
                            v:replace(start, smallest)
                            v:replace(indexToReplaceSmallestArray:get(1), originalStartValue)
                        else 
                            local begin = start 
                            for i=1,indexToReplaceSmallestArray:count() do
                                local originalValue = v:get(begin)
                                if originalValue ~= smallest then
                                    v:replace(begin, smallest)
                                    v:replace(indexToReplaceSmallestArray:get(i), originalValue)
                                end 
                                begin = begin + 1
                            end 
                            start = start + indexToReplaceSmallestArray:count() - 1
                        end 
                        
                        if indexToReplaceLargestArray:count() == 1 then
                            local originalStopValue = v:get(stop)
                            v:replace(stop, largest)
                            v:replace(indexToReplaceLargestArray:get(1), originalStopValue) 
                        else 
                            local last = stop
                            for i=1,indexToReplaceLargestArray:count() do 
                                local originalValue = v:get(last)
                                if originalValue ~= largest then 
                                    v:replace(last, largest)
                                    v:replace(indexToReplaceLargestArray:get(i), originalValue)
                                end
                                last = last - 1
                            end 
                            stop = stop - indexToReplaceLargestArray:count() + 1
                        end
                        print('LIST: ', v)
                        repeatSort(v, start + 1, stop - 1)
                    end
                    
                    repeatSort(v, start, stop)
                    
                    print("============================================")
                else 
                    for i=1,v:count() do    
                        local ltOp = getmetatable(v).__lt
                        local gtOp = getmetatable(v).__gt
                        if ltOp then
                            ltOp(v:get(i), v:get(i+1))
                        elseif gtOp then 
                            
                        else 
                            error("Unable to sort the " .. TypeOfA(v) .. " elements in the array.")
                        end
                    end
                end
            end 
            local returnArr = Array()
            for k, v in pairs(allTypes) do
                returnArr = returnArr + v
            end
            return returnArr
        end,
        toUnmodifiableSet = function(self)
            
        end,
        enumerate = function(self)
            local index = 1
            local size = self:count()
            return function() 
                if index <= size then 
                    local value = self:get(index)
                    index = index + 1
                    return index, value
                end 
            end 
        end, 
        allOf = function(self, predicate)
            if not self:isEmpty() then
                local currentNode = head
                if not predicate(currentNode.item) then
                    return false
                end 
                while currentNode.next ~= nil do
                    currentNode = currentNode.next
                    if not predicate(currentNode.item) then 
                        return false
                    end 
                end 
                return true
            end 
            return false  
        end,
        combinations = function(arr, size)
            local combinations = Array()
            size = size or arr:count()
            if not arr:isEmpty() then
                if size == 1 then
                    arr:forEach(function(item) combinations:add(Array(item)) end)
                    combinations = combinations:reduce(Array(), function(a, b) 
                        if not a:contains(b) then 
                            a:add(b) 
                        end 
                        return a 
                    end)
                elseif size == 2 then
                    local index=1
                    local offset=1
                    local bucket=Array()
                    while index <= arr:count() do
                        if index + offset <= arr:count() then
                            bucket:add(arr:get(index))
                            bucket:add(arr:get(index + offset)) 
                            combinations:add(bucket)
                            bucket = Array()
                        end 
                        offset = offset + 1
                        if offset == arr:count() then
                            index = index + 1
                            offset = 1
                        end
                    end
                    --reverse find
                    local index=arr:count()
                    local offset=1
                    while index >= 1 do
                        if index - offset >= 1 then
                            bucket:add(arr:get(index))
                            bucket:add(arr:get(index - offset)) 
                            combinations:add(bucket)
                            bucket = Array()
                        end 
                        offset = offset + 1
                        if offset == arr:count() then
                            index = index - 1
                            offset = 1
                        end
                    end
                    combinations = combinations:reduce(Array(), function(a, b) 
                        if not a:contains(b) then 
                            a:add(b) 
                        end 
                        return a 
                    end)
                else --3 and above
                    local n = arr:count()
                    if size > n then
                        size = n
                    end

                    for i = 1, n - size + 1 do
                        for j = i + 1, n - size + 2 do
                            local combination = Array()
                            combination:add(arr:get(i))
                            combination:add(arr:get(j))

                            if size > 2 then
                                local remaining = size - 2
                                local k = j + 1
                                while remaining > 0 and k <= n do
                                    combination:add(arr:get(k))
                                    k = k + 1
                                    remaining = remaining - 1
                                end
                            end

                            combinations:add(combination)
                        end
                    end
                    
                        -- Reverse combinations
                    for i = n, size, -1 do
                        for j = i - 1, size, -1 do
                            local combination = Array()
                            combination:add(arr:get(i))
                            combination:add(arr:get(j))

                            if size > 2 then
                                local remaining = size - 2
                                local k = j - 1
                                while remaining > 0 and k >= 1 do
                                    combination:add(arr:get(k))
                                    k = k - 1
                                    remaining = remaining - 1
                                end
                            end

                            combinations:add(combination)
                        end
                    end

                    combinations = combinations:reduce(Array(), function(a, b) 
                        if not a:contains(b) then 
                            a:add(b) 
                        end 
                        return a 
                    end)
                end 
            end 
            print(combinations)
            return combinations
        end 
    }
    setmetatable(arrayInstance, { 
        __tostring = function(self) 
            return self:toString()
        end,
        __add = function(self, operand)
            --merge two arrays together
            if TypeOfA(operand) == "Array" then
                operand:forEach(function(item) 
                    self:add(item)
                end)
                return self
            else 
                error("The operand must be of type 'Array' in order to continue. Given: " .. TypeOfA(operand))
            end
        end,
        __lt = function(self, operand)
            if self:count() < operand:count() then
                return true
            else
                return false
            end
        end,
        __static = FinalizeTable({   -- public static Array fromTable(table t)    DAB
            fromTable = function(t)
                assert(TypeOfA(t)=="table", "This function can only accept tables, Given: " .. TypeOfA(t)) 
                --Only take array part
                local newArray = Array()
                for k, v in pairs(t) do
                    if TypeOf(k)=="number" then
                        newArray:add(v)
                    end
                end
                return newArray
            end,
            unpack = function(arr) 
                --shallow unpacking only
                assert(TypeOfA(arr) == "Array", "The first argument must be of type 'Array'. Given: " .. TypeOfA(arr))
                local t = { }
                for i=1, arr:count() do
                    table.insert(t, arr:get(i))
                end 
                return table.unpack(t)
            end,
            deepUnpack = function(arr)
                assert(TypeOfA(arr) == "Array", "The first argument must be of type 'Array'. Given: " .. TypeOfA(arr))
                local t = { }
                for i = 1, arr:count() do
                    if TypeOfA(arr:get(i)) ~= "Array" then -- Corrected condition
                        table.insert(t, arr:get(i))
                    else 
                        table.insert(t, getmetatable(arrayInstance).__static.deepUnpack(arr:get(i))) -- Capture the result of the recursive call
                    end 
                end
                return table.unpack(t)
            end,
            fill = function(what, length)
                length = length or 1
                assert(TypeOfA(length) == "number")
                local newArray = Array()
                for i=1, length do
                    newArray:add(what)
                end 
                return newArray
            end, 
            populate = function(iterator)
                local newArray = Array()
                for i in iterator() do
                    newArray:add(i)
                end
                return newArray
            end
        }),
        __eq = function(self, other)
            assert(TypeOfA(self) == "Array" and TypeOfA(other) == "Array", "Both arguments need to be of type 'Array', arg1 is of type: " .. TypeOfA(self) .. " and arg 2 is of type: " .. TypeOfA(other))
            if self:count() == other:count() then 
                for i = 1, self:count() do
                    print('current: ', self:get(i), 'other: ', other:get(i))
                    if self:get(i) ~= other:get(i) then
                        return false
                    end 
                end
            else 
                return false
            end 
            return true
        end
    })
    setmetatable(getmetatable(arrayInstance).__static, { 
        __index = function(self, k)
            error("Symbol not found: " .. tostring(k))
        end,
        __newindex = function(self, k, v)
            error("You are not allowed to modify this.")
        end
    })
    local varargLength = select("#", ...)
    --Check for contents in vararg
    if varargLength > 0 then
        --Copy items from vararg table into array.
        local newArray = Array()
        for i=1, varargLength do
            newArray:add(select(i, ...))
        end
        return newArray
    end
    --Assign a type name to the
    AssignClassName(arrayInstance)
    return arrayInstance
end
LoadStatic(Array)

--include the Array class into _G
_[TypeOf(Array())] = Array

--make static methods callable without calling Array function
setmetatable(_, { 
    __call = function(self, k)
        assert(getmetatable(_G[k]()).__static, "NO STATIC METHODS FOUND!")
        return getmetatable(_G[k]()).__static
    end
})

--BitArray class that allows users to perform bitwise operations on numbers before the release of Lua 5.3 
function BitArray(num) 
    num = num or 1
    --convert to binary number
    local digits = Array()
    if TypeOfA(num) == "number" then
        expr = tostring(num)
        while math.floor(expr / 2) > 0 do
            digits:add(expr % 2)
            expr = math.floor(expr / 2)
        end 
        digits:add(expr % 2)
        digits:reverse()
    else 
        for i=1,num:len() do
            digits:add(num:get(i)) 
        end 
    end 
    local instance = { 
        count = function(self)
            return digits:count()
        end, 
        bitShiftLeft = function(self, spaces)
            for i=1,spaces do 
                digits:pop()
            end
            return self 
        end, 
        bitShiftRight = function(self, spaces)
            for i=1,spaces do
                digits:remove()
            end
            return self
        end,
        bitwiseAnd = function(self, other)
            if TypeOfA(other)=="BitArray" then
                local enumerator = _("Array").fromTable(other:toString():toCharTable()):map(tonumber):enumerate()
                digits:map(function(i) 
                    if i ~= enumerator() then
                        return 0
                    else 
                        return 1
                    end 
                end)
            elseif TypeOfA(other) == "number" then
                other = BitArray(other)
                self:bitwiseAnd(other)
            end
            return self
        end,
        bitwiseOr = function(self, other)
            if TypeOfA(other)=="BitArray" then
                local enumerator = _("Array").fromTable(other:toString():toCharTable()):map(tonumber):enumerate()
                digits:map(function(i) 
                    if i == 0 and enumerator() == 0 then
                        return 0
                    else
                        return 1
                    end
                end) 
            elseif TypeOfA(other) == "number" then
                other = BitArray(other)
                self:bitwiseOr(other)
            end
            return self
        end, 
        bitwiseXor = function(self, other)
            if TypeOfA(other)=="BitArray" then
                print('current: ', self)
                print('other: ', other)
                local enumerator = _("Array").fromTable(other:toString():toCharTable()):map(tonumber):enumerate()
                digits = digits:map(tonumber):map(function(i) 
                    local index, value = enumerator()
                    if i == value then 
                        return 0
                    else 
                        return 1
                    end 
                end)
            elseif TypeOfA(other) == "number" then 
                other = BitArray(other)
                self:bitwiseXor(other)
            end 
            return self 
        end, 
        bitwiseNot = function(self)
            --inverse all the bits in digits
            digits:map(function(item)  
                if item == 1 then 
                    return 0 
                else 
                    return 1
                end 
            end)
        end,
        toString = function(self)
            return digits:reduce("", function(a, b) a = a .. b; return a end)
        end 
    }
    setmetatable(instance, { 
        __tostring = function(self)
            return self:toString() 
        end, 
        __add = function(self, other)
            if TypeOfA(other)=="BitArray" then 
                local dOther = _("Array").fromTable(other:toString():toCharTable()):map(tonumber):reduce(0, function(a, b) a = (a * 2) + b; return a end)
                local dSelf = digits:reduce(0, function(a, b) a = (a * 2) + b; return a end)
                return BitArray(dOther + dSelf)
            elseif TypeOfA(other) == "number" then 
                local dSelf = digits:reduce(0, function(a, b) a = (a * 2) + b; return a end)
                return BitArray(other + dSelf)
            end 
        end, 
        __static = { 
            fromString = function(str)
                local charArray = _("Array").fromTable(str:toCharTable())
                if charArray:allOf(function(item) return item == '1' or item == '0' end) then
                    --construct the Binary Array from the string 
                    return BitArray(str)
                else 
                    error("Binary strings can only contain '1' or '0' as the value.")
                end 
            end
        }
    })
    AssignClassName(instance)
    return instance
end
LoadStatic(BitArray)

local FastMatrix = { }

setmetatable(FastMatrix, { 
    __call = function(self, w, h)
        w = w or 1
        h = h or 1
        local function Node(up, down, left, right, item)
            local instance = { 
                up = up, 
                down = down, 
                left = left, 
                right = right,
                item = item
            }
            return instance
        end
        local function UpdateLocationToAdd(newRow, newCol)
            newRow = newRow or 1
            newCol = newCol or 1
            return { 
                row = newRow,
                col = newCol
            }
        end 
        local whereToAdd = nil 
        local instance = { 
            head = nil, 
            getLength = function(self)
                return w
            end, 
            getHeight = function(self)
                return h
            end, 
            isEmpty = function(self)
                return self.head == nil
            end, 
            add = function(self, item) 
                --Construct the node in this 
                if self:isEmpty() then 
                    local newNode = Node(nil, nil, nil, nil, item)
                    self.head = newNode
                    whereToAdd = UpdateLocationToAdd(1, 2)
                else 
                    if whereToAdd.row == 1 then
                        --up, down, right should be nil for now
                        --traverse on the first row to the prevNode
                        local currentNode = self.head
                        while currentNode.right ~= nil do
                            currentNode = currentNode.right
                        end 
                        --got the previous node
                        local newNode = Node(currentNode, nil, nil, nil, item)
                        currentNode.right = newNode
                        if whereToAdd.col < w then
                            whereToAdd = UpdateLocationToAdd(whereToAdd.row, whereToAdd.col + 1)
                        else 
                            whereToAdd = UpdateLocationToAdd(whereToAdd.row + 1, 1)
                        end
                    else --if it is not the first row
                        --get the node directly above it
                        local currentNode = self.head
                        while currentNode.down ~= nil do
                            currentNode = currentNode.down
                        end
                        --newNode should be bound to currentNode
                        if whereToAdd.col == 1 then
                            --left, right, down is nil
                            local newNode = Node(currentNode, nil, nil, nil, item)
                            currentNode.down = newNode
                        
                        else 
                            while currentNode.right ~= nil do
                                currentNode = currentNode.right
                            end
                            --currentNode now needs to be on the left
                            --we need to get the up element
                            local upElement = currentNode.up.right
                            --bind upElement and currentNode to newNode
                            local newNode = Node(upElement, nil, currentNode, nil, item)
                            upElement.down = newNode
                            currentNode.right = newNode
                        end 
                        
                        if whereToAdd.col < w then
                            whereToAdd = UpdateLocationToAdd(whereToAdd.row, whereToAdd.col + 1)
                        else 
                            whereToAdd = UpdateLocationToAdd(whereToAdd.row + 1, 1)
                        end
                    end
                end 
                return self
            end,
            get = function(self, row, col)
                if not self:isEmpty() then
                    local rowTraverse = 1
                    local currentNode = self.head
                    if row == 1 and col == 1 then
                        return currentNode.item
                    end
                    while rowTraverse < row do
                        rowTraverse = rowTraverse + 1
                        currentNode = currentNode.right
                    end
                    local colTraverse = 1
                    while colTraverse < col do
                        colTraverse = colTraverse + 1
                        currentNode = currentNode.down
                    end
                    return currentNode.item
                else 
                    error("The matrix is empty. Unable to index.")
                end  
            end,
            reset = function(self)
                self.head = nil 
                return self
            end,
            toString = function(self)
                local outString = ""
                if not self:isEmpty() then
                    local firstNode = self.head
                    local firstNodeReference = self.head
                    outString = outString .. (firstNode.item or "nil")
                    outString = outString .. " "
                    while firstNode.right ~= nil do
                        firstNode = firstNode.right 
                        outString = outString .. (firstNode.item or "nil")
                        outString = outString .. " "
                    end 
                    outString = outString .. "\n"
                    while firstNodeReference.down ~= nil do
                        firstNodeReference = firstNodeReference.down
                        firstNode = firstNodeReference
                        outString = outString .. (firstNode.item or "nil")
                        outString = outString .. " "
                        while firstNode.right ~= nil do
                            firstNode = firstNode.right
                            outString = outString .. (firstNode.item or "nil")
                            outString = outString .. " " 
                        end      
                        outString = outString .. "\n"
                    end 
                    --fill up remaining empty cells with 'nil'
                    
                end
                return outString
            end,
            contains = function(self, other)
                local testFrameWidth = other:getLength()
                local testFrameHeight = other:getHeight()
                local testFrame = FastMatrix(testFrameWidth, testFrameHeight)
                
                for rowOffset = 0, self:getHeight() - testFrameHeight do
                    for colOffset = 0, self:getLength() - testFrameWidth do
                        for i = 1, testFrameHeight do
                            for j = 1, testFrameWidth do
                                testFrame:add(self:get(j + colOffset, i + rowOffset)) 
                            end 
                        end 
                        --print(testFrame:toString())
                        --print("=======================")
                        if testFrame:toString() == other:toString() then
                            return true
                        end 
                        testFrame:reset()
                    end 
                end 
                
                return false
            end
        }
        setmetatable(instance, { 
            __tostring = function(self) 
                return self:toString()
            end 
        })
        return instance
    end
})

function FastMatrix.fromTable(t)
    local newFastMatrix = FastMatrix(t[1]:len(), #t)
    for i=1, #t do
        for j=1,t[i]:len() do
            newFastMatrix:add(t[i]:sub(j,j))
        end
    end 
    return newFastMatrix
end

--Array based binary tree without pointers :)   (WIP) 
local function BinaryTree()
    local expr = { }
    local size = 0
    local temp = nil 
    local location = BitArray(0)
    local instance = { 
        add = function(self, item)
            if size == 0 then
                expr[0] = { }
                expr[0]['v'] = item
                size = size + 1
            else 
                local locator = "expr[0]"
                print(location, item)
                if _("Array").fromTable(location:toString():toCharTable()):subList(2):allOf(function(item) return item == '0' end) then 
                    --needs to advance'
                else 
                    
                end 
                location = location + 1
                size  = size + 1
            end
            return self
        end,
        toString = function(self)
            return expr
        end 
    }
    setmetatable(instance, { 
        __tostring = function(self)
            return ""
        end 
    })
    AssignClassName(instance)
    return instance
end 

local function CyclicArray(...)
    local function Node(item, next)
        local instance = { 
            item = item, 
            next = next
        }
        AssignClassName(instance, GenerateClassNameComplete())
        return instance
    end 
    local size = 0
    local arrayInstance = { 
        head = nil, 
        isEmpty = function(self)
            return super(self).isEmpty(self)
        end,
        indexOf = function(self, item)
            return super(self).indexOf(self, item)
        end,
        count = function(self)
            return size 
        end, 
        add = function(self, item)
            --Implementation is similar to the 'add' function in the 'Array' class
            if self:isEmpty() then
                local newNode = Node(item, nil)
                newNode.next = newNode
                self.head = newNode
            else 
                local movement = 1
                local currentNode = self.head 
                while movement < size do
                    currentNode = currentNode.next 
                    movement = movement + 1
                end
                local newNode = Node(item, self.head)
                currentNode.next = newNode
            end 
            size = size + 1
            return self
        end, 
        replace = function(self, index, value)
            --do modulo arithmetic here so long as index is greater than 1
            if index > size then 
                index = (index - 1) % (size + 1)
            end 
            super(self).replace(self, index, value)
            return self
        end,
        get = function(self, index)
            if index > size then 
                index = (index - 1) % size + 1
            end 
            return super(self).get(self, index)
        end, 
        removeAt = function(self, index)
            if index > size then
                index = (index - 1) % size + 1
            end
            size = size - 1
            return super(self).removeAt(self, index)
        end, 
        peek = function(self)
            return super(self).peek(self) 
        end, 
        forEach = function(self, callbackfn)
            for i=1,size do
                callbackfn(self:get(i))
            end
        end, 
        toString = function(self)
            local function HandleNestedCyclicArrays()
                
            end
            local outString = "["
            if self.head ~= nil then
                local currentNode = self.head
                if Array("number", "string", "boolean", "function", "thread", "userdata"):contains(TypeOf(currentNode.item)) then
                    outString = outString .. currentNode.item
                elseif TypeOf(currentNode.item) == "nil" then
                    outString = outString .. "nil"
                elseif TypeOfA(currentNode.item) == "Array" then
                    outString = outString .. super(self).toString(currentNode.item)
                end
                local traversals = 1
                while traversals < size do
                    currentNode = currentNode.next
                    if Array("number", "string", "boolean", "function", "thread", "userdata"):contains(TypeOf(currentNode.item)) then
                        outString = outString .. ", " .. currentNode.item
                    elseif TypeOf(currentNode.item) == "nil" then
                        outString = outString .. ", " .. "nil"
                    elseif TypeOfA(currentNode.item) == "Array" then
                        outString = outString .. ", " .. super(self).toString(currentNode.item)
                    end
                    traversals = traversals + 1
                end
            end 
            outString = outString .. "]"
            return outString 
        end
    }
    setmetatable(arrayInstance, { 
        __tostring = function(self)
            return self:toString()
        end, 
        __static = { 
            fromTable = function(t)
                local newCyclicArray = CyclicArray()
                for i=1,#t do 
                    newCyclicArray:add(t[i])
                end 
                return newCyclicArray
            end 
        }
    })
    AssignClassName(arrayInstance, "CyclicArray", "Array")
    return arrayInstance
end 
LoadStatic(CyclicArray)

-- print(_("Array").fromTable({ }))    no error 
-- print(Array().fromTable({ })) error

function DoublyLinkedList(...)
    local function Node(item, prev, next)
        local instance = { 
            item = item,
            prev = prev,
            next = next
        }
        AssignClassName(instance, debug.getinfo(1, "Sunfl"), nil)
        return instance
    end 
    local instance = { 
        head = nil, 
        tail = nil,
        isEmpty = function(self)
            return self.head == nil and self.tail == nil
        end,
        count = function(self)
            return getmetatable(self)["config"].__super__().count(self)
        end,
        add = function(self, item)
            if self:isEmpty() then
                local newNode = Node(item, nil, nil)
                self.head = newNode 
                self.tail = newNode
            else
                local currentNode = self.head
                if self.head == currentNode and self.tail == currentNode then 
                    local newNode = Node(item, currentNode, nil)
                    self.tail = newNode
                    currentNode.next = newNode
                else
                    while currentNode.next ~= nil do
                        currentNode = currentNode.next
                    end 
                    local newNode = Node(item, currentNode, nil)
                    self.tail = newNode
                    currentNode.next = newNode
                end
            end
            return self
        end,
        reverse = function(self)
            if not self:isEmpty() then
                local currentNode = self.head
                local tempPrev = nil
        
                while currentNode do
                    local tempNext = currentNode.next
                    currentNode.next = tempPrev
                    currentNode.prev = tempNext
                    tempPrev = currentNode
                    currentNode = tempNext
                end
                
                local tempHead = self.head
                self.head = self.tail
                self.tail = tempHead
            end
            return self
        end, 
        get = function(self, index)  --Get item at the specified index
            return super(self).get(self, index)
        end,
        forEach = function(self, callbackfn)   --Loops through each element in the list
            super(self).forEach(self, callbackfn)
        end,
        toString = function(self)
            local function HandleNestedArraysOrTable(self, item)
                local starting = ""
                if TypeOf(item) == "DoublyLinkedList" then
                    local isAllNonArrayOrTable = true
                    for i=1, item:count() do 
                        if TypeOf(item:get(i))=="Array" or TypeOf(item:get(i))=="table" then
                            isAllNonArrayOrTable = false 
                            break
                        end
                    end
                    if isAllNonArrayOrTable then 
                        starting = starting .. item:toString()
                    else 
                        starting = starting .. '['
                        --So long as not table append it to starting
                        for i=1, item:count() do 
                            if TypeOf(item:get(i))=="DoublyLinkedList" or TypeOf(item:get(i))=="table" then
                                starting = starting .. HandleNestedArraysOrTable(self, item:get(i))
                            else
                                starting = starting .. item:get(i)
                            end 
                            --Determine is comma is needed 
                            if i ~= item:count() then 
                                starting = starting .. ','
                            end 
                        end 
                        starting = starting .. ']'
                    end 
                elseif TypeOf(item) == "table" then 
                
                end 
                return starting
            end
            local header = "["
            if self.head ~= nil then
                local currentNode = self.head
                if TypeOf(currentNode.item) == "table" or TypeOf(currentNode.item) == "Array" then 
                    header = header .. HandleNestedArraysOrTable(self, currentNode.item) 
                else 
                    header = header .. currentNode.item
                end 
                while currentNode.next ~= nil do
                    currentNode = currentNode.next
                    if TypeOf(currentNode.item) == "table" or TypeOf(currentNode.item) == "Array" then 
                        header = header .. ", " .. HandleNestedArraysOrTable(self, currentNode.item) 
                    else
                        header = header .. ", " .. currentNode.item
                    end 
                end 
            end 
            header = header .. "]"
            return header
        end
    }
    setmetatable(instance, { 
        __tostring = function(self)
            return self:toString()
        end
    })
    AssignClassName(instance, GenerateClassNameComplete(), "Array")
    return instance
end

function Map()
  local function hash(key)
    assert(type(key) == "string", "The key must be a valid string for the hashing process to continue. Given type: " .. type(key))
    local hashResult = 0
    local characters = nil
    local strLen = key:len()
    if strLen < 2 then 
      characters = key:get(1):byte()
      return characters
    end
    characters = (key:get(1):byte() * 52 + key:get(2):byte()) % 1000
    for i = 1, strLen-1 do
      if i ~= strLen then
        characters = (characters * 52 + key:get(i+1):byte()) % 1000
      end 
    end
    return (characters % 1000) + 1
  end
  local function KeyValuePair(key, value)
    local instance = { 
       key = key, 
       value = value
    }
    setmetatable(instance, { 
      __tostring = function(self)
        return string.format("KeyValuePair { %s, %s }", self.key, self.value)
      end
    })
    AssignClassName(instance)
    return instance
  end
  local keyIndicesNotNull
  local instance = {
    data = Array(),
    insertionStack = Array(),
    count = function(self)
      return self.insertionStack:count()
    end, 
    insert = function(self, key, value)
      --keys are sparse arrays 'technically'
      --So technically hashmaps are 'sparse matrices'??
      --reduce memory consumption for locations which are marked as 'nil'
      keyIndicesNotNull = self.data:map(function(e) return self.data:indexOf(e) end):filter(function(e) return e ~= 0 end)
      --if not self:containsKey(key) then  --uncomment this portion of code to allow unique keys
        local h = hash(key)
        local success, result = pcall(function() 
          return self.data:get(h) 
        end)
        if not success then 
          self.data:insertAt(h, Array())
          local keyValuePair = KeyValuePair(key, value)
          self.data:get(h):add(keyValuePair)
        else 
          --if a list already exists at index h or if its nil then
          if result then
            local keyValuePair = KeyValuePair(key, value)
            result:add(keyValuePair)
          else
            self.data:replace(h, Array())
            local keyValuePair = KeyValuePair(key, value)
            self.data:get(h):add(keyValuePair)
          end
        end
        self.insertionStack:push(key)
      --end
      return self
    end,
    containsKey = function(self, key)
      local success, lengths = pcall(function() 
        return self.data:get(hash(key)) 
      end)
      if not success or not lengths then 
        return false 
      else 
        if lengths:count() == 1 then 
          return lengths:get(1).key == key
        else 
          for i=1, lengths:count() do
            if lengths:get(i).key == key then
              return true
            end 
          end 
        end
      end 
      return false
    end, 
    get = function(self, key)
      local success, lengths = pcall(function() return self.data:get(hash(key)) end)
      if success and lengths then 
        if lengths:count() == 1 then 
          return lengths:get(1).value
        else 
          for i=1, lengths:count() do
            if lengths:get(i).key == key then
              return lengths:get(i).value
            end 
          end 
        end
      else
        error("Key does not exist. Given: " .. key)
      end
      return lengths
    end,
    set = function(self, key, value)
        local success, lengths = pcall(function() return self.data:get(hash(key)) end)
            if success and lengths then 
                if lengths:count() == 1 then 
                lengths:get(1).value = value -- Update the value field
            else
                for i=1, lengths:count() do
                    if lengths:get(i).key == key then 
                        lengths:get(i).value = value -- Update the value field
                    end 
                end 
            end  
        else 
            error("Key does not exist. Given: " .. key)
        end
        return self 
    end, 
    forEach = function(self, callbackfn)
      --loop through the insertion stack instead 
      self.insertionStack:reverse():forEach(function(key) 
        local value = self:get(key)
        callbackfn(key, value)
      end)
    end, 
    remove = function(self, k)
      if not self:containsKey(k) then 
        error("Key does not exist in this map")
      else 
        local success, lengths = pcall(function() return self.data:get(hash(key)) end)
        if success and lengths then 
          if lengths:count() == 1 then
            --remove the first element in the lis
          end
        end
      end
    end,
    toString = function(self)
      local function HandleInternalMaps()
        local s = "Map ["
        
        s = s .. "]"
        return s
      end
      local s = "Map ["
      local array = Array()
      for i=1,self.data:count() do
        if TypeOfA(self.data:get(i)) == "Array" then 
          for j=1,self.data:get(i):count() do 
            local keyPortion = self.data:get(i):get(j).key
            local valuePortion = self.data:get(i):get(j).value
            array:add(KeyValuePair(keyPortion, valuePortion))
          end 
        end 
      end
      --re-arrange array such that it conforms to self.insertionStack
      local newReturn = Array()
      for i=1, self.insertionStack:count() do
        for j=1, array:count() do
          if array:get(j).key == self.insertionStack:get(i) then 
            newReturn:add(array:get(j).key, array:get(j).value)
          end
        end 
      end
      for i = 1, newReturn:count() do
        if TypeOf(self:get(newReturn:get(i))) == "string" then
          s = s .. string.format("{'%s': '%s'}", newReturn:get(i), self:get(newReturn:get(i)))
        else
          s = s .. string.format("{'%s': %s}", newReturn:get(i), self:get(newReturn:get(i)))
        end
        if i ~= newReturn:count() then
          s = s .. ", "
        end
      end
      s = s .. "]"
      return s
    end 
  }
  setmetatable(instance, {
    __newindex = function(self, k, v)
      error("You are not allowed to add methods to this class")
    end, 
    __tostring = function(self)
      return self:toString()
    end, 
    __static = { 
      fromTable = function(t)
        local newMap = Map()
        for k, v in pairs(t) do
          if TypeOf(k) == "string" then
            newMap:insert(k, v)
          end
        end
        return newMap
      end
    }
  })
  AssignClassName(instance)
  return instance
end
LoadStatic(Map)


--Wrapper class for table
function Table(t) 
    local data = t
    local instance = { 
        getData = function(self)
            return data
        end,
        toString = function(self)
            
        end
    }
    local function setData(self, newData)
        data = newData
    end
    setmetatable(instance, {
        __add = function(self, other)
            local current = self:getData()
            local other = other:getData()
            --perform a merge of both tables
            for i=1,#other do
                table.insert(current, other[i])
            end 
            for k, v in pairs(other) do
                if TypeOf(k) ~= "number" then
                    rawset(current, k, v)
                end
            end
            setData(self, current)
            return self
        end
    })
    AssignClassName(instance, GenerateClassNameComplete(), "table")
    return instance
end 

--Local functions
local function TokenizeAndExtractVariables(multiline)
    local tokens = {}
    local token = ""
    
    for i = 0, multiline:len() - 1 do
        if multiline:get(i):byte() ~= 32 then
            token = token .. multiline:get(i)
        else 
            table.insert(tokens, token)
            token = ""
        end
    end
    
    local LUAKEYWORDS = { 
        "self", "until", "repeat", "if", "then", "elseif", "else", "function", "end", "do", "for", "while", "local", "return", "true", "false", "and", "not", "or", "break", "nil"
    }
    
    local OPERATORS = { 
        '>', '<=', '>=', '<', '==', '+', '-', '*', '/', '~=', '%', '^', '#', '='
    } 
    
    local DIGITS = {
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
    }
    
    local variables = { }
    -- Print the tokens
    for _, v in ipairs(tokens) do
        if not table.contains(LUAKEYWORDS, v)
            and v:len() > 0 
            and not v:get(0):containsOneOf(DIGITS) then 
            if v:contains('(') then 
                --Find function argument afterwards
                table.insert(variables, v:get(v:locate('(').begin+1))
            elseif v:contains(',') then 
                --Find function argument before and after
                local indexBefore = v:locate(',').begin-1
                local indexAfter = v:locate(',').begin+1
                if indexBefore >= 0 then 
                    table.insert(variables, v:get(indexBefore))
                end 
                if indexAfter <= v:len() - 1 then 
                    table.insert(variables, v:get(indexAfter))
                end 
            elseif v:contains(')') then 
                local indexBefore = v:locate(')').begin - 1 
                local indexAfter = v:locate(')').begin + 1
                if indexBefore >= 0 then
                    table.insert(variables, v:get(v:locate(')').begin-1))
                end 
                if indexAfter <= v:len() - 1 then 
                    table.insert(variables, v:get(v:locate(')').begin+1))
                end
            elseif v:containsOneOf(OPERATORS) then 
                local operatorArray = Array()
                for k, op in pairs(OPERATORS) do 
                    operatorArray.add(op)
                end 
                operatorArray.forEach(function(i)
                    local bounds = v:locate(i)
                    if bounds ~= nil then 
                       local indexBefore = bounds.begin - v:len()
                       local indexAfter = bounds.begin + v:len()
                        if indexBefore >= 0 then 
                            table.insert(variables, v:get(indexBefore))
                            if indexAfter <= v:len() - 1 then
                                table.insert(variables, v:get(indexAfter))
                            end 
                        end 
                    end 
                end) 
            else
                if not table.contains(variables, v) then 
                    table.insert(variables, v)
                end 
            end
        end
    end
    local finalVariables = { }
    for _, var in pairs(variables) do 
        if var:match("^[%w_]+$") then
            table.insert(finalVariables, var)
        end
    end
    return finalVariables
end 

NumberFunction = {
  comparing = function(x, y)  --Returns 
    assert(x ~= nil and y ~= nil, "Both arguments cannot be nil")
    assert(type(x)=="number" and type(y) == "number", "Both arguments have to be a number")
    if x > y then 
      return 1
    elseif x < y then 
      return -1 
    else 
      return 0
    end 
  end
}

--Lexicographically
StringFunction = {
    comparing = function(x, y)
        assert(type(x)=="string", "The first argument of the function must be of type string, not: "..type(x))
        assert(type(y)=="string", "The second argument of the function must be of type string, not: "..type(y))
        if x:len() == y:len() then 
            --share one single for loop to perform the operation
            for i=0, x:len()-1 do 
                if (x:get(i):byte() >= 97 and x:get(i):byte() <= 122) or 
                   (x:get(i):byte() >= 65 and x:get(i):byte() <= 90) then
                    --capital letters take away 32
                    x:get(i):byte()
                end
            end 
        end 
    end 
} 

--Ternary operators
local Operator = {
    Ternary = function(cond, ifTrue, ifFalse) 
        assert(type(cond)=="boolean", "The first condition must be a boolean, not " .. type(cond))
        assert(ifTrue~=nil and ifFalse~=nil)
        if cond then 
            return ifTrue
        else 
            return ifFalse
        end 
    end
}

function ConstructFunction(mode, body)
    --main program logic
    assert(type(body)=="string", "Body must be of type string")
    if mode == 'p' then --Predicate   (one parameter but must return a boolean)
        return function(i)
            local variables = TokenizeAndExtractVariables(body)
            if #variables == 1 then
                local assignmentTable = "{"
                for _, v in pairs(variables) do
                    assignmentTable = assignmentTable .. v .. "=%d"
                end 
                assignmentTable = assignmentTable .. "}"
                assignmentTable = string.format(assignmentTable, i)
                local t = load("return "..assignmentTable)()
                --Implicitly insert return keyword into statement for lambda expressions
                assert(type(load(Operator.Ternary(string.find(body, "\n")~= nil and string.find(body, "return")~=nil, "", "return ")..body, "Predicate", "t", t)())=="boolean", "Predicate must return a value of type boolean")
                return load(Operator.Ternary(string.find(body, "\n")~= nil and string.find(body, "return")~=nil, "", "return ")..body, "Predicate", "t", t)()
            else 
                --Predicates must have exactly 1 parameter, not more and not less
                error("You can only have up to 1 type of variables in this predicate. Not " .. #variables)
            end 
        end
    elseif mode == 'f' then --Function (one parameter but must return a value of any type)
        return function(i)
            local variables = TokenizeAndExtractVariables(body)
            if #variables == 1 then 
                local assignmentTable = "{"
                for _, v in pairs(variables) do
                    assignmentTable = assignmentTable .. v .. "=%d"
                end 
                assignmentTable = assignmentTable .. "}"
                assignmentTable = string.format(assignmentTable, i)
                local t = load("return "..assignmentTable)()
                assert(i ~= nil, "For functions, a value must be supplied to the parameter")
                assert(load(Operator.Ternary(string.find(body, "\n")~= nil and string.find(body, "return")~=nil, "", "return ")..body, "Function", "t", t)(), "Function must return a value")
                return load(Operator.Ternary(string.find(body, "\n")~= nil and string.find(body, "return")~=nil, "", "return ")..body, "Function", "t", t)()
            else 
                --Function must have exactly 1 parameter, not more and not less
                error("You can only have up to 1 type of variables in this function. Not " .. #variables)
            end 
        end 
    elseif mode == 'f2' then --BiFunction  (two parameters but must return a value of any type)
        return function(i, j)
            local variables = TokenizeAndExtractVariables(body)
            if #variables == 2 then
                local assignmentTable = "{"
                for _, v in pairs(variables) do
                    assignmentTable = assignmentTable .. v .. "=" .. Operator.Ternary(_==#variables, "%d", "%d, ")
                end
                assignmentTable = assignmentTable .. "}"
                assignmentTable = string.format(assignmentTable, j, i)
                local t = load("return "..assignmentTable)()
                assert(i ~= nil and j ~= nil, "For bifunction, a value must be supplied to each of the parameter")
                assert(load(Operator.Ternary(string.find(body, "\n")~= nil and string.find(body, "return")~=nil, "", "return ")..body, "BiFunction", "t", t)(), "BiFunction must return a value")
                return load(Operator.Ternary(string.find(body, "\n")~= nil and string.find(body, "return")~=nil, "", "return ")..body, "BiFunction", "t", t)()
            else 
                --BiPredicates must have exactly 2 parameters or argumentss 
                error("You can only have up to 2 types of variables in this bifunction. Not " .. #variables)
            end 
        end
    elseif mode == 'a' then  --Action (no parameters and cannot return a value)
        return function()
            assert(not load(body), "Actions must not have a return type")
            return load(body)
        end 
    elseif mode == "p2" then  --BiPredicate (two parameters and must return a boolean)
        return function(i, j)
            local variables = TokenizeAndExtractVariables(body)
            if #variables == 2 then
                local assignmentTable = "{"
                for _, v in pairs(variables) do
                    assignmentTable = assignmentTable .. v .. "=" .. Operator.Ternary(_==#variables, "%d", "%d, ")
                end
                assignmentTable = assignmentTable .. "}"
                assignmentTable = string.format(assignmentTable, j, i)
                local t = load("return "..assignmentTable)()
                assert(i ~= nil and j ~= nil, "For BiPredicate, a value must be supplied to each of the parameter")
                assert(type(load(Operator.Ternary(string.find(body, "\n")~= nil and string.find(body, "return")~=nil, "", "return ")..body, "BiPredicate", "t", t)())=="boolean", "BiPredicate must return a value of type boolean")
                return load(Operator.Ternary(string.find(body, "\n")~= nil and string.find(body, "return")~=nil, "", "return ")..body, "BiPredicate", "t", t)()
            else 
                --BiPredicates must have exactly 2 parameters or argumentss 
                error("You can only have up to 2 types of variables in this bipredicate. Not " .. #variables)
            end 
        end 
    elseif mode == "c2" then  --Comparator (two parameters and must return a whole number)
        return function(i, j)
            local variables = TokenizeAndExtractVariables(body)
            if #variables == 2 then 
                local assignmentTable = "{"
                for _, v in pairs(variables) do
                    assignmentTable = assignmentTable .. v .. "=" .. Operator.Ternary(_==#variables, "%d", "%d, ")
                end
                assignmentTable = assignmentTable .. "}"
                assignmentTable = string.format(assignmentTable, j, i)
                local t = load("return "..assignmentTable)()
                assert(i ~= nil and j ~= nil, "For Comparator, a value must be supplied to each of the parameter")
                assert(type(load(Operator.Ternary(body:find("\n")~= nil and body:find("return")~=nil, "", "return ")..body, "Comparator", "t", t)())=="number", "Comparator must return a value of type boolean")
                local tempLoad = load(Operator.Ternary(body:find("\n")~= nil and body:find("return")~=nil, "", "return ")..body, "Comparator", "t", t)()
                return tempLoad
            else 
                --Comparators must have exactly 2 parameters or arguments
                error("You can only have up to 2 types of variables in this comparator. Not " .. #variables)
            end 
        end 
    end 
end

--Users can use this functions to construct classes 
function ClassConstructor(nameOfClass) 
    local LUAKEYWORDS = { 
        "until", "repeat", "if", "then", "elseif", "else", "function", "end", "do", "for", "while", "local", "return", "true", "false", "and", "not", "or", "break", "nil"
    }
    local classConstructorInstance = { 
        stringExpr = { },
        parameters = { },
        methods = { },
        properties = { }
    }
    local function NumberOfKeyValuePairs(t)
        assert(TypeOf(t)=="table", "This argument must be of type table, not "..TypeOf(t))
        local tally = 0
        for k, v in pairs(t) do 
            if TypeOf(k) ~= "number" then 
                tally = tally + 1
            end 
        end 
        return tally
    end 
    classConstructorInstance["setParameter"] = function(self, name, defaultValue)
        classConstructorInstance["parameters"][name] = defaultValue or "nil"
        return classConstructorInstance
    end
    classConstructorInstance["setProperty"] = function(self, name, value) 
        assert(TypeOf(name)=="string", "The name of the function must be a string")
        classConstructorInstance["properties"][name] = value
        return classConstructorInstance
    end 
    classConstructorInstance["setMethod"] = function(self, name, body, params)
        params = params or { }
        assert(TypeOf(name)=="string" and TypeOf(body)=="string", "Both parameters need to be a string")
        local functionString = "function("
        local currentIndex = 0
        if (#params + NumberOfKeyValuePairs(params)) == 0 then 
            functionString = functionString .. ")"
        else 
            for k, v in pairs(params) do 
                if TypeOf(k) == "number" then
                    assert(TypeOf(v)=="string", "The parameter must be a string")
                    --Check if v is a reserved keyword
                    if not table.contains(LUAKEYWORDS, v) then
                        functionString = functionString .. v
                        currentIndex = currentIndex + 1
                        if currentIndex < (#params + NumberOfKeyValuePairs(params)) then 
                            functionString = functionString .. ","
                        else 
                            functionString = functionString .. ")"
                        end 
                    else 
                        error("Parameters shall not contain a lua keyword")
                    end 
                elseif TypeOf(k) == "string" then
                    --Check if k is a reserved keyword.
                    if not table.contains(LUAKEYWORDS, k) then
                        functionString = functionString .. k
                        currentIndex = currentIndex + 1
                        if currentIndex < (#params + NumberOfKeyValuePairs(params)) then 
                            functionString = functionString .. ","
                        else 
                            functionString = functionString .. ")"
                        end
                    else 
                        error("Parameters shall not contain a lua keyword")
                    end 
                else 
                    error("Parameters must be of type string")
                end 
            end 
        end
        --analyze body and check for lua syntax errors 
        local a = TokenizeAndExtractVariables(body)
        print(body)
        
        functionString = functionString .. "\n\t\tend"
        classConstructorInstance["methods"][name] = functionString
        return classConstructorInstance
    end
    classConstructorInstance["build"] = function(self)
        --build the function afterwards
        local functionString = string.format("function %s(", nameOfClass)
        local currentIndex = 0
        if NumberOfKeyValuePairs(classConstructorInstance["parameters"]) == 0 then 
            functionString = functionString .. ')'
        else
            for var, val in pairs(classConstructorInstance["parameters"]) do 
                functionString = functionString .. var
                currentIndex = currentIndex + 1
                if currentIndex < NumberOfKeyValuePairs(classConstructorInstance["parameters"]) then
                    functionString = functionString .. ","
                else
                    functionString = functionString .. ")"
                end
            end 
        end
        local memberFunctionString = "local properties = {\n\t\t"
        local methodPointerIndex = 0
        for k, v in pairs(classConstructorInstance["methods"]) do 
            memberFunctionString = memberFunctionString .. string.format("%s = %s", k, v)
            methodPointerIndex = methodPointerIndex + 1
            if methodPointerIndex < NumberOfKeyValuePairs(classConstructorInstance["methods"]) then
                memberFunctionString = memberFunctionString .. ",\n"
            else
                memberFunctionString = memberFunctionString .. "\n"
            end 
        end 
        memberFunctionString = memberFunctionString .. "\t}\n\t"
        functionString = functionString .. "\n\t" .. memberFunctionString
        --Add member properties into the function as well!
        for var, val in pairs(classConstructorInstance["properties"]) do 
            functionString = functionString .. string.format("properites.%s = %s\n", var, val)
        end 
        functionString = functionString .. "\n\treturn properties"
        functionString = functionString .. "\nend"
        return functionString
    end 
    AssignClassName(classConstructorInstance, nameOfClass)
    return classConstructorInstance
end 

--keep track of overloaded function
setmetatable({ }, { })

--exports
return { 
    Array = Array,
    Table = Table,
    FinalizeTable = FinalizeTable,
    TypeOf = TypeOf,
    AssignClassName = AssignClassName,
    StringExtension = StringExtension,
    _ = _
}
