//
//  SymLink.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 02.01.2023
//

import Foundation
import SystemPackage

public struct SymLink<S: FilePathInput, D: FilePathInput>: BlockingRecipe {
    public enum Error: Swift.Error {
        case unexpectedNilPath
    }

    let source: S
    let destination: D

    public init(_ source: S, _ destination: D) {
        self.source = source
        self.destination = destination
    }

    public func perform(in kitchen: Kitchen, pantry: Pantry) async throws {
        let fileManager = FileManager.default

        guard let sourcePath = source.filePath(pantry: pantry), let destinationPath = destination.filePath(pantry: pantry) else {
            throw Error.unexpectedNilPath
        }

        let resolvedSourcePath = FilePath(kitchen.currentDirectory.absoluteURL.path).pushing(sourcePath)

        try fileManager.createSymbolicLink(atPath: resolvedSourcePath.string, withDestinationPath: destinationPath.string)
    }
}
