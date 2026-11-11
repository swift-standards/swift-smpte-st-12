import Cardinal
import Rate
import SMPTE_ST_12
import Testing

@Suite struct `Timecode Tests` {
    static func address(_ frame: UInt, _ rate: SMPTE_ST_12.Timecode.Rate, _ counting: SMPTE_ST_12.Timecode.Counting) throws -> String {
        try SMPTE_ST_12.Timecode(frame: Cardinal(frame), rate: rate, counting: counting).description
    }

    @Test func `29.97 drop-frame skips frames 0 and 1 each minute except every tenth`() throws {
        #expect(try Self.address(1799, .thirty, .drop) == "00:00:59;29")
        #expect(try Self.address(1800, .thirty, .drop) == "00:01:00;02")
        #expect(try Self.address(17_981, .thirty, .drop) == "00:09:59;29")
        #expect(try Self.address(17_982, .thirty, .drop) == "00:10:00;00")
        #expect(try Self.address(107_892, .thirty, .drop) == "01:00:00;00")
    }

    @Test func `59.94 drop-frame skips frames 0 to 3`() throws {
        #expect(try Self.address(3599, .sixty, .drop) == "00:00:59;59")
        #expect(try Self.address(3600, .sixty, .drop) == "00:01:00;04")
        #expect(try Self.address(215_784, .sixty, .drop) == "01:00:00;00")
    }

    @Test func `non-drop counting is plain arithmetic`() throws {
        #expect(try Self.address(900, .thirty, .nonDrop) == "00:00:30:00")
        #expect(try Self.address(86_399, .twentyFour, .nonDrop) == "00:59:59:23")
    }

    @Test func `every frame of a day maps to its address and back`() throws {
        for (rate, counting) in [(SMPTE_ST_12.Timecode.Rate.thirty, SMPTE_ST_12.Timecode.Counting.drop), (.sixty, .drop), (.twentyFive, .nonDrop)] {
            for frame in stride(from: 0, to: UInt(rate.nominal) * 86_000, by: 7) {
                let address = try SMPTE_ST_12.Timecode(frame: Cardinal(frame), rate: rate, counting: counting)
                #expect(address.frame == Cardinal(frame))
            }
        }
    }

    @Test func `an address counts back at the rate it was made with`() throws {
        let address = try SMPTE_ST_12.Timecode(frame: Cardinal(1800 as UInt), rate: .thirty, counting: .drop)
        #expect(address.rate == .thirty)
        #expect(address.frame == Cardinal(1800 as UInt))
        let twentyFive = try SMPTE_ST_12.Timecode(frame: Cardinal(1800 as UInt), rate: .twentyFive, counting: .nonDrop)
        #expect(twentyFive.description == "00:01:12:00")
        #expect(twentyFive.frame == Cardinal(1800 as UInt))
    }

    @Test func `drop-frame is refused where it is undefined`() {
        #expect(throws: SMPTE_ST_12.Timecode.Error.drop(.twentyFive)) {
            try SMPTE_ST_12.Timecode(frame: Cardinal(0 as UInt), rate: .twentyFive, counting: .drop)
        }
    }
}

extension `Timecode Tests` {
    @Test func `an exact frame rate is counted at its nominal rate, dropping only at 30000 and 60000 over 1001`() throws {
        typealias Nominal = SMPTE_ST_12.Timecode.Rate
        for nominal in Nominal.allCases {
            let whole = try #require(Nominal.counting(try Rate(Integer(nominal.nominal))))
            #expect(whole.rate == nominal && whole.counting == .nonDrop)
            let slowed = try #require(Nominal.counting(try Rate(Integer(nominal.nominal * 1000), per: 1001)))
            #expect(slowed.rate == nominal)
            #expect((slowed.counting == .drop) == (nominal == .thirty || nominal == .sixty))
        }
        for (count, units) in [(15, 1), (2997, 100), (30000, 1000), (30001, 1001), (120, 1), (25000, 1001 * 2)] {
            let rate = try Rate(Integer(count), per: Integer(units))
            #expect(Nominal.counting(rate).map(\.rate) == (rate == (try Rate(30)) ? .thirty : nil))
        }
    }

    @Test func `a frame's address at an exact rate is its address at the nominal rate`() throws {
        let ntsc = try Rate(30000, per: 1001)
        #expect(try SMPTE_ST_12.Timecode(frame: 1800, at: ntsc).description == "00:01:00;02")
        #expect(try SMPTE_ST_12.Timecode(frame: 107_892, at: ntsc).description == "01:00:00;00")
        #expect(try SMPTE_ST_12.Timecode(frame: 900, at: Rate(30)).description == "00:00:30:00")
        #expect(try SMPTE_ST_12.Timecode(frame: 86_399, at: Rate(24000, per: 1001)).description == "00:59:59:23")
        let odd = try Rate(2997, per: 100)
        #expect(throws: SMPTE_ST_12.Timecode.Error.uncounted(odd)) { try SMPTE_ST_12.Timecode(frame: 0, at: odd) }
    }
}
