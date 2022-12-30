//
//  GetFile.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 22.09.2022
//

import Foundation
import FoundationNetworking
import SystemPackage

public struct GetFile: Recipe {
    public enum Error: Swift.Error {
        case badResponseType(url: URL)
        case fileCreationFailed(url: URL)
        case badResponseCode(url: URL, code: Int)
    }

    internal let url: URL
    var urls: [URL] { [url] }

    enum KeyPathStorage {
        case optional(_ keyPath: Pantry.KeyPath<String?>)
        case nonOptional(_ keyPath: Pantry.KeyPath<String>)

        func store(value: String, in pantry: Pantry) {
            switch self {
                case .optional(let keyPath):
                    pantry[keyPath: keyPath] = value

                case .nonOptional(let keyPath):
                    pantry[keyPath: keyPath] = value
            }
        }
    }

    internal var nameKeyPath: KeyPathStorage?

    public let isBlocking: Bool

    public init(_ url: URL, blocking: Bool = true, storeNameIn keyPath: Pantry.KeyPath<String>? = nil) {
        self.url = url
        isBlocking = blocking
        if let keyPath {
            nameKeyPath = .nonOptional(keyPath)
        }
    }

    public init(_ url: URL, blocking: Bool = true, storeNameIn keyPath: Pantry.KeyPath<String?>) {
        self.url = url
        isBlocking = blocking
        nameKeyPath = .optional(keyPath)
    }

    public init(_ urlString: some StringProtocol, blocking: Bool = true, storeNameIn keyPath: Pantry.KeyPath<String>? = nil) {
        self.init(URL(string: String(urlString))!, blocking: blocking, storeNameIn: keyPath)
    }

    public func perform(in kitchen: any Kitchen, pantry: Pantry) async throws {
        let fileManager = FileManager.default

        if url.isFileURL {
            let destinationURL = kitchen.currentDirectory.appendingPathComponent(url.lastPathComponent)
            try fileManager.moveItem(at: url, to: destinationURL)
        } else {
            let suggestedFilename = url.lastPathComponent

            let (fileURL, _) = try await kitchen.urlSession.downloadFile(at: url)

            let destinationURL = kitchen.currentDirectory.appendingPathComponent(suggestedFilename)
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.moveItem(at: fileURL, to: destinationURL)

            nameKeyPath?.store(value: suggestedFilename, in: pantry)
        }
    }
}

extension URLSession {
    func downloadFile(at url: URL) async throws -> (URL, URLResponse) {
        try await withUnsafeThrowingContinuation { continuation in
            let downloadTask = downloadTask(with: url) { fileURL, response, error in
                if let error {
                    continuation.resume(throwing: error)
                }

                guard let response = response as? HTTPURLResponse else {
                    continuation.resume(throwing: GetFile.Error.badResponseType(url: url))
                    return
                }
                guard (200..<299).contains(response.statusCode) else {
                    continuation.resume(throwing: GetFile.Error.badResponseCode(url: url, code: response.statusCode))
                    return
                }

                guard let fileURL else {
                    continuation.resume(throwing: GetFile.Error.fileCreationFailed(url: url))
                    return
                }

                continuation.resume(returning: (fileURL, response))
            }
            downloadTask.resume()
        }
    }
}

public struct MultiFileGet: Recipe {
    @resultBuilder
    public struct Builder {
        public static func buildExpression(_ strings: String...) -> [URL] {
            return strings.map { URL(string: $0)! }
        }

        public static func buildBlock(_ components: [URL]...) -> [URL] {
            return components.flatMap { $0 }
        }

        public static func buildOptional(_ component: [URL]?) -> [URL] {
            return component ?? []
        }

        public static func buildEither(first component: [URL]) -> [URL] {
            return component
        }

        public static func buildEither(second component: [URL]) -> [URL] {
            return component
        }

        public static func buildArray(_ components: [[URL]]) -> [URL] {
            return components.flatMap { $0 }
        }

        public static func buildFinalResult(_ component: [URL]) -> [URL] {
            component
        }
    }

    let urls: [URL]
    public let isBlocking: Bool

    public init(blocking: Bool = true, @Builder _ content: () -> ([URL])) {
        urls = content()
        isBlocking = blocking
    }

    public func perform(in kitchen: any Kitchen, pantry: Pantry) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            download(&group, kitchen: kitchen)
            
            try await group.waitForAll()
        }
    }

    func download(_ group: inout ThrowingTaskGroup<Void, any Swift.Error>, kitchen: Kitchen) {
        let fileManager = FileManager.default

        let fileURLs = urls.filter { $0.isFileURL }
        let remoteURLs = urls.filter { !$0.isFileURL }

        for url in fileURLs {
            group.addTask {
                let destinationURL = kitchen.currentDirectory.appendingPathComponent(url.lastPathComponent)
                try fileManager.moveItem(at: url, to: destinationURL)
            }
        }

        for url in remoteURLs {
            group.addTask {
                let suggestedFilename = url.lastPathComponent

                let (fileURL, _) = try await kitchen.urlSession.downloadFile(at: url)

                let destinationURL = kitchen.currentDirectory.appendingPathComponent(suggestedFilename)
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                try fileManager.moveItem(at: fileURL, to: destinationURL)
            }
        }
    }
}

public extension GetFile {
    struct StoreNameInModifier: RecipeModifier {
        let storage: GetFile.KeyPathStorage

        init(keyPath: Pantry.KeyPath<String>) {
            storage = .nonOptional(keyPath)
        }

        init(keyPath: Pantry.KeyPath<String?>) {
            storage = .optional(keyPath)
        }
        
        public func body(content: GetFile) -> some Recipe {
            var copy = content
            copy.nameKeyPath = storage
            return copy
        }
    }

    func storeName(in keyPath: Pantry.KeyPath<String>) -> some Recipe {
        modifier(StoreNameInModifier(keyPath: keyPath))
    }

    func storeName(in keyPath: Pantry.KeyPath<String?>) -> some Recipe {
        modifier(StoreNameInModifier(keyPath: keyPath))
    }
}
