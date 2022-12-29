//
//  WriteToFile.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 28.12.2022
//

import Foundation
import SystemPackage

public protocol WriteToFileContent {
    static func storage(for value: Self) -> WriteToFile.ContentStorage
}

public protocol WriteToFileKeyPathContent {
    associatedtype SelfTypeHack
    static func keyPathStorage(for value: Pantry.KeyPath<SelfTypeHack>) -> WriteToFile.ContentStorage
    static func optionalKeyPathStorage(for value: Pantry.KeyPath<SelfTypeHack?>) -> WriteToFile.ContentStorage
}

extension String: WriteToFileContent {
    public static func storage(for value: Self) -> WriteToFile.ContentStorage {
        .string(value)
    }
}

extension Data: WriteToFileContent {
    public static func storage(for value: Self) -> WriteToFile.ContentStorage {
        .data(value)
    }
}

// extension InputStream: WriteToFileContent {
//     public static func storage(for value: InputStream) -> WriteToFile.ContentStorage {
//         .stream(value)
//     }
// }

extension String: WriteToFileKeyPathContent {
    public static func keyPathStorage(for value: Pantry.KeyPath<Self>) -> WriteToFile.ContentStorage {
        .stringKeyPath(value)
    }

    public static func optionalKeyPathStorage(for value: Pantry.KeyPath<Self?>) -> WriteToFile.ContentStorage {
        .optionalStringKeyPath(value)
    }
}

extension Data: WriteToFileKeyPathContent {
    public static func keyPathStorage(for value: Pantry.KeyPath<Self>) -> WriteToFile.ContentStorage {
        .dataKeyPath(value)
    }

    public static func optionalKeyPathStorage(for value: Pantry.KeyPath<Self?>) -> WriteToFile.ContentStorage {
        .optionalDataKeyPath(value)
    }
}
     
// extension InputStream: WriteToFileKeyPathContent {
//     public static func keyPathStorage(for value: Pantry.KeyPath<InputStream>) -> WriteToFile.ContentStorage {
//         .streamKeyPath(value)
//     }

//     public static func optionalKeyPathStorage(for value: Pantry.KeyPath<InputStream?>) -> WriteToFile.ContentStorage {
//         .optionalStreamKeyPath(value)
//     }
// }

public protocol WriteToFileLocation {
    static func storage(for value: Self) -> WriteToFile.LocationStorage
    static func keyPathStorage(for value: Pantry.KeyPath<Self>) -> WriteToFile.LocationStorage
    static func optionalKeyPathStorage(for value: Pantry.KeyPath<Self?>) -> WriteToFile.LocationStorage
}

extension String: WriteToFileLocation {
    public static func storage(for value: Self) -> WriteToFile.LocationStorage {
        .string(value)
    }

    public static func keyPathStorage(for value: Pantry.KeyPath<String>) -> WriteToFile.LocationStorage {
        .stringKeyPath(value)
    }

    public static func optionalKeyPathStorage(for value: Pantry.KeyPath<String?>) -> WriteToFile.LocationStorage {
        .optionalStringKeyPath(value)
    }
}

extension URL: WriteToFileLocation {
    public static func storage(for value: Self) -> WriteToFile.LocationStorage {
        .url(value)
    }

    public static func keyPathStorage(for value: Pantry.KeyPath<Self>) -> WriteToFile.LocationStorage {
        .urlKeyPath(value)
    }

    public static func optionalKeyPathStorage(for value: Pantry.KeyPath<Self?>) -> WriteToFile.LocationStorage {
        .optionalURLKeyPath(value)
    }
}

extension FilePath: WriteToFileLocation {
    public static func storage(for value: Self) -> WriteToFile.LocationStorage {
        .path(value)
    }

    public static func keyPathStorage(for value: Pantry.KeyPath<Self>) -> WriteToFile.LocationStorage {
        .pathKeyPath(value)
    }

    public static func optionalKeyPathStorage(for value: Pantry.KeyPath<Self?>) -> WriteToFile.LocationStorage {
        .optionalPathKeyPath(value)
    }
}

public struct WriteToFile: BlockingRecipe {
    public enum LocationStorage {
        case string(String)
        case stringKeyPath(Pantry.KeyPath<String>)
        case optionalStringKeyPath(Pantry.KeyPath<String?>)
        case url(URL)
        case urlKeyPath(Pantry.KeyPath<URL>)
        case optionalURLKeyPath(Pantry.KeyPath<URL?>)
        case path(FilePath)
        case pathKeyPath(Pantry.KeyPath<FilePath>)
        case optionalPathKeyPath(Pantry.KeyPath<FilePath?>)

