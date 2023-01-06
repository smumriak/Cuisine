//
//  Dish.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 22.09.2022
//

@resultBuilder
public enum RecipeBuilder {
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
        TupleRecipe(left: left, right: right)
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

    internal enum Storage {
        case simple(content: () -> (Root))
        case complex(content: (_ pantry: Pantry) -> (Root))
    }

    let storage: Storage
    let pantry: Pantry?

    public func perform(in kitchen: any Kitchen, pantry: Pantry) async throws {
        let root: Root
        
        switch storage {
            case .simple(let content):
                root = content()

            case .complex(let content):
                root = content(pantry)
        }

        try await root.injectingPerform(in: kitchen, pantry: pantry)
    }

    public func cook(in kitchen: Kitchen = EmptyKitchen()) async throws {
        let pantry = pantry ?? Pantry()
        try await self.injectingPerform(in: kitchen, pantry: pantry)
    }

    public init(_ pantry: Pantry? = nil, @RecipeBuilder _ content: @escaping () -> (Root)) {
        storage = .simple(content: content)
        self.pantry = pantry
    }

    public init(_ pantry: Pantry? = nil, @RecipeBuilder _ content: @escaping (_ pantry: Pantry) -> (Root)) {
        storage = .complex(content: content)
        self.pantry = pantry
    }
}
