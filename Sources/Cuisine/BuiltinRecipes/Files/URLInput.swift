//
//  URLInput.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 31.12.2022
//

import Foundation
import SystemPackage

public protocol URLInput {
    func url(pantry: Pantry) -> URL?
}

extension String: URLInput {
    public func url(pantry: Pantry) -> URL? {
        URL(string: self)
    }
}

extension URL: URLInput {
    public func url(pantry: Pantry) -> URL? {
        self.absoluteURL
    }
}

extension FilePath: URLInput {
    public func url(pantry: Pantry) -> URL? {
        URL(fileURLWithPath: string)
    }
}

extension Optional: URLInput where Wrapped: URLInput {
    public func url(pantry: Pantry) -> URL? {
        switch self {
            case .none: return nil
            case .some(let content): return content.url(pantry: pantry)
        }
    }
}

extension Pantry.KeyPath: URLInput where Value: URLInput, Root == Pantry {
    public func url(pantry: Pantry) -> URL? {
        nil
    }
}

extension State: URLInput where Value: FilePathStore {
    public func url(pantry: Pantry) -> URL? {
        nil
    }
}
