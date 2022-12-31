//
//  State.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 30.12.2022
//

import TinyFoundation

@propertyWrapper
public final class State<Value> {
    @Synchronized
    public var wrappedValue: Value
    
    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}
