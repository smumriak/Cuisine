//
//  Map.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 27.12.2022
//

public struct Map<Input, Output>: Recipe {
    public typealias Body = (Input, Kitchen, Pantry) async throws -> (Output)

    @usableFromInline
    internal enum InputStorage {
        case value(Input)
        case keyPath(Pantry.KeyPath<Input>)
        case state(State<Input>)

        @_transparent
        func value(in kitchen: Kitchen, pantry: Pantry, body: Body) async throws -> Output {
            let input: Input
            switch self {
                case .value(let value):
                    input = value

                case .keyPath(let keyPath):
                    input = pantry[keyPath: keyPath]

                case .state(let state):
                    input = state.wrappedValue
            }

            return try await body(input, kitchen, pantry)
        }
    }

    @usableFromInline
    internal enum OutputStorage {
        case keyPath(Pantry.KeyPath<Output>)
        case state(State<Output>)

        @_transparent
        func store(value: Output, pantry: Pantry) {
            switch self {
                case .keyPath(let content): pantry[keyPath: content] = value
                case .state(let content): content.wrappedValue = value
            }
        }
    }

    let input: InputStorage
    let body: Body
    let output: OutputStorage
    public let isBlocking: Bool

    @_transparent
    public init(_ value: Input, to output: Pantry.KeyPath<Output>, blocking: Bool = true, _ body: @escaping Body) {
        self.init(.value(value), to: .keyPath(output), blocking: blocking, body)
    }

    @_transparent
    public init(_ keyPath: Pantry.KeyPath<Input>, to output: Pantry.KeyPath<Output>, blocking: Bool = true, _ body: @escaping Body) {
        self.init(.keyPath(keyPath), to: .keyPath(output), blocking: blocking, body)
    }

    @_transparent
    public init(_ state: State<Input>, to output: Pantry.KeyPath<Output>, blocking: Bool = true, _ body: @escaping Body) {
        self.init(.state(state), to: .keyPath(output), blocking: blocking, body)
    }

    @_transparent
    public init(_ value: Input, to output: State<Output>, blocking: Bool = true, _ body: @escaping Body) {
        self.init(.value(value), to: .state(output), blocking: blocking, body)
    }

    @_transparent
    public init(_ keyPath: Pantry.KeyPath<Input>, to output: State<Output>, blocking: Bool = true, _ body: @escaping Body) {
        self.init(.keyPath(keyPath), to: .state(output), blocking: blocking, body)
    }

    @_transparent
    public init(_ state: State<Input>, to output: State<Output>, blocking: Bool = true, _ body: @escaping Body) {
        self.init(.state(state), to: .state(output), blocking: blocking, body)
    }

    @usableFromInline
    internal init(_ input: InputStorage, to output: OutputStorage, blocking: Bool, _ body: @escaping Body) {
        self.input = input
        self.output = output
        isBlocking = blocking
        self.body = body
    }

    public func perform(in kitchen: Kitchen, pantry: Pantry) async throws {
        let value = try await input.value(in: kitchen, pantry: pantry, body: body)
        output.store(value: value, pantry: pantry)
    }
}