        func url(kitchen: any Kitchen, pantry: Pantry) -> URL? {
            switch self {
                case .string(let content):
                    let path = FilePath(content)
                    return path.toURL(workingDirectory: kitchen.currentDirectory)
            
                case .stringKeyPath(let content):
                    let path = FilePath(pantry[keyPath: content])
                    return path.toURL(workingDirectory: kitchen.currentDirectory)
                
                case .optionalStringKeyPath(let content):
                    guard let pathString = pantry[keyPath: content] else { return nil }
                    let path = FilePath(pathString)
                    return path.toURL(workingDirectory: kitchen.currentDirectory)

                case .url(let content):
                    return content

                case .urlKeyPath(let content):
                    return pantry[keyPath: content]

                case .optionalURLKeyPath(let content):
                    return pantry[keyPath: content]

                case .path(let content):
                    return content.toURL(workingDirectory: kitchen.currentDirectory)
                    
                case .pathKeyPath(let content):
                    let path = pantry[keyPath: content]
                    return path.toURL(workingDirectory: kitchen.currentDirectory)

                case .optionalPathKeyPath(let content):
                    let path = pantry[keyPath: content]
                    return path?.toURL(workingDirectory: kitchen.currentDirectory)
            }
        }
    }

    public enum ContentStorage {
        case string(String)
        case stringKeyPath(Pantry.KeyPath<String>)
        case optionalStringKeyPath(Pantry.KeyPath<String?>)
        case simpleString(() -> (String))
        case complexString((_ pantry: Pantry) -> (String))
        case data(Data)
        case dataKeyPath(Pantry.KeyPath<Data>)
        case optionalDataKeyPath(Pantry.KeyPath<Data?>)
        case simpleData(() -> (Data))
        case complexData((_ pantry: Pantry) -> (Data))
        case formattedString(String, [String])
        case formattedStringKeyPath(String, [Pantry.KeyPath<String>])
        // case stream(InputStream)
        // case streamKeyPath(Pantry.KeyPath<InputStream>)
        // case optionalStreamKeyPath(Pantry.KeyPath<InputStream?>)
        // case simpleStream(() -> (InputStream))
        // case complexStream((_ pantry: Pantry) -> (InputStream))

        // written this way to have ability to extend it with streams in future
        func write(to url: URL, pantry: Pantry) async throws {
            switch self {
                case .string(let content):
                    try content.data(using: .utf8)?.write(to: url, options: .atomic)
          
                case .stringKeyPath(let content):
                    try pantry[keyPath: content].data(using: .utf8)?.write(to: url, options: .atomic)

                case .optionalStringKeyPath(let content):
                    try pantry[keyPath: content]?.data(using: .utf8)?.write(to: url, options: .atomic)
          
                case .simpleString(let content):
                    try content().data(using: .utf8)?.write(to: url, options: .atomic)
          
                case .complexString(let content):
                    try content(pantry).data(using: .utf8)?.write(to: url, options: .atomic)
          
                case .data(let content):
                    try content.write(to: url, options: .atomic)
          
                case .dataKeyPath(let content):
                    try pantry[keyPath: content].write(to: url, options: .atomic)

                case .optionalDataKeyPath(let content):
                    try pantry[keyPath: content]?.write(to: url, options: .atomic)
          
                case .simpleData(let content):
                    try content().write(to: url, options: .atomic)
          
                case .complexData(let content):
                    try content(pantry).write(to: url, options: .atomic)

                case .formattedString(let format, let content):
                    try format.asCuisineFormat(with: content).data(using: .utf8)?.write(to: url, options: .atomic)

                case .formattedStringKeyPath(let format, let content):
                    let content = content.map { pantry[keyPath: $0] }
                    try format.asCuisineFormat(with: content).data(using: .utf8)?.write(to: url, options: .atomic)

                    // case .stream(let content): break
                    // case .streamKeyPath(let content): break
                    // case .optionalStreamKeyPath(let content): break
                    // case .simpleStream(let content): break
                    // case .complexStream(let content): break
            }
        }
    }

    let location: LocationStorage
    let content: ContentStorage

    public init<L: WriteToFileLocation, C: WriteToFileContent>(_ location: L, _ content: C) {
        self.location = L.storage(for: location)
        self.content = C.storage(for: content)
    }

    public init<L: WriteToFileLocation, C: WriteToFileContent>(_ location: Pantry.KeyPath<L>, _ content: C) {
        self.location = L.keyPathStorage(for: location)
        self.content = C.storage(for: content)
    }

    public init<L: WriteToFileLocation, C: WriteToFileContent>(_ location: Pantry.KeyPath<L?>, _ content: C) {
        self.location = L.optionalKeyPathStorage(for: location)
        self.content = C.storage(for: content)
    }

