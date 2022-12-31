//
//  FilePathStore.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 30.12.2022
//
import Foundation
import SystemPackage

public protocol FilePathStore {
    mutating func store(filePath: String, pantry: Pantry, isDirectory: Bool)
    func fileURL(pantry: Pantry, isDirectory: Bool) -> URL?
    func filePath(pantry: Pantry) -> FilePath?
}

public protocol FilePathStringInitializable {
    init(_ filePath: String)
}

extension String: FilePathStore, FilePathStringInitializable {
    public mutating func store(filePath: String, pantry: Pantry, isDirectory: Bool) {
        self = filePath
    }

    public func fileURL(pantry: Pantry, isDirectory: Bool) -> URL? {
        URL(fileURLWithPath: self, isDirectory: false).absoluteURL
    }

    public func filePath(pantry: Pantry) -> FilePath? {
        FilePath(self)
    }
}

extension FilePath: FilePathStore, FilePathStringInitializable {
    public mutating func store(filePath: String, pantry: Pantry, isDirectory: Bool) {
        self = FilePath(filePath)
    }

    public func fileURL(pantry: Pantry, isDirectory: Bool) -> URL? {
        URL(fileURLWithPath: string, isDirectory: isDirectory).absoluteURL
    }

    public func filePath(pantry: Pantry) -> FilePath? {
        self
    }
}

extension URL: FilePathStore, FilePathStringInitializable {
    public mutating func store(filePath: String, pantry: Pantry, isDirectory: Bool) {
        self = URL(fileURLWithPath: filePath)
    }

    public init(_ filePath: String) {
        self = URL(fileURLWithPath: filePath)
    }

    public func fileURL(pantry: Pantry, isDirectory: Bool) -> URL? {
        self.absoluteURL
    }

    public func filePath(pantry: Pantry) -> FilePath? {
        FilePath(self.absoluteURL.path)
    }
}

extension Optional: FilePathStore & FilePathStringInitializable where Wrapped: FilePathStore & FilePathStringInitializable {
    public mutating func store(filePath: String, pantry: Pantry, isDirectory: Bool) {
        self = Wrapped(filePath)
    }

    public func fileURL(pantry: Pantry, isDirectory: Bool) -> URL? {
        switch self {
            case .none: return nil
            case .some(let content): return content.fileURL(pantry: pantry, isDirectory: isDirectory)
        }
    }

    public func filePath(pantry: Pantry) -> FilePath? {
        switch self {
            case .none: return nil
            case .some(let content): return content.filePath(pantry: pantry)
        }
    }

    public init(_ filePath: String) {
        self = Wrapped(filePath)
    }
}
