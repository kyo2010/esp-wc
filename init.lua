-- обнуление счетчика ьройного нажатия через 2.5 секунда
function timer_reset_double_detecter()
  print("remove reset file detecor")  
  if file.open("double_reset_detector.flag", "w") then
    file.write(0) 
    file.flush()
    file.close()
  end    
end 

-- иницилизация пинов  
dofile("pins.lua") 
-- поднятие wifi
dofile("wifi.lua")  
-- поднятие web-сервера
dofile("web.lua") 
  
-- таймер обнуления счетчика, выполняется один раз
local mytimer = tmr.create()
mytimer:register(2000, tmr.ALARM_SINGLE, timer_reset_double_detecter)
mytimer:start() 
  
  
