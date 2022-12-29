//
//  WriteFile.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 28.12.2022
//

import Foundation
import SystemPackage

public struct WriteFile: BlockingRecipe {
    enum LocationStorage {
        case string(String)
        case stringKeyPath(Pantry.KeyPath<String>)
        case urlKeyPath(Pantry.KeyPath<URL>)
        case pathKeyPath(Pantry.KeyPath<FilePath>)

        func url(kitchen: any Kitchen, pantry: Pantry) -> URL {
            switch self {
                case .string(let content):
                    let path = FilePath(content)
                    return path.toURL(workingDirectory: kitchen.currentDirectory)
            
                case .stringKeyPath(let content):
                    let path = FilePath(pantry[keyPath: content])
                    return path.toURL(workingDirectory: kitchen.currentDirectory)

                case .urlKeyPath(let content):
                    return pantry[keyPath: content]

                case .pathKeyPath(let content):
                    let path = pantry[keyPath: content]
                    return path.toURL(workingDirectory: kitchen.currentDirectory)
            }
        }
    }

    enum ContentStorage {
        case string(String)
        case stringKeyPath(Pantry.KeyPath<String>)
        case simpleString(() -> (String))
        case complexString((_ pantry: Pantry) -> (String))
        case data(Data)
        case dataKeyPath(Pantry.KeyPath<Data>)
        case simpleData(() -> (Data))
        case complexData((_ pantry: Pantry) -> (Data))
        case formattedString(String, [String])
        case formattedStringKeyPath(String, [Pantry.KeyPath<String>])

        // written this way to have ability to extend it with streams in future
        func write(to url: URL, pantry: Pantry) async throws {
            switch self {
                case .string(let content):
                    try content.data(using: .utf8)!.write(to: url, options: .atomic)
          
                case .stringKeyPath(let content):
                    try pantry[keyPath: content].data(using: .utf8)!.write(to: url, options: .atomic)
          
                case .simpleString(let content):
                    try content().data(using: .utf8)!.write(to: url, options: .atomic)
          
                case .complexString(let content):
                    try content(pantry).data(using: .utf8)!.write(to: url, options: .atomic)
          
                case .data(let content):
                    try content.write(to: url, options: .atomic)
          
                case .dataKeyPath(let content):
                    try pantry[keyPath: content].write(to: url, options: .atomic)
          
                case .simpleData(let content):
                    try content().write(to: url, options: .atomic)
          
                case .complexData(let content):
                    try content(pantry).write(to: url, options: .atomic)

                case .formattedString(let format, let content):
                    try format.asCuisineFormat(with: content).data(using: .utf8)!.write(to: url, options: .atomic)

                case .formattedStringKeyPath(let format, let content):
                    let content = content.map { pantry[keyPath: $0] }
                    try format.asCuisineFormat(with: content).data(using: .utf8)!.write(to: url, options: .atomic)
            }
        }
    }

    let location: LocationStorage
    let content: ContentStorage
  
    public init(_ location: String, _ content: String) {
        self.location = .string(location)
        self.content = .string(content)
    }

    public init(_ location: String, _ content: Pantry.KeyPath<String>) {
        self.location = .string(location)
        self.content = .stringKeyPath(content)
    }

    public init(_ location: String, _ content: @escaping () -> (String)) {
        self.location = .string(location)
        self.content = .simpleString(content)
    }

    public init(_ location: String, _ content: @escaping (_ pantry: Pantry) -> (String)) {
        self.location = .string(location)
        self.content = .complexString(content)
    }

    public init(_ location: String, _ content: Data) {
        self.location = .string(location)
        self.content = .data(content)
    }

    public init(_ location: String, _ content: Pantry.KeyPath<Data>) {
        self.location = .string(location)
        self.content = .dataKeyPath(content)
    }

    public init(_ location: String, _ content: @escaping () -> (Data)) {
        self.location = .string(location)
        self.content = .simpleData(content)
    }

