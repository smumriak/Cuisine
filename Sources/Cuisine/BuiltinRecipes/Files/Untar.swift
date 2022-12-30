//
//  Untar.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 30.12.2022
//

import Foundation

public struct Untar: BlockingRecipe {
    public enum Error: Swift.Error {
        case notFileURL
        case unsupportedArchive
        case doesNotExist
    }

    enum ContentStorage {
        case url(URL)
        case keyPath(Pantry.KeyPath<URL>)
        case optionalKeyPath(Pantry.KeyPath<URL?>)
    }

    internal let content: ContentStorage
    internal var nameKeyPath: GetFile.KeyPathStorage?

    public init(_ url: URL, storeNameIn nameKeyPath: Pantry.KeyPath<String>?) {
        content = .url(url)
        if let nameKeyPath {
            self.nameKeyPath = .nonOptional(nameKeyPath)
        }
    }

    public init(_ url: URL, storeNameIn nameKeyPath: Pantry.KeyPath<String?>?) {
        content = .url(url)
        if let nameKeyPath {
            self.nameKeyPath = .optional(nameKeyPath)
        }
    }

    public init(_ keyPath: Pantry.KeyPath<URL>, storeNameIn nameKeyPath: Pantry.KeyPath<String>?) {
        content = .keyPath(keyPath)
        if let nameKeyPath {
            self.nameKeyPath = .nonOptional(nameKeyPath)
        }
    }

    public init(_ keyPath: Pantry.KeyPath<URL>, storeNameIn nameKeyPath: Pantry.KeyPath<String?>?) {
        content = .keyPath(keyPath)
        if let nameKeyPath {
            self.nameKeyPath = .optional(nameKeyPath)
        }
    }

    public init(_ keyPath: Pantry.KeyPath<URL?>, storeNameIn nameKeyPath: Pantry.KeyPath<String>?) {
        content = .optionalKeyPath(keyPath)
        if let nameKeyPath {
            self.nameKeyPath = .nonOptional(nameKeyPath)
        }
    }

    public init(_ keyPath: Pantry.KeyPath<URL?>, storeNameIn nameKeyPath: Pantry.KeyPath<String?>?) {
        content = .optionalKeyPath(keyPath)
        if let nameKeyPath {
            self.nameKeyPath = .optional(nameKeyPath)
        }
    }

    func url(pantry: Pantry) -> URL? {
        switch content {
            case .url(let content):
                return content

            case .keyPath(let content):
                return pantry[keyPath: content]
                
            case .optionalKeyPath(let content):
                return pantry[keyPath: content]
        }
    }

    public func perform(in kitchen: Kitchen, pantry: Pantry) async throws {
        guard let url = url(pantry: pantry)?.absoluteURL else {
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
            "--one-top-level \(name)"
            "--strip-components 1"
        }
        try await run.injectingPerform(in: kitchen, pantry: pantry)

        nameKeyPath?.store(value: name, in: pantry)
    }
}

extension URL {
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
