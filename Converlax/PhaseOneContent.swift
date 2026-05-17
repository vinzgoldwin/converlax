import Foundation

enum PhaseOneContent {
    private static func savedLine(_ id: String, _ text: String, _ translation: String, _ source: String, _ note: String) -> SavedLine {
        SavedLine(id: id, text: text, translation: translation, source: source, note: note)
    }

    static let savedLines: [SavedLine] = [
        savedLine("line-intro-name", "Hi, I'm Alex. Nice to meet you.", "Introduce yourself in a first meeting", "Introduce yourself", "Swap Alex for your own name."),
        savedLine("line-intro-reason", "I'm learning English because I want to speak more confidently.", "Explain your speaking goal", "Introduce yourself", "Keep the reason short and real."),
        savedLine("line-small-talk", "Pretty good, thanks. How about you?", "Answer a check-in and ask back", "Small talk", "A short answer keeps the conversation moving."),
        savedLine("line-close-chat", "It was nice talking to you. See you later.", "Close small talk politely", "Small talk", "Use when you need to leave."),
        savedLine("line-routine", "I usually study English after work.", "Describe a regular habit", "Daily routine", "Usually means most days."),
        savedLine("line-free-time", "I like walking around the city on weekends.", "Talk about free time", "Free time", "Change the activity to your real life."),
        savedLine("line-plans", "Let's meet at six near the station.", "Confirm a time and place", "Making plans", "Use with friends, classmates, or coworkers."),
        savedLine("line-order", "Could I have a small coffee, please?", "Order politely at a counter", "Food and drinks", "Change small coffee to the item you want."),
        savedLine("line-restaurant", "Does this have nuts in it?", "Check ingredients", "Restaurant questions", "Useful for allergies and preferences."),
        savedLine("line-bill", "Could we get the bill, please?", "Ask to pay at a restaurant", "Restaurant questions", "Use at table-service restaurants."),
        savedLine("line-directions", "Excuse me, where is the nearest station?", "Ask for directions politely", "Directions", "Nearest means closest."),
        savedLine("line-confirm-directions", "So I go straight and turn left at the bank?", "Check directions back", "Directions", "Repeat the route to confirm."),
        savedLine("line-ticket", "Does this bus go to the airport?", "Check a route", "Transport", "Change bus and airport to your situation."),
        savedLine("line-shopping", "How much is this? Can I pay by card?", "Ask price and payment", "Shopping", "Use at shops, markets, and counters."),
        savedLine("line-clarify", "Could you say that again, please?", "Ask someone to repeat", "Help and clarification", "Use when you missed the sentence."),
        savedLine("line-slowly", "Sorry, could you speak more slowly?", "Ask for slower speech", "Help and clarification", "This is a confidence phrase, not a failure."),
        savedLine("line-work-intro", "Hi, I'm Alex. I work in product.", "Introduce yourself at work", "Work introductions", "Change product to your team or field."),
        savedLine("line-meeting-audio", "Hi everyone, can you hear me okay?", "Check audio in a meeting", "Meetings", "Useful for video calls."),
        savedLine("line-phone", "Sorry, the connection is not very clear.", "Handle bad call audio", "Phone and video calls", "Follow with a repeat request."),
        savedLine("line-problem", "I'm having a problem with my account.", "Explain a support issue", "Explaining problems", "Swap account for app, card, order, or booking."),
        savedLine("line-opinion", "I think this option is better because it's simpler.", "Give an opinion with a reason", "Giving opinions", "One reason is enough."),
        savedLine("line-disagree", "I see your point, but I'm not sure about the timing.", "Disagree politely", "Agree and disagree", "Start with acknowledgement before concern."),
        savedLine("line-hotel", "Hi, I have a reservation under Alex.", "Start hotel check-in", "Hotel", "Use under plus the booking name."),
        savedLine("line-travel-plan", "I'm going to Singapore for three days.", "Describe a travel plan", "Travel plans", "Change the city and length of stay."),
        savedLine("line-airport", "Which gate does this flight leave from?", "Ask airport information", "Airport", "Use when the gate is unclear."),
        savedLine("line-emergency", "I need help. I lost my phone.", "Ask for urgent help", "Emergency help", "Short sentences are best in stressful moments."),
        savedLine("line-pharmacy", "I have a headache and a sore throat.", "Describe symptoms", "Doctor and pharmacy", "Add when it started if you can."),
        savedLine("line-full-close", "Thanks for your help. It was nice talking to you.", "Close a helpful conversation", "Full conversation practice", "Use after someone helps you.")
    ]