    public init(_ location: String, _ content: @escaping (_ pantry: Pantry) -> (Data)) {
        self.location = .string(location)
        self.content = .complexData(content)
    }

    public init(_ location: String, format: String, _ values: String...) {
        self.location = .string(location)
        self.content = .formattedString(format, values)
    }

    public init(_ location: String, format: String, _ values: [String]) {
        self.location = .string(location)
        self.content = .formattedString(format, values)
    }

    public init(_ location: String, format: String, _ values: Pantry.KeyPath<String>...) {
        self.location = .string(location)
        self.content = .formattedStringKeyPath(format, values)
    }

    public init(_ location: String, format: String, _ values: [Pantry.KeyPath<String>]) {
        self.location = .string(location)
        self.content = .formattedStringKeyPath(format, values)
    }

    public init(_ location: Pantry.KeyPath<String>, _ content: String) {
        self.location = .stringKeyPath(location)
        self.content = .string(content)
    }

    public init(_ location: Pantry.KeyPath<String>, _ content: Pantry.KeyPath<String>) {
        self.location = .stringKeyPath(location)
        self.content = .stringKeyPath(content)
    }

    public init(_ location: Pantry.KeyPath<String>, _ content: @escaping () -> (String)) {
        self.location = .stringKeyPath(location)
        self.content = .simpleString(content)
    }

    public init(_ location: Pantry.KeyPath<String>, _ content: @escaping (_ pantry: Pantry) -> (String)) {
        self.location = .stringKeyPath(location)
        self.content = .complexString(content)
    }

    public init(_ location: Pantry.KeyPath<String>, _ content: Data) {
        self.location = .stringKeyPath(location)
        self.content = .data(content)
    }

    public init(_ location: Pantry.KeyPath<String>, _ content: Pantry.KeyPath<Data>) {
        self.location = .stringKeyPath(location)
        self.content = .dataKeyPath(content)
    }

    public init(_ location: Pantry.KeyPath<String>, _ content: @escaping () -> (Data)) {
        self.location = .stringKeyPath(location)
        self.content = .simpleData(content)
    }

    public init(_ location: Pantry.KeyPath<String>, _ content: @escaping (_ pantry: Pantry) -> (Data)) {
        self.location = .stringKeyPath(location)
        self.content = .complexData(content)
    }

    public init(_ location: Pantry.KeyPath<String>, format: String, _ values: String...) {
        self.location = .stringKeyPath(location)
        self.content = .formattedString(format, values)
    }

    public init(_ location: Pantry.KeyPath<String>, format: String, _ values: [String]) {
        self.location = .stringKeyPath(location)
        self.content = .formattedString(format, values)
    }

    public init(_ location: Pantry.KeyPath<String>, format: String, _ values: Pantry.KeyPath<String>...) {
        self.location = .stringKeyPath(location)
        self.content = .formattedStringKeyPath(format, values)
    }

    public init(_ location: Pantry.KeyPath<String>, format: String, _ values: [Pantry.KeyPath<String>]) {
        self.location = .stringKeyPath(location)
        self.content = .formattedStringKeyPath(format, values)
    }

    public init(_ location: Pantry.KeyPath<URL>, _ content: String) {
        self.location = .urlKeyPath(location)
        self.content = .string(content)
    }

    public init(_ location: Pantry.KeyPath<URL>, _ content: Pantry.KeyPath<String>) {
        self.location = .urlKeyPath(location)
        self.content = .stringKeyPath(content)
    }

    public init(_ location: Pantry.KeyPath<URL>, _ content: @escaping () -> (String)) {
        self.location = .urlKeyPath(location)
        self.content = .simpleString(content)
    }

    public init(_ location: Pantry.KeyPath<URL>, _ content: @escaping (_ pantry: Pantry) -> (String)) {
        self.location = .urlKeyPath(location)
        self.content = .complexString(content)
    }

    public init(_ location: Pantry.KeyPath<URL>, _ content: Data) {
        self.location = .urlKeyPath(location)
        self.content = .data(content)
    }

