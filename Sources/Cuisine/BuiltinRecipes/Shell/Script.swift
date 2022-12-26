//
//  Script.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 23.09.2022
//

public struct Script: Recipe {
    let script: String
    public var isBlocking: Bool

    public init(_ script: String, blocking: Bool = true) {
        self.script = script
        isBlocking = blocking
    }

    public init(blocking: Bool = true, _ content: () -> (String)) {
        self.init(content(), blocking: blocking)
    }

    public func perform(in kitchen: any Kitchen, pantry: Pantry) async throws {
        let run = Run("eval") {
            script
        }

        try await run.injectingPerform(in: kitchen, pantry: pantry)
    }
}
