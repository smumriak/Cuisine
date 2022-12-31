//
//  FilePathOutput.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 30.12.2022
//

import Foundation
import FoundationNetworking
import SystemPackage

public protocol FilePathOutput {
    func store(filePath: String, pantry: Pantry, isDirectory: Bool)
}

extension Pantry.KeyPath: FilePathOutput where Value: FilePathStore, Root == Pantry {
    public func store(filePath: String, pantry: Pantry, isDirectory: Bool) {
        pantry[keyPath: self].store(filePath: filePath, pantry: pantry, isDirectory: isDirectory)
    }
}

extension State: FilePathOutput where Value: FilePathStore {
    public func store(filePath: String, pantry: Pantry, isDirectory: Bool) {
        wrappedValue.store(filePath: filePath, pantry: pantry, isDirectory: isDirectory)
    }
}
