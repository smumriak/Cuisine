//
//  RecipeModifier.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 26.12.2022
//

public protocol RecipeModifier {
    associatedtype Body: Recipe
    associatedtype Content: Recipe
    
    func body(content: Self.Content) -> Self.Body
}

public extension Recipe {
    func modifier<T: RecipeModifier>(_ modifier: T) -> ModifiedContent<Self, T> {
        ModifiedContent(content: self, modifier: modifier)
    }
}

public struct ModifiedContent<Content, Modifier> {
    var content: Content
    var modifier: Modifier

    public init(content: Content, modifier: Modifier) {
        self.content = content
        self.modifier = modifier
    }
}

extension ModifiedContent: Recipe where Content: Recipe, Modifier: RecipeModifier, Modifier.Content == Content {
    public var isBlocking: Bool {
        content.isBlocking
    }

    public func perform(in kitchen: Kitchen, pantry: Pantry) async throws {
        try await modifier.body(content: content).injectingPerform(in: kitchen, pantry: pantry)
    }
}

extension ModifiedContent: NestedRecipe where Content: NestedRecipe, Modifier: RecipeModifier, Modifier.Content == Content {
    public var body: some Recipe {
        modifier.body(content: content)
    }
}

public extension NestedRecipe {
    func modifier<Modifier: RecipeModifier>(_ modifier: Modifier) -> some Recipe where Modifier.Content == Self {
        ModifiedContent(content: self, modifier: modifier)
    }
}

public extension RecipeModifier {}
