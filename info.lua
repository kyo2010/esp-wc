
-- чтение всех настроек
function readInfo() 
  -- read JSON from file
  if file.open("settings.json", "r") then
  -- convert JSON to object
    info = sjson.decode(file.read())    
    file.close()  
  else
    info.wname=""
    info.wpwd="" 
    info.wclogin = ""  
    info.sleepFlag = 0 
    info.wcsystem="http://jteam.ru/wc"
  end 
    
  read_pins() 
  if file.open("double_reset_detector.flag", "r") then
    local count = file.read()    
    file.close()
    if (count=='5') then
      info.wname=""
      info.wpwd=""  
      info.sleepFlag = 0
      print("saving...",info)
      if file.open("settings.json", "w") then
        local json_info = sjson.encode(info)
        file.write(json_info)
        file.flush()
        file.close()
      end   
      print("Double reset detector... wifi settings have been reset")
      node.restart()
    end 
    --if (count=='5') then -- 5 press
    --  file.remove("settings.json")
    --  print("Super Double reset detector... wifi settings have been reset")
    --  node.restart()
    --end      
  end    
end


local result = 'ok';
  
-- основной метод обработки GET запросов
if GET~=nil and GET['info'] ~= nil then
  local data = sjson.decode(GET['info'])
  print("saving...",GET['info'])
   if file.open("settings.json", "w") then
    file.write(GET['info'])
     file.flush()
    file.close()
  end    
  
  -- сохраняем значения для каждого pin
  for i, pin in pairs(PINS) do 
    --print(pin.name,info.PINS[pin.name].value)
    print("check..."..'pin_'..pin.name);
    if (data['pin_'..pin.name]~=nil) then      
      local value = 0 + data['pin_'..pin.name]
      info.PINS[pin.name].value = value
      if file.open(pin.name..".pin", "w") then
        file.write(value)
        file.flush()
        file.close()
      end    
    end
  end
  result = 'save is ok';

  if (data~=nil and data.restart==1) then
    wifi.ap.deauth()
    wifi.sta.disconnect()
    node.restart()
  end
end

-- считать все настройки
if (info==nil) then
  info = {}
  info.wname=""
  info.wpwd=""
  info.wcsystem = "http://jteam.ru/wc"
  info.wclogin=""  
end

readInfo()

info.chipid=node.chipid()
--info.chipid='test'

info.timer = tmr.now()

if (wifi.getmode()==wifi.STATIONAP) then
  info.connectInfo = wifi.sta.getip()
else  
  info.connectInfo = wifi.sta.status()  
end 

--print ("exec info.lua")
 
response="HTTP/1.0 200 OK\r\nServer: NodeMCU\r\nContent-Type: application/json\r\n\r\n"
response=response..sjson.encode(info)

collectgarbage()

return response
