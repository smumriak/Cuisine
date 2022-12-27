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

public struct ForEach<Data: RandomAccessCollection>: SupportsNonBlockingRecipes {
    let data: Data
    let content: (Data.Element) -> [any Recipe]
    let mode: ForEachMode
    var recipes: [Recipe] { data.flatMap(content) }

    public var isBlocking: Bool
    
    public init(_ data: Data, mode: ForEachMode = .default, blocking: Bool = true, @RecipeBuilder content: @escaping (Data.Element) -> [any Recipe]) {
        self.data = data
        self.content = content
        self.mode = mode
        isBlocking = blocking
    }

    func perform(in kitchen: Kitchen, pantry: Pantry, taskGroup group: inout ThrowingTaskGroup<Void, Error>) async throws {
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
