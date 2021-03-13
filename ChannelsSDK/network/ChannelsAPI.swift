//
//  ChannelsAPI.swift
//  ChannelsSDK
//
//  Created by Tiago Lima on 13/03/2021.
//

import Foundation


public class ChannelsAPI {
    
    private static let GET: String = "GET";
    private static let POST: String = "POST";
    private static let PUT: String = "PUT";
    private static let DELETE: String = "DELETE";
    
    let token: String;
    let appID: String;
    let baseURL: String
    
    init(base: String, token: String, appID: String) {
        self.baseURL = base;
        self.token = token;
        self.appID = appID;
    }
    
    public func getPublicChannels(result: @escaping ([Channel]?, Bool) -> ()) {
        let request = self.prepareRequest(method: ChannelsAPI.GET, suffix: "/channel/open")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                result(nil, false)
                return;
            }
            
            do {
                let response = try GetChannelsResponse(jsonUTF8Data: data);
                
                var channels: [Channel] = [];
                
                let channelsHandler = ChannelsSDK.shared().getChannelsHandler();
                
                response.channels.forEach { chan in
                    let channel = Channel(info: chan)
                    channelsHandler.registerChannel(chann: channel);
                    channels.append(Channel(info: chan))
                }
                
                result(channels, true);
                
            } catch {
                print("Failed to get public channels \(error)")
                result(nil, false);
            }
        }
        
        task.resume();
        
    }
    
    public func getPrivateChannels(result: @escaping ([Channel]?, Bool) -> ()) {
        let request = self.prepareRequest(method: ChannelsAPI.GET, suffix: "/channel/private")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if (error != nil) {
                
            }
            
            guard let data = data else {
                result(nil, false)
                return;
            }
            
            do {
                
                let response = try GetChannelsResponse(jsonUTF8Data: data);
                
                var channels: [Channel] = [];
                
                let channelsHandler = ChannelsSDK.shared().getChannelsHandler();
                
                response.channels.forEach { chan in
                    let channel = Channel(info: chan)
                    channelsHandler.registerChannel(chann: channel);
                    channels.append(Channel(info: chan))
                }
                
                result(channels, true);
                
            } catch {
                print("Failed to get private channels \(error.localizedDescription)")
                result(nil, false);
            }
        }
        
        task.resume();
        
    }
    
    public func getLastChannelEvents(channelID: String, amount: UInt64, result: @escaping ([EventChannel]?, Bool) -> ()) {
        let request = self.prepareRequest(method: ChannelsAPI.GET, suffix: "/last/\(channelID)/\(amount)")
        
        let task = URLSession.shared.dataTask(with: request) { [self] (data, response, error) in
            
            if (error != nil) {
                print("Error fetching events \(error!)")
            }
            
            guard let data = data else {
                result(nil, false)
                return;
            }
            
            parseEvents(data: data, result: result);
        }
        
        task.resume();
    }
    
    public func getLastChannelEventsSince(channelID: String, amount: UInt64, timestamp: UInt64, result: @escaping ([EventChannel]?, Bool) -> ()) {
        let request = self.prepareRequest(method: ChannelsAPI.GET, suffix: "/last/\(channelID)/\(amount)/last/\(timestamp)")
        
        let task = URLSession.shared.dataTask(with: request) { [self] (data, response, error) in
            
            if (error != nil) {
                print("Error fetching events \(error!)")
            }
            
            guard let data = data else {
                result(nil, false)
                return;
            }
            
            parseEvents(data: data, result: result);
        }
        
        task.resume();
    }
    
    public func getChannelEventsSince(channelID: String, timestamp: UInt64, result: @escaping ([EventChannel]?, Bool) -> ()) {
        let request = self.prepareRequest(method: ChannelsAPI.GET, suffix: "/c/\(channelID)/sync/\(timestamp)")
        
        let task = URLSession.shared.dataTask(with: request) { [self] (data, response, error) in
            
            if (error != nil) {
                print("Error fetching events \(error!)")
            }
            
            guard let data = data else {
                result(nil, false)
                return;
            }
            
            parseEvents(data: data, result: result);
        }
        
        task.resume();
    }
    
    public func getChannelEventsBetween(channelID: String, sinceTimestamp: UInt64, toTimestamp: UInt64, result: @escaping ([EventChannel]?, Bool) -> ()) {
        
        let request = self.prepareRequest(method: ChannelsAPI.GET, suffix: "/sync/\(channelID)/\(sinceTimestamp)/to/\(toTimestamp)")
        
        let task = URLSession.shared.dataTask(with: request) { [self] (data, response, error) in
            
            if (error != nil) {
                print("Error fetching events \(error!)")
            }
            
            guard let data = data else {
                result(nil, false)
                return;
            }
            
            parseEvents(data: data, result: result);
        }
        
        task.resume();
    }
    
    private func parseEvents(data: Data, result: @escaping ([EventChannel]?, Bool) -> ()) {
        do {
            
            let response = try GetEventsResponse(jsonUTF8Data: data);
            
            var events: [EventChannel] = [];
            
            response.events.forEach { event in
                events.append(EventChannel(event: event))
            }
            
            result(events, true);
            
        } catch {
            print("Failed to parse events \(error.localizedDescription)")
            result(nil, false);
        }
    }
    
    private func prepareRequest(method: String, suffix: String) -> URLRequest {
        let url = URL(string: baseURL + suffix)
        
        var request = URLRequest(url: url!)
        request.addValue(self.token, forHTTPHeaderField: "Authorization");
        request.addValue(self.appID, forHTTPHeaderField: "AppID")
        request.httpMethod = method;
        
        return request;
    }
}