    static let topics: [RoleplayTopic] = [
        RoleplayTopic(id: "everyday", title: "Everyday starts", subtitle: "Introductions, small talk, routines, and plans", symbol: "bubble.left.and.bubble.right.fill", colorName: .mint, scenarioIDs: ["first-meeting", "small-talk-neighbor", "free-time-chat", "make-weekend-plan"]),
        RoleplayTopic(id: "food", title: "Food and shops", subtitle: "Cafes, restaurants, shopping, and payment", symbol: "cup.and.saucer.fill", colorName: .amber, scenarioIDs: ["coffee-order", "restaurant-menu", "shop-price-check"]),
        RoleplayTopic(id: "around-town", title: "Around town", subtitle: "Directions, transport, and clarification", symbol: "map.fill", colorName: .blue, scenarioIDs: ["station-directions", "buy-ticket", "clarify-help"]),
        RoleplayTopic(id: "work", title: "Work and calls", subtitle: "Introductions, meetings, calls, and support issues", symbol: "briefcase.fill", colorName: .violet, scenarioIDs: ["team-intro", "video-meeting", "phone-call-audio", "support-problem"]),
        RoleplayTopic(id: "opinions", title: "Opinions and decisions", subtitle: "Give opinions, agree, disagree, and explain reasons", symbol: "lightbulb.fill", colorName: .mint, scenarioIDs: ["choose-option", "polite-disagreement"]),
        RoleplayTopic(id: "travel", title: "Travel and help", subtitle: "Hotels, airports, health, and urgent help", symbol: "airplane", colorName: .blue, scenarioIDs: ["hotel-check-in", "airport-delay", "pharmacy-symptoms", "lost-phone-help"])
    ]

