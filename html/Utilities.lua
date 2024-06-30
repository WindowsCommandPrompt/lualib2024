local Utilities = { 
  core = {
    writeln = function(...)
      local vararg = {...}
      local parameters = ""
      for i=1, #vararg do
        parameters = parameters .. vararg[i]
        if i < vararg then 
          parameters = parameters .. ", "
        end 
      end
      if parameters:len() == 0 then
      end 
      return string.format("console.log(\"%s\");", parameters)
    end, 
    errorWriteln = function(arg, ...)
      local vararg = {...}
      local parameters = ""
      for i=1, #vararg do
        parameters = parameters .. vararg[i]
        if i < vararg then 
          parameters = parameters .. ", "
        end 
      end
      return string.format("console.error(\"%s\");", arg or "\n")
    end, 
    infoWriteln = function(arg, ...)
      local vararg = {...}
      local parameters = ""
      for i=1, #vararg do
        parameters = parameters .. vararg[i]
        if i < vararg then 
          parameters = parameters .. ", "
        end 
      end
      return string.format("console.info(\"%s\");", arg or "\n")
    end,
    warnWriteln = function(arg, ...)
      local vararg = {...}
      local parameters = ""
      for i=1, #vararg do
        parameters = parameters .. vararg[i]
        if i < vararg then 
          parameters = parameters .. ", "
        end 
      end 
      return string.format("console.warn(\"%s\");", arg or "\n")
    end
  },
  math = { 
    cbrt = function(arg)
      return string.format
    sqrt = function(arg)
      return string.format("math.sqrt(%s);", arg)
    end,
    abs = function(arg)
      return string.format("math.abs(%s);", arg)
    end,
    acos = function(arg)
      return string.format("math.acos(%s);", arg)
    end,
    asin = function(arg)
      return string.format("math.asin(%s);", arg)
    end,
    atan = function(arg)
      return string.format("math.atan(%s);", arg)
    end,
    atan2 = function(arg)
      return string.format("math.atan2(%s);", arg)
    end,
    ceil = function(arg)
      return string.format("math.ceil(%s);", arg)
    end,
    cos = function(arg)
      return string.format("math.cos(%s);", arg)
    end,
    cosh = function(arg)
      return string.format("math.cosh(%s);", arg)
    end,
    deg = function(arg)
      return string.format("math.deg(%s);", arg)
    end
  },
  document = { 
    
  }
}
