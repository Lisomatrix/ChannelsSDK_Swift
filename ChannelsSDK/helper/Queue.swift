//
//  Queue.swift
//  ChannelsSDK
//
//  Created by Tiago Lima on 13/03/2021.
//

import Foundation

class Node<T> {
    var value: T
    var next: Node?
    var prev: Node?

    init(value: T) {
        self.value = value
    }
}

class Queue<T> {

    private var head: Node<T>?
    private var tail: Node<T>?
    private var size: Int = 0

    var isEmpty: Bool {
        get {
            return head == nil
        }
    }

    func getSize() -> Int {
        return self.size;
    }
    
    func add(value: T) {
        if head == nil {
            let node = Node(value: value)
            head = node
            tail = node
            head?.next = tail
            tail?.prev = head
        }  else {
            let curr = tail
            tail = Node(value: value)
            curr?.next = tail
            tail?.prev = curr
        }
        
        self.size += 1;
    }

    func peek() -> T? {
        return head?.value
    }

    func poll() -> T? {
        if let value = head?.value {
            head = head?.next
            self.size -= 1;
            return value
        }
        return nil
    }
}