    static let roleplays: [RoleplayScenario] = [
        RoleplayScenario(
            id: "first-meeting",
            topicID: "everyday",
            title: "Meet someone new",
            subtitle: "Say your name, where you are from, and ask back",
            setting: "Language meetup",
            difficulty: .beginner,
            minutes: 4,
            lines: [
                savedLine("meeting-line-1", "Hi, I'm Alex. Nice to meet you.", "Introduce yourself", "Situation", "Swap in your own name."),
                savedLine("meeting-line-2", "I'm from Indonesia. How about you?", "Say where you are from and ask back", "Situation", "Use your country or city."),
                savedLine("meeting-line-3", "I'm learning English because I want to speak more confidently.", "Explain your reason", "Situation", "Keep the reason short.")
            ],
            isCommunity: false
        ),
        RoleplayScenario(
            id: "small-talk-neighbor",
            topicID: "everyday",
            title: "Chat with a neighbor",
            subtitle: "Answer a check-in, ask back, and close naturally",
            setting: "Apartment lobby",
            difficulty: .beginner,
            minutes: 4,
            lines: [
                savedLine("neighbor-line-1", "Pretty good, thanks. How about you?", "Answer and ask back", "Situation", "Works for How are you? and How's your day?"),
                savedLine("neighbor-line-2", "Not bad. I'm just heading to work.", "Add one everyday detail", "Situation", "Keep the extra detail short."),
                savedLine("neighbor-line-3", "It was nice talking to you. See you later.", "Close politely", "Situation", "Use when you need to leave.")
            ],
            isCommunity: true
        ),
        RoleplayScenario(
            id: "free-time-chat",
            topicID: "everyday",
            title: "Talk about free time",
            subtitle: "Share one hobby and ask a follow-up",
            setting: "Lunch break",
            difficulty: .beginner,
            minutes: 5,
            lines: [
                savedLine("free-time-line-1", "I like walking around the city on weekends.", "Say a free-time activity", "Situation", "Change the activity to your real life."),
                savedLine("free-time-line-2", "I'm into cooking these days.", "Give a natural alternative", "Situation", "I'm into means I like it right now."),
                savedLine("free-time-line-3", "What do you like doing on weekends?", "Ask a follow-up", "Situation", "This keeps the conversation moving.")
            ],
            isCommunity: false
        ),
        RoleplayScenario(
            id: "make-weekend-plan",
            topicID: "everyday",
            title: "Make a simple plan",
            subtitle: "Invite someone, choose a time, and confirm",
            setting: "After class",
            difficulty: .beginner,
            minutes: 5,
            lines: [
                savedLine("plan-line-1", "Would you like to get coffee tomorrow?", "Invite someone politely", "Situation", "Use would you like to for friendly invitations."),
                savedLine("plan-line-2", "Let's meet at six near the station.", "Confirm time and place", "Situation", "Give one clear detail."),
                savedLine("plan-line-3", "Great, see you there at six.", "Close the plan", "Situation", "Repeat the time or place.")
            ],
            isCommunity: true
        ),
        RoleplayScenario(
            id: "coffee-order",
            topicID: "food",
            title: "Order at a cafe",
            subtitle: "Choose a drink, answer the barista, and finish politely",
            setting: "Busy cafe",
            difficulty: .beginner,
            minutes: 5,
            lines: [
                savedLine("coffee-line-1", "Could I have a small latte, please?", "Order a drink with a size", "Situation", "Small can become medium or large."),
                savedLine("coffee-line-2", "For here, please.", "Answer where you will drink", "Situation", "Use to go if you are leaving."),
                savedLine("coffee-line-3", "No, that's all. Thank you.", "Say you do not need anything else", "Situation", "Use this after Anything else?")
            ],
            isCommunity: false
        ),
        RoleplayScenario(
            id: "restaurant-menu",
            topicID: "food",
            title: "Ask about a menu",
            subtitle: "Check ingredients, spice, and the bill",
            setting: "Casual restaurant",
            difficulty: .elementary,
            minutes: 6,
            lines: [
                savedLine("restaurant-line-1", "Does this have nuts in it?", "Check ingredients", "Situation", "Useful for allergies."),
                savedLine("restaurant-line-2", "Is this dish spicy?", "Ask about spice level", "Situation", "A simple yes-or-no question."),
                savedLine("restaurant-line-3", "Could we get the bill, please?", "Ask to pay", "Situation", "Use at table-service restaurants.")
            ],
            isCommunity: true
        ),
        RoleplayScenario(
            id: "station-directions",
            topicID: "around-town",
            title: "Find the station",
            subtitle: "Ask where to go and check the answer",
            setting: "Street corner",
            difficulty: .beginner,
            minutes: 4,
            lines: [
                savedLine("station-line-1", "Excuse me, where is the nearest station?", "Ask for the closest station", "Situation", "Start with excuse me for politeness."),
                savedLine("station-line-2", "Is it far from here?", "Ask about distance", "Situation", "Useful before you start walking."),
                savedLine("station-line-3", "So I go straight and turn left at the bank?", "Check the route", "Situation", "Repeat the directions back.")
            ],
            isCommunity: true
        ),
        RoleplayScenario(
            id: "buy-ticket",
            topicID: "around-town",
            title: "Buy a ticket",
            subtitle: "Ask for a ticket and check the route",
            setting: "Train station counter",
            difficulty: .beginner,
            minutes: 5,
            lines: [
                savedLine("ticket-line-1", "One ticket to City Hall, please.", "Ask for a ticket", "Situation", "Change City Hall to your destination."),
                savedLine("ticket-line-2", "Does this train go downtown?", "Check the route", "Situation", "Use bus or train as needed."),
                savedLine("ticket-line-3", "How many stops is it from here?", "Ask when to get off", "Situation", "Useful on public transport.")
            ],
            isCommunity: false
        ),
        RoleplayScenario(
            id: "shop-price-check",
            topicID: "food",
            title: "Ask about a price",
            subtitle: "Ask the cost, size, and payment question",
            setting: "Small shop",
            difficulty: .beginner,
            minutes: 5,
            lines: [
                savedLine("shop-line-1", "How much is this?", "Ask the price", "Situation", "Use this while pointing to one item."),
                savedLine("shop-line-2", "Do you have this in a smaller size?", "Ask for another size", "Situation", "Swap smaller size for another color."),
                savedLine("shop-line-3", "Can I pay by card?", "Ask about payment", "Situation", "Useful at shops, cafes, and counters.")
            ],
            isCommunity: false
        ),
        RoleplayScenario(
            id: "clarify-help",
            topicID: "around-town",
            title: "Ask for help",
            subtitle: "Ask someone to repeat and speak more slowly",
            setting: "Ticket machine",
            difficulty: .beginner,
            minutes: 4,
            lines: [
                savedLine("help-line-1", "Could you help me, please?", "Ask politely for help", "Situation", "Works when you are stuck."),
                savedLine("help-line-2", "Could you say that again, please?", "Ask someone to repeat", "Situation", "Use this when you did not understand."),
                savedLine("help-line-3", "Sorry, could you speak more slowly?", "Ask someone to slow down", "Situation", "Helpful with fast speech.")
            ],
            isCommunity: true
        ),
        RoleplayScenario(
            id: "team-intro",
            topicID: "work",
            title: "Meet a new teammate",
            subtitle: "Introduce your role and ask about their team",
            setting: "Office chat",
            difficulty: .beginner,
            minutes: 5,
            lines: [
                savedLine("work-line-1", "Hi, I'm Alex. I work in product.", "Introduce yourself at work", "Situation", "Change product to your role or team."),
                savedLine("work-line-2", "What team are you on?", "Ask about someone's team", "Situation", "Useful for first work conversations."),
                savedLine("work-line-3", "Nice to meet you. I look forward to working with you.", "Close politely", "Situation", "Good for new teammates and meetings.")
            ],
            isCommunity: true
        ),
        RoleplayScenario(
            id: "video-meeting",
            topicID: "work",
            title: "Join a video meeting",
            subtitle: "Check audio, ask for a recap, and continue",
            setting: "Remote team call",
            difficulty: .elementary,
            minutes: 5,
            lines: [
                savedLine("meeting-call-line-1", "Hi everyone, can you hear me okay?", "Check audio", "Situation", "Use when you join a call."),
                savedLine("meeting-call-line-2", "Sorry I'm a little late. What did I miss?", "Ask for what happened", "Situation", "Only use if you joined late."),
                savedLine("meeting-call-line-3", "Could you give me a quick recap?", "Ask for a short summary", "Situation", "A practical meeting phrase.")
            ],
            isCommunity: false
        ),
        RoleplayScenario(
            id: "phone-call-audio",
            topicID: "work",
            title: "Fix call audio",
            subtitle: "Say the connection is bad and ask for repetition",
            setting: "Client phone call",
            difficulty: .elementary,
            minutes: 5,
            lines: [
                savedLine("phone-line-1", "Hi, this is Alex speaking.", "Answer a call professionally", "Situation", "Use your own name."),
                savedLine("phone-line-2", "Sorry, the connection is not very clear.", "Explain the audio issue", "Situation", "Name the problem."),
                savedLine("phone-line-3", "Could you repeat the last part?", "Ask for part of the sentence again", "Situation", "Useful when you understood most of it.")
            ],
            isCommunity: true
        ),
        RoleplayScenario(
            id: "support-problem",
            topicID: "work",
            title: "Explain a support problem",
            subtitle: "Say what happened and what you need",
            setting: "Customer support chat",
            difficulty: .elementary,
            minutes: 6,
            lines: [
                savedLine("support-line-1", "I'm having a problem with my account.", "Open a problem explanation", "Situation", "Swap account for app, card, order, or booking."),
                savedLine("support-line-2", "It says my password is incorrect, but I'm sure it's right.", "Report an error message", "Situation", "Use it says for app messages."),
                savedLine("support-line-3", "Could you help me fix it?", "Ask for help solving it", "Situation", "Finish with what you need.")
            ],
            isCommunity: false
        ),
        RoleplayScenario(
            id: "choose-option",
            topicID: "opinions",
            title: "Choose an option",
            subtitle: "Give an opinion and one reason",
            setting: "Team discussion",
            difficulty: .elementary,
            minutes: 5,
            lines: [
                savedLine("opinion-line-1", "I think this option is better because it's simpler.", "Give an opinion with a reason", "Situation", "One reason is enough."),
                savedLine("opinion-line-2", "I prefer the first idea because it's easier to understand.", "Choose between options", "Situation", "Use prefer for choices."),
                savedLine("opinion-line-3", "What do you think?", "Ask for another opinion", "Situation", "Make it a conversation.")
            ],
            isCommunity: true
        ),
        RoleplayScenario(
            id: "polite-disagreement",
            topicID: "opinions",
            title: "Disagree politely",
            subtitle: "Acknowledge the idea and explain your concern",
            setting: "Planning meeting",
            difficulty: .upperElementary,
            minutes: 6,
            lines: [
                savedLine("disagree-line-1", "I see your point, but I'm not sure about the timing.", "Disagree softly", "Situation", "Acknowledge first."),
                savedLine("disagree-line-2", "Maybe we could try a simpler version first.", "Suggest a change", "Situation", "Offer a path forward."),
                savedLine("disagree-line-3", "Could we talk through the timeline once more?", "Ask for more discussion", "Situation", "Useful when plans feel rushed.")
            ],
            isCommunity: true
        ),
        RoleplayScenario(
            id: "hotel-check-in",
            topicID: "travel",
            title: "Check in at a hotel",
            subtitle: "Give your name and ask about useful details",
            setting: "Hotel front desk",
            difficulty: .beginner,
            minutes: 5,
            lines: [
                savedLine("hotel-line-1", "Hi, I have a reservation under Alex.", "Start check-in", "Situation", "Use the booking name."),
                savedLine("hotel-line-2", "Could I check in, please?", "Ask to check in", "Situation", "Short and polite."),
                savedLine("hotel-line-3", "Could I get the Wi-Fi password, please?", "Ask for hotel Wi-Fi", "Situation", "A useful follow-up.")
            ],
            isCommunity: false
        ),
        RoleplayScenario(
            id: "airport-delay",
            topicID: "travel",
            title: "Ask about a delayed flight",
            subtitle: "Find the gate and new time",
            setting: "Airport information desk",
            difficulty: .elementary,
            minutes: 5,
            lines: [
                savedLine("airport-line-1", "Which gate does this flight leave from?", "Ask for the gate", "Situation", "Use when the screen is confusing."),
                savedLine("airport-line-2", "My flight is delayed. Do you know the new time?", "Ask about a delay", "Situation", "Say the problem, then ask for the update."),
                savedLine("airport-line-3", "Where can I pick up my bag?", "Ask about baggage", "Situation", "Use after a flight or delay.")
            ],
            isCommunity: true
        ),
        RoleplayScenario(
            id: "pharmacy-symptoms",
            topicID: "travel",
            title: "Ask at a pharmacy",
            subtitle: "Describe symptoms and medicine timing",
            setting: "Pharmacy counter",
            difficulty: .elementary,
            minutes: 6,
            lines: [
                savedLine("pharmacy-line-1", "I have a headache and a sore throat.", "Describe symptoms", "Situation", "Add two symptoms if needed."),
                savedLine("pharmacy-line-2", "I've felt like this since yesterday.", "Say when it started", "Situation", "Useful for health conversations."),
                savedLine("pharmacy-line-3", "How often should I take this medicine?", "Ask medicine timing", "Situation", "Always ask before taking medicine.")
            ],
            isCommunity: false
        ),
        RoleplayScenario(
            id: "lost-phone-help",
            topicID: "travel",
            title: "Get urgent help",
            subtitle: "Say what happened and ask for immediate support",
            setting: "Train station help desk",
            difficulty: .beginner,
            minutes: 5,
            lines: [
                savedLine("emergency-line-1", "I need help. I lost my phone.", "Ask for urgent help", "Situation", "Short sentences are best."),
                savedLine("emergency-line-2", "Could you call security, please?", "Ask someone to contact help", "Situation", "Change security if needed."),
                savedLine("emergency-line-3", "Please stay with me for a moment.", "Ask someone not to leave", "Situation", "Use if you feel unsafe or confused.")
            ],
            isCommunity: true
        )
    ]

