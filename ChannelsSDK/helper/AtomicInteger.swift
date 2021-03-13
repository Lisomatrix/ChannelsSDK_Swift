//
//  AtomicInteger.swift
//  ChannelsSDK
//
//  Created by Tiago Lima on 13/03/2021.
//

import Foundation

public final class AtomicUInteger32 {
    
    private let lock = DispatchSemaphore(value: 1)
    private var _value: UInt32
    
    public init(value initialValue: UInt32 = 0) {
        _value = initialValue
    }
    
    public var value: UInt32 {
        get {
            lock.wait()
            defer { lock.signal() }
            return _value
        }
        set {
            lock.wait()
            defer { lock.signal() }
            _value = newValue
        }
    }
    
    public func decrementAndGet() -> UInt32 {
        lock.wait()
        defer { lock.signal() }
        _value -= 1
        return _value
    }
    
    public func incrementAndGet() -> UInt32 {
        lock.wait()
        defer { lock.signal() }
        _value += 1
        return _value
    }
}
