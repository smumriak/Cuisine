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
        case unexpectedNilURL
        case badResponseType(url: URL)
        case fileCreationFailed(url: URL)
        case badResponseCode(url: URL, code: Int)
    }

    internal let location: any URLInput
    internal var pathOutput: (any FilePathOutput)?

    public let isBlocking: Bool

    public init<I: URLInput, O: FilePathOutput>(_ location: I, blocking: Bool = true, storePathIn pathOutput: O? = nil) {
        self.location = location
        isBlocking = blocking
        self.pathOutput = pathOutput
    }

    public func perform(in kitchen: any Kitchen, pantry: Pantry) async throws {
        guard let url = location.url(pantry: pantry) else {
            throw Error.unexpectedNilURL
        }

        let fileManager = FileManager.default

        let destinationURL: URL

        if url.isFileURL {
            destinationURL = kitchen.currentDirectory.appendingPathComponent(url.lastPathComponent)
            try fileManager.moveItem(at: url, to: destinationURL)
        } else {
            let suggestedFilename = url.lastPathComponent

            let (fileURL, _) = try await kitchen.urlSession.downloadFile(at: url)

            destinationURL = kitchen.currentDirectory.appendingPathComponent(suggestedFilename)
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.moveItem(at: fileURL, to: destinationURL)
        }

        pathOutput?.store(filePath: destinationURL.absoluteURL.path, pantry: pantry, isDirectory: destinationURL.hasDirectoryPath)
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
    struct StorePathInModifier: RecipeModifier {
        let storage: any FilePathOutput

        init<T: FilePathOutput>(storage: T) {
            self.storage = storage
        }
        
        public func body(content: GetFile) -> some Recipe {
            var copy = content
            copy.pathOutput = storage
            return copy
        }
    }

    func storePath<S: FilePathOutput>(in storage: S) -> some Recipe {
        modifier(StorePathInModifier(storage: storage))
    }
}
