//
//  MkDir.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 31.12.2022
//

import Foundation
import FoundationNetworking
import SystemPackage

public struct MkDir: Recipe {
    public enum Error: Swift.Error {
        case unexpectedNilPath
    }

    internal var location: any FilePathInput
    public let isBlocking: Bool

    public init<I: FilePathInput>(_ location: I, blocking: Bool = true) {
        self.location = location
        isBlocking = blocking
    }

    public func perform(in kitchen: any Kitchen, pantry: Pantry) async throws {
        guard let url = location.filePath(pantry: pantry)?.toURL(workingDirectory: kitchen.currentDirectory) else {
            throw Error.unexpectedNilPath
        }

        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        
        if fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) == false {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
