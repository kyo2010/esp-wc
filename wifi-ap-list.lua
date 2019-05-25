--- AP Search Params ---
ap_list_cfg={}
--- Enter SSID, use nil to list all SSIDs ---
ap_list_cfg.ssid=nil
--- Enter BSSID, use nil to list all SSIDs ---
ap_list_cfg.bssid=nil
--- Enter Channel ID, use 0 to list all channels ---
ap_list_cfg.channel=0
--- Use 0 to skip hidden networks, use 1 to l ist them ---
ap_list_cfg.show_hidden=1

--- AP Table Format --- 
--- 1 for Output table format - (BSSID : SSID, RSSI, AUTHMODE, CHANNEL)
--- 0 for Output table format - (SSID : AUTHMODE, RSSI, BSSID, CHANNEL)
ap_list_table_format = 1 

-----------------------------------------------

if (ap_list==nil) then
  ap_list={} 
  --if ( ap_list=={} && wifi.sta.getip()==nil) then  
  --mode = wifi.getmode()
  ---wifi.setmode(wifi.STATIONAP)
  --wifi.sta.getap(ap_list_cfg,ap_list_table_format, print_AP_List)
  --end  
end 
 
--- Print Output --- 
function print_AP_List(ap_table)
  for p,q in pairs(ap_table) do
    print(p.." : "..q)
    ap_list[p] = q 
  end
end

if (wifi.sta.getip()~=nil or wifi.ap.getip()~=nil) then
  wifi.sta.getap(ap_list_cfg,ap_list_table_format, print_AP_List)
end
  

--print ("exec wifi-ap-list.lua")

--- Call Get AP Method ---
--if (wifi.getmode()==wifi.STATIONAP) then

--end  

response="HTTP/1.0 200 OK\r\nServer: NodeMCU\r\nContent-Type: application/json\r\n\r\n"

response=response..sjson.encode(ap_list)

--print(response)

collectgarbage()

return response
