//
//  Concurrent.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 21.12.2022
//

public struct Concurrent: SupportsNonBlockingRecipes {
    let recipes: [any Recipe]
    public let isBlocking: Bool

    public init(_ recipes: [any Recipe], blocking: Bool = true) {
        self.recipes = recipes
        self.isBlocking = blocking
    }

    public init(blocking: Bool = true, @RecipeBuilder _ content: () -> (some Recipe) = { EmptyRecipe() }) {
        self.init([content()], blocking: blocking)
    }

    func perform(in kitchen: Kitchen, pantry: Pantry, taskGroup group: inout ThrowingTaskGroup<Void, Error>) async throws {
        for recipe in recipes {
            if let recipe = recipe as? TupleRecipeProtocol {
                try await recipe.injectingPerform(in: kitchen, pantry: pantry, taskGroup: &group, traversalMode: .concurrent)
            } else {
                group.addTask {
                    try await recipe.injectingPerform(in: kitchen, pantry: pantry)
                }
            }
        }

        try await group.waitForAll()
    }
}
