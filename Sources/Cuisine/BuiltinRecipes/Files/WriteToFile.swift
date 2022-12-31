//
//  WriteToFile.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 28.12.2022
//

import Foundation
import SystemPackage

public protocol FileWriteContent {
    func write(to url: URL, pantry: Pantry) async throws
}

extension String: FileWriteContent {
    public func write(to url: URL, pantry: Pantry) async throws {
        try data(using: .utf8)?.write(to: url, options: .atomic)
    }
}

extension Data: FileWriteContent {
    public func write(to url: URL, pantry: Pantry) async throws {
        try write(to: url, options: .atomic)
    }
}

extension Optional: FileWriteContent where Wrapped: FileWriteContent {
    public func write(to url: URL, pantry: Pantry) async throws {
        switch self {
            case .none: return
            case .some(let content): try await content.write(to: url, pantry: pantry)
        }
    }
}

extension Pantry.KeyPath: FileWriteContent where Value: FileWriteContent, Root == Pantry {
    public func write(to url: URL, pantry: Pantry) async throws {
        try await pantry[keyPath: self].write(to: url, pantry: pantry)
    }
}

extension Never: FileWriteContent {
    public func write(to url: URL, pantry: Pantry) async throws {
        fatalError("Calling write on never is wrong. Don't do that")
    }
}

public struct WriteToFile: BlockingRecipe {
    internal enum ContentStorage<T: FileWriteContent>: FileWriteContent {
        case simple(() -> (T))
        case complex((_ pantry: Pantry) -> (T))
        case formattedString(String, [String])
        case formattedStringKeyPath(String, [Pantry.KeyPath<String>])

        public init(_ content: @escaping () -> (T)) {
            self = .simple(content)
        }

        public init(_ content: @escaping (_ pantry: Pantry) -> (T)) {
            self = .complex(content)
        }

        public init(format: String, _ values: [String]) {
            self = .formattedString(format, values)
        }

        public init(format: String, _ values: [Pantry.KeyPath<String>]) {
            self = .formattedStringKeyPath(format, values)
        }
        
        func write(to url: URL, pantry: Pantry) async throws {
            let value: any FileWriteContent
            switch self {
                case .simple(let content): value = content()
                case .complex(let content): value = content(pantry)
                case .formattedString(let format, let content):
                    value = format.asCuisineFormat(with: content)

                case .formattedStringKeyPath(let format, let content):
                    let content = content.map { pantry[keyPath: $0] }
                    value = format.asCuisineFormat(with: content)
            }
            try await value.write(to: url, pantry: pantry)
        }
    }

    let location: any FilePathInput
    let content: any FileWriteContent

    public init<I: FilePathInput, C: FileWriteContent>(_ location: I, _ content: C) {
        self.location = location
        self.content = content
    }

    public init<I: FilePathInput, C: FileWriteContent>(_ location: I, _ content: @escaping () -> (C)) {
        self.location = location
        self.content = ContentStorage(content)
    }

    public init<I: FilePathInput, C: FileWriteContent>(_ location: I, _ content: @escaping (_ pantry: Pantry) -> (C)) {
        self.location = location
        self.content = ContentStorage(content)
    }

    public init<I: FilePathInput>(_ location: I, format: String, _ values: String...) {
        self.location = location
        self.content = ContentStorage<Never>(format: format, values)
    }

    public init<I: FilePathInput>(_ location: I, format: String, _ values: [String]) {
        self.location = location
        self.content = ContentStorage<Never>(format: format, values)
    }

    public init<I: FilePathInput>(_ location: I, format: String, _ values: Pantry.KeyPath<String>...) {
        self.location = location
        self.content = ContentStorage<Never>(format: format, values)
    }

    public init<I: FilePathInput>(_ location: I, format: String, _ values: [Pantry.KeyPath<String>]) {
        self.location = location
        self.content = ContentStorage<Never>(format: format, values)
    }

    public func perform(in kitchen: Kitchen, pantry: Pantry) async throws {
        guard let url = location.filePath(pantry: pantry)?.toURL(workingDirectory: kitchen.currentDirectory) else { return }
        try await content.write(to: url, pantry: pantry)
    }
}
