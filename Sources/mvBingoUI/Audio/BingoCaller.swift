import AVFoundation
import Foundation
import mvBingoKit

/// Text-to-speech caller. Announces each ball with the cadence of a real
/// bingo hall: "B... twelve."
///
/// Uses `AVSpeechSynthesizer` so there's nothing to bundle — every iOS
/// device ships with the voice catalog. The rate is intentionally slower
/// than the system default so the call sounds deliberate rather than
/// rushed.
@MainActor
final class BingoCaller {

    private let synthesizer = AVSpeechSynthesizer()
    private let voice: AVSpeechSynthesisVoice?

    init() {
        // Prefer an enhanced en-US voice when one's installed (richer
        // timbre); fall back to the default system voice otherwise.
        let enhanced = AVSpeechSynthesisVoice.speechVoices().first {
            $0.language.hasPrefix("en") && $0.quality == .enhanced
        }
        self.voice = enhanced ?? AVSpeechSynthesisVoice(language: "en-US")
    }

    /// Speak the ball's letter + number. Cancels any in-progress utterance
    /// so rapid draws don't queue a backlog.
    func call(_ ball: BingoBall) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        let utterance = AVSpeechUtterance(string: ball.spoken)
        utterance.voice = voice
        utterance.rate = 0.46
        utterance.pitchMultiplier = 0.96
        utterance.preUtteranceDelay = 0.05
        utterance.postUtteranceDelay = 0.05
        synthesizer.speak(utterance)
    }

    func cancel() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
