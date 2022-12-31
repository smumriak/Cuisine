//
//  State.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 30.12.2022
//

import TinyFoundation

@propertyWrapper
public final class State<Value>: Hashable {
    @Synchronized
    public var wrappedValue: Value
    
    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public static func == (lhs: State<Value>, rhs: State<Value>) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    public func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
    }
}
