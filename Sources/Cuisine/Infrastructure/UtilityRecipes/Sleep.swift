//
//  Sleep.swift
//  Cuisine
//
//  Created by Serhii Mumriak on 24.07.2023
//

public struct Sleep<C: Clock>: BlockingRecipe {
    let duration: C.Instant.Duration
    let tolerance: C.Instant.Duration?
    let clock: C

    public init(for duration: C.Instant.Duration, tolerance: C.Instant.Duration? = nil, clock: C = ContinuousClock()) {
        self.duration = duration
        self.tolerance = tolerance
        self.clock = clock
    }

    public func perform(in kitchen: Kitchen, pantry: Pantry) async throws {
        try await Task.sleep(for: duration, tolerance: tolerance, clock: clock)
    }
}
