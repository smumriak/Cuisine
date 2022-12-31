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
    public enum Error: Swift.Error {
        case unexpectedNilPath
    }

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
    internal var location: any FilePathInput
    public let isBlocking: Bool

    public init<I: FilePathInput>(_ location: I, blocking: Bool = true, @RecipeBuilder _ content: @escaping () -> (T) = { EmptyRecipe() }) {
        self.content = content
        self.location = location
        isBlocking = blocking
    }

    public func perform(in kitchen: any Kitchen, pantry: Pantry) async throws {
        let table = try table(for: kitchen, pantry: pantry)
        let root = content()
        try await root.injectingPerform(in: table, pantry: pantry)
    }

    internal func table(for kitchen: Kitchen, pantry: Pantry) throws -> ChDir.Table {
        guard let path = location.filePath(pantry: pantry) else {
            throw Error.unexpectedNilPath
        }
        
        let table = ChDir.Table(path: path, kitchen: kitchen)

        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        
        if fileManager.fileExists(atPath: table.currentDirectory.absoluteURL.path, isDirectory: &isDirectory) == false {
            try fileManager.createDirectory(at: table.currentDirectory.absoluteURL, withIntermediateDirectories: true, attributes: nil)
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
