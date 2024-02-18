# Type safety, type assignment and a better inheritance experience

The purpose of the 'AssignClassName' function is to provide extensibility to lua tables, aid type checking at a later date. 

## Usage
```lua
function Player()    -- <--Function for the player class
    local instance = { 
        --[[ All your properties, and member functions ]]
    }
    AssignClassName(instance, debug.getinfo(1, "Sunfl").name)     --   <-- You will have to manually call the AssignClassName function in the file, otherwise this class will have a default type 'table'
    return instance
end
```
<br />
However the above mentioned way seems to be ugly. You might be wondering, is there actually a way that we can tell lua to 'automatically' assign a type name to the class function. It seems that we have come up with a viable solution for this. Introducing...  
<br />
<br /> 

The ClassConstructor function!!!

## Usage
```lua
ClassConstructor("Player")     -- Assign a name to this class. 
    :setParameter("level", 3)
    :setParameter("name")
    :setProperty("level", 0)
    :setMethod("setLevel", [[ 
        self.level = level
        return nil
    ]], { 
        [1] = "self",
        [2] = "level"
    })
    :build()             --Call build to return the assembled 'constructor' function to be called. Enjoy your class!
```
<br /> 
<br /> 
<br /> 
Builder patterns in Lua? Hmm....not quite for this programming language. Yes, even with the ClassConstructor, it still looks very ugly. You might be wondering, what else can we use to achieve the same goal but at the same time 

The 

Normally we do inheritance like this according to the standard Lua&copy; manual from the following link: https://www.lua.org/pil/16.2.html as follows:
```lua
--Base class named 'Account'
Account = {balance = 0}
    
function Account:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Account:deposit (v)
  self.balance = self.balance + v
end

function Account:withdraw (v)
  if v > self.balance then error"insufficient funds" end
  self.balance = self.balance - v
end
-----------------------------------------------------------------------------------------
--Derived class called SpecialAccount 
local SpecialAccount = Account:new()
--Overriding the 'withdraw' method in the Account class
function SpecialAccount:withdraw (v)
  if v - self.balance >= self:getLimit() then
    error"insufficient funds"
  end
  self.balance = self.balance - v
end

--Still using the deposit method in the account class
function SpecialAccount:deposit(v)
    Account:deposit(v)   
end
```
This way of writing code to perform inheritance in Lua&copy; is alright, however declaring a class looks extremely long here, and looks rather ugly once again. So many things to write! In Lua&copy;, we can possibly represent the concept of inheritance using <code>setmetatable</code>. Let's take a look at the following example: 
```lua
function A()
    local instance = {
        num = 12, 
        getNum = function(self)
            return self.num
        end 
    } 
    setmetatable(instance, { 
        __super__ = nil,   --Base classes do not have a supertype. Assign 'nil' to indicate that the class is the base. 
        __name__ = debug.getinfo(1, "Sunfl").name   --type assignment
    })
    return instance
end 

function B()
    local instance = {
        num = 13,
        getNum = function(self)
            return getmetatable(self).__super__():getNum()
        end
    }
    setmetatable(instance, {
        __super__ = A,  --class B inherits from class A so we assign the __super__ property of class B's metatable to be class A
        __name__ = debug.getinfo(1, "Sunfl").name  --type assignment
    });
    return instance
end

print(B():getNum())   --getNum() in class B now returns the num field in class A instead. 
```
```txt
 ___________________
|        A          |
|                   |    <---  Root class named 'A'
|                   |
|___________________|
          △
          |
          |
          |
 ___________________
|        B          |
|                   |    <---  Derived class named 'B'
|                   |
|___________________|
```

The purpose of the 'Table' class is to provide extensibility to the 'table' type directly. You can now concatenate two tables directly. 

## Usage
```lua
local t1 = {1,2,3;x=12,y=13}
local t2 = {4,5,6;x=13,y=14}
local combined = Table(t1) + Table(t2)
for k, v in pairs(combined:getData()) do
    print(k, v)
end
```
Do note that the map part of the first table will be overwritten with data from the second table. 

One such application of table merging is for merging of two separate metatables. 
```lua
local m1 = { }
setmetatable(m1, {
    __tostring = function(self)
        return ""
    end 
})

setmetatable(m1, Table(getmetatable(m1)) + Table({
    __eq = function(self, other)
        return false
    end
}))
```
