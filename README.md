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