    static let usageSessions: [UsageSession] = [
        UsageSession(id: "usage-1", title: "First chat practice", detail: "Completed 7 speaking turns", minutes: 7, dateLabel: "Today"),
        UsageSession(id: "usage-2", title: "Order food and drinks", detail: "Practiced cafe and restaurant lines", minutes: 6, dateLabel: "Yesterday"),
        UsageSession(id: "usage-3", title: "Ask for help", detail: "Practiced repeat and slow-down phrases", minutes: 6, dateLabel: "This week"),
        UsageSession(id: "usage-4", title: "Work call practice", detail: "Handled audio and recap phrases", minutes: 5, dateLabel: "This week")
    ]

    static let activities: [LearningActivity] = [
        LearningActivity(id: "activity-streak", title: "Streak started", detail: "Completed a speaking lesson today", symbol: "flame.fill", dateLabel: "Today"),
        LearningActivity(id: "activity-line", title: "Saved a line", detail: "Could you say that again, please?", symbol: "bookmark.fill", dateLabel: "Today"),
        LearningActivity(id: "activity-roleplay", title: "Finished a situation", detail: "Order at a cafe, 5 minutes", symbol: "person.2.wave.2.fill", dateLabel: "Yesterday"),
        LearningActivity(id: "activity-review", title: "Review ready", detail: "Travel, work, and help phrases are due", symbol: "bolt.fill", dateLabel: "This week")
    ]