    public init(_ location: Pantry.KeyPath<URL>, _ content: Pantry.KeyPath<Data>) {
        self.location = .urlKeyPath(location)
        self.content = .dataKeyPath(content)
    }

    public init(_ location: Pantry.KeyPath<URL>, _ content: @escaping () -> (Data)) {
        self.location = .urlKeyPath(location)
        self.content = .simpleData(content)
    }

    public init(_ location: Pantry.KeyPath<URL>, _ content: @escaping (_ pantry: Pantry) -> (Data)) {
        self.location = .urlKeyPath(location)
        self.content = .complexData(content)
    }

    public init(_ location: Pantry.KeyPath<URL>, format: String, _ values: String...) {
        self.location = .urlKeyPath(location)
        self.content = .formattedString(format, values)
    }

    public init(_ location: Pantry.KeyPath<URL>, format: String, _ values: [String]) {
        self.location = .urlKeyPath(location)
        self.content = .formattedString(format, values)
    }
  
    public init(_ location: Pantry.KeyPath<URL>, format: String, _ values: Pantry.KeyPath<String>...) {
        self.location = .urlKeyPath(location)
        self.content = .formattedStringKeyPath(format, values)
    }

    public init(_ location: Pantry.KeyPath<URL>, format: String, _ values: [Pantry.KeyPath<String>]) {
        self.location = .urlKeyPath(location)
        self.content = .formattedStringKeyPath(format, values)
    }

    public init(_ location: Pantry.KeyPath<FilePath>, _ content: String) {
        self.location = .pathKeyPath(location)
        self.content = .string(content)
    }

    public init(_ location: Pantry.KeyPath<FilePath>, _ content: Pantry.KeyPath<String>) {
        self.location = .pathKeyPath(location)
        self.content = .stringKeyPath(content)
    }

    public init(_ location: Pantry.KeyPath<FilePath>, _ content: @escaping () -> (String)) {
        self.location = .pathKeyPath(location)
        self.content = .simpleString(content)
    }

    public init(_ location: Pantry.KeyPath<FilePath>, _ content: @escaping (_ pantry: Pantry) -> (String)) {
        self.location = .pathKeyPath(location)
        self.content = .complexString(content)
    }

    public init(_ location: Pantry.KeyPath<FilePath>, _ content: Data) {
        self.location = .pathKeyPath(location)
        self.content = .data(content)
    }

    public init(_ location: Pantry.KeyPath<FilePath>, _ content: Pantry.KeyPath<Data>) {
        self.location = .pathKeyPath(location)
        self.content = .dataKeyPath(content)
    }

    public init(_ location: Pantry.KeyPath<FilePath>, _ content: @escaping () -> (Data)) {
        self.location = .pathKeyPath(location)
        self.content = .simpleData(content)
    }

    public init(_ location: Pantry.KeyPath<FilePath>, _ content: @escaping (_ pantry: Pantry) -> (Data)) {
        self.location = .pathKeyPath(location)
        self.content = .complexData(content)
    }

    public init(_ location: Pantry.KeyPath<FilePath>, format: String, _ values: String...) {
        self.location = .pathKeyPath(location)
        self.content = .formattedString(format, values)
    }

    public init(_ location: Pantry.KeyPath<FilePath>, format: String, _ values: [String]) {
        self.location = .pathKeyPath(location)
        self.content = .formattedString(format, values)
    }

    public init(_ location: Pantry.KeyPath<FilePath>, format: String, _ values: Pantry.KeyPath<String>...) {
        self.location = .pathKeyPath(location)
        self.content = .formattedStringKeyPath(format, values)
    }

    public init(_ location: Pantry.KeyPath<FilePath>, format: String, _ values: [Pantry.KeyPath<String>]) {
        self.location = .pathKeyPath(location)
        self.content = .formattedStringKeyPath(format, values)
    }

    public func perform(in kitchen: Kitchen, pantry: Pantry) async throws {
        let url = location.url(kitchen: kitchen, pantry: pantry)
        try await content.write(to: url, pantry: pantry)
    }
}
