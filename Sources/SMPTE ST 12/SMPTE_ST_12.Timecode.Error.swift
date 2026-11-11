public import Rate

extension SMPTE_ST_12.Timecode {
    public enum Error: Swift.Error, Sendable, Hashable {
        /// Drop-frame counting is defined at nominal rates of 30 and 60 only.
        case drop(Rate)
        /// ST 12-1 counts whole rates of 24, 25, 30, 48, 50 and 60 and the same rates slowed by 1000/1001, and no other.
        case uncounted(Rate::Rate)
    }
}
