//
//  ChannelSettings.swift
//  ChannelsSDK
//
//  Created by Tiago Lima on 13/03/2021.
//

import Foundation


public struct ChannelSettings {
    
    public let id: String;
    public let name: String;
    public let createdAt: Int64;
    public let isClosed: Bool;
    public let extra: String;
    public let isPersistent: Bool;
    public let isPrivate: Bool;
    public let isPresence: Bool;
    
    init(info: ChannelInfo) {
        self.id = info.id;
        self.name = info.name;
        self.createdAt = info.createdAt;
        self.isClosed = info.isClosed;
        self.extra = info.extra;
        self.isPersistent = info.isPersistent;
        self.isPrivate = info.isPrivate;
        self.isPresence = info.isPresence;
    }
}
