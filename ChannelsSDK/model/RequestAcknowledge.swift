//
//  RequestAcknowledge.swift
//  ChannelsSDK
//
//  Created by Tiago Lima on 13/03/2021.
//

import Foundation

public struct RequestAcknowledge {
    
    public let replyTo: UInt32;
    public let status: Bool;
    
    init(publishACK: PublishAck) {
        self.replyTo = publishACK.replyTo;
        self.status = publishACK.status;
    }
    
}
