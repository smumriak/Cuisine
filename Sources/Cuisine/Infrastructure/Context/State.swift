//
//  State.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 30.12.2022
//

import TinyFoundation

@propertyWrapper
public final class State<Value>: Hashable {
    @Synchronized
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public var projectedValue: State<Value> { self }

    public static func == (lhs: State<Value>, rhs: State<Value>) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    public func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
    }
}

extension State: Codable where Value: Codable {
    enum CodingKeys: String, CodingKey {
        case wrappedValue
    }

    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(wrappedValue: values.decode(Value.self, forKey: .wrappedValue))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(wrappedValue, forKey: .wrappedValue)
    }
}
