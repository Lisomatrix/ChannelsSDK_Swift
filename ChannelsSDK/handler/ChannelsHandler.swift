//
//  ChannelsHandler.swift
//  ChannelsSDK
//
//  Created by Tiago Lima on 13/03/2021.
//

import Foundation

protocol ChannelsHandler {
    func onACK(ack: PublishAck) -> Void;
    func onChannelEvent(event: ChannelEvent) -> Void;
    func onJoinChannel(join: ClientJoin) -> Void;
    func onLeaveChannels(leave: ClientLeave) -> Void;
    func onChannelRemoved(channelID: String) -> Void;
    func onChannelAdded(channelID: String) -> Void;
    func onChannelInitialStatusPresence(initialPresenceStatus: InitialPresenceStatus) -> Void;
    func onChannelOnlineStatusUpdate(onlineStatusUpdate: OnlineStatusUpdate) -> Void;
}

class Channels: ChannelsHandler {
    
    private let channelsDic = ConcurrentDictionary<String, Channel>();
    private let acks = ConcurrentDictionary<UInt32, String>();
    
    private var channelAccessListener: ChannelsAccessListener?;
    
    func setChannelAccessListener(listener: ChannelsAccessListener) {
        self.channelAccessListener = listener;
    }
    
    func registerChannel(chann: Channel) {
        self.channelsDic.set(value: chann, forKey: chann.getChannelInfo().id)
    }
    
    public func getChannel(channelID: String) -> Channel? {
        return self.channelsDic.value(forKey: channelID)
    }
    
    func onACK(ack: PublishAck) {
        if (self.acks.contains(ack.replyTo)) {
            let channelID = self.acks.value(forKey: ack.replyTo)!;
            self.acks.remove(ack.replyTo);
            
            let channel = self.channelsDic.value(forKey: channelID)
            
            channel?.onACK(ack: RequestAcknowledge(publishACK: ack))
        }
    }
    
    func onChannelEvent(event: ChannelEvent) {
        if (self.channelsDic.contains(event.channelID)) {
            let channel = self.channelsDic.value(forKey: event.channelID)!
            
            channel.onChannelEvent(event: event)
        }
    }
    
    func onJoinChannel(join: ClientJoin) {
        if (self.channelsDic.contains(join.channelID)) {
            let channel = self.channelsDic.value(forKey: join.channelID)!
            
            channel.onJoinChannel(clientJoin: join)
        }
    }
    
    func onLeaveChannels(leave: ClientLeave) {
        if (self.channelsDic.contains(leave.channelID)) {
            let channel = self.channelsDic.value(forKey: leave.channelID)!
            
            channel.onLeaveChannel(clientLeave: leave)
        }
    }
    
    func onChannelRemoved(channelID: String) {
        if (self.channelsDic.contains(channelID)) {
            let channel = self.channelsDic.value(forKey: channelID)!
            
            channel.onRemoved();
        }
        
        self.channelAccessListener?.onChannelRemoved(channelID: channelID)
    }
    
    func onChannelAdded(channelID: String) {
        self.channelAccessListener?.onChannelAdded(channelID: channelID)
    }
    
    func onChannelInitialStatusPresence(initialPresenceStatus: InitialPresenceStatus) {
        if (self.channelsDic.contains(initialPresenceStatus.channelID)) {
            let channel = self.channelsDic.value(forKey: initialPresenceStatus.channelID)!
            
            channel.onInitialStatusUpdate(statusUpdate: initialPresenceStatus)
        }
    }
    
    func onChannelOnlineStatusUpdate(onlineStatusUpdate: OnlineStatusUpdate) {
        if (self.channelsDic.contains(onlineStatusUpdate.channelID)) {
            let channel = self.channelsDic.value(forKey: onlineStatusUpdate.channelID)!
            
            channel.onOnlineStatusUpdate(onlineStatusUpdate: onlineStatusUpdate)
        }
    }
    
    
}
