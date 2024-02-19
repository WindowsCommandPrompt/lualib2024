--Li Zhe Yun 2024

local _ = _G

--Keep track of inheritance lists (Attach a doubly linked list to it
_["inherit"] = nil

--Function add ons
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

--Keep track of class types 
function AssignClassName(t, name, super)
    assert(type(t) == "table", "The argument must be of type table, not: " .. type(t))
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
    -- if super is not nil
    if super then 
        for rootClass, inheritanceList in pairs(_["inherit"]) do
            for i=1, rootClass:count() do
                --go down the list of classes 
                if _["inherit"][rootClass][i] == super then
                    --add the subclass to the list
                    _["inherit"][rootClass]:add(name)
                end
            end
        end
    else
        _["inherit"][name] = DoublyLinkedList()
    end
    MakeConstant('transfer["config"]', transfer["config"]) 
    setmetatable(t, transfer)
    return t
end 

--ready for typechecking
function TypeOf(obj)
    if type(obj) == "table" then
        local types = getmetatable(obj)
        if types then 
            return types["config"].__name__
        else 
            return "table"
        end 
    else 
        return type(obj)
    end 
end

string.contains = function(sample, str)
    --returns boolean
    assert(TypeOf(sample)=="string", "Sample string must be of type 'string', not " .. TypeOf(sample))
    assert(TypeOf(str)=="string", "Search string must be of type 'string', not " .. TypeOf(str))
    for i = 0, string.len(sample) - 1 do
        if string.get(str, 0) == string.get(sample, i) and string.sub(sample, i+1, i + string.len(str)) == str then
            return true
        end
    end
    return false
end

string.containsOneOf = function(sample, list)     
    --[[ 
        Can be used in the following example to parse the following syntax
        'if a == { 'a' or 'b' } then'
    ]]
    assert(TypeOf(sample)=="string", "Sample string must be of type 'string', not " .. TypeOf(sample))
    assert(TypeOf(list)=="Array" or TypeOf(list) == "table", "Sample string must be of type 'table' or 'Array', not " .. TypeOf(list))
    if type(list) == "table" then 
        --Do table iteration
        for _, v in pairs(list) do 
            if sample:contains(v) then return true end 
        end 
    else 
        list.forEach(function(i) 
            if sample:contains(i) then return true end
        end) 
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

string.get = function(sample, index)
    if index > string.len(sample) or index < -string.len(sample) or index == 0 then
        error("Index out of bounds for string length: " .. string.len(sample))
    elseif index >= -string.len(sample) and index <= -1 then
        return string.sub(sample, index, index)
    else
        return string.sub(sample, index-1, index)
    end
end

string.findAll = function(sample, str)
    local matches = { }
    local start, finish = 1, 1
    repeat
      start, finish = sample:find(str, finish)
      if start then
        local match = sample:sub(start, finish)
        table.insert(matches, FinalizeTable({ 
            match = match,
            start = start,
            finish = finish
        }))
        finish = finish + 1  
      end
    until not start
    return matches
end 

string.split = function(sample, regex)
    local portions = { }
    local allMatches = sample:findAll(regex)
    local marker = 1
    for i=1,#allMatches+1 do
        if i == 1 then
            table.insert(portions, sample:sub(1, allMatches[i].start-1))
            marker = allMatches[i]
        elseif i > 1 and i < #allMatches+1 then
            table.insert(portions, sample:sub(marker.finish+1, allMatches[i].start-1))
            marker = allMatches[i]
        else 
           table.insert(portions, sample:sub(marker.finish+1, #sample-1))
        end
    end
    return portions
end

table.containsKey = function(t, elem)
    for k, _ in pairs(t) do
        if k == elem then return true end 
    end 
    return false
end 

function FixedArray(size, ...)
    local vararg = {...}
    assert(TypeOf(size)=="number" or TypeOf(size)=="nil", "The type of the first parameter must be of type number")
    local function Node(item, nextNode)
        local component = {
            item = item,
            next = nextNode
        }
        AssignClassName(component, debug.getinfo(1, "Sunfl").name)
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
                AssignClassName(component, debug.getinfo(1, "Sunfl").name)
                return component
            end
            return 
        ]]..expr)()
    end
    --perform initialization of FixedArray if size is specified
    if size then
        Initialize(size)
    end 
    AssignClassName(arrayInstance, debug.getinfo(1, "Sunfl").name)
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
        __concat = function(self, str)  --lua makes it impossible for u to append 'nil' to a string. Now u can
            getmetatable(self)["config"].__super__()
                
        end,
        __tostring = function(self)
            return self.sample
        end 
    })
    AssignClassName(instance, debug.getinfo(1, "Sunfl").name, "string") --inherits from 'string'
    return instance
end

