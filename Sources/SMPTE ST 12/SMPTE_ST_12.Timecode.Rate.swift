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
