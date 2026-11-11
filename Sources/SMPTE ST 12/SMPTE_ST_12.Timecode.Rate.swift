public import Rate

extension SMPTE_ST_12.Timecode {
    /// The whole nominal frame rates ST 12-1 counts at. 30 also counts 30000/1001 and 60 counts 60000/1001.
    public enum Rate: Sendable, Hashable, CaseIterable {
        case twentyFour
        case twentyFive
        case thirty
        case fortyEight
        case fifty
        case sixty
    }
}

extension SMPTE_ST_12.Timecode.Rate {
    /// Frames per counted second.
    public var nominal: Int {
        switch self {
        case .twentyFour: 24
        case .twentyFive: 25
        case .thirty: 30
        case .fortyEight: 48
        case .fifty: 50
        case .sixty: 60
        }
    }
}

extension SMPTE_ST_12.Timecode.Rate {
    /// The nominal rate that counts frames arriving at exactly `rate` a second, and how it counts them.
    ///
    /// A whole rate of 24, 25, 30, 48, 50 or 60 is counted at itself, every frame number used. The same
    /// rates slowed by 1000/1001 are counted at the whole rate too: 30000/1001 and 60000/1001 drop frame
    /// numbers, so the address keeps step with the clock, and the others (24000/1001, 48000/1001) do not,
    /// because drop-frame counting exists at 30 and 60 only. Any other rate has no time address.
    public static func counting(_ rate: Rate::Rate) -> (rate: Self, counting: SMPTE_ST_12.Timecode.Counting)? {
        for candidate in Self.allCases {
            if rate.perUnit == Rational(candidate.nominal) { return (candidate, .nonDrop) }
            if rate.perUnit * Rational(1001) == Rational(candidate.nominal * 1000) {
                return (candidate, candidate.nominal % 30 == 0 ? .drop : .nonDrop)
            }
        }
        return nil
    }
}
