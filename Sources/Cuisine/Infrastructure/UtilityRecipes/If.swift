//
//  If.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 27.12.2022
//

public struct If: Recipe {
    public typealias Body = () async throws -> ()
    let body: Body
    public let isBlocking: Bool

    internal enum Storage {
        case keyPath(keyPath: Pantry.KeyPath<Bool>)
        case value(Bool)
        case expression(() -> (Bool))
    }

    let storage: Storage

    internal init(storage: Storage, blocking: Bool, body: @escaping Body) {
        self.storage = storage
        self.body = body
        isBlocking = blocking
    }

    public init(_ keyPath: Pantry.KeyPath<Bool>, blocking: Bool = true, _ body: @escaping Body) {
        self.init(storage: .keyPath(keyPath: keyPath), blocking: blocking, body: body)
    }

    public init(_ value: Bool, blocking: Bool = true, _ body: @escaping Body) {
        self.init(storage: .value(value), blocking: blocking, body: body)
    }

    public init(_ expression: @escaping () -> (Bool), blocking: Bool = true, _ body: @escaping Body) {
        self.init(storage: .expression(expression), blocking: blocking, body: body)
    }

    public func perform(in kitchen: Kitchen, pantry: Pantry) async throws {
        switch storage {
            case .keyPath(let keyPath) where pantry[keyPath: keyPath] == true:
                try await body()
                
            case .value(let value) where value == true:
                try await body()

            case .expression(let expression) where expression() == true:
                try await body()

            default:
                break
        }
    }
}
