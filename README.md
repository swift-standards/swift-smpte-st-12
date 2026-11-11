# swift-smpte-st-12

Use this package when you need to turn a frame count into an SMPTE timecode address such as `01:00:00;00`, or an address back into a frame count. Start from `SMPTE_ST_12.Timecode`.

## Laws

- A rate is a whole nominal rate. `SMPTE_ST_12.Timecode.Rate.thirty` also counts 29.97 (30000/1001) video and `SMPTE_ST_12.Timecode.Rate.sixty` also counts 59.94 (60000/1001).
- With drop-frame counting, frame numbers 0 and 1 are skipped at the start of every minute except every tenth minute. At `SMPTE_ST_12.Timecode.Rate.sixty` frame numbers 0 to 3 are skipped. So frame 1800 at 29.97 is `00:01:00;02`, and frame 17982 is `00:10:00;00`.
- Drop-frame counting exists only at `SMPTE_ST_12.Timecode.Rate.thirty` and `SMPTE_ST_12.Timecode.Rate.sixty`. Any other rate throws `SMPTE_ST_12.Timecode.Error.drop(_:)`.
- `SMPTE_ST_12.Timecode.Rate.counting(_:)` says how an exact frame rate (a `Rate` from swift-rate, in frames per second) is counted. A whole rate of 24, 25, 30, 48, 50 or 60 is counted at itself without dropping. The same rates slowed by 1000/1001 are counted at the whole rate: 30000/1001 and 60000/1001 with drop-frame counting, 24000/1001 and the others without. Every other rate, 2997/100 included, has no time address: the answer is `nil`, and `SMPTE_ST_12.Timecode.init(frame:at:)` throws `SMPTE_ST_12.Timecode.Error.uncounted(_:)`.
- Non-drop counting is plain arithmetic on the nominal rate.
- Hours wrap at 24, so a frame count of a day or more maps to the same address as its remainder.
- An address stores its rate. `SMPTE_ST_12.Timecode.frame` inverts `SMPTE_ST_12.Timecode.init(frame:rate:counting:)` for any frame within a day.
- The description writes each field as two digits separated by colons. The separator before the frames is a semicolon when counting drops frames.
