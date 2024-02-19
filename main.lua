 local moduleCore = require("luafunctions")
 
 local arrInit = moduleCore.Array()

 -- You can also use 
 -- local typeChecker = moduleCore.TypeOf
 -- local arrStatic = moduleCore._(TypeOf(arrInit))

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
