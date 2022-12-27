//
//  TupleRecipe.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 24.12.2022
//

internal protocol TupleRecipeProtocol: SupportsNonBlockingRecipes {
    func perform(in kitchen: Kitchen, pantry: Pantry, taskGroup group: inout ThrowingTaskGroup<Void, any Swift.Error>, traversalMode: TupleRecipeTraversalMode) async throws
}

extension TupleRecipeProtocol {
    func perform(in kitchen: Kitchen, pantry: Pantry, taskGroup group: inout ThrowingTaskGroup<Void, any Swift.Error>) async throws {
        try await perform(in: kitchen, pantry: pantry, taskGroup: &group, traversalMode: .default)
    }

    func injectingPerform(in kitchen: Kitchen, pantry: Pantry, taskGroup group: inout ThrowingTaskGroup<Void, any Swift.Error>, traversalMode: TupleRecipeTraversalMode) async throws {
        injectPantry(pantry)
        try await perform(in: kitchen, pantry: pantry, taskGroup: &group, traversalMode: traversalMode)
    }
}

internal enum TupleRecipeTraversalMode {
    case `default`
    case sequential
    case concurrent
}

internal struct TupleRecipe<Left: Recipe, Right: Recipe>: Recipe, TupleRecipeProtocol {
    let left: Left
    let right: Right
    var isBlocking: Bool { true }

    init(left: Left, right: Right) {
        self.left = left
        self.right = right
    }

    func perform(in kitchen: Kitchen, pantry: Pantry, taskGroup group: inout ThrowingTaskGroup<Void, any Swift.Error>, traversalMode: TupleRecipeTraversalMode) async throws {
        // always execute left first so tree traversal would go depth-wise, left-to-right. this mimics iteration over array of recipes
        let recipes: [any Recipe] = [left, right]
        for recipe in recipes {
            if let recipe = recipe as? TupleRecipeProtocol {
                try await recipe.injectingPerform(in: kitchen, pantry: pantry, taskGroup: &group, traversalMode: traversalMode)
                continue
            }

            switch traversalMode {
                case .default:
                    if recipe.isBlocking {
                        try await recipe.injectingPerform(in: kitchen, pantry: pantry)
                    } else {
                        group.addTask {
                            try await recipe.injectingPerform(in: kitchen, pantry: pantry)
                        }
                    }

                case .sequential:
                    try await recipe.injectingPerform(in: kitchen, pantry: pantry)

                case .concurrent:
                    group.addTask {
                        try await recipe.injectingPerform(in: kitchen, pantry: pantry)
                    }
            }
        }
    }
}
