//
//  Map.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 27.12.2022
//

public struct Map<Input, Output>: Recipe {
    public typealias Body = (Input) async throws -> (Output)
    internal enum Storage {
        case value(value: Input)
        case keyPath(keyPath: Pantry.KeyPath<Input>)
    }

    let storage: Storage
    let body: Body
    let output: Pantry.KeyPath<Output>
    public let isBlocking: Bool

    public init(_ value: Input, to output: Pantry.KeyPath<Output>, blocking: Bool = true, _ body: @escaping Body) {
        storage = .value(value: value)
        self.output = output
        isBlocking = blocking
        self.body = body
    }

    public init(_ keyPath: Pantry.KeyPath<Input>, to output: Pantry.KeyPath<Output>, blocking: Bool = true, _ body: @escaping Body) {
        storage = .keyPath(keyPath: keyPath)
        self.output = output
        isBlocking = blocking
        self.body = body
    }

    public func perform(in kitchen: Kitchen, pantry: Pantry) async throws {
        let input: Input
        switch storage {
            case .value(let value):
                input = value

            case .keyPath(let keyPath):
                input = pantry[keyPath: keyPath]
        }
        pantry[keyPath: output] = try await body(input)
    }
}
