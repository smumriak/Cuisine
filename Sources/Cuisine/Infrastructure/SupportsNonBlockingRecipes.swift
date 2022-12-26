//
//  SupportsNonBlockingRecipes.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 24.12.2022
//

internal protocol SupportsNonBlockingRecipes: Recipe {
    func perform(in kitchen: Kitchen, pantry: Pantry, taskGroup group: inout ThrowingTaskGroup<Void, any Swift.Error>) async throws
}

extension SupportsNonBlockingRecipes {
    public func perform(in kitchen: Kitchen, pantry: Pantry) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            try await perform(in: kitchen, pantry: pantry, taskGroup: &group)
            
            try await group.waitForAll()
        }
    }

    public func injectingPerform(in kitchen: Kitchen, pantry: Pantry, taskGroup group: inout ThrowingTaskGroup<Void, any Swift.Error>) async throws {
        injectPantry(pantry)
        try await perform(in: kitchen, pantry: pantry, taskGroup: &group)
    }
}
