import Foundation

enum PhaseOneContent {
    static let savedLines: [SavedLine] = [
        SavedLine(id: "line-cafe-order", text: "Could I have a coffee, please?", translation: "A polite cafe order", source: "Cafe roleplay", note: "Use could I have for polite requests."),
        SavedLine(id: "line-greeting", text: "Nice to meet you too.", translation: "Natural reply to an introduction", source: "Tutor", note: "Works in casual and professional meetings."),
        SavedLine(id: "line-directions", text: "Excuse me, where is the nearest station?", translation: "Ask for directions politely", source: "Directions lesson", note: "Nearest means closest."),
        SavedLine(id: "line-routine", text: "I usually study English at night.", translation: "Describe a regular habit", source: "Daily routine lesson", note: "Usually means most days."),
        SavedLine(id: "line-plans", text: "Would you like to meet at six?", translation: "Invite someone politely", source: "Making plans lesson", note: "Would you like to is softer than do you want."),
        SavedLine(id: "line-help", text: "Could you help me, please?", translation: "Ask for help politely", source: "Help lesson", note: "Could you is useful for polite requests.")
    ]

    static let topics: [RoleplayTopic] = [
        RoleplayTopic(id: "travel", title: "Travel", subtitle: "Hotels, stations, airports", symbol: "suitcase.rolling.fill", colorName: .blue, scenarioIDs: ["hotel-checkin", "station-help"]),
        RoleplayTopic(id: "food", title: "Food & cafes", subtitle: "Ordering, paying, preferences", symbol: "cup.and.saucer.fill", colorName: .amber, scenarioIDs: ["coffee-order", "restaurant-choice"]),
        RoleplayTopic(id: "work", title: "Work", subtitle: "Introductions and meetings", symbol: "briefcase.fill", colorName: .violet, scenarioIDs: ["team-intro"])
    ]

    static let roleplays: [RoleplayScenario] = [
        RoleplayScenario(
            id: "hotel-checkin",
            topicID: "travel",
            title: "Check in at a hotel",
            subtitle: "Give your name, confirm a room, ask about breakfast",
            setting: "Front desk",
            difficulty: .beginner,
            minutes: 6,
            lines: [
                SavedLine(id: "hotel-line-1", text: "I have a reservation under Kevin.", translation: "Give your booking name", source: "Roleplay", note: "Use under before a reservation name."),
                SavedLine(id: "hotel-line-2", text: "What time is breakfast?", translation: "Ask for hotel information", source: "Roleplay", note: "Swap breakfast for checkout or dinner.")
            ],
            isCommunity: false
        ),
        RoleplayScenario(
            id: "station-help",
            topicID: "travel",
            title: "Find the right platform",
            subtitle: "Ask for help and confirm where to go",
            setting: "Train station",
            difficulty: .beginner,
            minutes: 4,
            lines: [
                SavedLine(id: "station-line-1", text: "Which platform goes to the city center?", translation: "Ask for the right platform", source: "Roleplay", note: "Which asks someone to choose from options.")
            ],
            isCommunity: true
        ),
        RoleplayScenario(
            id: "coffee-order",
            topicID: "food",
            title: "Order coffee quickly",
            subtitle: "Choose a drink, ask for a size, pay",
            setting: "Busy cafe",
            difficulty: .beginner,
            minutes: 5,
            lines: [
                SavedLine(id: "coffee-line-1", text: "Could I have a small latte?", translation: "Order a drink with a size", source: "Roleplay", note: "Small can become medium or large.")
            ],
            isCommunity: false
        ),
        RoleplayScenario(
            id: "restaurant-choice",
            topicID: "food",
            title: "Choose a table",
            subtitle: "Ask for a table and mention preferences",
            setting: "Restaurant entrance",
            difficulty: .elementary,
            minutes: 7,
            lines: [
                SavedLine(id: "restaurant-line-1", text: "Do you have a table for two?", translation: "Ask for a table", source: "Community", note: "Change the number for your group size.")
            ],
            isCommunity: true
        ),
        RoleplayScenario(
            id: "team-intro",
            topicID: "work",
            title: "Meet a new teammate",
            subtitle: "Introduce yourself and ask about their role",
            setting: "Office chat",
            difficulty: .elementary,
            minutes: 5,
            lines: [
                SavedLine(id: "work-line-1", text: "What team are you on?", translation: "Ask about someone's team", source: "Community", note: "Useful for first work conversations.")
            ],
            isCommunity: true
        )
    ]

    static let usageSessions: [UsageSession] = [
        UsageSession(id: "usage-1", title: "Cafe roleplay", detail: "Completed 5 speaking turns", minutes: 6, dateLabel: "Today"),
        UsageSession(id: "usage-2", title: "Smart review", detail: "Reviewed 8 saved lines", minutes: 4, dateLabel: "Yesterday"),
        UsageSession(id: "usage-3", title: "Tutor chat", detail: "Asked for travel phrases", minutes: 7, dateLabel: "This week")
    ]

    static let activities: [LearningActivity] = [
        LearningActivity(id: "activity-streak", title: "Streak started", detail: "Completed a lesson today", symbol: "flame.fill", dateLabel: "Today"),
        LearningActivity(id: "activity-line", title: "Saved a line", detail: "Could I have a coffee, please?", symbol: "bookmark.fill", dateLabel: "Today"),
        LearningActivity(id: "activity-roleplay", title: "Finished a roleplay", detail: "Cafe roleplay, 6 minutes", symbol: "person.2.wave.2.fill", dateLabel: "Yesterday")
    ]

    static let reviewItems: [ReviewItem] = [
        ReviewItem(id: "review-1", prompt: "Translate: Could I have a coffee, please?", answer: "Polite request for coffee", source: "Saved line"),
        ReviewItem(id: "review-2", prompt: "Fill the blank: Nice to meet you ___.", answer: "too", source: "Tutor"),
        ReviewItem(id: "review-3", prompt: "What does nearest mean?", answer: "Closest", source: "Directions"),
        ReviewItem(id: "review-4", prompt: "Choose a natural routine sentence: I ___ wake up at seven.", answer: "usually", source: "Daily routine"),
        ReviewItem(id: "review-5", prompt: "What do you say to ask a price?", answer: "How much is this?", source: "Shopping"),
        ReviewItem(id: "review-6", prompt: "Complete the invitation: Would you like to ___ at six?", answer: "meet", source: "Making plans"),
        ReviewItem(id: "review-7", prompt: "Say this politely: Help me.", answer: "Could you help me, please?", source: "Help lesson"),
        ReviewItem(id: "review-8", prompt: "What does nearby mean?", answer: "Close to here", source: "Health help")
    ]

    static func roleplay(id: String) -> RoleplayScenario? {
        roleplays.first { $0.id == id }
    }

    static func topic(id: String) -> RoleplayTopic? {
        topics.first { $0.id == id }
    }
}
