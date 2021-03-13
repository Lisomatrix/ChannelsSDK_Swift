//
//  ChannelsAccessListener.swift
//  ChannelsSDK
//
//  Created by Tiago Lima on 13/03/2021.
//

import Foundation

public protocol ChannelsAccessListener {
    func onChannelAdded(channelID: String);
    func onChannelRemoved(channelID: String);
}
