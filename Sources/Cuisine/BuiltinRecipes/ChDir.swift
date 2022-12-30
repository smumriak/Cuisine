//
//  ChDir.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 27.09.2022
//

import Foundation
import FoundationNetworking
import SystemPackage

public struct ChDir<T: Recipe>: Recipe {
    internal struct Table: Cuisine.Table {
        let kitchen: any Kitchen

        var urlSession: URLSession { kitchen.urlSession }
        var env: [String: String] { kitchen.env }
        let currentDirectory: URL

        init(path: FilePath, kitchen: any Kitchen) {
            self.kitchen = kitchen

            currentDirectory = path.toURL(workingDirectory: kitchen.currentDirectory)
        }
    }

    internal let content: () -> (T)
    internal var path: FilePath
    public let isBlocking: Bool

    public init(_ path: String, blocking: Bool = true, @RecipeBuilder _ content: @escaping () -> (T) = { EmptyRecipe() }) {
        self.init(FilePath(path), blocking: blocking, content)
    }

    public init(_ path: FilePath, blocking: Bool = true, @RecipeBuilder _ content: @escaping () -> (T) = { EmptyRecipe() }) {
        self.content = content
        self.path = path
        isBlocking = blocking
    }

    public func perform(in kitchen: any Kitchen, pantry: Pantry) async throws {
        let table = try table(for: kitchen)
        let root = content()
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

internal extension FilePath {
    func toURL(workingDirectory: URL) -> URL {
        let value = lexicallyNormalized().string
        if isAbsolute == false {
            return workingDirectory.appendingPathComponent(value)
        } else {
            return URL(fileURLWithPath: value, isDirectory: false)
        }
    }
}