    static let reviewItems: [ReviewItem] = [
        ReviewItem(id: "review-1", prompt: "Hi, I'm Alex. Nice to meet you.", answer: "Introduce yourself", source: "Introduce yourself"),
        ReviewItem(id: "review-2", prompt: "I'm from Indonesia.", answer: "Say where you are from", source: "Introduce yourself"),
        ReviewItem(id: "review-3", prompt: "Pretty good, thanks. How about you?", answer: "Answer and ask back", source: "Small talk"),
        ReviewItem(id: "review-4", prompt: "It was nice talking to you. See you later.", answer: "Close a short chat politely", source: "Small talk"),
        ReviewItem(id: "review-5", prompt: "I usually study English after work.", answer: "Describe a habit after work", source: "Daily routine"),
        ReviewItem(id: "review-6", prompt: "What do you do for fun?", answer: "Ask about free time", source: "Free time"),
        ReviewItem(id: "review-7", prompt: "Would you like to get coffee tomorrow?", answer: "Invite someone for coffee", source: "Making plans"),
        ReviewItem(id: "review-8", prompt: "Let's meet at six near the station.", answer: "Confirm a time and place", source: "Making plans"),
        ReviewItem(id: "review-9", prompt: "Could I have a small coffee, please?", answer: "Order a small coffee politely", source: "Food and drinks"),
        ReviewItem(id: "review-10", prompt: "Does this have nuts in it?", answer: "Ask about ingredients", source: "Restaurant questions"),
        ReviewItem(id: "review-11", prompt: "Could we get the bill, please?", answer: "Ask for the bill", source: "Restaurant questions"),
        ReviewItem(id: "review-12", prompt: "Excuse me, where is the nearest station?", answer: "Ask for the nearest station", source: "Directions"),
        ReviewItem(id: "review-13", prompt: "Does this bus go to the airport?", answer: "Check the route", source: "Transport"),
        ReviewItem(id: "review-14", prompt: "How much is this? Can I pay by card?", answer: "Ask price and payment", source: "Shopping"),
        ReviewItem(id: "review-15", prompt: "Could you say that again, please?", answer: "Ask someone to repeat", source: "Help and clarification"),
        ReviewItem(id: "review-16", prompt: "Sorry, could you speak more slowly?", answer: "Ask someone to slow down", source: "Help and clarification"),
        ReviewItem(id: "review-17", prompt: "Hi, I'm Alex. I work in product.", answer: "Introduce your team", source: "Work introductions"),
        ReviewItem(id: "review-18", prompt: "What team are you on?", answer: "Ask about someone's team", source: "Work introductions"),
        ReviewItem(id: "review-19", prompt: "Can you hear me okay?", answer: "Check audio in a meeting", source: "Meetings"),
        ReviewItem(id: "review-20", prompt: "Sorry, the connection is not very clear.", answer: "Explain the audio issue", source: "Phone and video calls"),
        ReviewItem(id: "review-21", prompt: "I'm having a problem with my account.", answer: "Explain an account problem", source: "Explaining problems"),
        ReviewItem(id: "review-22", prompt: "I think this option is better because it's simpler.", answer: "Give an opinion with one reason", source: "Giving opinions"),
        ReviewItem(id: "review-23", prompt: "I see your point, but I'm not sure about the timing.", answer: "Disagree politely about timing", source: "Agree and disagree"),
        ReviewItem(id: "review-24", prompt: "Hi, I have a reservation under Alex.", answer: "Start hotel check-in", source: "Hotel"),
        ReviewItem(id: "review-25", prompt: "I'm going to Singapore for three days.", answer: "Describe a travel plan", source: "Travel plans"),
        ReviewItem(id: "review-26", prompt: "Which gate does this flight leave from?", answer: "Ask about the gate", source: "Airport"),
        ReviewItem(id: "review-27", prompt: "I need help. I lost my phone.", answer: "Ask for urgent help", source: "Emergency help"),
        ReviewItem(id: "review-28", prompt: "I have a headache and a sore throat.", answer: "Describe symptoms", source: "Doctor and pharmacy"),
        ReviewItem(id: "review-29", prompt: "How often should I take this medicine?", answer: "Ask medicine timing", source: "Doctor and pharmacy"),
        ReviewItem(id: "review-30", prompt: "Thanks for your help. It was nice talking to you.", answer: "Close after someone helps you", source: "Full conversation practice")
    ]

    static func roleplay(id: String) -> RoleplayScenario? {
        roleplays.first { $0.id == id }
    }

    static func topic(id: String) -> RoleplayTopic? {
        topics.first { $0.id == id }
    }
}
