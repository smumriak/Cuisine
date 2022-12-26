//
//  Dish.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 22.09.2022
//

@resultBuilder
public struct RecipeBuilder {
    public static func buildExpression(_ expression: some Recipe) -> some Recipe {
        expression
    }

    public static func buildBlock() -> some Recipe {
        EmptyRecipe()
    }

    public static func buildPartialBlock(first: some Recipe) -> some Recipe {
        first
    }

    public static func buildPartialBlock(accumulated left: some Recipe, next right: some Recipe) -> some Recipe {
        BinaryTreeRecipe(left: left, right: right)
    }

    public static func buildOptional(_ recipe: (some Recipe)?) -> some Recipe {
        OptionalRecipe(recipe)
    }

    public static func buildEither(first component: some Recipe) -> some Recipe {
        return component
    }

    public static func buildEither(second component: some Recipe) -> some Recipe {
        return component
    }

    public static func buildArray(_ components: [any Recipe]) -> some Recipe {
        Group(components)
    }

    public static func buildFinalResult(_ recipe: some Recipe) -> some Recipe {
        recipe
    }
}

public struct Dish<Root: Recipe>: Recipe {
    public let isBlocking = true
    let root: Root

    public func perform(in kitchen: any Kitchen, pantry: Pantry) async throws {
        try await root.injectingPerform(in: kitchen, pantry: pantry)
    }

    public func cook(in kitchen: Kitchen = EmptyKitchen()) async throws {
        let pantry = Pantry()
        try await self.injectingPerform(in: kitchen, pantry: pantry)
    }

    public init(@RecipeBuilder _ content: @escaping () -> (Root)) {
        root = content()
    }
}
