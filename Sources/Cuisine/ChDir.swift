//
//  ChDir.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 27.09.2022
//

import Foundation
import FoundationNetworking
import SystemPackage

public struct ChDir: Recipe {
    internal struct Table: Cuisine.Table {
        let kitchen: any Kitchen

        var urlSession: URLSession { kitchen.urlSession }
        var env: [String: String] { kitchen.env }
        let currentDirectory: URL

        init(path: FilePath, kitchen: any Kitchen) {
            self.kitchen = kitchen

            if !path.isAbsolute {
                currentDirectory = URL(fileURLWithPath: path.string, isDirectory: false, relativeTo: kitchen.currentDirectory)
            } else {
                currentDirectory = URL(fileURLWithPath: path.string, isDirectory: false)
            }
        }
    }

    internal let root: any Recipe
    internal var path: FilePath
    public var isBlocking: Bool

    public init(_ path: String, blocking: Bool = true, @RecipeBuilder _ content: () -> (some Recipe) = { EmptyRecipe() }) {
        self.init(FilePath(path), blocking: blocking, content)
    }

    public init(_ path: FilePath, blocking: Bool = true, @RecipeBuilder _ content: () -> (some Recipe) = { EmptyRecipe() }) {
        root = content()
        self.path = path
        isBlocking = blocking
    }

    public func perform(in kitchen: any Kitchen, pantry: Pantry) async throws {
        let table = try table(for: kitchen)
        
        try await root.injectingPerform(in: table, pantry: pantry)
    }

    internal func table(for kitchen: Kitchen) throws -> ChDir.Table {
        let table = ChDir.Table(path: path, kitchen: kitchen)
        
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        
        if fileManager.fileExists(atPath: table.currentDirectory.path, isDirectory: &isDirectory) == false {
            try fileManager.createDirectory(at: table.currentDirectory, withIntermediateDirectories: true, attributes: nil)
        }

        return table
    }
}
