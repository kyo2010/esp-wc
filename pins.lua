
-- Список задействованных пинов 
PINS = {
    ["D3"]={ name = "D3",  pin = 3, value = 0 },  
    ["D4"]={ name = "D4",  pin = 4, value = 0 }           
}

-- вызывается при нсрабатывания пина, и стоит тамер с задержкой на 5 секунд, чтобы исключить дребезг контактов и двойное нажатие
function debounce (func, pin)
    local last = 0 
    local delay = 5000000
    return function (...) 
        local now = tmr.now()
        local delta = now - last
        if delta < 0 then delta = delta + 2147483647 end; 
        if delta < delay then          
          return 
        end;        
        last = now
        return func(pin)
    end
end

-- при срабатывания пина, открываем файл с пином и записываем туда занчение
function onChange (pin)  
  local value = 0
  if file.open(pin.name..".pin", "r") then
    value = file.read()
    file.close()
  end
  if (value == nil ) then
    value = 0 
  end  
  value = value + 1  
  pin.value = value  
  if file.open(pin.name..".pin", "w") then
    file.write(value)
    file.close()
  end    
  print( "pin click  ",pin.name,pin.pin, value );
  -- update pins info
  if (info.wcsystem~='' and info.wclogin~='' and info.wname~='') then
    if (wifi.sta.getip()~=nil) then
      wifi.sta.disconnect()
    end
    wifi.sta.connect()
  end
end  

function sendPinData(pin)

end


for i, pin in pairs(PINS) do 
  --print("init pin : ", pin.name, pin.pin)
  gpio.mode(pin.pin, gpio.INPUT)  
  gpio.trig(pin.pin, 'down', debounce(onChange, pin))
end

function read_pins()
  for i, pin in pairs(PINS) do 
    local value = 0
    if file.open(pin.name..".pin", "r") then
      value = file.read()
      file.close()
    end
    PINS[pin.name].value = value
    info.PINS = PINS
  end  
end
