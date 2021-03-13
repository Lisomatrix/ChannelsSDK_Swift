//
//  ChannelListener.swift
//  ChannelsSDK
//
//  Created by Tiago Lima on 13/03/2021.
//

import Foundation

public protocol ChannelListener {
    func onPublishAcknowledge(ack: RequestAcknowledge) -> Void;

    func onSubscribed() -> Void;

    func onChannelEvent(event: EventChannel) -> Void;

    func onRemoved() -> Void;
}
