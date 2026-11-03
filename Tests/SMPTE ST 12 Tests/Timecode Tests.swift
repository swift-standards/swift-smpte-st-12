import Cardinal
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
                #expect(address.frame(at: rate) == Cardinal(frame))
            }
        }
    }

    @Test func `drop-frame is refused where it is undefined`() {
        #expect(throws: SMPTE_ST_12.Timecode.Error.drop(.twentyFive)) {
            try SMPTE_ST_12.Timecode(frame: Cardinal(0 as UInt), rate: .twentyFive, counting: .drop)
        }
    }
}
