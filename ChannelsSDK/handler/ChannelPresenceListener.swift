//
//  ChannelPresenceListener.swift
//  ChannelsSDK
//
//  Created by Tiago Lima on 13/03/2021.
//

import Foundation

public protocol ChannelPresenceListener {
    
    func onClientJoinChannel(clientJoin: ClientJoined) -> Void;

    func onClientLeaveChannel(clientLeave: ClientLeft) -> Void;

    func onOnlineStatusUpdate(onlineStatusUpdate: ClientPresenceStatus) -> Void;

    func onInitialStatusUpdate() -> Void;
}
