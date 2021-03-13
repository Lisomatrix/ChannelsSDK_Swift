//
//  ChannelEvent.swift
//  ChannelsSDK
//
//  Created by Tiago Lima on 13/03/2021.
//

import Foundation

public struct EventChannel {
    public let senderID: String
    public let eventType: String
    public let payload: String
    public let channelID: String
    public let timestamp: Int64
    
    
    init(event: ChannelEvent) {
        self.senderID = event.senderID;
        self.eventType = event.eventType;
        self.payload = event.payload;
        self.channelID = event.channelID;
        self.timestamp = event.timestamp
    }
}
