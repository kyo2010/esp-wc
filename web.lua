-- dofile("wifi.lua")

if httpd then
  httpd:close()
end  
  
httpd=net.createServer(net.TCP) 

--httpd.serveStatic("/jquery-3.4.0.min.js",   SPIFFS, "/jquery-3.4.0.min.js"  ,"max-age=86400"); 

print("Web Server has been started")
 
if (wifi.sta.getip()~=nil) then  
  print("sta ip: ",wifi.sta.getip())
end
if (wifi.ap.getip()~=nil) then
  print("ap ip: ",wifi.ap.getip())  
end

function debounce (func, pin)
    local last = 0
    local delay = 50000
    return function (...)
        local now = tmr.now()
        local delta = now - last
        if delta < 0 then delta = delta + 2147483647 end; 
        if delta < delay then return end;
        last = now
        return func(pinn)
    end
end

function onChange (pin)
  print("pin click ", pin.name, pin.pin )
end

function build_post_request(host, uri)
    local data = ""
    data = "param1=1&param2=2" 
    request = "POST uri HTTP/1.1\r\n"..
      "Host: example.com\r\n"..
      "apiKey: e2sss3af-9ssd-43b0-bfdd-24a1dssssc46\r\n"..
      "Cache-Control: no-cache\r\n"..
      "Content-Type: application/x-www-form-urlencoded\r\n"..data
    return request
end
 
-- decode URI
function decodeURI(s)
    if(s) then
        s = string.gsub(s, '%%(%x%x)', 
        function (hex) return string.char(tonumber(hex,16)) end )
    end
    return s
end
 
function receive_http(sck, data)
  -- sendfile class
  local sendfile = {}
  sendfile.__index = sendfile
  function sendfile.new(sck, fname, dopInfo)
    local self = setmetatable({}, sendfile)
    self.sck = sck
    self.fd = file.open(fname, "r")
    self.dopInfo = dopInfo       
    --print("open ",fname)
    if self.fd then
      local function send(localSocket)
        local response = self.fd:read(128)
        --print("html:",response) 
        if response then
          localSocket:send(response)
        else
          if self.fd then
          end
          localSocket:close()
          self = nil
        end
      end
      self.sck:on("sent", send)      
      if self.dopInfo~=nil and sck~=nil then      
        self.sck:send(self.dopInfo)
      end  
      if (sck~=nil) then
        send(self.sck)
      end  
    else 
      if (localSocket~=nil) then
        localSocket:close()
      end  
    end
    return self
  end
  -----
  local host_name = string.match(data,"Host: ([0-9,\.]*)\r",1)
  local url_file = string.match(data,"[^/]*\/([^ ?]*)[ ?]",1)
  local uri = decodeURI(string.match(data,"[^?]*\?([^ ]*)[ ]",1))
  
  --print("data : ",data);
  --print("host_name : ",host_name);
  print("uri : ",url_file," uri:", uri) 
 
 -- parse GET parameters
  GET={}
  if uri then
    for key, value in string.gmatch(uri, "([^=&]*)=([^&]*)") do
     GET[key]=value
     print("GET ",key, value)
    end
  end
 
  -- parse POST parameters
  POST={}    
  if (data~=nil and data~='') then 
    --print("try POST : ",data);   
    --local post = string.match(data,"\n([^\n]*)$",1):gsub("+", " ")
    --if post then
    --  for key, value in string.gmatch(post, "([^=&]*)=([^&]*)") do
    --   POST[key]=decodeURI(value)
    --   print("POST ",key, POST[key])
    --  end
   -- end  
  end  
 
  request_OK = false 

  local dopInfo = nil
  local url_return = url_file  
 
  -- if file not specified then send index.html
  if url_file == '' then    
    dopInfo = "HTTP/1.0 200 OK\r\nServer: NodeMCU\r\nContent-Type: text/html; charset=utf-8\r\n\r\n"
    url_return = 'index.html'
    sendfile.new(sck, url_return,dopInfo)
    request_OK = true
  else
    local fext=url_file:match("^.+(%..+)$")
    if fext == '.html' or
       fext == '.txt' or
       fext == '.js' or
       fext == '.min.js' or
       fext == '.json' or
       fext == '.css' or
       fext == '.png' or
       fext == '.gif' or
       fext == '.ico' then
       if file.exists(url_file) then           
           if fext == '.html' then
             dopInfo = "HTTP/1.0 200 OK\r\nServer: NodeMCU\r\nContent-Type: text/html; charset=utf-8\r\n\r\n"
           end
           if fext == '.js' then
             dopInfo = "HTTP/1.0 200 OK\r\nServer: NodeMCU\r\nCache-Control: max-age=86400\r\nContent-Type: application/javascript; charset=utf-8\r\n\r\n"
           end
           if fext == '.css' then
             dopInfo = "HTTP/1.0 200 OK\r\nServer: NodeMCU\r\nCache-Control: max-age=86400\r\n\r\n"
           end
           if fext == '.gif' then
             dopInfo = "HTTP/1.0 200 OK\r\nServer: NodeMCU\r\nCache-Control: max-age=86400\r\nContent-Type: image/gif\r\n\r\n"
           end            
           if fext == '.png' then
             dopInfo = "HTTP/1.0 200 OK\r\nServer: NodeMCU\r\nCache-Control: max-age=86400\r\nContent-Type: image/png\r\n\r\n"
           end
           if fext == '.ico' then
             dopInfo = "HTTP/1.0 200 OK\r\nServer: NodeMCU\r\nCache-Control: max-age=86400\r\nContent-Type: image/x-icon\r\n\r\n"             
           end
           --dopInfo = nil      
           sendfile.new(sck, url_file, dopInfo)
           request_OK = true
       end
    end
 
    -- execute LUA file
    -- IT IS HAZARDOUS
    if fext == '.lua' then
      if file.exists(url_file) then
        response=dofile(url_file)
        sck:on("sent", function() sck:close() end)
        sck:send(response)
        request_OK = true
      end
    end
  end
 
  if request_OK == false then
    sck:on("sent", function() sck:close() end)
    --sck:send('Something wrong')
    --print ('Something wrong')
  else    
    print("url : ",url_return," uri:", uri, " ...ok") 
  end 
end
  
if httpd then
  httpd:listen(80, function(conn)
    conn:on("receive", receive_http)
  end)
end
