//
//  ChannelsSDK.swift
//  ChannelsSDK
//
//  Created by Tiago Lima on 12/03/2021.
//

import Foundation

public class ChannelsSDK {
    
    private static var sharedChannels: ChannelsSDK = {
        let channels = ChannelsSDK();
        
        return channels;
    }();
    
    private var url: String?;
    private var appID: String?;
    private var token: String?;
    private var deviceID: String?
    private var secure: Bool = false;
    
    private var webSocketListener: WebSocketListener?
    
    private let channelsHandler = Channels();
    private var channelsAPI: ChannelsAPI?
    
   
    public func initialize(url: String, appID: String, secure: Bool) {
        self.url = url;
        self.appID = appID;
        self.secure = secure;
    }
    
    public func isConnected() -> Bool {
        return self.webSocketListener?.getIsConnected() ?? false
    }
    
    public func connect(token: String, deviceID: String?) -> Void {
        self.token = token
        self.deviceID = deviceID
        
        self.channelsAPI = ChannelsAPI(base: self.getFormattedURL(isWS: false), token: self.token!, appID: self.appID!)
        
        self.webSocketListener = WebSocketListener(url: self.url!, token: self.token!, appID: self.appID!, deviceID: self.deviceID)
        
        self.webSocketListener?.setChannelsHandler(handler: self.channelsHandler)
        self.webSocketListener?.connect(url: self.getFormattedURL(isWS: true))
    }
    
    public func getChannelsAPI() -> ChannelsAPI {
        return self.channelsAPI!;
    }
    
    public func subscribe(channelID: String) {
        let request = createSubscribeRequest(channelID: channelID);
        
        do {
            let data: Data = try request.serializedData()
            
            let event = createNewEvent(type: NewEvent.NewEventType.subscribe, payload: data)
            
            self.webSocketListener?.send(newEvent: event)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func publish(channelID: String, eventType: String, payload: String, notify: Bool) {
        let request = createPublishRequest(
            channelID: channelID,
            eventType: eventType,
            payload: payload,
            notify: notify
        )
        
        do {
            let data: Data = try request.serializedData()
            
            let event = createNewEvent(type: NewEvent.NewEventType.publish, payload: data)
            
            self.webSocketListener?.send(newEvent: event)
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    public func getChannel(channelID: String) -> Channel? {
        return self.channelsHandler.getChannel(channelID: channelID)
    }
    
    private func getFormattedURL(isWS: Bool) -> String {
        var connURL = "";
        
        if (isWS) {
            if (self.secure) {
                connURL.append("wss")
            } else {
                connURL.append("ws")
            }
        } else {
            if (self.secure) {
                connURL.append("https")
            } else {
                connURL.append("http")
            }
        }
        
        connURL.append("://")
        connURL.append(self.url!)
        print(connURL)
        return connURL;
    }
    
    func getChannelsHandler() -> Channels {
        return self.channelsHandler;
    }
    
    public class func shared() -> ChannelsSDK {
           return sharedChannels
    }
}
