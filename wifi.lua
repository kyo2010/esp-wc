--WiFi Settup

info = {}
local cfg={}
USE_INTERNET = true

-- read JSON from file
--if file.open("settings.json", "r") then
  -- convert JSON to object 
--  info = sjson.decode(file.read())   
--  file.close()
--end 

dofile("info.lua")


  wifi.setmode(wifi.STATIONAP)
  cfg={}
  cfg.ssid="ESP-WC"
  --if info.wpwd~=nil and info.wpwd~='' then
  --  cfg.pwd=info.wpwd  
  --else
    cfg.pwd="12345678"    
  --end 
  wifi.ap.config(cfg)
  print( "Created AP: ", wifi.ap.getip() )
   

if info.wname=="" or info.wname==nil then
  wifi.sta.disconnect()
else 
  --wifi.setmode(wifi.SOFTAP)    
  --wifi.setmode(wifi.STATIONAP)
  cfg1 = {} 
  cfg1.ssid=info.wname
  cfg1.pwd=info.wpwd  
  wifi.sta.config(cfg1) 
  print("Connecting to"..info.wname)    
  --cfg={}
  --cfg.ssid="ESP-WC"
  --cfg.pwd="12345678"     
  --wifi.ap.config(cfg)
  --print("Created AP: ",wifi.ap.getip())     
end

local count = 1
if file.open("double_reset_detector.flag", "r") then
  --local st = "";
  --file.read(st)  
  count = file.read()
  --print ("Read counter:", count)
  if (count==nil) then 
    count = 1
  end 
  --count = c1    
  --count = st.toInt()
  --print ("Reset counter:",count)  
  file.close() 
end   

if file.open("double_reset_detector.flag", "w") then
  print ("Reset counter:", count)    
  count = count+1   
  file.write(count) 
  file.close()
end   

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
  print ("CONNECTED!!!")
  print("connected to  ip: ",wifi.sta.getip())   

  if (wifi.sta.getip()~=nil) then
    if (info.wcsystem~='' and info.wclogin~='') then
      --  http://localhost/wc/dev.save.php?mode=msg&CHIP_ID=123&msg=privet mir&user=KKV
      http.get(info.wcsystem.."/dev.save.php?mode=msg&CHIP_ID="..info.chipid.."&msg=restarted&user="..info.wclogin, "", function(Y)
        print ("restart info has been sent")
      end)


     local query = ""
     local index = 1
     for i, pin in pairs(PINS) do 
       query = query.."&pin"..index.."="..pin.name.."&new_value"..index.."="..PINS[pin.name].value
       index = index + 1
     end 

     -- counter.save.php?mode=tic&user=kkv&chip_id=123&pin1=D5&new_value1=1024&pin3=D3&new_value3=1015
     print(info.wcsystem.."/counter.save.php?mode=tic&chip_id="..info.chipid.."&user="..info.wclogin..query)
     http.get(info.wcsystem.."/counter.save.php?mode=tic&chip_id="..info.chipid.."&user="..info.wclogin..query, "", function(Y)
         print ("pins have been updated")
     end)
    
      
    end
  end
  
end)
 
-- Start reset detecter timer
--local mytimer = tmr.create()
--tmr.start(0)

cfg = nil 

--dofile("wifi-ap-list.lua") 

collectgarbage()

