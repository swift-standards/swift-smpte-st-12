extension SMPTE_ST_12.Timecode {
    public enum Counting: Sendable, Hashable {
        /// Every frame number is used.
        case nonDrop
        /// Frame numbers are skipped each minute but every tenth, at 30 and 60 only.
        case drop
    }
}
