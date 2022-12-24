//
//  Recipe.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 22.09.2022
//

public protocol Recipe {
    var isBlocking: Bool { get }
    func perform(in kitchen: any Kitchen, pantry: Pantry) async throws
}

public extension Recipe {
    func injectingPerform(in kitchen: any Kitchen, pantry: Pantry) async throws {
        injectPantry(pantry)
        try await perform(in: kitchen, pantry: pantry)
    }
}

public protocol BlockingRecipe: Recipe {}
public extension BlockingRecipe {
    var isBlocking: Bool { true }
}

public protocol NonBlockingRecipe: Recipe {}
public extension NonBlockingRecipe {
    var isBlocking: Bool { false }
}
