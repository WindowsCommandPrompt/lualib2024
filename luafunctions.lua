--Li Zhe Yun 2024

--Function add ons
string.contains = function(sample, str)
    --returns boolean
    for i = 0, string.len(sample) - 1 do
        if string.get(str, 0) == string.get(sample, i) and string.sub(sample, i+1, i + string.len(str)) == str then
            return true
        end
    end
    return false
end

string.containsOneOf = function(sample, list)
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
    if index >= string.len(sample) or index < -string.len(sample) then
        error("Index out of bounds for string length: " .. string.len(sample))
    elseif index >= -string.len(sample) and index <= -1 then
        return string.sub(sample, index, index)
    else
        return string.sub(sample, index + 1, index + 1)
    end
end

table.contains = function(t, elem)
    for _, v in pairs(t) do
        if v == elem then return true end 
    end 
    return false
end 

function Array(...)
    local vararg = {...}
    --if initLength is specified then this array is not growable
    function Node(item, nextNode)
        local component = {
            item = item,
            next = nextNode
        }
        return component
    end 
    --Start
    local arrayInstance = {
        head = nil,
        add = function(elem)
            if head == nil then
                head = Node(elem, nil)
            else
                local currentNode = head
                while currentNode.next ~= nil do
                    currentNode = currentNode.next
                end
                currentNode.next = Node(elem, nil)
            end
            return arrayInstance
        end,
        pop = function()
            if head ~= nil then
                head = head.next
            end 
            return true
        end,
        isEmpty = function()
            return not head
        end, 
        peek = function()
            return head.item
        end, 
        indexOf = function(elem) 
            
        end, 
        toString = function()
            local header = "["
            if head ~= nil then
                local currentNode = head
                header = header .. currentNode.item
                while currentNode.next ~= nil do
                    currentNode = currentNode.next
                    header = header .. ", " .. currentNode.item
                end 
            end 
            header = header .. "]"
            return header
        end,
        forEach = function(callbackfn)
            if head ~= nil then
                local currentNode = head
                callbackfn(currentNode.item)
                while currentNode.next ~= nil do
                    currentNode = currentNode.next
                    callbackfn(currentNode.item)
                end 
            end 
        end
    }
    --Check for contents in vararg
    if #vararg > 0 then
        --Copy items from vararg table into array.
        for _, val in pairs(vararg) do
            arrayInstance.add(val)
        end 
    end
    return arrayInstance
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

local function FinalizeTable(t)
  
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
  end 
} 

function ConstructFunction(mode, body)
    --main program logic
    assert(type(body)=="string", "Body must be of type string")
    if mode == 'p' then --Predicate   (one parameter but must return a boolean)
        return function(i)
            --Implicitly insert return keyword into statement for lambda expressions
            assert(type(load(Operator.Ternary(string.find(body, "\n")~= nil and string.find(body, "return")~=nil, "", "return ")..body, "Predicate", "t", {i=i})())=="boolean", "Predicate must return a value of type boolean")
            return load(Operator.Ternary(string.find(body, "\n")~= nil and string.find(body, "return")~=nil, "", "return ")..body, "Predicate", "t", {i=i})()
        end
    elseif mode == 'f' then --Function (one parameter but must return a value of any type)
        return function(i)
            assert(i ~= nil, "For functions, a value must be supplied to the parameter")
            assert(load(Operator.Ternary(string.find(body, "\n")~= nil and string.find(body, "return")~=nil, "", "return ")..body, "Function", "t", {i=i})(), "Function must return a value")
            return load(Operator.Ternary(string.find(body, "\n")~= nil and string.find(body, "return")~=nil, "", "return ")..body, "Function", "t", {i=i})()
        end 
    elseif mode == 'f2' then --BiFunction  (two parameters but must return a value of any type)
        return function(i, j)
            assert(i ~= nil and j ~= nil, "For bifunction, a value must be supplied to each of the parameter")
            assert(load(Operator.Ternary(string.find(body, "\n")~= nil and string.find(body, "return")~=nil, "", "return ")..body, "BiFunction", "t", {i=i, j=j})(), "BiFunction must return a value")
            return load(Operator.Ternary(string.find(body, "\n")~= nil and string.find(body, "return")~=nil, "", "return ")..body, "BiFunction", "t", {i=i, j=j})()
        end
    elseif mode == 'a' then  --Action (no parameters and cannot return a value)
        return function()
            assert(not load(body), "Actions must not have a return type")
            return load(body)
        end 
    elseif mode == "p2" then  --BiPredicate (two parameters and must return a boolean)
        return function(i, j)
            assert(i ~= nil and j ~= nil, "For BiPredicate, a value must be supplied to each of the parameter")
            assert(type(load(Operator.Ternary(string.find(body, "\n")~= nil and string.find(body, "return")~=nil, "", "return ")..body, "BiPredicate", "t", {i=i, j=j})())=="boolean", "BiPredicate must return a value of type boolean")
            return load(Operator.Ternary(string.find(body, "\n")~= nil and string.find(body, "return")~=nil, "", "return ")..body, "BiPredicate", "t", {i=i, j=j})()
        end 
    elseif mode == "c2" then  --Comparator (two parameters and must return a whole number)
        return function(i, j)
            assert(i ~= nil and j ~= nil, "For Comparator, a value must be supplied to each of the parameter")
            assert(type(load(Operator.Ternary(string.find(body, "\n")~= nil and string.find(body, "return")~=nil, "", "return ")..body, "Comparator", "t", {i=i, j=j})())=="number", "Comparator must return a value of type boolean")
            local tempLoad = load(Operator.Ternary(string.find(body, "\n")~= nil and string.find(body, "return")~=nil, "", "return ")..body, "Comparator", "t", {i=i, j=j})()
            return {
                comparingAndThen = function(comparator)
                    assert(comparator~=nil, "Comparator function cannot be nil over here")
                    return function(i, j) 
                        
                    end 
                end
            }
        end 
    end 
end