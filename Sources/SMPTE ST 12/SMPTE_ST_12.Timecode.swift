public import Cardinal
public import Rate

extension SMPTE_ST_12 {
    /// A time address, hours:minutes:seconds:frames, counted at a whole nominal rate.
    ///
    /// With drop-frame counting, used at 30000/1001 and 60000/1001 frames per second, frame
    /// numbers 0 and 1 (0 to 3 at 60) are skipped at the start of every minute except every
    /// tenth, so the address keeps step with clock time. The separator before the frames is
    /// then a semicolon.
    public struct Timecode: Sendable, Hashable {
        public let hours: Int
        public let minutes: Int
        public let seconds: Int
        public let frames: Int
        /// The nominal count the address is counted at.
        public let nominal: Nominal
        public let counting: Counting
    }
}

extension SMPTE_ST_12.Timecode {
    /// The address of the frame `count` frames after 00:00:00:00.
    public init(frame count: Cardinal, nominal: Nominal, counting: Counting) throws(SMPTE_ST_12.Timecode.Error) {
        let perSecond = nominal.frames
        let skipped = counting == .drop ? perSecond / 15 : 0
        guard counting == .nonDrop || perSecond % 30 == 0 else { throw .drop(nominal) }
        let count = Int(clamping: count)
        var label = count
        if counting == .drop {
            let minute = perSecond * 60 - skipped
            let tens = count / (minute * 10 + skipped)
            let rest = count % (minute * 10 + skipped)
            label += 9 * skipped * tens + (rest > skipped ? skipped * ((rest - skipped) / minute) : 0)
        }
        self.init(
            hours: label / (perSecond * 3600) % 24,
            minutes: label / (perSecond * 60) % 60,
            seconds: label / perSecond % 60,
            frames: label % perSecond,
            nominal: nominal,
            counting: counting
        )
    }

    /// How many frames this address lies after 00:00:00:00 at its own nominal, the inverse of
    /// `init(frame:nominal:counting:)` for any frame within a day.
    public var frame: Cardinal {
        let perSecond = nominal.frames
        let minutes = 60 * hours + self.minutes
        let label = ((minutes * 60) + seconds) * perSecond + frames
        let count = counting == .drop ? label - perSecond / 15 * (minutes - minutes / 10) : label
        return Cardinal(UInt(count))
    }
}

extension SMPTE_ST_12.Timecode {
    /// The address of the frame `count` frames after 00:00:00:00 when frames arrive at exactly `rate` a
    /// second, counted the way `Nominal.counting(_:)` says. Fails with `.uncounted` for a rate ST 12-1 does not count.
    public init(frame count: Cardinal, at rate: Rate) throws(SMPTE_ST_12.Timecode.Error) {
        guard let (nominal, counting) = Nominal.counting(rate) else { throw .uncounted(rate) }
        try self.init(frame: count, nominal: nominal, counting: counting)
    }
}

extension SMPTE_ST_12.Timecode: CustomStringConvertible {
    public var description: String {
        func two(_ value: Int) -> String { value < 10 ? "0\(value)" : "\(value)" }
        return "\(two(hours)):\(two(minutes)):\(two(seconds))\(counting == .drop ? ";" : ":")\(two(frames))"
    }
}
