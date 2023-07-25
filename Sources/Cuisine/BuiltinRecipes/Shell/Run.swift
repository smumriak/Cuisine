//
//  Run.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 23.09.2022
//

import ShellOut

public struct Run: Recipe {
    @resultBuilder
    public enum Builder {
        public static func buildBlock(_ component: String) -> [String] {
            [component]
        }

        public static func buildBlock(_ components: [String]) -> [String] {
            components
        }

        public static func buildBlock(_ components: String...) -> [String] {
            components
        }

        public static func buildOptional(_ component: [String]?) -> [String] {
            return component ?? []
        }

        public static func buildEither(first component: [String]) -> [String] {
            return component
        }

        public static func buildEither(second component: [String]) -> [String] {
            return component
        }

        public static func buildArray(_ components: [[String]]) -> [String] {
            return components.flatMap { $0 }
        }

        public static func buildFinalResult(_ component: [String]) -> [String] {
            component
        }
    }

    public let isBlocking: Bool
    let command: String

    enum Storage {
        case stringArray(content: [String])
        case simple(content: () -> ([String]))
        case complex(content: (_ pantry: Pantry) -> ([String]))
    }

    let storage: Storage

    public init(_ command: String, argument: String, blocking: Bool = true) {
        self.command = command
        storage = .stringArray(content: [argument])
        isBlocking = blocking
    }

    public init(_ command: String, arguments: [String], blocking: Bool = true) {
        self.command = command
        storage = .stringArray(content: arguments)
        isBlocking = blocking
    }

    public init(_ command: String, blocking: Bool = true, @Builder _ content: @escaping () -> (String)) {
        self.command = command
        storage = .simple { [content()] }
        isBlocking = blocking
    }

    public init(_ command: String, blocking: Bool = true, @Builder _ content: @escaping () -> ([String]) = { return [] }) {
        self.command = command
        storage = .simple(content: content)
        isBlocking = blocking
    }

    public init(_ command: String, blocking: Bool = true, @Builder _ content: @escaping (_ pantry: Pantry) -> (String)) {
        self.command = command
        storage = .complex { [content($0)] }
        isBlocking = blocking
    }

    public init(_ command: String, blocking: Bool = true, @Builder _ content: @escaping (_ pantry: Pantry) -> ([String])) {
        self.command = command
        storage = .complex(content: content)
        isBlocking = blocking
    }

    public func perform(in kitchen: any Kitchen, pantry: Pantry) async throws {
        let arguments: [String]
        switch storage {
            case let .stringArray(content):
                arguments = content

            case let .simple(content):
                arguments = content()

            case let .complex(content):
                arguments = content(pantry)
        }
        let output = try shellOut(to: command, arguments: arguments, at: kitchen.currentDirectory.string)
        print(output)
    }
}
