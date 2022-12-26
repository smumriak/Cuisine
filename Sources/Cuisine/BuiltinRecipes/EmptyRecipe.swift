//
//  EmptyRecipe.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 24.12.2022
//

public struct EmptyRecipe: BlockingRecipe {
    public func perform(in kitchen: Kitchen, pantry: Pantry) async throws {}
}
