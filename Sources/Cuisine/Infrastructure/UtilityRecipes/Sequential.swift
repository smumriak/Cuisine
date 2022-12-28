//
//  Sequential.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 24.12.2022
//

public struct Sequential: Recipe {
    let recipes: [any Recipe]
    public let isBlocking: Bool
    
    public init(blocking: Bool = true, @RecipeBuilder _ content: () -> ([any Recipe])) {
        recipes = content()
        self.isBlocking = blocking
    }

    public func perform(in kitchen: Kitchen, pantry: Pantry) async throws {
        for recipe in recipes {
            if let recipe = recipe as? TupleRecipeProtocol {
                try await withThrowingTaskGroup(of: Void.self) { group in
                    try await recipe.injectingPerform(in: kitchen, pantry: pantry, taskGroup: &group, traversalMode: .sequential)
                    try await group.waitForAll()
                }
            } else {
                try await recipe.injectingPerform(in: kitchen, pantry: pantry)
            }
        }
    }
}
