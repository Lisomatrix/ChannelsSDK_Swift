//
//  RequestsHelper.swift
//  ChannelsSDK
//
//  Created by Tiago Lima on 12/03/2021.
//

import Foundation

let requestIDCounter = AtomicUInteger32(value: 1);

func createNewEvent(type: NewEvent.NewEventType, payload: Data) -> NewEvent {
    var newEvent = NewEvent()
    newEvent.type = type;
    newEvent.payload = payload;
    
    return newEvent;
}

func createPublishRequest(channelID: String, eventType: String, payload: String, notify: Bool) -> PublishRequest {
    
    var request = PublishRequest()
    request.channelID = channelID;
    request.eventType = eventType;
    request.payload = payload;
    
    if (notify) {
        request.id = requestIDCounter.incrementAndGet()
    }
        
    return request;
}

func createSubscribeRequest(channelID: String) -> SubscribeRequest {
    var request = SubscribeRequest()
    request.channelID = channelID;
    request.id = requestIDCounter.incrementAndGet()
    
    return request;
}