    public init<L: WriteToFileLocation, C: WriteToFileKeyPathContent>(_ location: L, _ content: Pantry.KeyPath<C>) where C.SelfTypeHack == C {
        self.location = L.storage(for: location)
        self.content = C.keyPathStorage(for: content)
    }

    public init<L: WriteToFileLocation, C: WriteToFileKeyPathContent>(_ location: Pantry.KeyPath<L>, _ content: Pantry.KeyPath<C>) where C.SelfTypeHack == C {
        self.location = L.keyPathStorage(for: location)
        self.content = C.keyPathStorage(for: content)
    }

    public init<L: WriteToFileLocation, C: WriteToFileKeyPathContent>(_ location: Pantry.KeyPath<L?>, _ content: Pantry.KeyPath<C>) where C.SelfTypeHack == C {
        self.location = L.optionalKeyPathStorage(for: location)
        self.content = C.keyPathStorage(for: content)
    }
  
    public init<L: WriteToFileLocation, C: WriteToFileKeyPathContent>(_ location: L, _ content: Pantry.KeyPath<C?>) where C.SelfTypeHack == C {
        self.location = L.storage(for: location)
        self.content = C.optionalKeyPathStorage(for: content)
    }

    public init<L: WriteToFileLocation, C: WriteToFileKeyPathContent>(_ location: Pantry.KeyPath<L>, _ content: Pantry.KeyPath<C?>) where C.SelfTypeHack == C {
        self.location = L.keyPathStorage(for: location)
        self.content = C.optionalKeyPathStorage(for: content)
    }

    public init<L: WriteToFileLocation, C: WriteToFileKeyPathContent>(_ location: Pantry.KeyPath<L?>, _ content: Pantry.KeyPath<C?>) where C.SelfTypeHack == C {
        self.location = L.optionalKeyPathStorage(for: location)
        self.content = C.optionalKeyPathStorage(for: content)
    }

    public init<L: WriteToFileLocation>(_ location: L, _ content: @escaping () -> (String)) {
        self.location = L.storage(for: location)
        self.content = .simpleString(content)
    }

    public init<L: WriteToFileLocation>(_ location: Pantry.KeyPath<L>, _ content: @escaping () -> (String)) {
        self.location = L.keyPathStorage(for: location)
        self.content = .simpleString(content)
    }

    public init<L: WriteToFileLocation>(_ location: Pantry.KeyPath<L?>, _ content: @escaping () -> (String)) {
        self.location = L.optionalKeyPathStorage(for: location)
        self.content = .simpleString(content)
    }

    public init<L: WriteToFileLocation>(_ location: L, _ content: @escaping (_ pantry: Pantry) -> (String)) {
        self.location = L.storage(for: location)
        self.content = .complexString(content)
    }

    public init<L: WriteToFileLocation>(_ location: Pantry.KeyPath<L>, _ content: @escaping (_ pantry: Pantry) -> (String)) {
        self.location = L.keyPathStorage(for: location)
        self.content = .complexString(content)
    }

    public init<L: WriteToFileLocation>(_ location: Pantry.KeyPath<L?>, _ content: @escaping (_ pantry: Pantry) -> (String)) {
        self.location = L.optionalKeyPathStorage(for: location)
        self.content = .complexString(content)
    }

    public init<L: WriteToFileLocation>(_ location: L, _ content: @escaping () -> (Data)) {
        self.location = L.storage(for: location)
        self.content = .simpleData(content)
    }

    public init<L: WriteToFileLocation>(_ location: Pantry.KeyPath<L>, _ content: @escaping () -> (Data)) {
        self.location = L.keyPathStorage(for: location)
        self.content = .simpleData(content)
    }

    public init<L: WriteToFileLocation>(_ location: Pantry.KeyPath<L?>, _ content: @escaping () -> (Data)) {
        self.location = L.optionalKeyPathStorage(for: location)
        self.content = .simpleData(content)
    }

    public init<L: WriteToFileLocation>(_ location: L, _ content: @escaping (_ pantry: Pantry) -> (Data)) {
        self.location = L.storage(for: location)
        self.content = .complexData(content)
    }

    public init<L: WriteToFileLocation>(_ location: Pantry.KeyPath<L>, _ content: @escaping (_ pantry: Pantry) -> (Data)) {
        self.location = L.keyPathStorage(for: location)
        self.content = .complexData(content)
    }

    public init<L: WriteToFileLocation>(_ location: Pantry.KeyPath<L?>, _ content: @escaping (_ pantry: Pantry) -> (Data)) {
        self.location = L.optionalKeyPathStorage(for: location)
        self.content = .complexData(content)
    }

