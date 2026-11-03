extension SMPTE_ST_12.Timecode {
    public enum Error: Swift.Error, Sendable, Hashable {
        /// Drop-frame counting is defined at nominal rates of 30 and 60 only.
        case drop(Rate)
    }
}
