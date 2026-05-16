# Real Microphone Speech Goal

You are working in `/Users/kego/Projects/converlax`, a SwiftUI iOS language-learning app.

Goal:

Replace mock voice input with real microphone recording and Apple speech recognition so a user can speak into the simulator or iPhone, see their actual transcript, and use it in lesson and Tutor feedback.

Current problem:

- `LessonPlayerView.swift` generates fake transcripts with `mockTranscript(for:)`.
- `TutorView.swift` submits a hardcoded voice message.
- Settings copy says speech recognition is a placeholder.
- The app has no real `Speech`, `AVAudioEngine`, microphone permission, or speech permission flow.

Implement:

1. Add a real speech service, for example `Converlax/SpeechRecognitionService.swift`, using:
   - `Speech`
   - `SFSpeechRecognizer`
   - `AVAudioEngine`
   - `AVAudioSession`

2. Add required permission strings:
   - `NSMicrophoneUsageDescription`
   - `NSSpeechRecognitionUsageDescription`

3. Wire real speech into `LessonPlayerView.swift`:
   - Start recording from the existing voice button.
   - Show partial/final transcript.
   - Stop recording and pass the real transcript into `state.acceptSpeechPractice(...)`.
   - Show retry/error if no speech is recognized.
   - Do not use mock transcript generation in the real user path.

4. Wire real speech into `TutorView.swift`:
   - Record real voice input.
   - Submit the recognized transcript as the user's Tutor message.
   - Remove the hardcoded voice phrase.

5. Update settings copy in `PhaseOneViews.swift`:
   - Voice recognition should no longer be described as a local placeholder.
   - Handle denied permissions clearly.

Keep local:

- Feedback, scoring, Tutor responses, saved lines, and review items can remain deterministic/local.
- The key change is real microphone input and real speech-to-text.

Verify:

- Build and run on iOS simulator.
- Fresh install prompts for microphone and speech recognition permissions.
- Speak a unique phrase not present in fixtures, such as: "I want to practice at seven thirty tonight."
- Confirm the real phrase appears in the transcript UI.
- Confirm lesson feedback uses that transcript as the attempted text.
- Confirm Tutor voice input sends that transcript as the user message.
- Test denied permission, empty speech, retry, cancel, and navigating away during recording.

Acceptance criteria:

- No real voice-input flow uses mock transcripts.
- Tutor voice input no longer sends a hardcoded phrase.
- The app has real microphone and speech recognition permission strings.
- A tester can speak a unique phrase and see it appear in the app.
- The recognized transcript is passed into existing feedback/progress recording.

