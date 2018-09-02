//
//  SGVQueue.swift
//  ScrollableGraphView
//
//  Created by Pho Hale on 9/2/18.
//  Copyright © 2018 SGV. All rights reserved.
//

import Foundation

// Simple queue data structure for keeping track of which
// plots have been added.
internal class SGVQueue<T> {

    var storage: [T]

    public var count: Int {
        get {
            return storage.count
        }
    }

    init() {
        storage = [T]()
    }

    public func enqueue(element: T) {
        storage.insert(element, at: 0)
    }

    public func dequeue() -> T? {
        return storage.popLast()
    }
}
