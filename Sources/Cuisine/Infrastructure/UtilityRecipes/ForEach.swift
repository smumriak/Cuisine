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

public struct ForEach<Input: RandomAccessCollection, InputStorage: InputArgument<Input>, Result: Recipe>: SupportsNonBlockingRecipes {
    public typealias Content = (Input.Element) throws -> Result

    let input: InputStorage
    let content: Content
    let mode: ForEachMode

    public let isBlocking: Bool
    
    // smumriak: I tried to make this a generic init, but doing so will break type inference for provided KeyPath's. and it's never going to happen since it would be an unsolvable problem on compiler side
    @_transparent
    public init(_ value: Input, mode: ForEachMode = .default, blocking: Bool = true, @RecipeBuilder content: @escaping Content) where InputStorage == ValueStorage<Input> {
        self.init(input: ValueStorage(value), mode: mode, blocking: blocking, content: content)
    }

    @_transparent
    public init(_ keyPath: Pantry.KeyPath<Input>, mode: ForEachMode = .default, blocking: Bool = true, @RecipeBuilder content: @escaping Content) where InputStorage == Pantry.KeyPath<Input> {
        self.init(input: keyPath, mode: mode, blocking: blocking, content: content)
    }

    @_transparent
    public init(_ state: State<Input>, mode: ForEachMode = .default, blocking: Bool = true, @RecipeBuilder content: @escaping Content) where InputStorage == State<Input> {
        self.init(input: state, mode: mode, blocking: blocking, content: content)
    }

    @usableFromInline
    internal init(input: InputStorage, mode: ForEachMode, blocking: Bool, content: @escaping Content) {
        self.input = input
        self.content = content
        self.mode = mode
        isBlocking = blocking
    }

    public func perform(in kitchen: Kitchen, pantry: Pantry, taskGroup group: inout ThrowingTaskGroup<Void, Error>) async throws {
        let recipes = try await input.value(in: kitchen, pantry: pantry).map(content)
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
