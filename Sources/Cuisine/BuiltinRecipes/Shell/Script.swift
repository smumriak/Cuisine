//
//  Script.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 23.09.2022
//

public struct Script: Recipe {
    enum Storage {
        case stringArray(content: [String])
        case simple(content: () -> ([String]))
        case complex(content: (_ pantry: Pantry) -> ([String]))
    }

    let storage: Storage
    public let isBlocking: Bool

    public init(_ script: String, blocking: Bool = true) {
        storage = .stringArray(content: [script])
        isBlocking = blocking
    }

    public init(_ script: [String], blocking: Bool = true) {
        storage = .stringArray(content: script)
        isBlocking = blocking
    }

    public init(blocking: Bool = true, _ content: @escaping () -> (String)) {
        storage = .simple { [content()] }
        isBlocking = blocking
    }

    public init(blocking: Bool = true, _ content: @escaping () -> ([String])) {
        storage = .simple(content: content)
        isBlocking = blocking
    }

    public init(blocking: Bool = true, _ content: @escaping (_ pantry: Pantry) -> (String)) {
        storage = .complex { [content($0)] }
        isBlocking = blocking
    }

    public init(blocking: Bool = true, _ content: @escaping (_ pantry: Pantry) -> ([String])) {
        storage = .complex(content: content)
        isBlocking = blocking
    }

    public func perform(in kitchen: any Kitchen, pantry: Pantry) async throws {
        let script: [String]

        switch storage {
            case .stringArray(let content):
                script = content

            case .simple(let content):
                script = content()

            case .complex(let content):
                script = content(pantry)
        }

        try await Run("eval", argument: script.joined(separator: "\n"))
            .injectingPerform(in: kitchen, pantry: pantry)
    }
}