    public init<L: WriteToFileLocation>(_ location: L, format: String, _ values: String...) {
        self.location = L.storage(for: location)
        self.content = .formattedString(format, values)
    }

    public init<L: WriteToFileLocation>(_ location: L, format: String, _ values: [String]) {
        self.location = L.storage(for: location)
        self.content = .formattedString(format, values)
    }

    public init<L: WriteToFileLocation>(_ location: Pantry.KeyPath<L>, format: String, _ values: String...) {
        self.location = L.keyPathStorage(for: location)
        self.content = .formattedString(format, values)
    }

    public init<L: WriteToFileLocation>(_ location: Pantry.KeyPath<L>, format: String, _ values: [String]) {
        self.location = L.keyPathStorage(for: location)
        self.content = .formattedString(format, values)
    }

    public init<L: WriteToFileLocation>(_ location: Pantry.KeyPath<L?>, format: String, _ values: String...) {
        self.location = L.optionalKeyPathStorage(for: location)
        self.content = .formattedString(format, values)
    }

    public init<L: WriteToFileLocation>(_ location: Pantry.KeyPath<L?>, format: String, _ values: [String]) {
        self.location = L.optionalKeyPathStorage(for: location)
        self.content = .formattedString(format, values)
    }

    public init<L: WriteToFileLocation>(_ location: L, format: String, _ values: Pantry.KeyPath<String>...) {
        self.location = L.storage(for: location)
        self.content = .formattedStringKeyPath(format, values)
    }

    public init<L: WriteToFileLocation>(_ location: L, format: String, _ values: [Pantry.KeyPath<String>]) {
        self.location = L.storage(for: location)
        self.content = .formattedStringKeyPath(format, values)
    }

    public init<L: WriteToFileLocation>(_ location: Pantry.KeyPath<L>, format: String, _ values: Pantry.KeyPath<String>...) {
        self.location = L.keyPathStorage(for: location)
        self.content = .formattedStringKeyPath(format, values)
    }

    public init<L: WriteToFileLocation>(_ location: Pantry.KeyPath<L>, format: String, _ values: [Pantry.KeyPath<String>]) {
        self.location = L.keyPathStorage(for: location)
        self.content = .formattedStringKeyPath(format, values)
    }

    public init<L: WriteToFileLocation>(_ location: Pantry.KeyPath<L?>, format: String, _ values: Pantry.KeyPath<String>...) {
        self.location = L.optionalKeyPathStorage(for: location)
        self.content = .formattedStringKeyPath(format, values)
    }

    public init<L: WriteToFileLocation>(_ location: Pantry.KeyPath<L?>, format: String, _ values: [Pantry.KeyPath<String>]) {
        self.location = L.optionalKeyPathStorage(for: location)
        self.content = .formattedStringKeyPath(format, values)
    }

    // public init<L: WriteToFileLocation>(_ location: L, _ content: @escaping () -> (InputStream)) {
    //     self.location = L.storage(for: location)
    //     self.content = .simpleStream(content)
    // }

    // public init<L: WriteToFileLocation>(_ location: Pantry.KeyPath<L>, _ content: @escaping () -> (InputStream)) {
    //     self.location = L.keyPathStorage(for: location)
    //     self.content = .simpleStream(content)
    // }

    // public init<L: WriteToFileLocation>(_ location: Pantry.KeyPath<L?>, _ content: @escaping () -> (InputStream)) {
    //     self.location = L.optionalKeyPathStorage(for: location)
    //     self.content = .simpleStream(content)
    // }

    // public init<L: WriteToFileLocation>(_ location: L, _ content: @escaping (_ pantry: Pantry) -> (InputStream)) {
    //     self.location = L.storage(for: location)
    //     self.content = .complexStream(content)
    // }

    // public init<L: WriteToFileLocation>(_ location: Pantry.KeyPath<L>, _ content: @escaping (_ pantry: Pantry) -> (InputStream)) {
    //     self.location = L.keyPathStorage(for: location)
    //     self.content = .complexStream(content)
    // }

    // public init<L: WriteToFileLocation>(_ location: Pantry.KeyPath<L?>, _ content: @escaping (_ pantry: Pantry) -> (InputStream)) {
    //     self.location = L.optionalKeyPathStorage(for: location)
    //     self.content = .complexStream(content)
    // }

    public func perform(in kitchen: Kitchen, pantry: Pantry) async throws {
        guard let url = location.url(kitchen: kitchen, pantry: pantry) else { return }
        try await content.write(to: url, pantry: pantry)
    }
}
