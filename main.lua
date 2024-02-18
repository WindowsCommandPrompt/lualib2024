 local moduleCore = require("luafunctions")
 
 local arrInit = moduleCore.Array()
 local arrStatic = moduleCore._("Array")
 
 local FILE = io.open("main.luapp", "r")
 
 function main(source)
     print(source)
 end
 
 --Method call
  if FILE then 
     local content = FILE:read("*a")
     main(content)
     FILE:close()
  else 
      error("No such file found. Compilation failed.")
  end
 --End
