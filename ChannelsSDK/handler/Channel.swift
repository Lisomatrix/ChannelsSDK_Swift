//
//  Channel.swift
//  ChannelsSDK
//
//  Created by Tiago Lima on 13/03/2021.
//

import Foundation

public class Channel {
    
    private var _isSubscribed: Bool = false
    
    private let channelInfo: ChannelInfo;
    
    private var channelListener: ChannelListener?
    private var channelPresenceListener: ChannelPresenceListener?
    
    private let onlineStatus = ConcurrentDictionary<String, ClientPresenceStatus>()
    
    init(info: ChannelInfo) {
        self.channelInfo = info;
    }
    
    public func getPresences() -> Dictionary<String, ClientPresenceStatus> {
        var presencesDic = Dictionary<String, ClientPresenceStatus>()
        let keys = self.onlineStatus.keys;
        let values = self.onlineStatus.values;
        
        var i = 0;
        keys.forEach { key in
            presencesDic[key] = values[i]
            i += 1;
        }
        
        return presencesDic;
    }
    
    public func getChannelSettings() -> ChannelSettings {
        return ChannelSettings(info: self.channelInfo);
    }
    
    func getChannelInfo() -> ChannelInfo {
        return self.channelInfo;
    }
    
    public func isSubscribed() -> Bool {
        return self._isSubscribed;
    }
    
    public func subscribe(listener: ChannelListener) {
        self.channelListener = listener;
        
        ChannelsSDK.shared().subscribe(channelID: self.channelInfo.id)
    }
    
    public func publish(eventType: String, payload: String, notify: Bool) {
        ChannelsSDK.shared().publish(
            channelID: self.channelInfo.id,
            eventType: eventType,
            payload: payload,
            notify: notify
        );
    }
    
    public func setPresenceListener(presenceListener: ChannelPresenceListener) {
        self.channelPresenceListener = presenceListener;
    }
    
    public func getLastEvents(amount: UInt64, result: @escaping ([EventChannel]?, Bool) -> ()) {
        ChannelsSDK.shared().getChannelsAPI().getLastChannelEvents(channelID: self.channelInfo.id, amount: amount, result: result);
    }
    
    public func getLastEventsSince(amount: UInt64, timestamp: UInt64, result: @escaping ([EventChannel]?, Bool) -> ()) {
        ChannelsSDK.shared().getChannelsAPI().getLastChannelEventsSince(channelID: self.channelInfo.id, amount: amount, timestamp: timestamp, result: result);
    }
    
    public func getEventsBetween(sinceTimestamp: UInt64, toTimestamp: UInt64, result: @escaping ([EventChannel]?, Bool) -> ()) {
        ChannelsSDK.shared().getChannelsAPI().getChannelEventsBetween(channelID: self.channelInfo.id, sinceTimestamp: sinceTimestamp, toTimestamp: toTimestamp, result: result);
    }
    
    public func getEventsSince(timestamp: UInt64, result: @escaping ([EventChannel]?, Bool) -> ()) {
        ChannelsSDK.shared().getChannelsAPI().getChannelEventsSince(channelID: self.channelInfo.id, timestamp: timestamp, result: result);
    }
    
    func onRemoved() {
        self._isSubscribed = false;
        self.channelListener?.onRemoved();
    }
    
    func onJoinChannel(clientJoin: ClientJoin) {
        
        self.onlineStatus.set(value: ClientPresenceStatus(status: false, timestamp: 0), forKey: clientJoin.clientID)
        
        self.channelPresenceListener?.onClientJoinChannel(clientJoin: ClientJoined(join: clientJoin))
    }
    
    func onLeaveChannel(clientLeave: ClientLeave) {
        self.onlineStatus.remove(clientLeave.clientID)
        
        self.channelPresenceListener?.onClientLeaveChannel(clientLeave: ClientLeft(left: clientLeave))
    }
    
    func onInitialStatusUpdate(statusUpdate: InitialPresenceStatus) {
        let statuses = statusUpdate.clientStatus;
        
        statuses.forEach { key, value in
            self.onlineStatus.set(value: ClientPresenceStatus(status: value), forKey: key)
        }
        
        self.channelPresenceListener?.onInitialStatusUpdate();
    }
    
    func onOnlineStatusUpdate(onlineStatusUpdate: OnlineStatusUpdate) {
        let presenceStatus = ClientPresenceStatus(onlineUpdateStatus: onlineStatusUpdate)
        
        self.onlineStatus.set(value: presenceStatus, forKey: onlineStatusUpdate.clientID)
        
        self.channelPresenceListener?.onOnlineStatusUpdate(onlineStatusUpdate: presenceStatus)
    }
    
    func onChannelEvent(event: ChannelEvent) {
        self.channelListener?.onChannelEvent(event: EventChannel(event: event))
    }
    
    func onACK(ack: RequestAcknowledge) {
        
        if (!self._isSubscribed) {
            self._isSubscribed = true;
            self.channelListener?.onSubscribed();
        } else {
            self.channelListener?.onPublishAcknowledge(ack: ack)
        }
    }
}
