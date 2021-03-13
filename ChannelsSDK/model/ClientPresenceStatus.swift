//
//  ClientPresenceStatus.swift
//  ChannelsSDK
//
//  Created by Tiago Lima on 13/03/2021.
//

import Foundation

public struct ClientPresenceStatus {
    
    public let status: Bool
    public let timestamp: Int64
    
    init(status: Bool, timestamp: Int64) {
        self.status = status;
        self.timestamp = timestamp;
    }
    
    init(status: ClientStatus) {
        self.status = status.status;
        self.timestamp = status.timestamp
    }
    
    init(onlineUpdateStatus: OnlineStatusUpdate) {
        self.status = onlineUpdateStatus.status;
        self.timestamp = onlineUpdateStatus.timestamp;
    }
}
