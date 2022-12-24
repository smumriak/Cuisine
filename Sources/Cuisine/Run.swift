//
//  Run.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 23.09.2022
//

import ShellOut

public struct Run: Recipe {
    @resultBuilder
    public struct Builder {
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

    public var isBlocking: Bool
    let command: String
    let arguments: [String]

    public init(_ command: String, blocking: Bool = true, @Builder _ content: () -> ([String]) = { return [] }) {
        self.command = command
        arguments = content()
        isBlocking = blocking
    }

    public func perform(in kitchen: any Kitchen, pantry: Pantry) async throws {
        let output = try shellOut(to: command, arguments: arguments, at: kitchen.currentDirectory.absoluteURL.path)
        print(output)
    }
}
