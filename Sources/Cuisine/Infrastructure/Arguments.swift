//
//  Arguments.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 02.07.2023
//

public protocol InputArgument<Value> {
    associatedtype Value
    
    @inlinable @inline(__always)
    func value(in kitchen: Kitchen, pantry: Pantry) async throws -> Value
}

public struct ValueStorage<Value>: InputArgument {
    @usableFromInline
    let value: Value

    @_transparent
    public init(_ value: Value) {
        self.value = value
    }
    
    @_transparent
    public func value(in kitchen: Kitchen, pantry: Pantry) async throws -> Value {
        value
    }
}

extension Pantry.KeyPath: InputArgument where Root == Pantry {
    @_transparent
    public func value(in kitchen: Kitchen, pantry: Pantry) async throws -> Value {
        pantry[keyPath: self]
    }
}

extension State: InputArgument {
    @_transparent
    public func value(in kitchen: Kitchen, pantry: Pantry) async throws -> Value {
        wrappedValue
    }
}

public protocol OutputArgument<Value> {
    associatedtype Value

    @inlinable @inline(__always)
    func store(_ value: Value, kitchen: Kitchen, pantry: Pantry) async throws
}

extension Pantry.KeyPath: OutputArgument where Root == Pantry {
    @_transparent
    public func store(_ value: Value, kitchen: Kitchen, pantry: Pantry) async throws {
        pantry[keyPath: self] = value
    }
}

extension State: OutputArgument {
    @_transparent
    public func store(_ value: Value, kitchen: Kitchen, pantry: Pantry) async throws {
        wrappedValue = value
    }
}
