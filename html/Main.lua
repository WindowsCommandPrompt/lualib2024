--import Operator.Ternary

local function execute(statement)
  return coroutine.yield(statement)
end

function html(prop) 
  return Operator.Ternary(type(prop.inner)=="string", string.format([[
    <!DOCTYPE html>
    <html lang="%s">
      %s
    </html>]], prop.lang, prop.inner), string.format([[
    <!DOCTYPE html>
    <html lang="%s">
      %s
    </html>]], prop.lang, (function() 
      local full = [[]]
      table.forEach(prop.inner, function(i)
          full = full .. i
      end) 
      return full 
    end)())
  )
end

--for the head tag
function head(prop)
  return Operator.Ternary(type(prop.inner)=="string",
    string.format([[<head>
      %s
    </head>
    ]], prop.inner),
    string.format([[<head>
        %s
      </head>
      ]], (function() 
      local full = [[]]
      table.forEach(prop.inner, function(i)
          full = full .. i
      end) 
      return full 
    end)())
  )
end 

function meta(prop)
  return string.format("<meta%s%s%s%s/>\n\t\t\t\t", 
    Operator.Ternary(prop.charset, string.format(" charset=\"%s\"", prop.charset), ""), --charset
    Operator.Ternary(prop.viewport, string.format(" viewport=\"%s\"", prop.viewport), ""), --viewport
    Operator.Ternary(prop.name, string.format(" name=\"%s\"", prop.name), ""), --name
    Operator.Ternary(prop.content, string.format(" content=\"%s\"", prop.content), "")
  )
end

function link(prop)
  return string.format("<link%s%s%s%s%s%s/>\n\t\t\t\t",
    Operator.Ternary(prop.href, string.format(" href=\"%s\"", prop.href), ""),
    Operator.Ternary(prop.rel, string.format(" rel=\"%s\"", prop.rel), ""),
    Operator.Ternary(prop.type, string.format(" type=\"%s\"", prop.type), ""),
    Operator.Ternary(prop.crossorigin, string.format(" crossorigin=\"%s\"", prop.crossorigin), ""),
    Operator.Ternary(prop.hreflang, string.format(" hreflang=\"%s\"", prop.hreflang), ""),
    Operator.Ternary(prop.media, string.format(" media=\"%s\"", prop.media), ""),
    Operator.Ternary(prop.referrerpolicy, string.format(" referrerpolicy=\"%s\"", prop.referrerpolicy), ""),
    Operator.Ternary(prop.sizes, string.format(" sizes=\"%s\"", prop.sizes), ""),
    Operator.Ternary(prop.title, string.format(" title=\"%s\"", prop.title), "")
  )
end 

function noscript(prop)
  return string.format("<noscript>%s</noscript>\n\t\t\t\t", prop.inner or "")
end

function script(prop)
  return string.format("<script%s%s%s%s%s%s%s%s></script>\n\t\t\t\t", 
    Operator.Ternary(prop.src, string.format(" src=\"%s\"", prop.src), ""),
    Operator.Ternary(prop.type, string.format(" href=\"%s\"", prop.type), ""),
    Operator.Ternary(prop.crossorigin, string.format(" crossorigin=\"%s\"", prop.crossorigin), ""),
    Operator.Ternary(prop.integrity, string.format(" href=\"%s\"", prop.integrity), ""),
    Operator.Ternary(prop.nomodule, string.format(" nomodule=\"%s\"", prop.nomodule), ""),
    Operator.Ternary(prop.referrerpolicy, string.format(" referrerpolicy=\"%s\"", prop.referrerpolicy), ""),
    Operator.Ternary(type(prop.defer)=="string", string.format(" defer=\"%s\"", prop.defer), Operator.Ternary(table.containsKey(prop, "defer"), " defer", "")),
    Operator.Ternary(prop.async, string.format(" async=\"%s\"", prop.async), "")
  )
end