function Array(...)
    local vararg = {...}
    --if initLength is specified then this array is not growable
    local function Node(item, nextNode)
        local component = {
            item = item,
            next = nextNode
        }
        AssignClassName(component, debug.getinfo(1, "Sunfl").name)
        return component
    end 
    --Start
    local arrayInstance = {
        head = nil,
        count = function(self)  --Return the length of the array
            local currentNode = self.head
            local length = 0
            while currentNode ~= nil do
                length = length + 1
                currentNode = currentNode.next 
            end 
            return length
        end, 
        add = function(self, elem)   --Add element into the add of the array
            if self.head == nil then
                self.head = Node(elem, nil)
            else
                local currentNode = self.head
                while currentNode.next ~= nil do
                    currentNode = currentNode.next
                end
                currentNode.next = Node(elem, nil)
            end
            return self
        end,
        pop = function(self)   --pop first element in the array
            if self.head ~= nil then
                self.head = self.head.next
            end 
            return self
        end,
        push = function(self, item)    --insert item at the start of the array
            local newNode = Node(item, head.next)
            self.head = newNode
            return self
        end,
        remove = function(self, elem)  --pop last element in the array
            if self.head ~= nil then
                local currentNode = self.head
                if elem then
                    --Find the first instance of the element and then removes it
                    if elem == currentNode.item then
                        self.pop()
                    else 
                        while currentNode.next ~= nil and currentNode.next.item ~= elem do
                            currentNode = currentNode.next
                        end 
                        --Reached the affected node named 'currentNode'
                        if currentNode.next then
                            --Just remove the last node as usual
                            self.remove()
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
                    while currentNode.next ~= nil do 
                        currentNode = currentNode.next
                    end 
                    --currentNode at the end of the linked list
                    local auxNode = self.head
                    while auxNode.next ~= currentNode do 
                        auxNode = auxNode.next 
                    end 
                    auxNode.next = nil
                end
            end 
            return self
        end,
        isEmpty = function(self)  --Check if the array is empty or not
            return not self.head
        end, 
        peek = function(self)  --Return the first item in the array
            return self.head.item
        end, 
        indexOf = function(self, elem)   --Return the index of the items in the list
            local currentNode = self.head
            local index = 0
            if self.head.item == elem or self.head == nil then 
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
                local currentNode = self.head
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
                error("Index out of bounds")
            end 
        end,
        forEach = function(self, callbackfn)   --Loops through each element in the list
            if self.head ~= nil then
                local currentNode = self.head
                callbackfn(currentNode.item)
                while currentNode.next ~= nil do
                    currentNode = currentNode.next
                    callbackfn(currentNode.item)
                end 
            end 
        end,
        toString = function(self)  --Return the array in a string representation
            local function HandleNestedArraysOrTable(self, item)
                local starting = ""
                if TypeOf(item) == "Array" then
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
                            if TypeOf(item:get(i))=="Array" or TypeOf(item:get(i))=="table" then
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
        end,
        toFixedArray = function(self)
            --Once the array is converted into a fixed array, the contents with the array cannot be modified anymore.
            local fixedArrayCallString = "FixedArray(nil"
            if self.head ~= nil then
                local currentNode = self.head
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
        map = function(self, mappingFunction)
            local newArray = Array() --to be mapped to
            self:forEach(function(item) 
                assert(TypeOf(mappingFunction(item))~="nil", "Must return a type")
                newArray:add(mappingFunction(item))
            end)
            return newArray
        end,
        --use pcall for this function (recommended)
        sum = function(self)
            local total = 0
            local currentNode = self.head
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
                    error("A non-number is detected in the array! Failed to perform sum. Erroneous item index: " .. i .. " which is of type: " .. TypeOf(currentNode.item))
                end 
            end 
            return total
        end,
        min = function(self)
            local minimum = 0
            local currentNode = self.head
            local currentIndex = 1
            if TypeOf(currentNode.item)=="number" then
                minimum = currentNode.item
                currentIndex = currentIndex + 1
            end
            while currentNode.next ~= nil do
                
            end
        end 
    }
    setmetatable(arrayInstance, { 
        __tostring = function(self) 
            return self:toString()
        end,
        __static = FinalizeTable({   -- public static Array fromTable(table t)    DAB
            fromTable = function(t)
                assert(TypeOf(t)=="table") 
                --Only take array part
                local newArray = Array()
                for k, v in pairs(t) do
                    if TypeOf(k)=="number" then
                        newArray:add(v)
                    end
                end
                return newArray
            end
        }),
        __eq = function(self, other)
            assert(TypeOf(self) == "Array" and TypeOf(other) == "Array", "Both arguments need to be of type 'Array'")
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
        end
    })
    --Check for contents in vararg
    if #vararg > 0 then
        --Copy items from vararg table into array.
        for _, val in pairs(vararg) do
            arrayInstance:add(val)
        end 
    end
    --Assign a type name to the
    AssignClassName(arrayInstance, debug.getinfo(1, "Sunfl").name)
    return arrayInstance
end

--include the Array class into _G
_[TypeOf(Array())] = Array

--make static methods callable without calling Array function
setmetatable(_, { 
    __call = function(self, k)
        assert(getmetatable(_G[k]()).__static, "NO STATIC METHODS FOUND!")
        return getmetatable(_G[k]()).__static
    end
})

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
            return getmetatable(self)["config"].__super__().get(self, index)
        end,
        forEach = function(self, callbackfn)   --Loops through each element in the list
            getmetatable(self)["config"].__super__().forEach(self, callbackfn)
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
    AssignClassName(instance, debug.getinfo(1, "Sunfl"), "Array")
    return instance
end

function Map()

end

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
