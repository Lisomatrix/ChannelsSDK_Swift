//
//  ClientJoined.swift
//  ChannelsSDK
//
//  Created by Tiago Lima on 13/03/2021.
//

import Foundation

public struct ClientJoined {
    public let channelID: String
    public let clientID: String;
    
    init(join: ClientJoin) {
        self.channelID = join.channelID;
        self.clientID = join.clientID;
    }
}
