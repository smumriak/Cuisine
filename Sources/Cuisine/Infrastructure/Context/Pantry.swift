//
//  Pantry.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 23.12.2022
//

@_spi(Reflection) import ReflectionMirror
import TinyFoundation

// smumriak:could have been actor, but swift decided NOT TO support keypaths for actors
// smumriak:thinking about this more: it's *better* to have unfairly locked synchronization here because it removes time inconsistency of sending messages to actors from different tasks
public final class Pantry: Codable {
    public init() {}
    public subscript<K: PantryKey>(key: K.Type) -> K.Value {
        get {
            if let result = elements[ObjectIdentifier(key)] as? K.Value {
                return result
            } else {
                return key.defaultValue
            }
        }
        set {
            elements[ObjectIdentifier(key)] = newValue
        }
    }

    @Synchronized
    private var elements: [ObjectIdentifier: Any] = [:]

    // Fake codable to make this work as stored property for now. This should be properly codable tho
    public init(from decoder: Decoder) throws {}
    public func encode(to encoder: Encoder) throws {}
}

internal protocol PantryItem {
    mutating func injectPantry(_ pantry: Pantry)
    mutating func clearPantry()
}

public extension Pantry {
    typealias KeyPath<Value> = ReferenceWritableKeyPath<Pantry, Value>

    @propertyWrapper
    struct Item<Value>: PantryItem {
        @usableFromInline
        final class Storage {
            @usableFromInline
            weak var pantry: Pantry!
        }

        @usableFromInline
        let storage = Storage()
        
        mutating func injectPantry(_ pantry: Pantry) {
            storage.pantry = pantry
        }

        mutating func clearPantry() {
            storage.pantry = nil
        }

        @inlinable @inline(__always)
        public var wrappedValue: Value {
            get {
                if keyPath == \Pantry.self {
                    return storage.pantry as! Value
                } else {
                    return storage.pantry[keyPath: keyPath]
                }
            }
            set {
                storage.pantry[keyPath: keyPath] = newValue
            }
        }
        
        @usableFromInline
        internal let keyPath: WritableKeyPath<Pantry, Value>

        public init(_ keyPath: WritableKeyPath<Pantry, Value>) {
            self.keyPath = keyPath
        }
    }
}

public protocol PantryKey: Hashable {
    associatedtype Value
    static var defaultValue: Self.Value { get }
}

internal extension Recipe {
    // smumriak:what you see here is some swift runtime magic. it works while it works and may be removed by swift engineers in future. but I'm 100% confident this is how SwiftUI works, so it's gonna stick for a while
    @_transparent
    func injectPantry(_ pantry: Pantry) {
        _forEachField(of: Self.self, options: [.ignoreUnknown]) { name, offset, type, metadataKind in
       
            func performPantryInjection<T: PantryItem>(_ openedType: T.Type) {
                withUnsafePointer(to: self) {
                    let mutablePointer = UnsafeMutablePointer(mutating: $0)
                    let address = UnsafeMutableRawPointer(mutablePointer) + offset
                    let pointer = address.assumingMemoryBound(to: T.self)
                    pointer.pointee.injectPantry(pantry)
                }
            }

            func project<T>(_ openedType: T.Type) {
                if let newType = T.self as? PantryItem.Type {
                    performPantryInjection(newType)
                }
            }
            
            _openExistential(type, do: project)

            return true
        }
    }
}
