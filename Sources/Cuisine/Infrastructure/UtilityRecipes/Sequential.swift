//
//  Sequential.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 24.12.2022
//

public struct Sequential: Recipe {
    @resultBuilder
    public enum Builder {
        public static func buildExpression(_ expression: some Recipe) -> [any Recipe] {
            [expression]
        }

        public static func buildBlock() -> [any Recipe] {
            []
        }

        public static func buildPartialBlock(first: [any Recipe]) -> [any Recipe] {
            first
        }

        public static func buildPartialBlock(accumulated left: [any Recipe], next right: [any Recipe]) -> [any Recipe] {
            left + right
        }

        public static func buildOptional(_ recipe: [any Recipe]?) -> [any Recipe] {
            if let recipe {
                return recipe
            } else {
                return []
            }
        }

        public static func buildEither(first component: [any Recipe]) -> [any Recipe] {
            return component
        }

        public static func buildEither(second component: [any Recipe]) -> [any Recipe] {
            return component
        }

        public static func buildArray(_ components: [[any Recipe]]) -> [any Recipe] {
            components.flatMap { $0 }
        }

        public static func buildFinalResult(_ recipe: [any Recipe]) -> [any Recipe] {
            recipe
        }
    }

    public typealias Content = () -> ([any Recipe])
    let content: Content
    public let isBlocking: Bool
    
    public init(blocking: Bool = true, @Builder _ content: @escaping Content) {
        self.content = content
        self.isBlocking = blocking
    }

    public func perform(in kitchen: Kitchen, pantry: Pantry) async throws {
        for recipe in content() {
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
