//
//  Kitchen.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 25.09.2022
//

import Foundation
import FoundationNetworking
import SystemPackage
import LinuxSys

public protocol Kitchen {
    var urlSession: URLSession { get }
    var env: [String: String] { get }
    var currentDirectory: URL { get }
    var currentShell: FilePath { get }
}

public extension Kitchen {
    var currentDirectory: FilePath {
        FilePath(currentDirectory.absoluteURL.path)
    }
}

public struct EmptyKitchen: Kitchen {
    private static let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)

    public init() {}
    public var urlSession: URLSession = .shared
    public var env: [String: String] = ProcessInfo.processInfo.environment
    public var currentDirectory: URL = EmptyKitchen.currentDirectory
    public var currentShell: FilePath = {
        guard let userInfo = getpwuid(geteuid() /* uid */ ) else {
            return "/bin/sh"
        }
        
        return FilePath(String(cString: userInfo.pointee.pw_shell))
    }()
}

public protocol Table: Kitchen {
    var kitchen: any Kitchen { get }
}

public extension Table {
    var urlSession: URLSession { kitchen.urlSession }
    var env: [String: String] { kitchen.env }
    var currentDirectory: URL { kitchen.currentDirectory }
    var currentShell: FilePath { kitchen.currentShell }
}
