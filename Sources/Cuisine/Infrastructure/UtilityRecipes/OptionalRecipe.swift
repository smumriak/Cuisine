//
//  OptionalRecipe.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 24.12.2022
//

internal struct OptionalRecipe<Value: Recipe>: Recipe {
    var isBlocking: Bool { recipe?.isBlocking ?? false }
    let recipe: Value?

    init(_ recipe: Value?) {
        self.recipe = recipe
    }

    func perform(in kitchen: Kitchen, pantry: Pantry) async throws {
        try await recipe?.perform(in: kitchen, pantry: pantry)
    }
}

extension OptionalRecipe: SupportsNonBlockingRecipes where Value: SupportsNonBlockingRecipes {
    func perform(in kitchen: Kitchen, pantry: Pantry, taskGroup group: inout ThrowingTaskGroup<Void, Error>) async throws {
        try await recipe?.injectingPerform(in: kitchen, pantry: pantry, taskGroup: &group)
    }
}

extension OptionalRecipe: BinaryTreeRecipeProtocol where Value: BinaryTreeRecipeProtocol {
    func perform(in kitchen: Kitchen, pantry: Pantry, taskGroup group: inout ThrowingTaskGroup<Void, any Swift.Error>, traversalMode: BinaryTreeRecipeTraversalMode) async throws {
        try await recipe?.injectingPerform(in: kitchen, pantry: pantry, taskGroup: &group, traversalMode: traversalMode)
    }
}
