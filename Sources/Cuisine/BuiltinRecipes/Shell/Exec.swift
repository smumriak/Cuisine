//
//  Exec.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 21.10.2023
//

import Foundation
import TinyFoundation
import SystemPackage

public struct Exec: Recipe {
    public let isBlocking: Bool
    let executable: String

    enum Storage {
        case stringArray(content: [String])
        case simple(content: () -> ([String]))
        case complex(content: (_ pantry: Pantry) -> ([String]))
    }

    let storage: Storage

    public init(_ executable: String, argument: String, blocking: Bool = true) {
        self.executable = executable
        storage = .stringArray(content: [argument])
        isBlocking = blocking
    }

    public init(_ executable: String, arguments: [String], blocking: Bool = true) {
        self.executable = executable
        storage = .stringArray(content: arguments)
        isBlocking = blocking
    }

    public init(_ executable: String, blocking: Bool = true, @Run.Builder _ content: @escaping () -> (String)) {
        self.executable = executable
        storage = .simple { [content()] }
        isBlocking = blocking
    }

    public init(_ executable: String, blocking: Bool = true, @Run.Builder _ content: @escaping () -> ([String]) = { return [] }) {
        self.executable = executable
        storage = .simple(content: content)
        isBlocking = blocking
    }

    public init(_ executable: String, blocking: Bool = true, @Run.Builder _ content: @escaping (_ pantry: Pantry) -> (String)) {
        self.executable = executable
        storage = .complex { [content($0)] }
        isBlocking = blocking
    }

    public init(_ executable: String, blocking: Bool = true, @Run.Builder _ content: @escaping (_ pantry: Pantry) -> ([String])) {
        self.executable = executable
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

        let pid = try spoonProcess(executablePath: FilePath(executable), arguments: arguments, environment: kitchen.env, workDirectoryPath: kitchen.currentDirectory)

        var status: CInt = 0
        if waitpid(pid, &status, 0) == -1 {
            fatalError()
        }
    }
}
