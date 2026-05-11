import AVFoundation
import Foundation

/// Plays short procedurally-generated sound effects for game events.
///
/// All buffers are baked at init so `play(_:)` is allocation-free. Audio
/// session is `.ambient` on iOS so the game mixes in over the user's
/// existing audio rather than ducking it.
///
/// Procedural synthesis keeps the package self-contained — no audio assets
/// to bundle, version, or license.
@MainActor
final class SoundEffectPlayer {

    enum Effect: Hashable, Sendable {
        /// A new ball was drawn from the bag — short low "bonk".
        case ballDrawn
        /// A cell was daubed (manual tap or auto-daub catching a match).
        case daub
        /// Pattern completed — C5-E5-G5-C6 arpeggio.
        case bingo
    }

    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let format: AVAudioFormat
    private var buffers: [Effect: AVAudioPCMBuffer] = [:]
    private var didStart = false

    init() {
        guard let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1) else {
            self.format = AVAudioFormat()
            return
        }
        self.format = format

        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)

        buffers[.ballDrawn] = Self.makeBallPop(format: format, duration: 0.18)
        buffers[.daub]      = Self.makeDaubPop(format: format, duration: 0.09)
        buffers[.bingo]     = Self.makeArpeggio(
            format: format,
            frequencies: [523.25, 659.25, 783.99, 1046.50],
            noteDuration: 0.14
        )

        do {
            #if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            #endif
            try engine.start()
            playerNode.play()
            didStart = true
        } catch {
            // Best-effort: silent fallback if audio init fails.
        }
    }

    func play(_ effect: Effect) {
        guard didStart, let buffer = buffers[effect] else { return }
        playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts)
    }

    // MARK: - Buffer generators

    /// Wood-thunk-ish sound for a ball coming out of the bag. Mid-low
    /// frequency body + filtered noise envelope.
    private static func makeBallPop(format: AVAudioFormat, duration: TimeInterval) -> AVAudioPCMBuffer? {
        let sampleRate = Float(format.sampleRate)
        let frameCount = AVAudioFrameCount(duration * Double(sampleRate))
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }
        buffer.frameLength = frameCount
        let data = buffer.floatChannelData![0]
        var prev: Float = 0
        let alpha: Float = 0.10
        for i in 0..<Int(frameCount) {
            let t = Float(i) / sampleRate
            let envelope = exp(-t * 18)
            let noise = Float.random(in: -1...1)
            prev = alpha * noise + (1 - alpha) * prev
            // Body: a falling sine pitch from ~180Hz to ~120Hz, which gives
            // a "boink" feel reminiscent of a real bingo ball.
            let pitch = 180 - 60 * t / Float(duration)
            let body = sin(2 * .pi * pitch * t) * 0.36
            data[i] = (prev * 0.55 + body) * envelope * 0.55
        }
        return buffer
    }

    /// Quick mid-frequency pop for a single daub. Short attack, short release,
    /// soft volume so the sound doesn't dominate when 4 cards auto-daub.
    private static func makeDaubPop(format: AVAudioFormat, duration: TimeInterval) -> AVAudioPCMBuffer? {
        let sampleRate = Float(format.sampleRate)
        let frameCount = AVAudioFrameCount(duration * Double(sampleRate))
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }
        buffer.frameLength = frameCount
        let data = buffer.floatChannelData![0]
        for i in 0..<Int(frameCount) {
            let t = Float(i) / sampleRate
            let envelope = exp(-t * 38)
            let f1 = sin(2 * .pi * 720 * t)
            let f2 = sin(2 * .pi * 480 * t) * 0.4
            data[i] = (f1 + f2) * envelope * 0.22
        }
        return buffer
    }

    private static func makeArpeggio(
        format: AVAudioFormat,
        frequencies: [Float],
        noteDuration: TimeInterval
    ) -> AVAudioPCMBuffer? {
        let sampleRate = Float(format.sampleRate)
        let noteFrames = Int(noteDuration * Double(sampleRate))
        let totalFrames = AVAudioFrameCount(noteFrames * frequencies.count)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: totalFrames) else {
            return nil
        }
        buffer.frameLength = totalFrames
        let data = buffer.floatChannelData![0]
        for (idx, frequency) in frequencies.enumerated() {
            for i in 0..<noteFrames {
                let t = Float(i) / sampleRate
                let envelope = exp(-t * 8) * (1 - exp(-t * 80))
                data[idx * noteFrames + i] = sin(2 * .pi * frequency * t) * envelope * 0.38
            }
        }
        return buffer
    }
}
