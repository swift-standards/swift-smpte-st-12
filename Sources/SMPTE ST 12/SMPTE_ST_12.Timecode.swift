public import Cardinal

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
        public let counting: Counting
    }
}

extension SMPTE_ST_12.Timecode {
    /// The address of the frame `count` frames after 00:00:00:00.
    public init(frame count: Cardinal, rate: Rate, counting: Counting) throws(SMPTE_ST_12.Timecode.Error) {
        let nominal = rate.nominal
        let skipped = counting == .drop ? nominal / 15 : 0
        guard counting == .nonDrop || nominal % 30 == 0 else { throw .drop(rate) }
        let count = Int(clamping: count)
        var label = count
        if counting == .drop {
            let minute = nominal * 60 - skipped
            let tens = count / (minute * 10 + skipped)
            let rest = count % (minute * 10 + skipped)
            label += 9 * skipped * tens + (rest > skipped ? skipped * ((rest - skipped) / minute) : 0)
        }
        self.init(
            hours: label / (nominal * 3600) % 24,
            minutes: label / (nominal * 60) % 60,
            seconds: label / nominal % 60,
            frames: label % nominal,
            counting: counting
        )
    }

    /// How many frames this address lies after 00:00:00:00, the inverse of `init(frame:rate:counting:)`.
    public func frame(at rate: Rate) -> Cardinal {
        let nominal = rate.nominal
        let minutes = 60 * hours + self.minutes
        let label = ((minutes * 60) + seconds) * nominal + frames
        let count = counting == .drop ? label - nominal / 15 * (minutes - minutes / 10) : label
        return Cardinal(UInt(count))
    }
}

extension SMPTE_ST_12.Timecode: CustomStringConvertible {
    public var description: String {
        func two(_ value: Int) -> String { value < 10 ? "0\(value)" : "\(value)" }
        return "\(two(hours)):\(two(minutes)):\(two(seconds))\(counting == .drop ? ";" : ":")\(two(frames))"
    }
}
