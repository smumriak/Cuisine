//
//  FilePathInput.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 30.12.2022
//

import Foundation
import SystemPackage

public protocol FilePathInput {
    func fileURL(pantry: Pantry, isDirectory: Bool) -> URL?
    func filePath(pantry: Pantry) -> FilePath?
}

extension String: FilePathInput {}
extension URL: FilePathInput {}
extension FilePath: FilePathInput {}
extension Optional: FilePathInput where Wrapped: FilePathStore {
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
}

extension Pantry.KeyPath: FilePathInput where Value: FilePathStore, Root == Pantry {
    public func fileURL(pantry: Pantry, isDirectory: Bool) -> URL? {
        let result = pantry[keyPath: self] as? URL
        return result?.absoluteURL
    }

    public func filePath(pantry: Pantry) -> FilePath? {
        pantry[keyPath: self] as? FilePath
    }
}

extension State: FilePathInput where Value: FilePathStore {
    public func fileURL(pantry: Pantry, isDirectory: Bool) -> URL? {
        wrappedValue.fileURL(pantry: pantry, isDirectory: isDirectory)
    }

    public func filePath(pantry: Pantry) -> FilePath? {
        wrappedValue.filePath(pantry: pantry)
    }
}
