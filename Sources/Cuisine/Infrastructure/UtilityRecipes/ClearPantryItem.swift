//
//  ClearPantryItem.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 27.12.2022
//

public struct ClearPantryItem<T>: Recipe {
    let keyPath: Pantry.KeyPath<T>

    public init(at keyPath: Pantry.KeyPath<T>, blocking: Bool = true) {
        self.keyPath = keyPath
        isBlocking = blocking
    }

    public let isBlocking: Bool

    public func perform(in kitchen: Kitchen, pantry: Pantry) async throws {
        // empty value
        pantry[keyPath: keyPath] = Pantry()[keyPath: keyPath]
    }
}