--just pass a multi-line string into prop.inner
function style(prop)
  local flattened = "" 
  for i=1,prop.inner:len() do
    flattened = flattened .. Operator.Ternary(prop.inner:get(i):byte() ~= 32 and prop.inner:get(i):byte() ~= 10, prop.inner:get(i), "")
  end 
  local ruleSetStart = flattened:findAll("{")
  local ruleSetEnd = flattened:findAll("}")
  if #ruleSetStart ~= #ruleSetEnd then 
    error("Mismatched ruleset '{' and '}'") 
  end
  for i=1, #ruleSetStart do
    local ruleSetContent = flattened:sub(ruleSetStart[i].start+1, ruleSetEnd[i].start-1)
    if i - 1 >= 1 then
      local ruleSetName = flattened:sub(ruleSetEnd[i-1].finish+1, ruleSetStart[i].start-1)
      --pseudo -> ::
      --id -> #
      --class -> .
      --special -> :
      
    else
      local ruleSetName = flattened:sub(1, ruleSetStart[i].start-1)
    end
    local rules = ruleSetContent:split(";")
    for i=1, #rules-1 do
      local property, value = unpack(rules[i]:split(":"))
      if property == "opacity" then
        if not (value >= 0.0 and value <= 1.0) then
          error("Opacity css property ranges must be within 0.0 and 1.0")
        end 
      elseif property == "display" then
        if not table.contains({ "flex", "display", "block", "none", "inline-block", "inline", "contents", "grid", "inline-flex", "inline-grid", "inline-table", "list-item", "run-in", "table", "table-caption", "table-column-group", "table-header-group", "table-footer-group", "table-row-group", "table-cell", "table-column", "initial", "inherit" }, value) then
          error("Display css property can only be of the following values: 'flex', 'display', 'block', 'none', 'inline-block', 'inline', 'contents', 'grid', 'inline-flex', 'inline-grid', 'inline-table', 'list-item', 'run-in', 'table', 'table-caption', 'table-column-group', 'table-header-group', 'table-footer-group', 'table-row-group', 'table-cell', 'table-column', 'initial', 'inherit', provided property is: " .. value) 
        end
      elseif property == "align-content" then 
        if not table.contains({ "center", "stretch", "flex-start", "flex-end", "space-between", "space-around", "space-evenly", "initial", "inherit" }, value) then 
          error("Align-content css property can only be of the following values: 'center', 'stretch', 'flex-start', 'flex-end', 'space-between', 'space-around', 'space-evenly', 'initial', or 'inherit', provided property is: " .. value)
        end 
      elseif property == "align-items" then 
        if not table.contains({"normal", "stretch", "center", "flex-start", "flex-end", "start", "end", "baseline", "initial", "inherit"}, value)then
          error("Align-items css property can only be of the following values: 'normal', 'stretch', 'flex-start', 'flex-end', 'start', 'end', 'baseline', 'initial', or 'inherit', provided property is: " .. value) 
        end 
      elseif property == "align-self" then 
        if not table.contains({ "auto", "stretch", "center", "flex-start", "flex-end", "baseline", "initial", "inherit" }, value) then 
          error("Align-self css property can only be of the following values: 'auto', 'stretch', 'center', 'flex-start', 'flex-end', 'baseline', 'initial', or 'inherit', provided property is: " .. value)
        end 
      elseif property == "all" then 
        if not table.contains({ "initial", "inherit", "unset", "none" }, value) then 
          error("All css property can only be of the following values: 'initial', 'inherit', 'unset', or 'none', provided property is: " .. value)
        end 
      elseif property == "animation" then 
        local animation_name, animation_duration, animation_timing_function, animation_delay, animation_iteration_count, animation_direction, animation_fill_mode, animation_play_state = unpack(value:split("/"))
        animation_name = animation_name or "none"
        animation_duration = animation_duration or 0
        animation_timing_function = animation_timing_function or "ease"
        animation_delay = animation_delay or 0
        animation_iteration_count = animation_iteration_count or 1
        animation_direction = animation_direction or "normal"
        animation_fill_mode = animation_fill_mode or "none" 
        animation_play_state = animation_play_state or "running"
        --check if format for animation-delay is correct
        if animation_delay ~= 0 then 
          if animation_delay:find('ms') then 
            if tonumber(animation_delay:split('ms')[1]) < 0 then
              error("Animation delay must be a positive number")
            end
          elseif animation_delay:find('%d+s') then 
            if tonumber(animation_delay:split('s')[1]) < 0 then
              error("Animation delay must be a positive number")
            end
          else
            error("Invalid format for animation delay, given: " .. animation_delay)
          end 
        end
        --Check if the animation-direction is of a correct value
        if not table.contains({ "normal", "reverse", "alternate", "alternate-reverse", "initial", "inherit" }, animation_direction) then 
          error("Invalid value for animation direction, given: " .. animation_direction)
        end
        --Check if the animation-duration is of a correct value
        if animation_duration ~= 0 then
          if animation_duration:find('ms') then 
            if tonumber(animation_duration:split('ms')[1]) < 0 then
              error("Animation duration must be a positive number")
            end
          elseif animation_duration:find('%d+s') then 
            if tonumber(animation_duration:split('s')[1]) < 0 then
              error("Animation duration must be a positive number")
            end
          else
            error("Invalid format for animation duration, given: " .. animation_duration)
          end 
        end 
        --Check if the animation fill mode is of a correct value
        if not table.contains({ "none", "forwards", "backwards", "both", "initial", "inherit" }, animation_fill_mode) then
          error("Invalid value for animation fill mode: " .. animation_fill_mode)
        end
        --Check if the animation iteration count is a positive value
        local _, err = xpcall(
          function() 
            if tonumber(animation_iteration_count) < 1 then 
              return "Invalid value for animation iteration count. Acceptable values are 'infinite' and any integer value that is greater than or equal to 1, given: " .. animation_iteration_count 
            end 
          end, 
          function() 
            if animation_iteration_count ~= "infinite" then 
              return "Invalid value for animation iteration count. Acceptable values are 'infinite' and any integer value that is greater than or equal to 1, given: " .. animation_iteration_count  
            end
          end
        ) 
        if err then 
          error(err)
        end
        --Check if the animation-name is an empty string
        if animation_name:len() == 0 then 
          error("Animation name cannot be empty")
        end 
        --Check if the animation-play-state is of a valid value
        if not table.contains({ "running", "paused", "initial", "inherit" }, animation_play_state) then
          error("Invalid value for the animation play state css property. Given: " .. animation_play_state)
        end 
        --Check if the animation-timing-function is of a valid value
        local isValidAnimationTimingFunction = false
        if animation_timing_function:contains("cubic-bezier") then
          if not animation_timing_function:find("^cubic%-bezier%((%d%.?[0-9]*),(%d%.?[0-9]*),(%d%.?[0-9]*),(%d%.?[0-9]*)%)$") then 
            error("You have specified 'cubic-bezier' for your animation-timing-function. However, the format is not correct. The correct format is 'cubic-bezier(n,n,n,n)' where n >= 0.0 and n <= 1.0. Given: " .. animation_timing_function)
          end
          local a,b,c,d = unpack(animation_timing_function:sub(animation_timing_function:find("(", 1, true)+1, animation_timing_function:len()-1):split(','))
          a = tonumber(a)
          b = tonumber(b)
          c = tonumber(c)
          d = tonumber(d)
          if not ((a >= 0.0 and a <= 1.0) and (b >= 0.0 and b <= 1.0) and (c >= 0.0 and c <= 1.0) and (d >= 0.0 and d <= 1.0)) then
            error(string.format("All arguments in the cubic-bezier function must be within the range: 0.0 and 1.0. Given: a: %.1f, b: %.1f, c: %.1f, d: %.1f", a, b, c, d))
          end 
          isValidAnimationTimingFunction = not isValidAnimationTimingFunction
        end
        if animation_timing_function:contains("steps") then 
          if not (animation_timing_function:find("^steps%((%d*),%s?(%d*)%)$") or animation_timing_function:find("^steps%((%d*)%)$")) then
            error("You have specified 'steps' for your animation-timing-function. However, the format is not correct. The correct format is 'steps(n,n)' where n must be a positive integer value that is greater than 0. Given: " .. animation_timing_function)
          end 
          --check values
          local _, val = xpcall(
            function()
              local start, finish = unpack(animation_timing_function:sub(animation_timing_function:find("(",1,true)+1,animation_timing_function:len()-1):split(','))
              start = tonumber(start)
              finish = tonumber(finish)
              return { start, finish }
            end, 
            function() 
              local finish = animation_timing_function:sub(animation_timing_function:find("(",1,true)+1,animation_timing_function:len()-1)
              return finish
            end
          )
          if type(val) == "table" then 
            local start, finish = unpack(val)
            if not (finish > start) then 
              error(string.format("The finish must be smaller than the value of start. Given: Start: %d, End: %d", start, finish))
            elseif start == 0 or finish == 0 then
              error(string.format("The value for both 'start' and 'finish' must be greater than 0. Given: Start: %d, End: %d", start, finish))
            end
          else
            if val == 0 then 
              error("The end must be greater than 0")
            end 
          end 
          isValidAnimationTimingFunction = not isValidAnimationTimingFunction
        end
        if not (table.contains({ "linear", "ease", "ease-in", "ease-out", "ease-in-out", "step-start", "step-end", "initial", "inherit" }, animation_timing_function) or isValidAnimationTimingFunction) then
          error("Invalid value for the animation timing function. Allowed values are: 'linear', 'ease', 'ease-in', 'ease-in-out', 'step-start', 'step-end', 'initial', 'inherit', 'cubic-bezier(n,n,n,n)', or 'steps(n,n)'. Given: " .. animation_timing_function)
        end
        value = string.format("%s %s %s %s %s %s %s %s", animation_name, animation_duration, animation_timing_function, animation_delay, animation_iteration_count, animation_direction, animation_fill_mode, animation_play_state)
      elseif property == "aspect-ratio" then
        local isValidValue = false
        if value:find("%d+/%d+") then 
          local width, height = unpack(value:split("/")) 
          if tonumber(height) == 0 or tonumber(width) == 0 then 
            error(string.format("The height and width of the aspect-ratio cannot be set to 0. Given: width: %d, height: %d", width, height))
          end
          isValidValue = not isValidValue
        else
          if value:find("%d+%p+%d+") then 
            local start, stop = value:find("%p+")
            local numerator = value:sub(1, start-1)
            local denominator = value:sub(stop+1, value:len())
            error(string.format("Aspect ratio must either be expressed in the form of a fraction value or of the following values, 'inherit' or 'initial'. You have given the following value: %s, which is invalid, do you mean %d/%d", value, numerator, denominator))
          end 
          isValidValue = not isValidValue
        end 
        if not (table.contains({ "initial", "inherit" }, value) or isValidValue) then 
          error("Invalid value for the aspect-ratio property. Acceptable values include 'inherit', 'initial', and a fraction value represented in the form of m/n. Given: " .. value)
        end 
      elseif property == "backdrop-filter" then 
        local isValidBackdropFilterValue = false
        if value:find("^blur%s?%(%s?%d+.+%s?%)%s?$") then 
          local extent = value:sub(value:find('(',1,true)+1, value:find(')',1,true)-1)
          local function test(target)   --check for units, and then return the magnitude, acceptable units are px,rem,em,vh,vw
            return xpcall(
              function() --CAN ACCESS
                local there = target:find("px")
                return target:sub(1, there-1)
              end, 
              function(err) 
                local t = {xpcall(  --CAN ACCESS
                  function() 
                    local there1 = target:find("rem")
                    return target:sub(1, there1-1)
                  end, 
                  function(err1)
                    --void try next xpcall
                  end
                )}
                local success1, result1 = unpack(t)
                if success1 then 
                  return result1
                else
                  local t = {xpcall(
                    function()
                      local there2 = target:find("vh")
                      return target:sub(1, there2-1)
                    end, 
                    function(err2)
                      --void try next xpcall 
                    end
                  )}
                  local success2, result2 = unpack(t)
                  if success2 then 
                    return result2
                  else
                    local t = {xpcall(
                      function()
                        local there3 = target:find("em")
                        return target:sub(1, there3-1)
                      end, 
                      function(err3)
                        --void perform next xpcall
                      end
                    )}
                    local success3, result3 = unpack(t)
                    if success3 then 
                      return result3
                    else 
                      local t = {xpcall(
                        function()
                          local there4 = target:find("vw")
                          return target:sub(1, there4-1)
                        end,
                        function(err4)
                          --void return custom error message
                        end
                      )}
                      local success4, result4 = unpack(t)
                      if success4 then 
                        return result4
                      else
                        local t = {xpcall(
                          function() 
                            local units = target:find("cm")
                            return target:sub(1, units - 1)
                          end, 
                          function() 
                            --void proceed to next xpcall
                          end
                        )}
                        local success, result = unpack(t)
                        if success then 
                          return result
                        else
                          local t = {xpcall(
                            function()
                              local units = target:find("mm")
                              return target:sub(1, units - 1)
                            end, 
                            function()
                              --void proceed to next xpcall
                            end 
                          )}
                          local success, result = unpack(t)
                          if success then 
                            return result
                          else
                            local t = {xpcall(
                              function()
                                local units = target:find("in")
                                return target:sub(1, units - 1)
                              end,
                              function()
                                --void proceed to next xpcall
                              end
                            )}
                            local success, result = unpack(t)
                            if success then 
                              return result
                            else
                              local t = {xpcall(
                                function()
                                  local units = target:find("pt")
                                  return target:sub(1, units - 1)
                                end,
                                function()
                                  --void go to next xpcall
                                end
                              )}
                              local success, result = unpack(t)
                              if success then 
                                return result
                              else
                                local t = {xpcall(
                                  function() 
                                    local units = target:find("pc")
                                    return target:sub(1, units - 1)
                                  end, 
                                  function() 
                                    --void go to next xpcall
                                  end
                                )}
                                local success, result = unpack(t)
                                if success then 
                                  return result
                                else
                                  local t = {xpcall(
                                    function() 
                                      local units = target:find("vmin")
                                      return target:sub(1, units-1)
                                    end, 
                                    function() 
                                      --void go to next xpcall
                                    end
                                  )}
                                  local success, result = unpack(t)
                                  if success then 
                                    return result
                                  else
                                    local t = {xpcall(
                                      function()
                                        local units = target:find("vmax")
                                        return target:sub(1, units - 1)
                                      end,
                                      function()
                                        --void go to next xpcall
                                      end
                                    )}
                                    local success, result = unpack(t)
                                    if success then 
                                      return result
                                    else
                                      local t = {xpcall(
                                        function()
                                          local units = target:find("ch")
                                          return target:sub(1, units - 1)
                                        end,
                                        function()
                                          --void return nil
                                        end
                                      )}
                                      local success, result = unpack(t)
                                      if success then 
                                        return result 
                                      else 
                                        return nil
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            )
          end
          if not rawget({test(extent)}, 2) then
            error("The parameter for this blur function must be expressed in terms of 'px', 'rem', 'vh', 'vw', 'em'. Given: " )
          end
        elseif value:find("^brightness%s?%(%s?%d+.+%s?%)%s?$") then 
          local extent = value:sub(value:find('(',1,true)+1, value:find(')',1,true)-1)
          local start, stop = extent:find("^%d+")
          local unit = extent:sub(stop+1)
          if not table.contains({ "%" }, unit) then
            error("The parameter for this brightness function must be expressed in terms of a percentage (%), not " .. unit)
          end
          --check if the percentage value is greater than equal to 0 and smaller than or equal to 100 for the brightness function
          local magnitude = tonumber(extent:sub(1, stop))
          if not (magnitude >= 0 and magnitude <= 100) then
            error(string.format("The percentage value for the brightness function must be between 0 (inclusive) and 100 (inclusive). Given: %s%%", magnitude))
          end 
        --contrast
        elseif value:find("^contrast%s?%(%s?%d+.+%s?%)%s?$") then
          local extent = value:sub(value:find('(',1,true)+1, value:find(')',1,true)-1)
          local start, stop = extent:find("^%d+")
          local unit = extent:sub(stop+1)
          if not table.contains({ "%" }, unit) then
            error("The parameter for this contrast function must be expressed in terms of a percentage (%), not " .. unit)
          end
        --drop-shadow
      elseif value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*px)%s?,%s?(%-?%s?%d*px)%s?,%s?(%-?%s?%d*px)%s?,%s?([Rr][Ee][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*px)%s?,%s?(%-?%s?%d*px)%s?,%s?([Rr][Ee][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Yy][Ee][Ll][Ll][Oo][Ww])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Yy][Ee][Ll][Ll][Oo][Ww])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Bb][Ll][Uu][Ee])%s?%)%s?$") 
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Bb][Ll][Uu][Ee])%s?%)%s?$") 
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Aa][Ll][Ii][Cc][Ee][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Aa][Ll][Ii][Cc][Ee][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Aa][Nn][Tt][Ii][Qq][Uu][Ee][Ww][Hh][Ii][Tt][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Aa][Nn][Tt][Ii][Qq][Uu][Ee][Ww][Hh][Ii][Tt][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Aa][Qq][Uu][Aa])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Aa][Qq][Uu][Aa])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Aa][Qq][Uu][Aa][Mm][Aa][Rr][Ii][Nn][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Aa][Qq][Uu][Aa][Mm][Aa][Rr][Ii][Nn][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Aa][Zz][Uu][Rr][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Aa][Zz][Uu][Rr][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Bb][Ee][Ii][Gg][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Bb][Ee][Ii][Gg][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Bb][Ii][Ss][Qq][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Bb][Ii][Ss][Qq][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Bb][Ll][Aa][Cc][Kk])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Bb][Ll][Aa][Cc][Kk])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Bb][Ll][Aa][Nn][Cc][Hh][Ee][Dd][Aa][Ll][Mm][Oo][Nn][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Bb][Ll][Aa][Nn][Cc][Hh][Ee][Dd][Aa][Ll][Mm][Oo][Nn][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Bb][Ll][Uu][Ee][Vv][Ii][Oo][Ll][Ee][Tt])%s?%)%s?$") 
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Bb][Ll][Uu][Ee][Vv][Ii][Oo][Ll][Ee][Tt])%s?%)%s?$") 
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Bb][Rr][Oo][Ww][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Bb][Rr][Oo][Ww][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Bb][Uu][Rr][Ll][Yy][Ww][Oo][Oo][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Bb][Uu][Rr][Ll][Yy][Ww][Oo][Oo][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Cc][Aa][Dd][Ee][Tt][Bb][Ll][Uu][Ee])%s?%)%s?$") 
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Cc][Aa][Dd][Ee][Tt][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Cc][Hh][Aa][Rr][Tt][Rr][Ee][Uu][Ss][Ee])%s?%)%s?$") 
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Cc][Hh][Aa][Rr][Tt][Rr][Ee][Uu][Ss][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Cc][Hh][Oo][Cc][Oo][Ll][Aa][Tt][Ee])%s?%)%s?$") 
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Cc][Hh][Oo][Cc][Oo][Ll][Aa][Tt][Ee])%s?%)%s?$") 
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Cc][Oo][Rr][Aa][Ll])%s?%)%s?$") 
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Cc][Oo][Rr][Aa][Ll])%s?%)%s?$") 
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Cc][Oo][Rr][Nn][Ff][Ll][Oo][Ww][Ee][Rr][Bb][Ll][Uu][Ee])%s?%)%s?$") 
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Cc][Oo][Rr][Nn][Ff][Ll][Oo][Ww][Ee][Rr][Bb][Ll][Uu][Ee])%s?%)%s?$") 
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Cc][Oo][Rr][Nn][Ss][Ii][Ll][Kk])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Cc][Oo][Rr][Nn][Ss][Ii][Ll][Kk])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Cc][Rr][Ii][Mm][Ss][Oo][Nn])%s?%)%s?$") 
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Cc][Rr][Ii][Mm][Ss][Oo][Nn])%s?%)%s?$") 
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Cc][Yy][Aa][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Cc][Yy][Aa][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Cc][Yy][Aa][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Cc][Yy][Aa][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Gg][Oo][Ll][Dd][Ee][Nn][Rr][Oo][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Gg][Oo][Ll][Dd][Ee][Nn][Rr][Oo][Dd])%s?%)%s?$")
          or value:find(
"^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Gg][Rr][Aa][Yy])%s?%)%s?$")
          or value:find(
"^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Gg][Rr][Aa][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Gg][Rr][Ee][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Gg][Rr][Ee][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Kk][Hh][Aa][Kk][Ii])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Kk][Hh][Aa][Kk][Ii])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Mm][Aa][Gg][Ee][Nn][Tt][Aa])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Mm][Aa][Gg][Ee][Nn][Tt][Aa])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Oo][Ll][Ii][Vv][Ee][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Oo][Ll][Ii][Vv][Ee][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Oo][Rr][Aa][Nn][Gg][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Oo][Rr][Aa][Nn][Gg][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Oo][Rr][Cc][Hh][Ii][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Oo][Rr][Cc][Hh][Ii][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Rr][Ee][Dd])%s?%)%s?$") 
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Rr][Ee][Dd])%s?%)%s?$") 
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Ss][Aa][Ll][Mm][Oo][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Ss][Aa][Ll][Mm][Oo][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Ss][Ee][Aa][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Ss][Ee][Aa][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Ss][Ll][Aa][Tt][Ee][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Ss][Ll][Aa][Tt][Ee][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Ss][Ll][Aa][Tt][Ee][Gg][Rr][Aa][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Ss][Ll][Aa][Tt][Ee][Gg][Rr][Aa][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Ss][Ll][Aa][Tt][Ee][Gg][Rr][Ee][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Ss][Ll][Aa][Tt][Ee][Gg][Rr][Ee][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Tt][Uu][Rr][Qq][Uu][Oo][Ii][Ss][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Tt][Uu][Rr][Qq][Uu][Oo][Ii][Ss][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Vv][Ii][Oo][Ll][Ee][Tt])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Aa][Rr][Kk][Vv][Ii][Oo][Ll][Ee][Tt])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Ee][Ee][Pp][Pp][Ii][Nn][Kk])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Ee][Ee][Pp][Pp][Ii][Nn][Kk])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*px)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Ee][Ee][Pp][Ss][Kk][Yy][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*px)%s?,%s?([Dd][Ee][Ee][Pp][Ss][Kk][Yy][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Ii][Mm][Gg][Rr][Aa][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Ii][Mm][Gg][Rr][Aa][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Ii][Mm][Gg][Rr][Ee][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Ii][Mm][Gg][Rr][Ee][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Oo][Dd][Gg][Ee][Rr][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Dd][Oo][Dd][Gg][Ee][Rr][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ff][Ii][Rr][Ee][Bb][Rr][Ii][Cc][Kk])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ff][Ii][Rr][Ee][Bb][Rr][Ii][Cc][Kk])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ff][Ll][Oo][Rr][Aa][Ll][Ww][Hh][Ii][Tt][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ff][Ll][Oo][Rr][Aa][Ll][Ww][Hh][Ii][Tt][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ff][Oo][Rr][Ee][Ss][Tt][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ff][Oo][Rr][Ee][Ss][Tt][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ff][Uu][Cc][Hh][Ss][Ii][Aa])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ff][Uu][Cc][Hh][Ss][Ii][Aa])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Gg][Aa][Ii][Nn][Ss][Bb][Oo][Rr][Oo])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Gg][Aa][Ii][Nn][Ss][Bb][Oo][Rr][Oo])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Gg][Hh][Oo][Ss][Tt][Ww][Hh][Ii][Tt][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Gg][Hh][Oo][Ss][Tt][Ww][Hh][Ii][Tt][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Gg][Oo][Ll][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Gg][Oo][Ll][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Gg][Oo][Ll][Dd][Ee][Nn][Rr][Oo][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Gg][Oo][Ll][Dd][Ee][Nn][Rr][Oo][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Gg][Rr][Aa][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Gg][Rr][Aa][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Gg][Rr][Ee][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Gg][Rr][Ee][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Gg][Rr][Ee][Ee][Nn][Yy][Ee][Ll][Ll][Oo][Ww])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Gg][Rr][Ee][Ee][Nn][Yy][Ee][Ll][Ll][Oo][Ww])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Hh][Oo][Nn][Ee][Yy][Dd][Ee][Ww])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Hh][Oo][Nn][Ee][Yy][Dd][Ee][Ww])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Hh][Oo][Tt][Pp][Ii][Nn][Kk])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Hh][Oo][Tt][Pp][Ii][Nn][Kk])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ii][Nn][Dd][Ii][Aa][Nn][Rr][Ee][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ii][Nn][Dd][Ii][Aa][Nn][Rr][Ee][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ii][Nn][Dd][Ii][Gg][Oo])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ii][Nn][Dd][Ii][Gg][Oo])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ii][Vv][Oo][Rr][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ii][Vv][Oo][Rr][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Kk][Hh][Aa][Kk][Ii])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Kk][Hh][Aa][Kk][Ii])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Aa][Vv][Ee][Nn][Dd][Ee][Rr])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Aa][Vv][Ee][Nn][Dd][Ee][Rr])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Aa][Vv][Ee][Nn][Dd][Ee][Rr][Bb][Ll][Uu][Ss][Hh])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Aa][Vv][Ee][Nn][Dd][Ee][Rr][Bb][Ll][Uu][Ss][Hh])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Aa][Ww][Nn][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Aa][Ww][Nn][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ee][Mm][Oo][Nn][Cc][Hh][Ii][Ff][Ff][Oo][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ee][Mm][Oo][Nn][Cc][Hh][Ii][Ff][Ff][Oo][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Cc][Oo][Rr][Aa][Ll])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Cc][Oo][Rr][Aa][Ll])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Cc][Yy][Aa][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Cc][Yy][Aa][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Gg][Oo][Ll][Dd][Ee][Nn][Rr][Oo][Dd][Yy][Ee][Ll][Ll][Oo][Ww])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Gg][Oo][Ll][Dd][Ee][Nn][Rr][Oo][Dd][Yy][Ee][Ll][Ll][Oo][Ww])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Gg][Rr][Aa][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Gg][Rr][Aa][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Gg][Rr][Ee][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Gg][Rr][Ee][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Pp][Ii][Nn][Kk])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Pp][Ii][Nn][Kk])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Ss][Aa][Ll][Mm][Oo][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Ss][Aa][Ll][Mm][Oo][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Ss][Ee][Aa][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Ss][Ee][Aa][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Ss][Kk][Yy][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Ss][Kk][Yy][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Ss][Ll][Aa][Tt][Ee][Gg][Rr][Aa][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Ss][Ll][Aa][Tt][Ee][Gg][Rr][Aa][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Ss][Ll][Aa][Tt][Ee][Gg][Rr][Ee][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Ss][Ll][Aa][Tt][Ee][Gg][Rr][Ee][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Ss][Tt][Ee][Ee][Ll][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Ss][Tt][Ee][Ee][Ll][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Yy][Ee][Ll][Ll][Oo][Ww])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Gg][Hh][Tt][Yy][Ee][Ll][Ll][Oo][Ww])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Mm][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Mm][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Mm][Ee][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Mm][Ee][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Nn][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ll][Ii][Nn][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Aa][Gg][Ee][Nn][Tt][Aa])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Aa][Gg][Ee][Nn][Tt][Aa])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Aa][Rr][Oo][Oo][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Aa][Rr][Oo][Oo][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ee][Dd][Ii][Uu][Mm][Aa][Qq][Uu][Aa][Mm][Aa][Rr][Ii][Nn][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ee][Dd][Ii][Uu][Mm][Aa][Qq][Uu][Aa][Mm][Aa][Rr][Ii][Nn][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ee][Dd][Ii][Uu][Mm][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ee][Dd][Ii][Uu][Mm][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ee][Dd][Ii][Uu][Mm][Oo][Rr][Cc][Hh][Ii][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ee][Dd][Ii][Uu][Mm][Oo][Rr][Cc][Hh][Ii][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ee][Dd][Ii][Uu][Mm][Pp][Uu][Rr][Pp][Ll][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ee][Dd][Ii][Uu][Mm][Pp][Uu][Rr][Pp][Ll][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ee][Dd][Ii][Uu][Mm][Ss][Ee][Aa][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ee][Dd][Ii][Uu][Mm][Ss][Ee][Aa][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ee][Dd][Ii][Uu][Mm][Ss][Ll][Aa][Tt][Ee][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ee][Dd][Ii][Uu][Mm][Ss][Ll][Aa][Tt][Ee][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ee][Dd][Ii][Uu][Mm][Ss][Pp][Rr][Ii][Nn][Gg][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ee][Dd][Ii][Uu][Mm][Ss][Pp][Rr][Ii][Nn][Gg][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ee][Dd][Ii][Uu][Mm][Tt][Uu][Rr][Qq][Uu][Oo][Ii][Ss][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ee][Dd][Ii][Uu][Mm][Tt][Uu][Rr][Qq][Uu][Oo][Ii][Ss][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ee][Dd][Ii][Uu][Mm][Vv][Ii][Oo][Ll][Ee][Tt][Rr][Ee][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ee][Dd][Ii][Uu][Mm][Vv][Ii][Oo][Ll][Ee][Tt][Rr][Ee][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ee][Dd][Ii][Uu][Mm][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ee][Dd][Ii][Uu][Mm][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ii][Nn][Tt][Cc][Rr][Ee][Aa][Mm])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ii][Nn][Tt][Cc][Rr][Ee][Aa][Mm])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ii][Ss][Tt][Yy][Rr][Oo][Ss][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Ii][Ss][Tt][Yy][Rr][Oo][Ss][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Oo][Cc][Cc][Aa][Ss][Ii][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Mm][Oo][Cc][Cc][Aa][Ss][Ii][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Nn][Aa][Vv][Aa][Jj][Oo][Ww][Hh][Ii][Tt][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Nn][Aa][Vv][Aa][Jj][Oo][Ww][Hh][Ii][Tt][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Oo][Ll][Dd][Ll][Aa][Cc][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Oo][Ll][Dd][Ll][Aa][Cc][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Oo][Ll][Ii][Vv][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Oo][Ll][Ii][Vv][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Oo][Ll][Ii][Vv][Ee][Dd][Rr][Aa][Bb])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Oo][Ll][Ii][Vv][Ee][Dd][Rr][Aa][Bb])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Oo][Rr][Aa][Nn][Gg][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Oo][Rr][Aa][Nn][Gg][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Oo][Rr][Aa][Nn][Gg][Ee][Rr][Ee][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Oo][Rr][Aa][Nn][Gg][Ee][Rr][Ee][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Oo][Rr][Cc][Hh][Ii][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Oo][Rr][Cc][Hh][Ii][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Pp][Aa][Ll][Ee][Gg][Oo][Ll][Dd][Ee][Nn][Rr][Oo][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Pp][Aa][Ll][Ee][Gg][Oo][Ll][Dd][Ee][Nn][Rr][Oo][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Pp][Aa][Ll][Ee][Gg][Rr][Ee][Ee][Nn]%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Pp][Aa][Ll][Ee][Gg][Rr][Ee][Ee][Nn]%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Pp][Aa][Ll][Ee][Tt][Uu][Rr][Qq][Uu][Oo][Ii][Ss][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Pp][Aa][Ll][Ee][Tt][Uu][Rr][Qq][Uu][Oo][Ii][Ss][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Pp][Aa][Ll][Ee][Vv][Ii][Oo][Ll][Ee][Tt][Rr][Ee][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Pp][Aa][Ll][Ee][Vv][Ii][Oo][Ll][Ee][Tt][Rr][Ee][Dd])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Pp][Aa][Pp][Aa][Yy][Aa][Ww][Hh][Ii][Pp])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Pp][Aa][Pp][Aa][Yy][Aa][Ww][Hh][Ii][Pp])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Pp][Ee][Aa][Cc][Hh][Pp][Uu][Ff][Ff])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Pp][Ee][Aa][Cc][Hh][Pp][Uu][Ff][Ff])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Pp][Ee][Rr][Uu])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Pp][Ee][Rr][Uu])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Pp][Ii][Nn][Kk])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Pp][Ii][Nn][Kk])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Pp][Ll][Uu][Mm])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Pp][Ll][Uu][Mm])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Pp][Oo][Ww][Dd][Ee][Rr][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Pp][Oo][Ww][Dd][Ee][Rr][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Pp][Uu][Rr][Pp][Ll][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Pp][Uu][Rr][Pp][Ll][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Rr][Ee][Bb][Ee][Cc][Cc][Aa][Pp][Uu][Rr][Pp][Ll][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Rr][Ee][Bb][Ee][Cc][Cc][Aa][Pp][Uu][Rr][Pp][Ll][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Rr][Oo][Ss][Yy][Bb][Rr][Oo][Ww][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Rr][Oo][Ss][Yy][Bb][Rr][Oo][Ww][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Rr][Oo][Yy][Aa][Ll][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Rr][Oo][Yy][Aa][Ll][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Aa][Dd][Dd][Ll][Ee][Bb][Rr][Oo][Ww][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Aa][Dd][Dd][Ll][Ee][Bb][Rr][Oo][Ww][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Aa][Ll][Mm][Oo][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Aa][Ll][Mm][Oo][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Aa][Nn][Dd][Yy][Bb][Rr][Oo][Ww][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Aa][Nn][Dd][Yy][Bb][Rr][Oo][Ww][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Ee][Aa][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Ee][Aa][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Ee][Aa][Ss][Hh][Ee][Ll][Ll])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Ee][Aa][Ss][Hh][Ee][Ll][Ll])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Ii][Ee][Nn][Nn][Aa])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Ii][Ee][Nn][Nn][Aa])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Ii][Ll][Vv][Ee][Rr])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Ii][Ll][Vv][Ee][Rr])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Kk][Yy][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Kk][Yy][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Ll][Aa][Tt][Ee][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Ll][Aa][Tt][Ee][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Ll][Aa][Tt][Ee][Gg][Rr][Aa][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Ll][Aa][Tt][Ee][Gg][Rr][Aa][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Ll][Aa][Tt][Ee][Gg][Rr][Ee][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Ll][Aa][Tt][Ee][Gg][Rr][Ee][Yy])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Nn][Oo][Ww])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Nn][Oo][Ww])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Pp][Rr][Ii][Nn][Gg][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Pp][Rr][Ii][Nn][Gg][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Tt][Ee][Ee][Ll][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ss][Tt][Ee][Ee][Ll][Bb][Ll][Uu][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*px)%s?,%s?(%-?%s?%d*px)%s?,%s?(%-?%s?%d*px)%s?,%s?([Tt][Aa][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*px)%s?,%s?(%-?%s?%d*px)%s?,%s?([Tt][Aa][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Tt][Ee][Aa][Ll])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Tt][Ee][Aa][Ll])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Tt][Hh][Ii][Ss][Tt][Ll][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Tt][Hh][Ii][Ss][Tt][Ll][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Tt][Oo][Mm][Aa][Tt][Oo])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Tt][Oo][Mm][Aa][Tt][Oo])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Tt][Uu][Rr][Qq][Uu][Oo][Ii][Ss][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Tt][Uu][Rr][Qq][Uu][Oo][Ii][Ss][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Vv][Ii][Oo][Ll][Ee][Tt])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Vv][Ii][Oo][Ll][Ee][Tt])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ww][Hh][Ee][Aa][Tt])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ww][Hh][Ee][Aa][Tt])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ww][Hh][Ii][Tt][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ww][Hh][Ii][Tt][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ww][Hh][Ii][Tt][Ee][Ss][Mm][Oo][Kk][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Ww][Hh][Ii][Tt][Ee][Ss][Mm][Oo][Kk][Ee])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Yy][Ee][Ll][Ll][Oo][Ww][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Yy][Ee][Ll][Ll][Oo][Ww][Gg][Rr][Ee][Ee][Nn])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Tt][Rr][Aa][Nn][Ss][Pp][Aa][Rr][Ee][Nn][Tt])%s?%)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?([Tt][Rr][Aa][Nn][Ss][Pp][Aa][Rr][Ee][Nn][Tt])%s?%)%s?$")
          --HEXADECIMAL COLOR MATCH
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?,%s?(#[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])%s?%)%s?$") --aliceblue color hexadecimal
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*)%s?$")
          or value:find("^drop%-shadow%s?%(%s?(%-?%s?%d*.*)%s?,%s?(%-?%s?%d*.*),%s?(%-?%s?%d*.*)%s?$")
          --drop-shadow(4px 4px 4px red) or drop-shadow(4px 4px red) or drop-shadow(4px 4px) or drop-shadow(4px 4px 4px)
        then 
          --For the drop shadow function
          --l3 may or may not exist according to the above regex expression
          --color may or may not exist according to the above regex expression
          local l1, l2, l3, color = unpack(value:sub(value:find('%(')+1, value:find('%)')-1):split(','))
          if not color then
            --check if color is moved to l3 instead.
            --check the format of the color value
            if not (l3:find("px") or l3:find("rem") or l3:find("vw") or l3:find("vh") or l3:find("em")) then
              color = l3 
              l3 = "0px" --assign l3 with a default value of "0px"
            else 
              color = "transparent"
            end
          end
          if not l3 then
            l3 = "0px"
          end
          color = color:lower()
          --check for all units using xpcall directly.
          local lengths = { l1, l2, l3 }
          local function test(target)   --check for units, and then return the magnitude, acceptable units are px,rem,em,vh,vw
            return xpcall(
              function() --CAN ACCESS
                local there = target:find("px")
                return target:sub(1, there-1)
              end, 
              function(err) 
                local t = {xpcall(  --CAN ACCESS
                  function() 
                    local there1 = target:find("rem")
                    return target:sub(1, there1-1)
                  end, 
                  function(err1)
                    --void try next xpcall
                  end
                )}
                local success1, result1 = unpack(t)
                if success1 then 
                  return result1
                else
                  local t = {xpcall(
                    function()
                      local there2 = target:find("vh")
                      return target:sub(1, there2-1)
                    end, 
                    function(err2)
                      --void try next xpcall 
                    end
                  )}
                  local success2, result2 = unpack(t)
                  if success2 then 
                    return result2
                  else
                    local t = {xpcall(
                      function()
                        local there3 = target:find("em")
                        return target:sub(1, there3-1)
                      end, 
                      function(err3)
                        --void perform next xpcall
                      end
                    )}
                    local success3, result3 = unpack(t)
                    if success3 then 
                      return result3
                    else 
                      local t = {xpcall(
                        function()
                          local there4 = target:find("vw")
                          return target:sub(1, there4-1)
                        end,
                        function(err4)
                          --void return custom error message
                        end
                      )}
                      local success4, result4 = unpack(t)
                      if success4 then 
                        return result4
                      else
                        local t = {xpcall(
                          function() 
                            local units = target:find("cm")
                            return target:sub(1, units - 1)
                          end, 
                          function() 
                            --void proceed to next xpcall
                          end
                        )}
                        local success, result = unpack(t)
                        if success then 
                          return result
                        else
                          local t = {xpcall(
                            function()
                              local units = target:find("mm")
                              return target:sub(1, units - 1)
                            end, 
                            function()
                              --void proceed to next xpcall
                            end 
                          )}
                          local success, result = unpack(t)
                          if success then 
                            return result
                          else
                            local t = {xpcall(
                              function()
                                local units = target:find("in")
                                return target:sub(1, units - 1)
                              end,
                              function()
                                --void proceed to next xpcall
                              end
                            )}
                            local success, result = unpack(t)
                            if success then 
                              return result
                            else
                              local t = {xpcall(
                                function()
                                  local units = target:find("pt")
                                  return target:sub(1, units - 1)
                                end,
                                function()
                                  --void go to next xpcall
                                end
                              )}
                              local success, result = unpack(t)
                              if success then 
                                return result
                              else
                                local t = {xpcall(
                                  function() 
                                    local units = target:find("pc")
                                    return target:sub(1, units - 1)
                                  end, 
                                  function() 
                                    --void go to next xpcall
                                  end
                                )}
                                local success, result = unpack(t)
                                if success then 
                                  return result
                                else
                                  local t = {xpcall(
                                    function() 
                                      local units = target:find("vmin")
                                      return target:sub(1, units-1)
                                    end, 
                                    function() 
                                      --void go to next xpcall
                                    end
                                  )}
                                  local success, result = unpack(t)
                                  if success then 
                                    return result
                                  else
                                    local t = {xpcall(
                                      function()
                                        local units = target:find("vmax")
                                        return target:sub(1, units - 1)
                                      end,
                                      function()
                                        --void go to next xpcall
                                      end
                                    )}
                                    local success, result = unpack(t)
                                    if success then 
                                      return result
                                    else
                                      local t = {xpcall(
                                        function()
                                          local units = target:find("ch")
                                          return target:sub(1, units - 1)
                                        end,
                                        function()
                                          --void return nil
                                        end
                                      )}
                                      local success, result = unpack(t)
                                      if success then 
                                        return result 
                                      else 
                                        return nil
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            )
          end 
          if not rawget({test(lengths[1])}, 2) then
            error("L1 property is of an unknown unit. Acceptable units are: 'px', 'rem', 'em', 'vh', 'vw'. Given: ")
          end
          if not rawget({test(lengths[2])}, 2) then
            error("L2 property is of an unknown unit. Acceptable units are: 'px', 'rem', 'em', 'vh', 'vw'. Given: ")
          end
          if not rawget({test(lengths[3])}, 2) then
            error("L3 property is of an unknown unit. Acceptable units are: 'px', 'rem', 'em', 'vh', 'vw'. Given: ")
          end
          --must begin with a numeric value
          if not rawget({test(lengths[1])}, 2):match("^%d*") then 
            local start, finish = rawget({test(lengths[1])}, 2):find("^[^%d*]*")
            local defect = rawget({test(lengths[1])}, 2):sub(start, finish)
            error(string.format("The value for L1 property in the drop-shadow function should begin with a numeric value. Given: %s. Remove '%s' from the string", rawget({test(lengths[1])}, 2), defect))
          end 
          if not rawget({test(lengths[2])}, 2):match("^%d*") then 
            local start, finish = rawget({test(lengths[2])}, 2):find("^[^%d*]*")
            local defect = rawget({test(lengths[2])}, 2):sub(start, finish)
            error(string.format("The value for L1 property in the drop-shadow function should begin with a numeric value. Given: %s. Remove '%s' from the string", rawget({test(lengths[2])}, 2), defect))
          end 
          if not rawget({test(lengths[3])}, 2):match("^%d*") then 
            local start, finish = rawget({test(lengths[3])}, 2):find("^[^%d*]*")
            local defect = rawget({test(lengths[3])}, 2):sub(start, finish)
            error(string.format("The value for L1 property in the drop-shadow function should begin with a numeric value. Given: %s. Remove '%s' from the string", rawget({test(lengths[3])}, 2), defect))
          end 
          local v1, v2, v3 = tonumber(rawget({test(lengths[1])}, 2)), tonumber(rawget({test(lengths[2])}, 2)), tonumber(rawget({test(lengths[3])}, 2))
          if not (v1 >= 0 and v2 >= 0 and v3 >= 0) then
            error(string.format("Width, length and height must not be less than 0. Given: Length1: %.2f  Length2: %.2f  Length3: %.2f", v1, v2, v3))
          end
          --reformat the css value
          value = string.format("%s%s %s %s %s%s", value:sub(1, value:find('%(')), l1, l2, l3, color, value:sub(value:find('%)')))
          isValidBackdropFilterValue = not isValidBackdropFilterValue
        --grayscale
        elseif value:find("^grayscale%s?%(%s?%-?%s?%d+.+%s?%)%s?$") then 
          local extent = value:sub(value:find('(',1,true)+1, value:find(')',1,true)-1)
          local start, stop = extent:find("^%d+")
          local unit = extent:sub(stop+1)
          if not table.contains({ "%" }, unit) then
            error("The parameter for this grayscale function must be expressed in terms of a percentage (%), not " .. unit)
          end
          --check if the percentage value is greater than equal to 0 and smaller than or equal to 100 for the grayscale value
          local magnitude = tonumber(extent:sub(1, stop))
          if not (magnitude >= 0 and magnitude <= 100) then
            error(string.format("The percentage value for the grayscale function must be between 0 (inclusive) and 100 (inclusive). Given: %s%%", magnitude))
          end 
          isValidBackdropFilterValue = not isValidBackdropFilterValue
        --hue-rotate
      elseif value:find("^hue%-rotate%s?%(%s?%-?%s?%d*.*%s?%)%s?$") then 
          --[[ 
            valid units: 
            deg -> degrees: range => 0.00 thru 360.00
            rad -> radians: range => 0.00 thru 2*math.pi approx. 6.28...
            grad -> gradians: range => 0.00 thru 400.00
          ]]
          local extent = value:sub(value:find('(',1,true)+1, value:find(')',1,true)-1)
          local function test(target)
            return xpcall(
              function()
                local there = target:find("deg")
                return target:sub(1, there-1)
              end,
              function()
                local t = {xpcall(
                  function()
                    local there1 = target:find("rad")
                    return target:sub(1, there1-1)
                  end,
                  function()
                    --void try next xpcall
                  end
                )}
                local success1, result1 = unpack(t)
                if success1 then 
                  return result1 
                else
                  local t = {xpcall(
                    function()
                      local there2 = target:find("grad")
                      return target:sub(1, there2-1)
                    end, 
                    function()
                      --void try next xpcall
                    end
                  )}
                  local success2, result2 = unpack(t)
                  if success2 then
                    return result2
                  else
                    return nil
                  end
                end 
              end 
            )
          end
          if not rawget({test(extent)}, 2) then
            error("The parameter for this hue-rotate function must be expressed in terms of degrees(deg), radians(rad) or gradians(grad), not " .. unit)
          end
          if not rawget({test(extent)}, 2):match("^%d*") then 
            local start, finish = rawget({test(extent)}, 2):find("^[^%d*]*")
            local defect = rawget({test(extent)}, 2):sub(start, finish)
            error(string.format("The value should begin with a numeric value. Given: %s. Remove '%s' from the string", rawget({test(extent)}, 2), defect))
          end 
          isValidBackdropFilterValue = not isValidBackdropFilterValue
        --invert
        elseif value:find("^invert%s?%(%s?%-?%s?%d*.*%s?%)%s?$") then 
          local extent = value:sub(value:find('(',1,true)+1, value:find(')',1,true)-1)
          local start, stop = extent:find("^%d+")
          local unit = extent:sub(stop+1)
          if not table.contains({ "%" }, unit) then
            error("The parameter for this invert function must be expressed in terms of a percentage (%), not " .. unit)
          end
          --check if the percentage value is greater than equal to 0 and smaller than or equal to 100 for the grayscale value
          local magnitude = tonumber(extent:sub(1, stop))
          if not (magnitude >= 0 and magnitude <= 100) then
            error(string.format("The percentage value for the invert function must be between 0 (inclusive) and 100 (inclusive). Given: %s%%", magnitude))
          end
          isValidBackdropFilterValue = not isValidBackdropFilterValue
        --opacity
        elseif value:find("^opacity%s?%(%s?%-?%s?%d*.*%s?%)%s?$") then 
          local extent = value:sub(value:find('(',1,true)+1, value:find(')',1,true)-1)
          local start, stop = extent:find("^%d+")
          local unit = extent:sub(stop+1)
          if not table.contains({ "%" }, unit) then
            error("The parameter for this opacity function must be expressed in terms of a percentage (%), not " .. unit)
          end
          --check if the percentage value is greater than equal to 0 and smaller than or equal to 100 for the grayscale value
          local magnitude = tonumber(extent:sub(1, stop))
          if not (magnitude >= 0 and magnitude <= 100) then
            error(string.format("The percentage value for the opacity function must be between 0 (inclusive) and 100 (inclusive). Given: %s%%", magnitude))
          end
          isValidBackdropFilterValue = not isValidBackdropFilterValue
        --sepia 
        elseif value:find("^sepia%s?%(%s?%-?%s?%d*.*%s?%)%s?$") then 
          local extent = value:sub(value:find('(',1,true)+1, value:find(')',1,true)-1)
          local start, stop = extent:find("^%d+")
          local unit = extent:sub(stop+1)
          if not table.contains({ "%" }, unit) then
            error("The parameter for this sepia function must be expressed in terms of a percentage (%), not " .. unit)
          end
          --check if the percentage value is greater than equal to 0 and smaller than or equal to 100 for the grayscale value
          local magnitude = tonumber(extent:sub(1, stop))
          if not (magnitude >= 0 and magnitude <= 100) then
            error(string.format("The percentage value for the sepia function must be between 0 (inclusive) and 100 (inclusive). Given: %s%%", magnitude))
          end
          isValidBackdropFilterValue = not isValidBackdropFilterValue
        --saturate
        elseif value:find("^saturate%s?%(%s?%-?%s?%d*%.?%d*%s?%)%s?$") then
          local extent = value:sub(value:find('(',1,true)+1, value:find(')',1,true)-1)
          local magnitude = tonumber(extent)
          if not (magnitude >= 0 and magnitude <= 100) then
            error(string.format("The value to be passed as the parameter for this saturate function must be a positive integer or floating point number. Given: %s", Operator.Ternary(extent:find('%.'), string.format("%.4f", magnitude), string.format("%d", magnitude))))
          end
          isValidBackdropFilterValue = not isValidBackdropFilterValue
        end
        if not (table.contains({ "none", "initial", "inherit" }, value) or isValidBackdropFilterValue) then 
          error(string.format("Invalid value for the backdrop-filter property. Acceptable values include 'inherit', 'initial', or one of the following functions: \n'blur()'\n'brightness()'\n'contrast()'\n'drop-shadow()'\n'grayscale()'\n'hue-rotate()'\n'invert()'\n'opacity()'\n'sepia()'\n'saturate()'\nGiven: %s", value))
        end
      elseif property == "backface-visibility" then
        if not table.contains({ "visible", "hidden", "initial", "inherit" }, value) then
          error("The backface-visibility css property can only be of the following values: 'visible', 'hidden', 'initial' and 'inherit'. Given: " .. value)
        end
      elseif property == "border-bottom-left-radius" then
        local isValidBorderBottomLeftRadiusValue = false
        local l1, l2 = unpack(value:split("/"))
        local function test(target)  --find units and return value otherwise return nil
          return xpcall(
            function() 
              local units = target:find("px")
              return target:sub(1, units-1)
            end, 
            function() 
              local t = {xpcall(
                function() 
                  local units = target:find("rem")
                  return target:sub(1, units-1)
                end, 
                function() 
                  --void proceed to next xpcall
                end
              )}
              local success, result = unpack(t)
              if success then 
                return result
              else 
                local t = {xpcall(
                  function() 
                    local units = target:find("em")
                    return target:sub(1, units-1)
                  end, 
                  function() 
                    --void proceed to next xpcall
                  end
                )}
                local success, result = unpack(t)
                if success then 
                  return result
                else
                  local t = {xpcall(
                    function() 
                      local units = target:find("vw")
                      return target:sub(1, units - 1)
                    end, 
                    function() 
                      --void proceed to next xpcall
                    end
                  )}
                  local success, result = unpack(t)
                  if success then 
                    return result
                  else
                    local t = {xpcall(
                      function() 
                        local units = target:find("vh")
                        return target:sub(1, units - 1)
                      end, 
                      function() 
                        --void proceed to next xpcall
                      end
                    )}
                    local success, result = unpack(t)
                    if success then 
                      return result
                    else
                      local t = {xpcall(
                        function() 
                          local units = target:find("cm")
                          return target:sub(1, units - 1)
                        end, 
                        function() 
                          --void proceed to next xpcall
                        end
                      )}
                      local success, result = unpack(t)
                      if success then 
                        return result
                      else
                        local t = {xpcall(
                          function()
                            local units = target:find("mm")
                            return target:sub(1, units - 1)
                          end, 
                          function()
                            --void proceed to next xpcall
                          end 
                        )}
                        local success, result = unpack(t)
                        if success then 
                          return result
                        else
                          local t = {xpcall(
                            function()
                              local units = target:find("in")
                              return target:sub(1, units - 1)
                            end,
                            function()
                              --void proceed to next xpcall
                            end
                          )}
                          local success, result = unpack(t)
                          if success then 
                            return result
                          else
                            local t = {xpcall(
                              function()
                                local units = target:find("pt")
                                return target:sub(1, units - 1)
                              end,
                              function()
                                --void go to next xpcall
                              end
                            )}
                            local success, result = unpack(t)
                            if success then 
                              return result
                            else
                              local t = {xpcall(
                                function() 
                                  local units = target:find("pc")
                                  return target:sub(1, units - 1)
                                end, 
                                function() 
                                  --void go to next xpcall
                                end
                              )}
                              local success, result = unpack(t)
                              if success then 
                                return result
                              else
                                local t = {xpcall(
                                  function() 
                                    local units = target:find("vmin")
                                    return target:sub(1, units-1)
                                  end, 
                                  function() 
                                    --void go to next xpcall
                                  end
                                )}
                                local success, result = unpack(t)
                                if success then 
                                  return result
                                else
                                  local t = {xpcall(
                                    function()
                                      local units = target:find("vmax")
                                      return target:sub(1, units - 1)
                                    end,
                                    function()
                                      --void go to next xpcall
                                    end
                                  )}
                                  local success, result = unpack(t)
                                  if success then 
                                    return result
                                  else
                                    local t = {xpcall(
                                      function()
                                        local units = target:find("ch")
                                        return target:sub(1, units - 1)
                                      end,
                                      function()
                                        --void return nil
                                      end
                                    )}
                                    local success, result = unpack(t)
                                    if success then 
                                      return result 
                                    else 
                                      return nil
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end 
                  end
                end
              end
            end
          )
        end 
        --check if the value starts with a numerical value, otherwise throw an error
        if l1 and not l1:match("^%d+") then 
          error(string.format("The value should begin with a numeric value. Given '%s' in property: %s", l2, property))
        end 
        if l2 and not l2:match("^%d+") then 
          error(string.format("The value should begin with a numeric value. Given '%s' in property: %s", l2, property))
        end
      elseif property == "background" then
        local background_color, background_image, background_position, background_size, background_repeat, background_origin, background_clip, background_attachment = unpack(value:split('/'))
        local BACKGROUND_ATTACHMENT_VALID_VALUES = { "scroll", "fixed", "local", "initial", "inherit" }
        local BACKGROUND_CLIP_VALID_VALUES = { "border-box", "padding-box", "content-box", "initial", "inherit" }
        local BACKGROUND_ORIGIN_VALID_VALUES = { "border-box", "padding-box", "content-box", "initial", "inherit" }
        local BACKGROUND_REPEAT_VALID_VALUES = { "repeat", "repeat-x", "repeat-y", "no-repeat", "space", "round", "initial", "inherit" }
        local BACKGROUND_POSITION_VALID_VALUES = { "initial", "inherit", "left top", "left center", "left bottom", "right top", "right center", "right bottom", "center top", "center center", "center bottom", "^%d*%s%d*$" }


        --TODO:  complete all CSS properties here: 
        
        
        
      else
        --error("Unknown property: " .. property)
      end
    end
  end
  return string.format("<style>\n\t\t\t\t\t%s\n\t\t\t\t</style>\n\t\t\t\t", prop.inner)
end
