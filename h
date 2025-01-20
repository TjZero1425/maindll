getgenv().WebSocket = {}
getgenv().WebSocket.connect = function(url)
    local onmsgws = Instance.new("BindableEvent")
    local onclosews = Instance.new("BindableEvent")
    local connected = true
    local websocket = {}
    function websocket:Send(message)
        if connected then
            onmsgws:Fire(message)
        else
            warn("WebSocket is closed")
        end
    end
    function websocket:Close()
        if connected then
            connected = false
            onclosews:Fire()
        else
            warn("WebSocket is already closed")
        end
    end
    websocket.OnMessage = onmsgws.Event
    websocket.OnClose = onclosews.Event
    return websocket
end
getgenv().WebSocket.New = getgenv().WebSocket.connect
getgenv().WebSocket.new = getgenv().WebSocket.connect
getgenv().WebSocket.Connect = getgenv().WebSocket.connect
