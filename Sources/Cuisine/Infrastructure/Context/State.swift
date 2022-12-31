//
//  State.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 30.12.2022
//

import TinyFoundation

@propertyWrapper
public final class State<T> {
    @Synchronized
    public var wrappedValue: T
    
    public init(_ wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}
