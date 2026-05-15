import Foundation

enum BeginnerContent {
    static let lessons: [BeginnerLesson] = frenchLessons

    static func lessons(for language: TargetLanguage) -> [BeginnerLesson] {
        switch language {
        case .english: englishLessons
        case .french: frenchLessons
        case .spanish, .italian: []
        }
    }

    static func firstLessonID(for language: TargetLanguage) -> String {
        lessons(for: language).first?.id ?? frenchLessons[0].id
    }

    static func lesson(id: String) -> BeginnerLesson? {
        (frenchLessons + englishLessons).first { $0.id == id }
    }

    static func vocabPracticeLesson(for language: TargetLanguage) -> BeginnerLesson {
        switch language {
        case .english:
            lesson(id: "english-small-talk") ?? englishLessons[1]
        case .french, .spanish, .italian:
            lesson(id: "beginner-greetings") ?? frenchLessons[1]
        }
    }

    static func verbPracticeLesson(for language: TargetLanguage) -> BeginnerLesson {
        switch language {
        case .english:
            lesson(id: "english-work-chat") ?? englishLessons[4]
        case .french, .spanish, .italian:
            lesson(id: "beginner-hotel") ?? frenchLessons[4]
        }
    }

    private static let englishLessons: [BeginnerLesson] = [
        BeginnerLesson(
            id: "english-introductions",
            unit: 1,
            title: "Introduce yourself",
            subtitle: "Name, country, and reason for learning",
            icon: "person.wave.2.fill",
            accent: .blue,
            minutes: 4,
            steps: [
                LessonStep(id: "english-intro-1", kind: .teach, title: "Start naturally", prompt: "Hi, I'm Kevin. Nice to meet you.", helper: "Use this in casual introductions and first meetings.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-intro-2", kind: .speak, title: "Say it out loud", prompt: "Hi, I'm ... Nice to meet you.", helper: "Replace the blank with your name.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-intro-3", kind: .choice, title: "Choose the best reply", prompt: "Nice to meet you.", helper: "Pick the most natural response.", choices: ["Nice to meet you too.", "I am going to meet you.", "Meet me nice."], correctAnswer: "Nice to meet you too.")
            ],
            savedWords: [
                SavedWord(term: "nice to meet you", translation: "a polite first-meeting phrase", example: "Hi, I'm Maya. Nice to meet you."),
                SavedWord(term: "I'm from", translation: "use this to say your country or city", example: "I'm from Indonesia.")
            ]
        ),
        BeginnerLesson(
            id: "english-small-talk",
            unit: 1,
            title: "Start small talk",
            subtitle: "Ask how someone is doing",
            icon: "bubble.left.fill",
            accent: .mint,
            minutes: 3,
            steps: [
                LessonStep(id: "english-talk-1", kind: .teach, title: "Simple check-in", prompt: "How's your day going?", helper: "A friendly question for casual conversation.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-talk-2", kind: .choice, title: "Pick the natural answer", prompt: "How's your day going?", helper: "Choose the response that sounds natural.", choices: ["Pretty good, thanks.", "It is going day.", "I am day fine."], correctAnswer: "Pretty good, thanks."),
                LessonStep(id: "english-talk-3", kind: .speak, title: "Short exchange", prompt: "Pretty good, thanks. How about you?", helper: "This keeps the conversation moving.", choices: [], correctAnswer: nil)
            ],
            savedWords: [
                SavedWord(term: "how's your day going", translation: "a friendly check-in", example: "How's your day going?"),
                SavedWord(term: "how about you", translation: "ask the same question back", example: "I'm doing well. How about you?")
            ]
        ),
        BeginnerLesson(
            id: "english-ordering",
            unit: 1,
            title: "Order at a cafe",
            subtitle: "Ask politely for food or drinks",
            icon: "cup.and.saucer.fill",
            accent: .amber,
            minutes: 5,
            steps: [
                LessonStep(id: "english-cafe-1", kind: .teach, title: "Polite request", prompt: "Could I have a coffee, please?", helper: "Could I have is polite and useful in cafes.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-cafe-2", kind: .choice, title: "Choose the polite request", prompt: "You want tea.", helper: "Pick the best sentence.", choices: ["Could I have a tea, please?", "I tea now.", "Give tea to me."], correctAnswer: "Could I have a tea, please?"),
                LessonStep(id: "english-cafe-3", kind: .speak, title: "Make it yours", prompt: "Could I have ..., please?", helper: "Try coffee, tea, water, or a sandwich.", choices: [], correctAnswer: nil)
            ],
            savedWords: [
                SavedWord(term: "could I have", translation: "polite way to ask for something", example: "Could I have a coffee, please?"),
                SavedWord(term: "please", translation: "adds politeness to a request", example: "Could I have some water, please?")
            ]
        ),
        BeginnerLesson(
            id: "english-directions",
            unit: 1,
            title: "Ask for directions",
            subtitle: "Find a place in the city",
            icon: "map.fill",
            accent: .violet,
            minutes: 4,
            steps: [
                LessonStep(id: "english-directions-1", kind: .teach, title: "Find a place", prompt: "Excuse me, where is the station?", helper: "Start with excuse me to sound polite.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-directions-2", kind: .choice, title: "Choose the meaning", prompt: "Where is the station?", helper: "What is the speaker asking for?", choices: ["They want to find the station.", "They want to buy a ticket.", "They work at the station."], correctAnswer: "They want to find the station."),
                LessonStep(id: "english-directions-3", kind: .speak, title: "Ask clearly", prompt: "Excuse me, where is the nearest station?", helper: "Nearest means closest to you.", choices: [], correctAnswer: nil)
            ],
            savedWords: [
                SavedWord(term: "excuse me", translation: "polite way to get attention", example: "Excuse me, where is the station?"),
                SavedWord(term: "nearest", translation: "closest", example: "Where is the nearest cafe?")
            ]
        ),
        BeginnerLesson(
            id: "english-work-chat",
            unit: 1,
            title: "Talk about work",
            subtitle: "Say what you do and ask back",
            icon: "briefcase.fill",
            accent: .blue,
            minutes: 5,
            steps: [
                LessonStep(id: "english-work-1", kind: .teach, title: "Your role", prompt: "I work in design.", helper: "Use I work in plus your field.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-work-2", kind: .choice, title: "Fill the blank", prompt: "I ___ in marketing.", helper: "Choose the missing word.", choices: ["work", "am", "do"], correctAnswer: "work"),
                LessonStep(id: "english-work-3", kind: .speak, title: "Ask back", prompt: "What do you do?", helper: "This asks about someone's job or work.", choices: [], correctAnswer: nil)
            ],
            savedWords: [
                SavedWord(term: "I work in", translation: "say your field or industry", example: "I work in marketing."),
                SavedWord(term: "what do you do", translation: "ask about someone's job", example: "What do you do?")
            ]
        ),
        BeginnerLesson(
            id: "english-daily-routine",
            unit: 1,
            title: "Describe your routine",
            subtitle: "Talk about everyday habits",
            icon: "clock.fill",
            accent: .mint,
            minutes: 5,
            steps: [
                LessonStep(id: "english-routine-1", kind: .teach, title: "Daily habits", prompt: "I usually wake up at seven.", helper: "Use usually for something you do most days.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-routine-2", kind: .choice, title: "Choose the natural sentence", prompt: "You want to describe your morning.", helper: "Pick the sentence that sounds natural.", choices: ["I usually wake up at seven.", "I wake usually at seven.", "I am wake at seven."], correctAnswer: "I usually wake up at seven."),
                LessonStep(id: "english-routine-3", kind: .speak, title: "Make it personal", prompt: "I usually ... before work.", helper: "Try: drink coffee, check messages, or study English.", choices: [], correctAnswer: nil)
            ],
            savedWords: [
                SavedWord(term: "usually", translation: "most days; normally", example: "I usually study English at night."),
                SavedWord(term: "before work", translation: "earlier than work starts", example: "I usually drink coffee before work.")
            ]
        ),
        BeginnerLesson(
            id: "english-shopping-prices",
            unit: 1,
            title: "Shop and ask prices",
            subtitle: "Ask how much something costs",
            icon: "bag.fill",
            accent: .amber,
            minutes: 5,
            steps: [
                LessonStep(id: "english-shopping-1", kind: .teach, title: "Ask the price", prompt: "How much is this?", helper: "Use this when you are holding or pointing at one item.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-shopping-2", kind: .choice, title: "Pick the right question", prompt: "You want to know the price of a shirt.", helper: "Choose the most useful question.", choices: ["How much is this?", "How many this?", "How price this?"], correctAnswer: "How much is this?"),
                LessonStep(id: "english-shopping-3", kind: .speak, title: "Add a request", prompt: "How much is this? Do you have a smaller size?", helper: "Smaller size can become larger size or another color.", choices: [], correctAnswer: nil)
            ],
            savedWords: [
                SavedWord(term: "how much is this", translation: "ask for the price of one thing", example: "How much is this jacket?"),
                SavedWord(term: "smaller size", translation: "a size that is less large", example: "Do you have a smaller size?")
            ]
        ),
        BeginnerLesson(
            id: "english-making-plans",
            unit: 1,
            title: "Make plans",
            subtitle: "Suggest a time and confirm",
            icon: "calendar.badge.plus",
            accent: .violet,
            minutes: 5,
            steps: [
                LessonStep(id: "english-plans-1", kind: .teach, title: "Suggest a plan", prompt: "Would you like to meet at six?", helper: "Would you like to is a polite way to invite someone.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-plans-2", kind: .choice, title: "Choose the polite invitation", prompt: "Invite someone to dinner.", helper: "Pick the sentence that sounds friendly and natural.", choices: ["Would you like to have dinner?", "You dinner with me now?", "Dinner you like?"], correctAnswer: "Would you like to have dinner?"),
                LessonStep(id: "english-plans-3", kind: .speak, title: "Confirm details", prompt: "Great. Let's meet at six near the station.", helper: "Use let's to suggest doing something together.", choices: [], correctAnswer: nil)
            ],
            savedWords: [
                SavedWord(term: "would you like to", translation: "polite invitation phrase", example: "Would you like to meet tomorrow?"),
                SavedWord(term: "let's meet", translation: "suggest a meeting", example: "Let's meet near the station.")
            ]
        ),
        BeginnerLesson(
            id: "english-ask-for-help",
            unit: 1,
            title: "Ask for help",
            subtitle: "Explain a problem simply",
            icon: "questionmark.circle.fill",
            accent: .blue,
            minutes: 4,
            steps: [
                LessonStep(id: "english-help-1", kind: .teach, title: "Polite help request", prompt: "Could you help me, please?", helper: "Use could you for polite requests to another person.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-help-2", kind: .choice, title: "Choose the clear problem", prompt: "Your phone has no battery.", helper: "Pick the sentence that explains the problem.", choices: ["My phone is out of battery.", "My phone no energy.", "Phone finish battery."], correctAnswer: "My phone is out of battery."),
                LessonStep(id: "english-help-3", kind: .speak, title: "Ask and explain", prompt: "Could you help me, please? My phone is out of battery.", helper: "Say the request first, then explain the problem.", choices: [], correctAnswer: nil)
            ],
            savedWords: [
                SavedWord(term: "could you help me", translation: "polite way to ask for help", example: "Could you help me, please?"),
                SavedWord(term: "out of battery", translation: "has no battery power left", example: "My phone is out of battery.")
            ]
        ),
        BeginnerLesson(
            id: "english-health-help",
            unit: 1,
            title: "Say what hurts",
            subtitle: "Ask for basic health help",
            icon: "cross.case.fill",
            accent: .mint,
            minutes: 4,
            steps: [
                LessonStep(id: "english-health-1", kind: .teach, title: "Simple symptom", prompt: "I have a headache.", helper: "Use I have a plus symptom for common health problems.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-health-2", kind: .choice, title: "Pick the natural symptom", prompt: "You feel pain in your head.", helper: "Choose the common English phrase.", choices: ["I have a headache.", "I am head pain.", "My head is have hurt."], correctAnswer: "I have a headache."),
                LessonStep(id: "english-health-3", kind: .speak, title: "Ask for a pharmacy", prompt: "I have a headache. Is there a pharmacy nearby?", helper: "Nearby means close to your current location.", choices: [], correctAnswer: nil)
            ],
            savedWords: [
                SavedWord(term: "headache", translation: "pain in your head", example: "I have a headache."),
                SavedWord(term: "nearby", translation: "close to here", example: "Is there a pharmacy nearby?")
            ]
        ),
        BeginnerLesson(
            id: "english-review",
            unit: 1,
            title: "Conversation review",
            subtitle: "One complete starter conversation",
            icon: "checkmark.seal.fill",
            accent: .mint,
            minutes: 8,
            steps: [
                LessonStep(id: "english-review-1", kind: .teach, title: "Put it together", prompt: "Hi, I'm Kevin. Nice to meet you. How's your day going?", helper: "You can now start a simple English conversation.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-review-2", kind: .choice, title: "Cafe response", prompt: "Could I have a coffee, please?", helper: "What might the barista say?", choices: ["Sure. Anything else?", "I am coffee.", "Where is Kevin?"], correctAnswer: "Sure. Anything else?"),
                LessonStep(id: "english-review-3", kind: .choice, title: "Plan details", prompt: "Would you like to meet at six?", helper: "Choose a natural reply.", choices: ["Yes, that works for me.", "Six is like meet.", "I am meeting six yes."], correctAnswer: "Yes, that works for me."),
                LessonStep(id: "english-review-4", kind: .choice, title: "Ask for help", prompt: "My phone is out of battery.", helper: "Choose the useful follow-up request.", choices: ["Could you help me, please?", "Could you battery me?", "Help is phone."], correctAnswer: "Could you help me, please?"),
                LessonStep(id: "english-review-5", kind: .speak, title: "Final speaking prompt", prompt: "Hi, I'm ... Nice to meet you. Would you like to meet at six?", helper: "Say the full exchange with your own name and a clear invitation.", choices: [], correctAnswer: nil)
            ],
            savedWords: [
                SavedWord(term: "anything else", translation: "ask if someone wants more", example: "Sure. Anything else?"),
                SavedWord(term: "that works for me", translation: "that plan is okay for me", example: "Yes, that works for me."),
                SavedWord(term: "could you help me", translation: "polite way to ask for help", example: "Could you help me, please?"),
                SavedWord(term: "pretty good", translation: "natural answer for how you are", example: "Pretty good, thanks.")
            ]
        )
    ]

