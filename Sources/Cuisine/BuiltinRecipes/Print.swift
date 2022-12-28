//
//  Print.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 23.09.2022
//

public struct Print: BlockingRecipe {
    @resultBuilder
    public struct Builder {
        public static func buildExpression(_ expression: String...) -> [String] {
            return expression
        }

        public static func buildBlock(_ components: [String]...) -> [String] {
            return components.flatMap { $0 }
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

    enum Storage {
        case content(() -> ([String]))
        case stringKeyPath(Pantry.KeyPath<String>)
        case arrayKeyPath(Pantry.KeyPath<[String]>)
        case formattedString(String, [Pantry.KeyPath<String>])

        func createText(pantry: Pantry) -> String {
            switch self {
                case .content(let content):
                    return content().joined(separator: "\n")

                case .stringKeyPath(let keyPath):
                    let value = pantry[keyPath: keyPath]
                    return String(value)

                case .arrayKeyPath(let keyPath):
                    let value = pantry[keyPath: keyPath]
                    return value.map { String($0) }.joined(separator: "\n")

                case .formattedString(let format, let keyPaths):
                    return format.split(separator: "%@")
                        .enumerated()
                        .map { element in
                            if element.offset < keyPaths.count {
                                let value = pantry[keyPath: keyPaths[element.offset]]
                                return element.element + value
                            } else {
                                return element.element
                            }
                        }
                        .joined()
            }
        }
    }

    let storage: Storage

    public init(@Builder _ content: @escaping () -> ([String])) {
        storage = .content(content)
    }

    public init(_ strings: String...) {
        storage = .content { strings.map { $0 } }
    }

    public init(_ keyPath: Pantry.KeyPath<String>) {
        storage = .stringKeyPath(keyPath)
    }

    public init<T: StringProtocol>(format: T, _ keyPaths: Pantry.KeyPath<String>...) {
        storage = .formattedString(String(format), keyPaths)
    }

    public init(_ keyPath: Pantry.KeyPath<[String]>) {
        storage = .arrayKeyPath(keyPath)
    }

    public func perform(in kitchen: any Kitchen, pantry: Pantry) async throws {
        let text = storage.createText(pantry: pantry)
        print(text)
    }
}
