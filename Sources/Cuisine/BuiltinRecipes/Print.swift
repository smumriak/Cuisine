//
//  Print.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 23.09.2022
//

public struct Print: BlockingRecipe {
    @resultBuilder
    public enum Builder {
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
        case formattedStringKeyPath(String, [Pantry.KeyPath<String>])

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

                case .formattedStringKeyPath(let format, let keyPaths):
                    let strings = keyPaths.map {
                        pantry[keyPath: $0]
                    }

                    return format.asCuisineFormat(with: strings)
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
        storage = .formattedStringKeyPath(String(format), keyPaths)
    }

    public init(_ keyPath: Pantry.KeyPath<[String]>) {
        storage = .arrayKeyPath(keyPath)
    }

    public func perform(in kitchen: any Kitchen, pantry: Pantry) async throws {
        let text = storage.createText(pantry: pantry)
        print(text)
    }
}

public extension StringProtocol {
    func asCuisineFormat(with values: [String]) -> String {
        split(separator: "%@")
            .enumerated()
            .map { element in
                if element.offset < values.count {
                    return element.element + values[element.offset]
                } else {
                    return String(element.element)
                }
            }
            .joined()
    }

    func asCuisineFormat(with values: String...) -> String {
        asCuisineFormat(with: values)
    }
}
