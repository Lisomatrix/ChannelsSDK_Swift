//
//  WebSocketListener.swift
//  ChannelsSDK
//
//  Created by Tiago Lima on 12/03/2021.
//

import Foundation
import Starscream

class WebSocketListener: WebSocketDelegate {
    
    private var webSocket: WebSocket? = nil
    private let url: String
    private let token: String
    private let appID: String
    private var deviceID: String?
    
    private var isConnected: Bool = false
    
    private var channelsHandler: ChannelsHandler?;
    
    private let eventsQueue = Queue<NewEvent>()
    
    init(url: String, token: String, appID: String, deviceID: String?) {
        self.url = url;
        self.token = token;
        self.appID = appID;
        
    }
    
    func setChannelsHandler(handler: ChannelsHandler) {
        self.channelsHandler = handler;
    }

    func connect(url: String) {
        var request = URLRequest(url: URL(string: url + "/optimized")!)
        
        request.setValue(self.token, forHTTPHeaderField: "Authorization")
        request.setValue(self.appID, forHTTPHeaderField: "AppID")
        
        if (self.deviceID != nil) {
            request.setValue(self.deviceID!, forHTTPHeaderField: "deviceID")
        }
        
        request.timeoutInterval = 5
        self.webSocket = WebSocket(request: request)
        self.webSocket?.delegate = self;
        self.webSocket?.connect();
        
    }
    
    public func getIsConnected() -> Bool {
        return self.isConnected;
    }
    
    func send(newEvent: NewEvent) {
        
        if (self.webSocket == nil) {
            self.eventsQueue.add(value: newEvent)
            return;
        }
        
        do {
            
            let eventBinaryData: Data = try newEvent.serializedData()
            self.webSocket?.write(data: eventBinaryData)
            
            print("Sending message with size: \(eventBinaryData.count)")
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func onConnected() {
        print("ChannelsSDK connected!")
        self.isConnected = true;
        
        do {
            
            for _ in 0..<self.eventsQueue.getSize() {
                let event = self.eventsQueue.poll();
                
                if (event != nil) {
                    let eventData = try event!.serializedData();
                    self.webSocket?.write(data: eventData)
                }
            }
            
        } catch {
            print(error)
        }
        
    }
    
    func onDisconnected() {
        print("ChannelsSDK disconnected!")
        self.isConnected = false;
    }
    
    func onTextMessage(message: String) {
        print("ChannelsSDK: Received unexpected text message \(message)")
    }
    
    func onBinaryMessage(message: Data) {
        print("ChannelsSDK: New message received!")
        
        do {
            
            let newEvent = try NewEvent(serializedData: message);
            
            let eventType: NewEvent.NewEventType = newEvent.type;
            
            switch eventType {
            case NewEvent.NewEventType.ack:
                
                let publishACK = try PublishAck(serializedData: newEvent.payload)
                self.channelsHandler?.onACK(ack: publishACK);
                
                break;
                
            case NewEvent.NewEventType.publish:
                
                let channelEvent = try ChannelEvent(serializedData: newEvent.payload)
                self.channelsHandler?.onChannelEvent(event: channelEvent)
                
                break;
                
            case NewEvent.NewEventType.initialOnlineStatus:
                
                let initialOnlineStatus = try InitialPresenceStatus(serializedData: newEvent.payload)
                self.channelsHandler?.onChannelInitialStatusPresence(initialPresenceStatus: initialOnlineStatus);
                
                break;
                
            case NewEvent.NewEventType.onlineStatus:
                
                let onlineStatusUpdate = try OnlineStatusUpdate(serializedData: newEvent.payload)
                self.channelsHandler?.onChannelOnlineStatusUpdate(onlineStatusUpdate: onlineStatusUpdate);
                
                break;
                
            case NewEvent.NewEventType.joinChannel:
                
                let clientJoin = try ClientJoin(serializedData: newEvent.payload);
                self.channelsHandler?.onJoinChannel(join: clientJoin);
                
                break;
                
            case NewEvent.NewEventType.leaveChannel:
                
                let clientLeave = try ClientLeave(serializedData: newEvent.payload);
                self.channelsHandler?.onLeaveChannels(leave: clientLeave);
                
                break;
                
            case NewEvent.NewEventType.removeChannel:
                
                let channelID = String(bytes: newEvent.payload, encoding: .utf8)
                
                if (channelID != nil) {
                    self.channelsHandler?.onChannelRemoved(channelID: channelID!)
                }
                
                break;
                
            case NewEvent.NewEventType.newChannel:
                
                let channelID = String(bytes: newEvent.payload, encoding: .utf8)
                
                if (channelID != nil) {
                    self.channelsHandler?.onChannelAdded(channelID: channelID!)
                }
                
                break;
                
            default:
                print("ChannelsSDK: Invalid message type recieved")
            }
            
        } catch {
            print("ChannelsSDK: Error parsing message \(error)")
        }
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
                case .connected(_):
                    self.onConnected();
                case .disconnected(let reason, let code):
                    self.onDisconnected();
                    print("Close reason: \(reason)\nClose code \(code)")
                case .text(let string):
                    self.onTextMessage(message: string)
                case .binary(let data):
                    self.onBinaryMessage(message: data)
                case .ping(_):
                    break
                case .pong(_):
                    break
                case .viabilityChanged(_):
                    break
                case .reconnectSuggested(_):
                    break
                case .cancelled:
                    isConnected = false
                case .error(let error):
                    isConnected = false
                    handleError(error: error)
                }
    }
    
    func handleError(error: Error?) {
        print(error?.localizedDescription ?? "")
    }
}
