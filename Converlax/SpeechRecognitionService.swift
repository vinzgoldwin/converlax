import AVFoundation
import Speech

@MainActor
final class SpeechRecognitionService: ObservableObject {
    @Published private(set) var transcript = ""
    @Published private(set) var isRecording = false
    @Published private(set) var voiceLevel: Double = 0
    @Published private(set) var errorMessage: String?

    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var speechRecognizer: SFSpeechRecognizer?

    var trimmedTranscript: String {
        transcript.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func startRecording(localeIdentifier: String = Locale.current.identifier) async -> Bool {
        stopRecording()
        transcript = ""
        errorMessage = nil

        guard await requestPermissions() else {
            errorMessage = "Voice practice needs Microphone and Speech Recognition. You can allow access in Settings, then try again."
            return false
        }

        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier)) ?? SFSpeechRecognizer()

        guard let speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Speech recognition is unavailable right now. Try again in a moment."
            return false
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else {
            errorMessage = "Could not prepare voice input. Try again in a moment."
            return false
        }

        recognitionRequest.shouldReportPartialResults = true
        if speechRecognizer.supportsOnDeviceRecognition {
            recognitionRequest.requiresOnDeviceRecognition = false
        }

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: [.duckOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.removeTap(onBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1_024, format: recordingFormat) { buffer, _ in
                Self.publishVoiceLevel(from: buffer, to: self)
                recognitionRequest.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true

            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                Task { @MainActor in
                    guard let self else { return }

                    if let result {
                        self.transcript = result.bestTranscription.formattedString
                    }

                    if let error {
                        self.errorMessage = error.localizedDescription
                        self.stopRecording()
                    } else if result?.isFinal == true {
                        self.stopRecording()
                    }
                }
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            stopRecording()
            return false
        }
    }

    @discardableResult
    func stopRecording() -> String {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
        voiceLevel = 0

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        return trimmedTranscript
    }

    func cancelRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        isRecording = false
        voiceLevel = 0
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private nonisolated static func publishVoiceLevel(from buffer: AVAudioPCMBuffer, to service: SpeechRecognitionService) {
        guard
            let channelData = buffer.floatChannelData?[0],
            buffer.frameLength > 0
        else { return }

        let frameCount = Int(buffer.frameLength)
        var sum: Float = 0

        for frame in 0..<frameCount {
            let sample = channelData[frame]
            sum += sample * sample
        }

        let rms = sqrt(sum / Float(frameCount))
        let normalizedLevel = min(1, max(0, Double(rms) * 24))

        Task { @MainActor in
            service.voiceLevel = service.voiceLevel * 0.62 + normalizedLevel * 0.38
        }
    }

    private func requestPermissions() async -> Bool {
        let speechAllowed = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }

        guard speechAllowed else { return false }

        return await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { allowed in
                continuation.resume(returning: allowed)
            }
        }
    }
}
