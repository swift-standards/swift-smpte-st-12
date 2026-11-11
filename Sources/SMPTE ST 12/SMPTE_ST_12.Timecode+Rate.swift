public import Cardinal
public import Rate

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

extension SMPTE_ST_12.Timecode {
    /// The address of the frame `count` frames after 00:00:00:00 when frames arrive at exactly `rate` a
    /// second, counted the way `Rate.counting(_:)` says. Fails with `.uncounted` for a rate ST 12-1 does not count.
    public init(frame count: Cardinal, at rate: Rate::Rate) throws(SMPTE_ST_12.Timecode.Error) {
        guard let (nominal, counting) = Rate.counting(rate) else { throw .uncounted(rate) }
        try self.init(frame: count, rate: nominal, counting: counting)
    }
}
