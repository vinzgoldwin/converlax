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
            subtitle: "Say your name, where you are from, and why you are learning",
            icon: "person.wave.2.fill",
            accent: .blue,
            minutes: 4,
            steps: [
                LessonStep(id: "english-intro-1", kind: .teach, title: "Start with your name", prompt: "Hi, I'm Maya. Nice to meet you.", helper: "Use this for first meetings, class, travel, or work.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-intro-2", kind: .choice, title: "Reply naturally", prompt: "Nice to meet you.", helper: "Choose the response a real person would say.", choices: ["Nice to meet you too.", "I meet you nice.", "You are meet."], correctAnswer: "Nice to meet you too."),
                LessonStep(id: "english-intro-3", kind: .speak, title: "Add where you are from", prompt: "I'm from Indonesia.", helper: "Change Indonesia to your country or city.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-intro-4", kind: .speak, title: "Say your reason", prompt: "I'm learning English for travel and work.", helper: "Keep the reason short: for travel, for work, or for my studies.", choices: [], correctAnswer: nil)
            ],
            savedWords: [
                SavedWord(term: "nice to meet you", translation: "polite phrase for a first meeting", example: "Hi, I'm Maya. Nice to meet you."),
                SavedWord(term: "I'm from", translation: "use this to say your country or city", example: "I'm from Indonesia."),
                SavedWord(term: "I'm learning English for", translation: "use this to explain your reason", example: "I'm learning English for travel and work.")
            ]
        ),
        BeginnerLesson(
            id: "english-small-talk",
            unit: 1,
            title: "Greet and make small talk",
            subtitle: "Start a friendly check-in and ask back",
            icon: "bubble.left.fill",
            accent: .mint,
            minutes: 4,
            steps: [
                LessonStep(id: "english-talk-1", kind: .teach, title: "Open the conversation", prompt: "Hi, how's your day going?", helper: "A relaxed greeting for classmates, neighbors, or coworkers.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-talk-2", kind: .choice, title: "Answer casually", prompt: "How's your day going?", helper: "Choose the answer that sounds natural.", choices: ["Pretty good, thanks.", "It is going day.", "I am day fine."], correctAnswer: "Pretty good, thanks."),
                LessonStep(id: "english-talk-3", kind: .speak, title: "Ask back", prompt: "Pretty good, thanks. How about you?", helper: "Ask back so the conversation does not stop.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-talk-4", kind: .choice, title: "Close politely", prompt: "I have to go now.", helper: "Pick a friendly closing line.", choices: ["It was nice talking to you.", "I go nice.", "Talk is finished good."], correctAnswer: "It was nice talking to you.")
            ],
            savedWords: [
                SavedWord(term: "how's your day going", translation: "friendly question about someone's day", example: "Hi, how's your day going?"),
                SavedWord(term: "pretty good, thanks", translation: "natural short answer when you feel okay", example: "Pretty good, thanks. How about you?"),
                SavedWord(term: "how about you", translation: "ask the same question back", example: "I'm doing well. How about you?"),
                SavedWord(term: "it was nice talking to you", translation: "polite way to end a short chat", example: "I have to go. It was nice talking to you.")
            ]
        ),
        BeginnerLesson(
            id: "english-ordering",
            unit: 1,
            title: "Order at a cafe",
            subtitle: "Order a drink, add a size, and answer the barista",
            icon: "cup.and.saucer.fill",
            accent: .amber,
            minutes: 5,
            steps: [
                LessonStep(id: "english-cafe-1", kind: .teach, title: "Make a polite order", prompt: "Could I have a small coffee, please?", helper: "Could I have is polite and useful in cafes and shops.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-cafe-2", kind: .choice, title: "Choose the polite request", prompt: "You want tea.", helper: "Pick the sentence that sounds ready to use.", choices: ["Could I have a tea, please?", "I tea now.", "Give tea to me."], correctAnswer: "Could I have a tea, please?"),
                LessonStep(id: "english-cafe-3", kind: .speak, title: "Make it yours", prompt: "Could I have a medium latte, please?", helper: "Swap medium latte for water, tea, coffee, or a sandwich.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-cafe-4", kind: .choice, title: "Answer the barista", prompt: "Anything else?", helper: "Choose the short answer you can say at the counter.", choices: ["No, that's all. Thank you.", "Else no all.", "Coffee is finished."], correctAnswer: "No, that's all. Thank you.")
            ],
            savedWords: [
                SavedWord(term: "could I have", translation: "polite way to ask for something", example: "Could I have a small coffee, please?"),
                SavedWord(term: "for here or to go", translation: "barista question about where you will drink or eat", example: "For here or to go?"),
                SavedWord(term: "no, that's all", translation: "say this when you do not want anything else", example: "No, that's all. Thank you.")
            ]
        ),
        BeginnerLesson(
            id: "english-directions",
            unit: 1,
            title: "Ask for directions",
            subtitle: "Find a place and understand simple directions",
            icon: "map.fill",
            accent: .violet,
            minutes: 4,
            steps: [
                LessonStep(id: "english-directions-1", kind: .teach, title: "Ask politely", prompt: "Excuse me, where is the nearest station?", helper: "Start with excuse me when you need a stranger's attention.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-directions-2", kind: .choice, title: "Check the meaning", prompt: "nearest", helper: "What does nearest mean?", choices: ["closest", "most expensive", "closed"], correctAnswer: "closest"),
                LessonStep(id: "english-directions-3", kind: .speak, title: "Change the place", prompt: "Excuse me, where is the nearest bus stop?", helper: "Swap bus stop for station, cafe, pharmacy, or restroom.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-directions-4", kind: .choice, title: "Understand the answer", prompt: "Go straight and turn left.", helper: "Choose the meaning of the direction.", choices: ["Walk ahead, then go left.", "Stop here and wait.", "Buy a ticket first."], correctAnswer: "Walk ahead, then go left.")
            ],
            savedWords: [
                SavedWord(term: "excuse me", translation: "polite way to get attention", example: "Excuse me, where is the station?"),
                SavedWord(term: "where is the nearest", translation: "ask for the closest place", example: "Where is the nearest cafe?"),
                SavedWord(term: "turn left", translation: "go to the left side", example: "Go straight and turn left.")
            ]
        ),
        BeginnerLesson(
            id: "english-ask-for-help",
            unit: 1,
            title: "Ask for help or clarification",
            subtitle: "Ask someone to repeat, slow down, or help with a problem",
            icon: "questionmark.circle.fill",
            accent: .blue,
            minutes: 5,
            steps: [
                LessonStep(id: "english-help-1", kind: .teach, title: "Ask for help", prompt: "Could you help me, please?", helper: "Use could you for polite requests to another person.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-help-2", kind: .choice, title: "Ask them to repeat", prompt: "You did not understand.", helper: "Choose the useful clarification question.", choices: ["Could you say that again, please?", "You say again me?", "Again word please me."], correctAnswer: "Could you say that again, please?"),
                LessonStep(id: "english-help-3", kind: .speak, title: "Ask for slower speech", prompt: "Sorry, could you speak more slowly?", helper: "This helps when someone speaks too fast.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-help-4", kind: .choice, title: "Explain the problem", prompt: "Your phone has no battery.", helper: "Pick the clear sentence.", choices: ["My phone is out of battery.", "My phone no energy.", "Phone finish battery."], correctAnswer: "My phone is out of battery.")
            ],
            savedWords: [
                SavedWord(term: "could you help me", translation: "polite way to ask for help", example: "Could you help me, please?"),
                SavedWord(term: "could you say that again", translation: "ask someone to repeat", example: "Could you say that again, please?"),
                SavedWord(term: "could you speak more slowly", translation: "ask someone to slow down", example: "Sorry, could you speak more slowly?"),
                SavedWord(term: "out of battery", translation: "has no battery power left", example: "My phone is out of battery.")
            ]
        ),
        BeginnerLesson(
            id: "english-making-plans",
            unit: 1,
            title: "Make plans",
            subtitle: "Suggest a time, place, and confirm the plan",
            icon: "calendar.badge.plus",
            accent: .violet,
            minutes: 5,
            steps: [
                LessonStep(id: "english-plans-1", kind: .teach, title: "Suggest a plan", prompt: "Would you like to meet tomorrow?", helper: "Would you like to is a polite way to invite someone.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-plans-2", kind: .choice, title: "Invite someone", prompt: "Invite someone for coffee.", helper: "Pick the friendly invitation.", choices: ["Would you like to get coffee?", "You coffee with me now?", "Coffee you like meet?"], correctAnswer: "Would you like to get coffee?"),
                LessonStep(id: "english-plans-3", kind: .speak, title: "Add time and place", prompt: "Let's meet at six near the station.", helper: "This reuses the directions lesson and makes the plan specific.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-plans-4", kind: .choice, title: "Confirm the time", prompt: "Does six work for you?", helper: "Choose the natural yes response.", choices: ["Yes, that works for me.", "Six works me yes.", "I am six good."], correctAnswer: "Yes, that works for me.")
            ],
            savedWords: [
                SavedWord(term: "would you like to", translation: "polite way to invite someone", example: "Would you like to meet tomorrow?"),
                SavedWord(term: "let's meet at", translation: "suggest a meeting time or place", example: "Let's meet at six near the station."),
                SavedWord(term: "does six work for you", translation: "ask if the time is okay", example: "Does six work for you?"),
                SavedWord(term: "that works for me", translation: "say a plan is okay", example: "Yes, that works for me.")
            ]
        ),
        BeginnerLesson(
            id: "english-daily-routine",
            unit: 1,
            title: "Talk about daily routine",
            subtitle: "Say what you usually do before and after work",
            icon: "clock.fill",
            accent: .mint,
            minutes: 5,
            steps: [
                LessonStep(id: "english-routine-1", kind: .teach, title: "Daily habits", prompt: "I usually wake up at seven.", helper: "Use usually for something you do most days.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-routine-2", kind: .choice, title: "Choose the natural sentence", prompt: "You want to describe your morning.", helper: "Pick the sentence that sounds natural.", choices: ["I usually wake up at seven.", "I wake usually at seven.", "I am wake at seven."], correctAnswer: "I usually wake up at seven."),
                LessonStep(id: "english-routine-3", kind: .speak, title: "Make it personal", prompt: "I usually drink coffee before work.", helper: "Change drink coffee to check messages, exercise, or study English.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-routine-4", kind: .choice, title: "Answer a routine question", prompt: "What do you usually do after work?", helper: "Choose the beginner answer that sounds natural.", choices: ["I usually study English after work.", "I am after work study usually.", "After work is study me."], correctAnswer: "I usually study English after work.")
            ],
            savedWords: [
                SavedWord(term: "I usually", translation: "start a sentence about a normal habit", example: "I usually study English at night."),
                SavedWord(term: "before work", translation: "earlier than work starts", example: "I usually drink coffee before work."),
                SavedWord(term: "after work", translation: "later than work ends", example: "I usually study English after work."),
                SavedWord(term: "what do you usually do", translation: "ask about someone's regular habit", example: "What do you usually do after work?")
            ]
        ),
        BeginnerLesson(
            id: "english-shopping-prices",
            unit: 1,
            title: "Handle shopping and prices",
            subtitle: "Ask the price, size, and payment question",
            icon: "bag.fill",
            accent: .amber,
            minutes: 5,
            steps: [
                LessonStep(id: "english-shopping-1", kind: .teach, title: "Ask the price", prompt: "How much is this?", helper: "Use this when you are holding or pointing at one item.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-shopping-2", kind: .choice, title: "Pick the right question", prompt: "You want to know the price of a shirt.", helper: "Choose the most useful question.", choices: ["How much is this?", "How many this?", "How price this?"], correctAnswer: "How much is this?"),
                LessonStep(id: "english-shopping-3", kind: .speak, title: "Ask for a size", prompt: "Do you have this in a smaller size?", helper: "Smaller can become larger, blue, black, or another color.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-shopping-4", kind: .choice, title: "Respond to the price", prompt: "The price is too high.", helper: "Pick the natural sentence.", choices: ["That's a little too expensive for me.", "Price very big for me.", "I am expensive no."], correctAnswer: "That's a little too expensive for me.")
            ],
            savedWords: [
                SavedWord(term: "how much is this", translation: "ask for the price of one thing", example: "How much is this jacket?"),
                SavedWord(term: "do you have this in", translation: "ask for a size or color", example: "Do you have this in a smaller size?"),
                SavedWord(term: "too expensive for me", translation: "say the price is higher than you want", example: "That's a little too expensive for me."),
                SavedWord(term: "can I pay by card", translation: "ask if card payment is okay", example: "Can I pay by card?")
            ]
        ),
        BeginnerLesson(
            id: "english-work-chat",
            unit: 1,
            title: "Introduce yourself at work",
            subtitle: "Say your role and ask about another person's team",
            icon: "briefcase.fill",
            accent: .blue,
            minutes: 5,
            steps: [
                LessonStep(id: "english-work-1", kind: .teach, title: "Say your role", prompt: "Hi, I'm Maya. I work in product.", helper: "Use I work in plus your field or team.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-work-2", kind: .speak, title: "Ask about their team", prompt: "What team are you on?", helper: "Use this to ask a coworker where they work in the company.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-work-3", kind: .speak, title: "Connect your work", prompt: "I work with the design team. What do you do?", helper: "This reuses What do you do? for a simple workplace chat.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-work-4", kind: .speak, title: "Close the introduction", prompt: "Nice to meet you. I look forward to working with you.", helper: "Use this when you meet a new teammate or join a new group.", choices: [], correctAnswer: nil)
            ],
            savedWords: [
                SavedWord(term: "I work in", translation: "say your field, role, or team", example: "I work in product."),
                SavedWord(term: "what team are you on", translation: "ask about someone's team at work", example: "What team are you on?"),
                SavedWord(term: "I work with", translation: "say who you work with", example: "I work with the design team."),
                SavedWord(term: "I look forward to working with you", translation: "polite workplace closing", example: "Nice to meet you. I look forward to working with you.")
            ]
        ),
        BeginnerLesson(
            id: "english-review",
            unit: 1,
            title: "Review starter conversation",
            subtitle: "Combine introductions, cafes, directions, help, plans, routine, shopping, and work",
            icon: "checkmark.seal.fill",
            accent: .mint,
            minutes: 8,
            steps: [
                LessonStep(id: "english-review-1", kind: .teach, title: "Put it together", prompt: "Hi, I'm Maya. Nice to meet you. How's your day going?", helper: "You can now open a simple conversation and keep it moving.", choices: [], correctAnswer: nil),
                LessonStep(id: "english-review-2", kind: .choice, title: "Cafe exchange", prompt: "Could I have a small coffee, please?", helper: "What might the barista ask next?", choices: ["Sure. For here or to go?", "I am coffee.", "Where is Maya?"], correctAnswer: "Sure. For here or to go?"),
                LessonStep(id: "english-review-3", kind: .choice, title: "Directions check", prompt: "Where is the nearest station?", helper: "Choose the answer that gives directions.", choices: ["Go straight and turn left.", "Nice to meet you too.", "No, that's all."], correctAnswer: "Go straight and turn left."),
                LessonStep(id: "english-review-4", kind: .choice, title: "Clarify politely", prompt: "You did not understand the answer.", helper: "Choose the useful follow-up.", choices: ["Could you say that again, please?", "You answer again me.", "I no answer."], correctAnswer: "Could you say that again, please?"),
                LessonStep(id: "english-review-5", kind: .choice, title: "Confirm plans", prompt: "Does six work for you?", helper: "Choose a natural reply.", choices: ["Yes, that works for me.", "Six is like meet.", "I am meeting six yes."], correctAnswer: "Yes, that works for me."),
                LessonStep(id: "english-review-6", kind: .speak, title: "Final speaking prompt", prompt: "Hi, I'm ... Nice to meet you. I'm learning English for work. Could I have a coffee, please? Later, let's meet at six near the station.", helper: "Say the mini conversation with your own name and a clear plan.", choices: [], correctAnswer: nil)
            ],
            savedWords: [
                SavedWord(term: "for here or to go", translation: "cafe question about where you will drink or eat", example: "Sure. For here or to go?"),
                SavedWord(term: "go straight and turn left", translation: "simple direction answer", example: "The station? Go straight and turn left."),
                SavedWord(term: "could you say that again", translation: "ask someone to repeat", example: "Could you say that again, please?"),
                SavedWord(term: "that works for me", translation: "say a plan is okay", example: "Yes, that works for me."),
                SavedWord(term: "I look forward to working with you", translation: "polite workplace closing", example: "Nice to meet you. I look forward to working with you.")
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
