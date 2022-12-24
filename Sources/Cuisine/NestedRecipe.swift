//
//  NestedRecipe.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 24.12.2022
//

public protocol NestedRecipe: Recipe {
    associatedtype Body: Recipe

    @RecipeBuilder var body: Self.Body { get }
}

public extension NestedRecipe {
    func perform(in kitchen: Kitchen, pantry: Pantry) async throws {
        try await body.injectingPerform(in: kitchen, pantry: pantry)
    }
}
