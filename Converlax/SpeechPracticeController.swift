import Foundation
import Combine
import SwiftUI

@MainActor
final class SpeechPracticeController: ObservableObject {
    @Published private(set) var phase: SpeechPracticePhase = .ready
    @Published private(set) var transcript: String = ""
    @Published private(set) var errorMessage: String?

    let recognizer: SpeechRecognitionService

    private let localeProvider: () -> String
    private let canStartProvider: () -> Bool
    private let testTranscriptOverride: () -> String?
    private var activeRecordingTask: Task<Void, Never>?
    private var transcriptSubscription: AnyCancellable?

    init(
        recognizer: SpeechRecognitionService? = nil,
        localeProvider: @escaping () -> String,
        canStartProvider: @escaping () -> Bool = { true },
        testTranscriptOverride: @escaping () -> String? = { nil }
    ) {
        self.recognizer = recognizer ?? SpeechRecognitionService()
        self.localeProvider = localeProvider
        self.canStartProvider = canStartProvider
        self.testTranscriptOverride = testTranscriptOverride
        self.transcriptSubscription = self.recognizer.$transcript
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transcript in
                self?.syncLiveTranscript(transcript)
            }
    }

    deinit {
        activeRecordingTask?.cancel()
    }

    func startRecording() {
        guard canStartProvider() else { return }

        if let override = testTranscriptOverride() {
            transcript = override
            errorMessage = nil
            phase = .transcript
            return
        }

        phase = .requestingPermission
        transcript = ""
        errorMessage = nil

        let locale = localeProvider()
        activeRecordingTask = Task { [weak self, recognizer] in
            let started = await recognizer.startRecording(localeIdentifier: locale)
            guard !Task.isCancelled else { return }
            self?.handleRecordingStartResult(started: started)
        }
    }

    func finishRecording() {
        phase = .transcribing
        let recognizedText = recognizer.stopRecording()
        transcript = recognizedText

        guard !recognizedText.isEmpty else {
            errorMessage = "Nothing clear was captured. Say one short sentence and try again."
            phase = .noSpeech
            return
        }

        phase = .transcript
    }

    func cancel() {
        activeRecordingTask?.cancel()
        activeRecordingTask = nil
        recognizer.cancelRecording()
        phase = .ready
        transcript = ""
        errorMessage = nil
    }

    func reset() {
        phase = .ready
        transcript = ""
        errorMessage = nil
    }

    func syncLiveTranscript() {
        syncLiveTranscript(recognizer.transcript)
    }

    func forceState(phase: SpeechPracticePhase, transcript: String = "", errorMessage: String? = nil) {
        self.phase = phase
        self.transcript = transcript
        self.errorMessage = errorMessage
    }

    private func handleRecordingStartResult(started: Bool) {
        if started {
            phase = .recording
            syncLiveTranscript()
        } else {
            errorMessage = recognizer.errorMessage
            phase = recognizer.errorMessage?.localizedCaseInsensitiveContains("permission") == true
                ? .permissionDenied
                : .error
        }
    }

    private func syncLiveTranscript(_ liveTranscript: String) {
        guard phase == .recording else { return }
        transcript = liveTranscript
    }
}
