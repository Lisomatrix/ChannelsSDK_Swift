//
//  ClientLeft.swift
//  ChannelsSDK
//
//  Created by Tiago Lima on 13/03/2021.
//

import Foundation

public struct ClientLeft {
    public let channelID: String
    public let clientID: String
    
    init(left: ClientLeave) {
        self.channelID = left.channelID;
        self.clientID = left.clientID;
    }
}
