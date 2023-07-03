//
//  Map.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 27.12.2022
//

public struct Map<Input, Output, InputStorage: InputArgument<Input>, OutputStorage: OutputArgument<Output>>: Recipe {
    public typealias Body = (Input, Kitchen, Pantry) async throws -> (Output)

    // smumriak: I tried to make this a generic init, but doing so will break type inference for provided KeyPath's. and it's never going to happen since it would be an unsolvable problem on compiler side
    let input: InputStorage
    let body: Body
    let output: OutputStorage
    public let isBlocking: Bool

    @_transparent
    public init(_ value: Input, to output: Pantry.KeyPath<Output>, blocking: Bool = true, _ body: @escaping Body) where InputStorage == ValueStorage<Input>, OutputStorage == Pantry.KeyPath<Output> {
        self.init(input: ValueStorage(value), to: output, blocking: blocking, body)
    }

    @_transparent
    public init(_ keyPath: Pantry.KeyPath<Input>, to output: Pantry.KeyPath<Output>, blocking: Bool = true, _ body: @escaping Body) where InputStorage == Pantry.KeyPath<Input>, OutputStorage == Pantry.KeyPath<Output> {
        self.init(input: keyPath, to: output, blocking: blocking, body)
    }

    @_transparent
    public init(_ state: State<Input>, to output: Pantry.KeyPath<Output>, blocking: Bool = true, _ body: @escaping Body) where InputStorage == State<Input>, OutputStorage == Pantry.KeyPath<Output> {
        self.init(input: state, to: output, blocking: blocking, body)
    }

    @_transparent
    public init(_ value: Input, to output: State<Output>, blocking: Bool = true, _ body: @escaping Body) where InputStorage == ValueStorage<Input>, OutputStorage == State<Output> {
        self.init(input: ValueStorage(value), to: output, blocking: blocking, body)
    }

    @_transparent
    public init(_ keyPath: Pantry.KeyPath<Input>, to output: State<Output>, blocking: Bool = true, _ body: @escaping Body) where InputStorage == Pantry.KeyPath<Input>, OutputStorage == State<Output> {
        self.init(input: keyPath, to: output, blocking: blocking, body)
    }

    @_transparent
    public init(_ state: State<Input>, to output: State<Output>, blocking: Bool = true, _ body: @escaping Body) where InputStorage == State<Input>, OutputStorage == State<Output> {
        self.init(input: state, to: output, blocking: blocking, body)
    }

    @usableFromInline
    internal init(input: InputStorage, to output: OutputStorage, blocking: Bool, _ body: @escaping Body) {
        self.input = input
        self.output = output
        isBlocking = blocking
        self.body = body
    }

    public func perform(in kitchen: Kitchen, pantry: Pantry) async throws {
        let value = try await body(input.value(in: kitchen, pantry: pantry), kitchen, pantry)
        try await output.store(value, kitchen: kitchen, pantry: pantry)
    }
}
