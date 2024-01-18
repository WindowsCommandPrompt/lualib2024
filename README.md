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
