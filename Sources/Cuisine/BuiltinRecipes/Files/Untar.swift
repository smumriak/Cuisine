//
//  Untar.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 30.12.2022
//

import Foundation
import SystemPackage

public struct Untar: BlockingRecipe {
    public enum Error: Swift.Error {
        case notFileURL
        case unsupportedArchive
        case doesNotExist
    }

    internal let pathInput: any FilePathInput
    internal var pathOutput: (any FilePathOutput)?

    public init<I: FilePathInput, O: FilePathOutput>(_ pathInput: I, storePathIn pathOutput: O? = nil) {
        self.pathInput = pathInput
        self.pathOutput = pathOutput
    }

    public func perform(in kitchen: Kitchen, pantry: Pantry) async throws {
        guard let url = pathInput.fileURL(pantry: pantry, isDirectory: false)?.absoluteURL else {
            throw Error.notFileURL
        }
        
        guard url.isFileURL == true,
              url.isTarArchive else {
            throw Error.unsupportedArchive
        }

        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) == false || isDirectory.boolValue == false {
            throw Error.doesNotExist
        }
        
        let name = url.tarName

        let run = Run("tar xf \(url.path)") {
            "--one-top-level \(url.tarName)"
            "--strip-components 1"
        }
        try await run.injectingPerform(in: kitchen, pantry: pantry)

        pathOutput?.store(filePath: kitchen.currentDirectory.absoluteURL.appendingPathComponent(name).path, pantry: pantry, isDirectory: true)
    }
}

public extension URL {
    var isTarArchive: Bool {
        let firstPathExtension = pathExtension.lowercased()
        
        if firstPathExtension == "tar" {
            return true
        }

        if ["gz", "bz", "xz"].contains(firstPathExtension) {
            return deletingPathExtension().pathExtension.lowercased() == "tar"
        }

        return false
    }

    var tarName: String {
        let firstPathExtension = pathExtension.lowercased()

        let withoutFirstExtension = deletingPathExtension()
        
        if firstPathExtension == "tar" {
            return withoutFirstExtension.lastPathComponent
        }

        if ["gz", "bz", "xz"].contains(firstPathExtension),
           withoutFirstExtension.pathExtension.lowercased() == "tar" {
            return withoutFirstExtension.deletingPathExtension().lastPathComponent
        }

        return lastPathComponent
    }
}