    private static let frenchLessons: [BeginnerLesson] = [
        BeginnerLesson(
            id: "beginner-introductions",
            unit: 1,
            title: "Introduce yourself",
            subtitle: "Name, origin, and first goal",
            icon: "person.wave.2.fill",
            accent: .blue,
            minutes: 4,
            steps: [
                LessonStep(id: "intro-1", kind: .teach, title: "Your first sentence", prompt: "Bonjour. Je m'appelle Kevin.", helper: "Hello. My name is Kevin.", choices: [], correctAnswer: nil),
                LessonStep(id: "intro-2", kind: .speak, title: "Say it out loud", prompt: "Je m'appelle ...", helper: "Use your own name after the phrase.", choices: [], correctAnswer: nil),
                LessonStep(id: "intro-3", kind: .choice, title: "Choose the meaning", prompt: "Je viens d'Indonesie.", helper: "Pick the closest translation.", choices: ["I come from Indonesia.", "I am going to Indonesia.", "I speak Indonesian."], correctAnswer: "I come from Indonesia.")
            ],
            savedWords: [
                SavedWord(term: "bonjour", translation: "hello", example: "Bonjour, je m'appelle Kevin."),
                SavedWord(term: "je m'appelle", translation: "my name is", example: "Je m'appelle Sarah.")
            ]
        ),
        BeginnerLesson(
            id: "beginner-greetings",
            unit: 1,
            title: "Greet someone",
            subtitle: "Polite hello and goodbye",
            icon: "bubble.left.fill",
            accent: .mint,
            minutes: 3,
            steps: [
                LessonStep(id: "greeting-1", kind: .teach, title: "Two everyday greetings", prompt: "Salut is casual. Bonjour is polite.", helper: "Use bonjour in shops, cafes, and first meetings.", choices: [], correctAnswer: nil),
                LessonStep(id: "greeting-2", kind: .choice, title: "Translate", prompt: "Hi.", helper: "Pick the natural casual French greeting.", choices: ["Au revoir.", "Salut.", "Bonsoir."], correctAnswer: "Salut."),
                LessonStep(id: "greeting-3", kind: .speak, title: "Short exchange", prompt: "Bonjour. Comment ca va ?", helper: "Answer with Ca va bien.", choices: [], correctAnswer: nil)
            ],
            savedWords: [
                SavedWord(term: "salut", translation: "hi", example: "Salut, ca va ?"),
                SavedWord(term: "au revoir", translation: "goodbye", example: "Au revoir, a demain.")
            ]
        ),
        BeginnerLesson(
            id: "beginner-ordering",
            unit: 1,
            title: "Order coffee",
            subtitle: "Ask for something politely",
            icon: "cup.and.saucer.fill",
            accent: .amber,
            minutes: 5,
            steps: [
                LessonStep(id: "coffee-1", kind: .teach, title: "Cafe phrase", prompt: "Je voudrais un cafe, s'il vous plait.", helper: "I would like a coffee, please.", choices: [], correctAnswer: nil),
                LessonStep(id: "coffee-2", kind: .choice, title: "Pick the polite request", prompt: "I would like water, please.", helper: "Look for je voudrais and s'il vous plait.", choices: ["Je voudrais de l'eau, s'il vous plait.", "Je suis de l'eau.", "J'aime demain."], correctAnswer: "Je voudrais de l'eau, s'il vous plait."),
                LessonStep(id: "coffee-3", kind: .speak, title: "Make it yours", prompt: "Je voudrais ..., s'il vous plait.", helper: "Try un cafe, de l'eau, or un croissant.", choices: [], correctAnswer: nil)
            ],
            savedWords: [
                SavedWord(term: "je voudrais", translation: "I would like", example: "Je voudrais un cafe."),
                SavedWord(term: "s'il vous plait", translation: "please", example: "Un croissant, s'il vous plait.")
            ]
        ),
        BeginnerLesson(
            id: "beginner-directions",
            unit: 1,
            title: "Ask for directions",
            subtitle: "Find a station or street",
            icon: "map.fill",
            accent: .violet,
            minutes: 4,
            steps: [
                LessonStep(id: "directions-1", kind: .teach, title: "Finding a place", prompt: "Ou est la gare ?", helper: "Where is the train station?", choices: [], correctAnswer: nil),
                LessonStep(id: "directions-2", kind: .choice, title: "Choose the place", prompt: "la gare", helper: "What place is this?", choices: ["the station", "the hotel", "the bakery"], correctAnswer: "the station"),
                LessonStep(id: "directions-3", kind: .speak, title: "Ask clearly", prompt: "Excusez-moi, ou est la gare ?", helper: "Start with excusez-moi to sound polite.", choices: [], correctAnswer: nil)
            ],
            savedWords: [
                SavedWord(term: "ou est", translation: "where is", example: "Ou est la gare ?"),
                SavedWord(term: "la gare", translation: "the station", example: "La gare est a gauche.")
            ]
        ),
        BeginnerLesson(
            id: "beginner-hotel",
            unit: 1,
            title: "Check in at a hotel",
            subtitle: "Name, reservation, room",
            icon: "building.2.fill",
            accent: .blue,
            minutes: 5,
            steps: [
                LessonStep(id: "hotel-1", kind: .teach, title: "At reception", prompt: "J'ai une reservation.", helper: "I have a reservation.", choices: [], correctAnswer: nil),
                LessonStep(id: "hotel-2", kind: .choice, title: "Fill the blank", prompt: "J'ai ___ reservation.", helper: "Choose the missing word.", choices: ["une", "bonjour", "gare"], correctAnswer: "une"),
                LessonStep(id: "hotel-3", kind: .speak, title: "Speak", prompt: "Bonjour, j'ai une reservation.", helper: "Then add your name: Je m'appelle ...", choices: [], correctAnswer: nil)
            ],
            savedWords: [
                SavedWord(term: "j'ai", translation: "I have", example: "J'ai une reservation."),
                SavedWord(term: "une reservation", translation: "a reservation", example: "J'ai une reservation pour deux nuits.")
            ]
        ),
        BeginnerLesson(
            id: "beginner-review",
            unit: 1,
            title: "Beginner review",
            subtitle: "One travel conversation",
            icon: "checkmark.seal.fill",
            accent: .mint,
            minutes: 6,
            steps: [
                LessonStep(id: "review-1", kind: .teach, title: "Put it together", prompt: "Bonjour. Je voudrais un cafe. Ou est la gare ?", helper: "You can now greet, order, and ask for a place.", choices: [], correctAnswer: nil),
                LessonStep(id: "review-2", kind: .choice, title: "Best response", prompt: "Bonjour, vous desirez ?", helper: "The server asks what you would like.", choices: ["Je voudrais un cafe, s'il vous plait.", "Je viens de la gare.", "Au revoir Kevin."], correctAnswer: "Je voudrais un cafe, s'il vous plait."),
                LessonStep(id: "review-3", kind: .speak, title: "Final speaking prompt", prompt: "Bonjour. Je m'appelle ... Je voudrais ..., s'il vous plait.", helper: "Say the full sentence with your own name and order.", choices: [], correctAnswer: nil)
            ],
            savedWords: [
                SavedWord(term: "comment ca va", translation: "how are you", example: "Bonjour, comment ca va ?"),
                SavedWord(term: "excusez-moi", translation: "excuse me", example: "Excusez-moi, ou est la gare ?")
            ]
        )
    ]
}
