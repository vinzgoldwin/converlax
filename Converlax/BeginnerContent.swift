import Foundation

enum BeginnerContent {
    static let lessons: [BeginnerLesson] = englishLessons

    static func lessons(for language: TargetLanguage) -> [BeginnerLesson] {
        switch language {
        case .english: englishLessons
        case .french: frenchLessons
        case .spanish, .italian: []
        }
    }

    static func firstLessonID(for language: TargetLanguage) -> String {
        lessons(for: language).first?.id ?? englishLessons[0].id
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
            lesson(id: "english-work-chat") ?? englishLessons[12]
        case .french, .spanish, .italian:
            lesson(id: "beginner-hotel") ?? frenchLessons[4]
        }
    }

    private static func phrase(_ term: String, _ translation: String, _ example: String) -> SavedWord {
        SavedWord(term: term, translation: translation, example: example)
    }

    private static func englishConversationLesson(
        id: String,
        unit: Int,
        title: String,
        subtitle: String,
        icon: String,
        accent: LessonAccent,
        minutes: Int,
        goal: String,
        model: String,
        modelHelper: String,
        speak: String,
        speakHelper: String,
        alternative: String,
        alternativeHelper: String,
        mistakePrompt: String,
        correctAnswer: String,
        commonMistake: String,
        roleplay: String,
        roleplayHelper: String,
        followUp: String,
        followUpHelper: String,
        savedWords: [SavedWord],
        extraMistake: String = ""
    ) -> BeginnerLesson {
        let answerChoices = [correctAnswer, commonMistake, extraMistake].filter { !$0.isEmpty }

        return BeginnerLesson(
            id: id,
            unit: unit,
            title: title,
            subtitle: subtitle,
            icon: icon,
            accent: accent,
            minutes: minutes,
            steps: [
                LessonStep(id: "\(id)-goal", kind: .teach, title: "Speaking goal", prompt: goal, helper: "Say the goal first so your brain knows the job.", choices: [], correctAnswer: nil),
                LessonStep(id: "\(id)-model", kind: .teach, title: "Listen and repeat", prompt: model, helper: modelHelper, choices: [], correctAnswer: nil),
                LessonStep(id: "\(id)-speak", kind: .speak, title: "Say it your way", prompt: speak, helper: speakHelper, choices: [], correctAnswer: nil),
                LessonStep(id: "\(id)-alternative", kind: .speak, title: "Natural alternative", prompt: alternative, helper: alternativeHelper, choices: [], correctAnswer: nil),
                LessonStep(id: "\(id)-mistake", kind: .choice, title: "Common mistake", prompt: mistakePrompt, helper: "Choose the clear line, then say it out loud.", choices: answerChoices, correctAnswer: correctAnswer),
                LessonStep(id: "\(id)-roleplay", kind: .speak, title: "Roleplay", prompt: roleplay, helper: roleplayHelper, choices: [], correctAnswer: nil),
                LessonStep(id: "\(id)-follow-up", kind: .speak, title: "Follow-up practice", prompt: followUp, helper: followUpHelper, choices: [], correctAnswer: nil)
            ],
            savedWords: savedWords
        )
    }

    private static let englishLessons: [BeginnerLesson] = [
        englishConversationLesson(
            id: "english-introductions",
            unit: 1,
            title: "Introduce yourself",
            subtitle: "Start a first conversation without freezing",
            icon: "person.wave.2.fill",
            accent: .blue,
            minutes: 5,
            goal: "My goal is to introduce myself in two calm sentences.",
            model: "Hi, I'm Maya. Nice to meet you.",
            modelHelper: "Use this in class, at work, while traveling, or when a friend introduces you.",
            speak: "Hi, I'm Alex. I'm from Indonesia.",
            speakHelper: "Change Alex and Indonesia to your real name and place.",
            alternative: "Good to meet you. I'm Alex.",
            alternativeHelper: "A little more casual than nice to meet you.",
            mistakePrompt: "You meet someone for the first time.",
            correctAnswer: "Hi, I'm Alex. Nice to meet you.",
            commonMistake: "Hi, I am Alex. Nice meet you.",
            roleplay: "A new classmate says, Hi, I'm Sara. What should I call you?",
            roleplayHelper: "Answer with your name, then ask their name back.",
            followUp: "I'm learning English because I want to speak more confidently.",
            followUpHelper: "Swap the reason: for work, for travel, for my studies, or for friends.",
            savedWords: [
                phrase("nice to meet you", "polite phrase for a first meeting", "Hi, I'm Maya. Nice to meet you."),
                phrase("I'm from", "use this to say your city or country", "I'm from Indonesia."),
                phrase("what should I call you", "ask what name someone prefers", "What should I call you?"),
                phrase("I'm learning English because", "explain your reason simply", "I'm learning English because I want to travel.")
            ],
            extraMistake: "My name Alex and nice meet."
        ),
        englishConversationLesson(
            id: "english-small-talk",
            unit: 1,
            title: "Keep small talk moving",
            subtitle: "Answer a check-in and ask back naturally",
            icon: "bubble.left.fill",
            accent: .mint,
            minutes: 5,
            goal: "My goal is to answer a simple check-in and ask one question back.",
            model: "Pretty good, thanks. How about you?",
            modelHelper: "This keeps the conversation open without needing a long answer.",
            speak: "I'm doing well. How's your day going?",
            speakHelper: "Use doing well for a calm, friendly answer.",
            alternative: "Not bad. How about you?",
            alternativeHelper: "This sounds natural when your day is okay, not amazing.",
            mistakePrompt: "Someone asks, How's your day going?",
            correctAnswer: "Pretty good, thanks. How about you?",
            commonMistake: "I am day good. And you?",
            roleplay: "A neighbor says, Morning. How are you today?",
            roleplayHelper: "Answer with one short feeling and ask back.",
            followUp: "It was nice talking to you. See you later.",
            followUpHelper: "Use this to close small talk politely.",
            savedWords: [
                phrase("how's your day going", "friendly question about someone's day", "Hi, how's your day going?"),
                phrase("pretty good, thanks", "natural short answer when you feel okay", "Pretty good, thanks."),
                phrase("how about you", "ask the same question back", "I'm doing well. How about you?"),
                phrase("it was nice talking to you", "polite way to end a short chat", "It was nice talking to you. See you later.")
            ],
            extraMistake: "My day is going nice you?"
        ),
        englishConversationLesson(
            id: "english-daily-routine",
            unit: 1,
            title: "Talk about your day",
            subtitle: "Say a normal routine without overthinking",
            icon: "clock.fill",
            accent: .mint,
            minutes: 5,
            goal: "My goal is to describe one normal day in simple English.",
            model: "I usually start work around nine.",
            modelHelper: "Usually means most days. Around makes the time feel natural.",
            speak: "I usually study English after work.",
            speakHelper: "Change study English to exercise, cook dinner, or call my family.",
            alternative: "Most days, I have coffee before work.",
            alternativeHelper: "Most days is a natural alternative to usually.",
            mistakePrompt: "You want to describe a daily habit.",
            correctAnswer: "I usually study English at night.",
            commonMistake: "I study English in night usually.",
            roleplay: "A friend asks, What do you usually do after work?",
            roleplayHelper: "Answer with one habit, then ask the same question back.",
            followUp: "After work, I usually rest for a bit, then I study English.",
            followUpHelper: "Use then to connect two easy actions.",
            savedWords: [
                phrase("I usually", "start a sentence about a normal habit", "I usually study English at night."),
                phrase("around nine", "about nine o'clock, not exact", "I usually start work around nine."),
                phrase("after work", "later than work ends", "I study English after work."),
                phrase("for a bit", "for a short time", "I rest for a bit, then I study.")
            ],
            extraMistake: "Usually I am study at night."
        ),
        englishConversationLesson(
            id: "english-free-time",
            unit: 1,
            title: "Talk about free time",
            subtitle: "Share likes and ask a follow-up",
            icon: "sparkles",
            accent: .violet,
            minutes: 5,
            goal: "My goal is to say what I like and ask about the other person.",
            model: "I like watching movies when I have free time.",
            modelHelper: "This is easy, personal, and useful for friendly conversation.",
            speak: "I like walking around the city on weekends.",
            speakHelper: "Change walking around the city to your real activity.",
            alternative: "I'm into cooking these days.",
            alternativeHelper: "I'm into means I like it right now.",
            mistakePrompt: "You want to talk about a hobby.",
            correctAnswer: "I like watching movies.",
            commonMistake: "I like watch movies.",
            roleplay: "A coworker asks, What do you do for fun?",
            roleplayHelper: "Answer with one activity and ask, How about you?",
            followUp: "How about you? What do you like doing on weekends?",
            followUpHelper: "Ask a follow-up so the conversation does not stop.",
            savedWords: [
                phrase("I like watching", "say an activity you enjoy", "I like watching movies."),
                phrase("when I have free time", "when you are not busy", "I read when I have free time."),
                phrase("I'm into", "casual way to say you like something", "I'm into cooking these days."),
                phrase("what do you do for fun", "ask about free-time activities", "What do you do for fun?")
            ],
            extraMistake: "I am like movies."
        ),
        englishConversationLesson(
            id: "english-making-plans",
            unit: 1,
            title: "Make simple plans",
            subtitle: "Invite, choose a time, and confirm",
            icon: "calendar.badge.plus",
            accent: .blue,
            minutes: 6,
            goal: "My goal is to suggest a simple plan and confirm the details.",
            model: "Would you like to get coffee tomorrow?",
            modelHelper: "Would you like to is polite and friendly.",
            speak: "Let's meet at six near the station.",
            speakHelper: "Use let's meet at plus a time and place.",
            alternative: "Does Saturday afternoon work for you?",
            alternativeHelper: "This checks if the time is okay for the other person.",
            mistakePrompt: "You want to invite someone for coffee.",
            correctAnswer: "Would you like to get coffee tomorrow?",
            commonMistake: "You want coffee tomorrow with me?",
            roleplay: "A classmate says, I'd like to practice English more. Suggest a time.",
            roleplayHelper: "Invite them, give a time, and check if it works.",
            followUp: "Great, see you there at six.",
            followUpHelper: "Close the plan with the time or place.",
            savedWords: [
                phrase("would you like to", "polite way to invite someone", "Would you like to meet tomorrow?"),
                phrase("let's meet at", "suggest a meeting time or place", "Let's meet at six near the station."),
                phrase("does Saturday work for you", "ask if a day is okay", "Does Saturday work for you?"),
                phrase("see you there", "confirm the meeting place", "Great, see you there at six.")
            ],
            extraMistake: "Let's meeting at six."
        ),
        englishConversationLesson(
            id: "english-review-first-chat",
            unit: 1,
            title: "First chat practice",
            subtitle: "Put introductions, small talk, and plans together",
            icon: "checkmark.seal.fill",
            accent: .amber,
            minutes: 7,
            goal: "My goal is to keep a first conversation going for one minute.",
            model: "Hi, I'm Alex. Nice to meet you. How's your day going?",
            modelHelper: "This opens a real conversation with two safe lines.",
            speak: "I'm from Indonesia, and I'm learning English for work.",
            speakHelper: "Add one detail after and to sound more complete.",
            alternative: "Good to meet you. I'm trying to speak more confidently.",
            alternativeHelper: "This names your real speaking goal without sounding formal.",
            mistakePrompt: "You want to continue after saying your name.",
            correctAnswer: "Nice to meet you. How's your day going?",
            commonMistake: "Nice meet you. Your day how?",
            roleplay: "You meet a new person at a language meetup. Start the conversation.",
            roleplayHelper: "Use your name, one detail, and one question.",
            followUp: "Would you like to practice together sometime?",
            followUpHelper: "End by making a simple future plan.",
            savedWords: [
                phrase("I'm trying to", "say what you are working on", "I'm trying to speak more confidently."),
                phrase("for work", "explain a practical reason", "I'm learning English for work."),
                phrase("sometime", "not a fixed time yet", "Would you like to practice together sometime?"),
                phrase("language meetup", "a place where people practice languages", "I met Sara at a language meetup.")
            ],
            extraMistake: "I learning English because work."
        ),
        englishConversationLesson(
            id: "english-ordering",
            unit: 2,
            title: "Order food and drinks",
            subtitle: "Order clearly and answer counter questions",
            icon: "cup.and.saucer.fill",
            accent: .amber,
            minutes: 6,
            goal: "My goal is to order one item politely and finish the order.",
            model: "Could I have a small coffee, please?",
            modelHelper: "Could I have is useful in cafes, bakeries, and casual restaurants.",
            speak: "Could I have a chicken sandwich and a bottle of water, please?",
            speakHelper: "Say the item slowly. Use and to add one more thing.",
            alternative: "I'll have the soup, please.",
            alternativeHelper: "I'll have is natural when ordering from a menu.",
            mistakePrompt: "You want tea at a counter.",
            correctAnswer: "Could I have a tea, please?",
            commonMistake: "Give me tea.",
            roleplay: "The barista asks, Anything else?",
            roleplayHelper: "Say no if you are finished, or add one item.",
            followUp: "No, that's all. Thank you.",
            followUpHelper: "A short close is enough at the counter.",
            savedWords: [
                phrase("could I have", "polite way to ask for something", "Could I have a small coffee, please?"),
                phrase("I'll have", "natural way to order from a menu", "I'll have the soup, please."),
                phrase("anything else", "question asking if you want more", "Anything else?"),
                phrase("no, that's all", "say you do not want more", "No, that's all. Thank you.")
            ],
            extraMistake: "I want one tea for me please now."
        ),
        englishConversationLesson(
            id: "english-restaurant-check",
            unit: 2,
            title: "Ask restaurant questions",
            subtitle: "Check a menu, allergies, and the bill",
            icon: "fork.knife",
            accent: .violet,
            minutes: 6,
            goal: "My goal is to ask one clear question before I order.",
            model: "Does this have nuts in it?",
            modelHelper: "Use does this have when you need to check ingredients.",
            speak: "Is this dish spicy?",
            speakHelper: "This is a simple yes-or-no question.",
            alternative: "Could we get the bill, please?",
            alternativeHelper: "Use this when you are ready to pay at a table.",
            mistakePrompt: "You need to ask if the food is spicy.",
            correctAnswer: "Is this dish spicy?",
            commonMistake: "This food have spicy?",
            roleplay: "A server recommends a dish. Ask one question before ordering.",
            roleplayHelper: "Ask about spice, meat, nuts, or the portion size.",
            followUp: "I'll have that, please, but without onions.",
            followUpHelper: "Use without to remove one ingredient.",
            savedWords: [
                phrase("does this have", "ask about ingredients", "Does this have nuts in it?"),
                phrase("is this dish spicy", "ask about spice level", "Is this dish spicy?"),
                phrase("without onions", "ask to remove an ingredient", "I'll have that without onions."),
                phrase("could we get the bill", "ask to pay at a restaurant", "Could we get the bill, please?")
            ],
            extraMistake: "Can we have billing?"
        ),
        englishConversationLesson(
            id: "english-directions",
            unit: 2,
            title: "Ask for directions",
            subtitle: "Find a place and check the route",
            icon: "map.fill",
            accent: .blue,
            minutes: 6,
            goal: "My goal is to ask for directions and repeat the answer back.",
            model: "Excuse me, where is the nearest station?",
            modelHelper: "Excuse me helps you get a stranger's attention politely.",
            speak: "Is it far from here?",
            speakHelper: "Ask this if you need to know the distance.",
            alternative: "Could you point me in the right direction?",
            alternativeHelper: "This is useful when you do not need detailed directions.",
            mistakePrompt: "You need the closest bus stop.",
            correctAnswer: "Where is the nearest bus stop?",
            commonMistake: "Where nearest bus stop is?",
            roleplay: "A person says, Go straight, then turn left at the bank.",
            roleplayHelper: "Repeat the main direction to check you understood.",
            followUp: "So I go straight and turn left at the bank?",
            followUpHelper: "Repeat with so to confirm directions.",
            savedWords: [
                phrase("excuse me", "polite way to get attention", "Excuse me, where is the station?"),
                phrase("where is the nearest", "ask for the closest place", "Where is the nearest cafe?"),
                phrase("is it far from here", "ask about distance", "Is it far from here?"),
                phrase("turn left at", "direction with a landmark", "Turn left at the bank.")
            ],
            extraMistake: "Where is station nearest?"
        ),
        englishConversationLesson(
            id: "english-transport-ticket",
            unit: 2,
            title: "Buy a ticket or ride",
            subtitle: "Ask for tickets, stops, and arrival time",
            icon: "tram.fill",
            accent: .mint,
            minutes: 6,
            goal: "My goal is to ask for a ticket and check where to get off.",
            model: "One ticket to City Hall, please.",
            modelHelper: "This works at a ticket counter or station kiosk.",
            speak: "Does this bus go to the airport?",
            speakHelper: "Use does this bus go to plus the place.",
            alternative: "How many stops is it from here?",
            alternativeHelper: "This helps you know when to get off.",
            mistakePrompt: "You are checking if a train goes downtown.",
            correctAnswer: "Does this train go downtown?",
            commonMistake: "This train go downtown?",
            roleplay: "A driver asks, Where are you going?",
            roleplayHelper: "Say the destination and ask the approximate time.",
            followUp: "How long does it take to get there?",
            followUpHelper: "Use this for buses, taxis, trains, and rideshares.",
            savedWords: [
                phrase("one ticket to", "ask for a ticket to a place", "One ticket to City Hall, please."),
                phrase("does this bus go to", "check a route", "Does this bus go to the airport?"),
                phrase("how many stops", "ask about stops before your destination", "How many stops is it from here?"),
                phrase("how long does it take", "ask about travel time", "How long does it take to get there?")
            ],
            extraMistake: "How long time to there?"
        ),
        englishConversationLesson(
            id: "english-shopping-prices",
            unit: 2,
            title: "Shop and pay",
            subtitle: "Ask price, size, and payment questions",
            icon: "bag.fill",
            accent: .amber,
            minutes: 6,
            goal: "My goal is to ask about a product and pay without panic.",
            model: "How much is this?",
            modelHelper: "Use this when you point to one item.",
            speak: "Do you have this in a smaller size?",
            speakHelper: "Change smaller size to larger size, black, blue, or another color.",
            alternative: "Can I pay by card?",
            alternativeHelper: "Ask this before you tap or insert your card.",
            mistakePrompt: "The price is higher than you want.",
            correctAnswer: "That's a little too expensive for me.",
            commonMistake: "It is too much expensive for me.",
            roleplay: "A shop assistant says, Can I help you find anything?",
            roleplayHelper: "Ask for a size, a color, or the price.",
            followUp: "I'll think about it. Thank you.",
            followUpHelper: "A polite way to leave without buying.",
            savedWords: [
                phrase("how much is this", "ask the price of one thing", "How much is this jacket?"),
                phrase("do you have this in", "ask for a size or color", "Do you have this in black?"),
                phrase("can I pay by card", "ask if card payment is okay", "Can I pay by card?"),
                phrase("I'll think about it", "polite way to pause before buying", "I'll think about it. Thank you.")
            ],
            extraMistake: "Can I card pay?"
        ),
        englishConversationLesson(
            id: "english-ask-for-help",
            unit: 2,
            title: "Ask for help",
            subtitle: "Get someone to repeat, slow down, or explain",
            icon: "questionmark.circle.fill",
            accent: .violet,
            minutes: 6,
            goal: "My goal is to ask for help when I do not understand.",
            model: "Could you say that again, please?",
            modelHelper: "This is one of the most important speaking-confidence phrases.",
            speak: "Sorry, could you speak more slowly?",
            speakHelper: "Use sorry softly. You are not apologizing too much; you are being polite.",
            alternative: "Could you show me what you mean?",
            alternativeHelper: "Use this when pointing or showing is easier than explaining.",
            mistakePrompt: "Someone speaks too fast.",
            correctAnswer: "Could you speak more slowly, please?",
            commonMistake: "You speak slow again?",
            roleplay: "You are at a ticket machine and feel stuck. Ask a stranger for help.",
            roleplayHelper: "Start with excuse me, then ask for help.",
            followUp: "Thanks, I understand now.",
            followUpHelper: "Close the help exchange clearly.",
            savedWords: [
                phrase("could you say that again", "ask someone to repeat", "Could you say that again, please?"),
                phrase("could you speak more slowly", "ask someone to slow down", "Could you speak more slowly, please?"),
                phrase("could you show me", "ask someone to demonstrate", "Could you show me what you mean?"),
                phrase("I understand now", "say the problem is solved", "Thanks, I understand now.")
            ],
            extraMistake: "Again please you say me."
        ),
        englishConversationLesson(
            id: "english-work-chat",
            unit: 3,
            title: "Introduce yourself at work",
            subtitle: "Say your role, team, and first question",
            icon: "briefcase.fill",
            accent: .blue,
            minutes: 6,
            goal: "My goal is to introduce myself at work in a simple, confident way.",
            model: "Hi, I'm Maya. I work in product.",
            modelHelper: "Use I work in plus a team, department, or field.",
            speak: "I work with the design team. What team are you on?",
            speakHelper: "This connects your role to the other person.",
            alternative: "I'm new here, so I'm still learning how everything works.",
            alternativeHelper: "This is useful when you join a new company or group.",
            mistakePrompt: "You are saying your department.",
            correctAnswer: "I work in marketing.",
            commonMistake: "I work at marketing.",
            roleplay: "A new teammate asks, What do you do here?",
            roleplayHelper: "Say your role, then ask about their team.",
            followUp: "Nice to meet you. I look forward to working with you.",
            followUpHelper: "Good for first meetings with coworkers.",
            savedWords: [
                phrase("I work in", "say your field or team", "I work in product."),
                phrase("what team are you on", "ask about someone's team", "What team are you on?"),
                phrase("I'm new here", "say you recently joined", "I'm new here, so I'm still learning."),
                phrase("I look forward to working with you", "polite workplace closing", "Nice to meet you. I look forward to working with you.")
            ],
            extraMistake: "I am work in marketing."
        ),
        englishConversationLesson(
            id: "english-meeting-check-in",
            unit: 3,
            title: "Join a meeting",
            subtitle: "Start, check audio, and ask for a recap",
            icon: "person.2.fill",
            accent: .mint,
            minutes: 6,
            goal: "My goal is to join a meeting and handle the first minute.",
            model: "Hi everyone, can you hear me okay?",
            modelHelper: "This is natural for online and phone meetings.",
            speak: "Sorry I'm a little late. What did I miss?",
            speakHelper: "Use this if you join late and need a quick recap.",
            alternative: "Could you give me a quick recap?",
            alternativeHelper: "Quick recap means a short summary.",
            mistakePrompt: "You need to check your audio.",
            correctAnswer: "Can you hear me okay?",
            commonMistake: "You can hear me okay?",
            roleplay: "You enter a video meeting. Greet the group and check your sound.",
            roleplayHelper: "Keep it short and professional.",
            followUp: "Thanks. I'm ready now.",
            followUpHelper: "Use this when the tech issue is solved.",
            savedWords: [
                phrase("can you hear me okay", "check audio in a call", "Hi everyone, can you hear me okay?"),
                phrase("what did I miss", "ask for what happened before you arrived", "Sorry I'm late. What did I miss?"),
                phrase("quick recap", "short summary", "Could you give me a quick recap?"),
                phrase("I'm ready now", "say you can continue", "Thanks. I'm ready now.")
            ],
            extraMistake: "What I missed?"
        ),
        englishConversationLesson(
            id: "english-phone-call",
            unit: 3,
            title: "Handle phone and video calls",
            subtitle: "Open, clarify, and close calls",
            icon: "phone.fill",
            accent: .violet,
            minutes: 6,
            goal: "My goal is to manage a short phone or video call.",
            model: "Hi, this is Alex speaking.",
            modelHelper: "Use this is when you answer a call professionally.",
            speak: "Sorry, the connection is not very clear.",
            speakHelper: "Say this when the audio or video is bad.",
            alternative: "Could you repeat the last part?",
            alternativeHelper: "Use last part when you understood most of the sentence.",
            mistakePrompt: "You answer a work call.",
            correctAnswer: "Hi, this is Alex speaking.",
            commonMistake: "Hi, I am Alex speaking.",
            roleplay: "A client calls and the audio cuts out. Ask them to repeat.",
            roleplayHelper: "Name the problem, then ask for the line again.",
            followUp: "Thanks for calling. Talk to you soon.",
            followUpHelper: "A simple call closing that works in many situations.",
            savedWords: [
                phrase("this is Alex speaking", "professional way to answer a call", "Hi, this is Alex speaking."),
                phrase("the connection is not very clear", "say audio or video is bad", "Sorry, the connection is not very clear."),
                phrase("repeat the last part", "ask for the end again", "Could you repeat the last part?"),
                phrase("talk to you soon", "friendly call closing", "Thanks for calling. Talk to you soon.")
            ],
            extraMistake: "The connection not clear very."
        ),
        englishConversationLesson(
            id: "english-explain-problem",
            unit: 3,
            title: "Explain a problem",
            subtitle: "Say what happened and what you need",
            icon: "exclamationmark.bubble.fill",
            accent: .amber,
            minutes: 6,
            goal: "My goal is to explain a simple problem without getting stuck.",
            model: "I'm having a problem with my account.",
            modelHelper: "I'm having a problem with is a flexible opener.",
            speak: "It says my password is incorrect, but I'm sure it's right.",
            speakHelper: "Use it says when an app or website shows an error.",
            alternative: "Could you help me fix it?",
            alternativeHelper: "Finish with the help you need.",
            mistakePrompt: "You need help with your account.",
            correctAnswer: "I'm having a problem with my account.",
            commonMistake: "I have problem in my account.",
            roleplay: "Customer support asks, What seems to be the problem?",
            roleplayHelper: "Say the problem and what you tried.",
            followUp: "I tried again, but it still doesn't work.",
            followUpHelper: "This helps support understand the problem is not solved.",
            savedWords: [
                phrase("I'm having a problem with", "open a problem explanation", "I'm having a problem with my account."),
                phrase("it says", "report an error message", "It says my password is incorrect."),
                phrase("could you help me fix it", "ask for help solving a problem", "Could you help me fix it?"),
                phrase("it still doesn't work", "say the problem continues", "I tried again, but it still doesn't work.")
            ],
            extraMistake: "It still no work."
        ),
        englishConversationLesson(
            id: "english-give-opinion",
            unit: 3,
            title: "Give a simple opinion",
            subtitle: "Say what you think and one reason",
            icon: "lightbulb.fill",
            accent: .blue,
            minutes: 6,
            goal: "My goal is to give one opinion with one clear reason.",
            model: "I think this option is better because it's simpler.",
            modelHelper: "I think plus because is enough for many conversations.",
            speak: "I prefer the first idea because it's easier to understand.",
            speakHelper: "Prefer is useful when choosing between options.",
            alternative: "For me, the second option feels clearer.",
            alternativeHelper: "For me softens your opinion.",
            mistakePrompt: "You are giving an opinion in a meeting.",
            correctAnswer: "I think this option is better.",
            commonMistake: "I am think this option better.",
            roleplay: "A teammate asks, Which design do you prefer?",
            roleplayHelper: "Choose one option and give one short reason.",
            followUp: "What do you think?",
            followUpHelper: "Ask back so it becomes a conversation, not a speech.",
            savedWords: [
                phrase("I think", "simple way to give an opinion", "I think this option is better."),
                phrase("I prefer", "say which option you choose", "I prefer the first idea."),
                phrase("because it's simpler", "give a short reason", "I like it because it's simpler."),
                phrase("what do you think", "ask for another opinion", "What do you think?")
            ],
            extraMistake: "For me it is more better."
        ),
        englishConversationLesson(
            id: "english-agree-disagree",
            unit: 3,
            title: "Agree and disagree politely",
            subtitle: "Respond without sounding too strong",
            icon: "hand.thumbsup.fill",
            accent: .mint,
            minutes: 6,
            goal: "My goal is to agree or disagree politely in one sentence.",
            model: "I agree with you. That sounds reasonable.",
            modelHelper: "Use this when you want to support someone's idea.",
            speak: "I see your point, but I'm not sure about the timing.",
            speakHelper: "I see your point softens disagreement.",
            alternative: "Maybe we could try a simpler version first.",
            alternativeHelper: "Suggest a change instead of only saying no.",
            mistakePrompt: "You disagree in a polite way.",
            correctAnswer: "I see your point, but I'm not sure.",
            commonMistake: "I don't agree you.",
            roleplay: "A teammate suggests a plan that feels too rushed.",
            roleplayHelper: "Acknowledge the idea, then explain your concern.",
            followUp: "Could we talk through the timeline once more?",
            followUpHelper: "Ask for discussion instead of ending the conversation.",
            savedWords: [
                phrase("I agree with you", "polite agreement", "I agree with you. That sounds reasonable."),
                phrase("I see your point", "soften disagreement", "I see your point, but I'm not sure."),
                phrase("I'm not sure about", "express a concern", "I'm not sure about the timing."),
                phrase("talk through", "discuss step by step", "Could we talk through the timeline?")
            ],
            extraMistake: "I not agree with this."
        ),
        englishConversationLesson(
            id: "english-hotel-check-in",
            unit: 4,
            title: "Check in at a hotel",
            subtitle: "Give your name and ask practical questions",
            icon: "bed.double.fill",
            accent: .violet,
            minutes: 6,
            goal: "My goal is to check in and ask one hotel question.",
            model: "Hi, I have a reservation under Alex.",
            modelHelper: "Under Alex means the reservation name is Alex.",
            speak: "Could I check in, please?",
            speakHelper: "Use this at the front desk.",
            alternative: "What time is breakfast?",
            alternativeHelper: "Ask one useful detail before leaving the desk.",
            mistakePrompt: "You arrive at a hotel with a booking.",
            correctAnswer: "I have a reservation under Alex.",
            commonMistake: "I have booking by Alex.",
            roleplay: "The receptionist asks, May I see your passport?",
            roleplayHelper: "Respond naturally and ask about check-in.",
            followUp: "Could I get the Wi-Fi password, please?",
            followUpHelper: "A common hotel follow-up question.",
            savedWords: [
                phrase("I have a reservation under", "say the booking name", "I have a reservation under Alex."),
                phrase("could I check in", "ask to start hotel check-in", "Could I check in, please?"),
                phrase("what time is breakfast", "ask hotel breakfast time", "What time is breakfast?"),
                phrase("Wi-Fi password", "hotel internet password", "Could I get the Wi-Fi password?")
            ],
            extraMistake: "Reservation is in my name Alex under."
        ),
        englishConversationLesson(
            id: "english-travel-plans",
            unit: 4,
            title: "Talk about travel plans",
            subtitle: "Say where you are going and what you plan to do",
            icon: "airplane.departure",
            accent: .blue,
            minutes: 6,
            goal: "My goal is to describe a travel plan in three short lines.",
            model: "I'm going to Singapore for three days.",
            modelHelper: "Use going to for travel plans that are already decided.",
            speak: "I'm planning to visit a museum and try local food.",
            speakHelper: "Add two simple activities with and.",
            alternative: "I'm here for work, but I have one free afternoon.",
            alternativeHelper: "Useful when travel is not only for vacation.",
            mistakePrompt: "You describe a future trip.",
            correctAnswer: "I'm going to Singapore next week.",
            commonMistake: "I go to Singapore next week.",
            roleplay: "A hotel guest asks, What are your plans while you're here?",
            roleplayHelper: "Say the place, length of stay, and one activity.",
            followUp: "Do you have any recommendations?",
            followUpHelper: "Ask locals for ideas.",
            savedWords: [
                phrase("I'm going to", "talk about a planned trip", "I'm going to Singapore next week."),
                phrase("for three days", "say trip length", "I'm going to Singapore for three days."),
                phrase("I'm planning to", "say what you intend to do", "I'm planning to visit a museum."),
                phrase("any recommendations", "ask for suggestions", "Do you have any recommendations?")
            ],
            extraMistake: "I will going to Singapore."
        ),
        englishConversationLesson(
            id: "english-airport-travel",
            unit: 4,
            title: "Handle airport moments",
            subtitle: "Ask about gates, bags, and delays",
            icon: "airplane",
            accent: .amber,
            minutes: 6,
            goal: "My goal is to ask for airport information clearly.",
            model: "Which gate does this flight leave from?",
            modelHelper: "Use which gate when you cannot find the gate number.",
            speak: "My flight is delayed. Do you know the new time?",
            speakHelper: "Say the problem first, then ask for the update.",
            alternative: "Where can I pick up my bag?",
            alternativeHelper: "Use pick up for baggage claim.",
            mistakePrompt: "You need the gate for your flight.",
            correctAnswer: "Which gate does this flight leave from?",
            commonMistake: "This flight leave which gate?",
            roleplay: "An airport staff member asks, How can I help you?",
            roleplayHelper: "Ask about your gate, delay, or baggage.",
            followUp: "Thanks. Is it still on time?",
            followUpHelper: "Check if the flight time changed.",
            savedWords: [
                phrase("which gate", "ask for the flight gate", "Which gate does this flight leave from?"),
                phrase("my flight is delayed", "say your flight is late", "My flight is delayed."),
                phrase("the new time", "updated departure or arrival time", "Do you know the new time?"),
                phrase("pick up my bag", "collect baggage", "Where can I pick up my bag?")
            ],
            extraMistake: "Where I can pick my bag?"
        ),
        englishConversationLesson(
            id: "english-emergency-help",
            unit: 4,
            title: "Emergency help phrases",
            subtitle: "Ask for urgent help and say what is wrong",
            icon: "cross.case.fill",
            accent: .blue,
            minutes: 6,
            goal: "My goal is to ask for help quickly in an urgent situation.",
            model: "I need help. I lost my phone.",
            modelHelper: "Use short sentences in stressful moments.",
            speak: "Could you call security, please?",
            speakHelper: "Change security to the police, a doctor, or an ambulance if needed.",
            alternative: "Is there someone who speaks English?",
            alternativeHelper: "Useful when you need language support.",
            mistakePrompt: "You lost your bag and need help.",
            correctAnswer: "I need help. I lost my bag.",
            commonMistake: "I need helping. My bag lost.",
            roleplay: "You are at a station and cannot find your phone.",
            roleplayHelper: "Say you need help, what happened, and what you need now.",
            followUp: "Please stay with me for a moment.",
            followUpHelper: "Use this if you feel unsafe or confused.",
            savedWords: [
                phrase("I need help", "urgent request for help", "I need help. I lost my phone."),
                phrase("I lost my", "say something is missing", "I lost my bag."),
                phrase("could you call", "ask someone to contact help", "Could you call security, please?"),
                phrase("stay with me", "ask someone not to leave", "Please stay with me for a moment.")
            ],
            extraMistake: "Can call to security?"
        ),
        englishConversationLesson(
            id: "english-doctor-pharmacy",
            unit: 4,
            title: "Doctor and pharmacy",
            subtitle: "Describe symptoms and ask for medicine",
            icon: "pills.fill",
            accent: .mint,
            minutes: 6,
            goal: "My goal is to describe how I feel and ask what to do.",
            model: "I have a headache and a sore throat.",
            modelHelper: "Use I have plus the symptom.",
            speak: "I've felt like this since yesterday.",
            speakHelper: "Since yesterday tells when the symptom started.",
            alternative: "Do I need to see a doctor?",
            alternativeHelper: "Ask this at a pharmacy or clinic.",
            mistakePrompt: "You describe a sore throat.",
            correctAnswer: "I have a sore throat.",
            commonMistake: "My throat is pain.",
            roleplay: "A pharmacist asks, What symptoms do you have?",
            roleplayHelper: "Say two symptoms and when they started.",
            followUp: "How often should I take this medicine?",
            followUpHelper: "Always ask how often when you get medicine.",
            savedWords: [
                phrase("I have a headache", "describe head pain", "I have a headache."),
                phrase("sore throat", "pain in the throat", "I have a sore throat."),
                phrase("since yesterday", "from yesterday until now", "I've felt like this since yesterday."),
                phrase("how often should I take this", "ask medicine timing", "How often should I take this medicine?")
            ],
            extraMistake: "I am headache since yesterday."
        ),
        englishConversationLesson(
            id: "english-course-wrap-up",
            unit: 4,
            title: "Full conversation practice",
            subtitle: "Use the course phrases in one realistic exchange",
            icon: "checkmark.seal.fill",
            accent: .violet,
            minutes: 8,
            goal: "My goal is to handle a real conversation from start to finish.",
            model: "Hi, I'm Alex. I'm visiting for work, and I'm trying to speak more English.",
            modelHelper: "This combines identity, situation, and purpose.",
            speak: "Could I ask you a quick question about this area?",
            speakHelper: "Use quick question to sound respectful of someone's time.",
            alternative: "I'm not sure I understood. Could you say that again?",
            alternativeHelper: "Use this when the conversation gets too fast.",
            mistakePrompt: "You did not understand and need repetition.",
            correctAnswer: "Could you say that again, please?",
            commonMistake: "Can you repeat again one more?",
            roleplay: "You meet someone while traveling. Introduce yourself, ask for a recommendation, and close politely.",
            roleplayHelper: "Use three short lines. Do not try to say everything.",
            followUp: "Thanks for your help. It was nice talking to you.",
            followUpHelper: "End warmly and clearly.",
            savedWords: [
                phrase("I'm visiting for work", "say why you are in a place", "I'm visiting for work."),
                phrase("quick question", "small request for information", "Could I ask you a quick question?"),
                phrase("I'm not sure I understood", "soft way to say you missed something", "I'm not sure I understood."),
                phrase("thanks for your help", "polite closing after support", "Thanks for your help.")
            ],
            extraMistake: "I didn't understood."
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
                LessonStep(id: "greeting-2", kind: .choice, title: "Say the greeting", prompt: "Hi.", helper: "Use the natural casual French greeting.", choices: ["Au revoir.", "Salut.", "Bonsoir."], correctAnswer: "Salut."),
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
