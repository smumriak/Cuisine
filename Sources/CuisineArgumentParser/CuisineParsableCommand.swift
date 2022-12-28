//
//  CuisineParsableCommand.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 27.12.2022
//

import ArgumentParser
import Cuisine

public protocol CuisineParsableCommand: AsyncParsableCommand, NestedRecipe, BlockingRecipe {
    var kitchen: Kitchen { get }
    var pantry: Pantry { get }
}

public extension CuisineParsableCommand {
    var kitchen: Kitchen { EmptyKitchen() }
    var pantry: Pantry { Pantry() }
}

public extension CuisineParsableCommand {
    mutating func run() async throws {
        let recipe = self.body
        try await Dish(pantry) { recipe }.cook(in: kitchen)
    }
}
