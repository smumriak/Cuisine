//
//  ForEach.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 22.12.2022
//

public enum ForEachMode {
    case `default`
    case sequential
    case concurrent
}

internal extension ForEachMode {
    var binaryTreeTraversalMode: TupleRecipeTraversalMode {
        switch self {
            case .default: return .default
            case .sequential: return .sequential
            case .concurrent: return .concurrent
        }
    }
}

public struct ForEach<Input: RandomAccessCollection, Result: Recipe>: SupportsNonBlockingRecipes {
    public typealias Content = (Input.Element) throws -> Result

    @usableFromInline
    internal enum InputStorage {
        case value(Input)
        case keyPath(Pantry.KeyPath<Input>)
        case state(State<Input>)

        func buildRecipes(in kitchen: Kitchen, pantry: Pantry, content: Content) throws -> [Result] {
            let input: Input
            switch self {
                case .value(let value):
                    input = value
                 
                case .keyPath(let keypath):
                    input = pantry[keyPath: keypath]
                 
                case .state(let state):
                    input = state.wrappedValue
            }

            return try input.map(content)
        }
    }

    let input: InputStorage
    let content: Content
    let mode: ForEachMode

    public let isBlocking: Bool
    
    @_transparent
    public init(_ value: Input, mode: ForEachMode = .default, blocking: Bool = true, @RecipeBuilder content: @escaping Content) {
        self.init(.value(value), mode: mode, blocking: blocking, content: content)
    }

    @_transparent
    public init(_ keyPath: Pantry.KeyPath<Input>, mode: ForEachMode = .default, blocking: Bool = true, @RecipeBuilder content: @escaping Content) {
        self.init(.keyPath(keyPath), mode: mode, blocking: blocking, content: content)
    }

    @_transparent
    public init(_ state: State<Input>, mode: ForEachMode = .default, blocking: Bool = true, @RecipeBuilder content: @escaping Content) {
        self.init(.state(state), mode: mode, blocking: blocking, content: content)
    }

    @usableFromInline
    internal init(_ input: InputStorage, mode: ForEachMode, blocking: Bool, content: @escaping Content) {
        self.input = input
        self.content = content
        self.mode = mode
        isBlocking = blocking
    }

    public func perform(in kitchen: Kitchen, pantry: Pantry, taskGroup group: inout ThrowingTaskGroup<Void, Error>) async throws {
        let recipes = try input.buildRecipes(in: kitchen, pantry: pantry, content: content)
        for recipe in recipes {
            if let recipe = recipe as? TupleRecipeProtocol {
                try await recipe.injectingPerform(in: kitchen, pantry: pantry, taskGroup: &group, traversalMode: mode.binaryTreeTraversalMode)
                continue
            }

            switch mode {
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
