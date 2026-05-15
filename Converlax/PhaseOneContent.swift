import Foundation

enum PhaseOneContent {
    static let savedLines: [SavedLine] = [
        SavedLine(id: "line-intro-name", text: "Hi, I'm Maya. Nice to meet you.", translation: "Introduce yourself in a first meeting", source: "Introduce yourself", note: "Swap Maya for your own name."),
        SavedLine(id: "line-small-talk", text: "Pretty good, thanks. How about you?", translation: "Answer a check-in and ask back", source: "Small talk lesson", note: "A short answer keeps the conversation moving."),
        SavedLine(id: "line-cafe-order", text: "Could I have a small coffee, please?", translation: "Order politely at a cafe", source: "Cafe lesson", note: "Change small coffee to the item you want."),
        SavedLine(id: "line-directions", text: "Excuse me, where is the nearest station?", translation: "Ask for directions politely", source: "Directions lesson", note: "Nearest means closest."),
        SavedLine(id: "line-clarify", text: "Could you say that again, please?", translation: "Ask someone to repeat", source: "Help lesson", note: "Use this when you did not understand."),
        SavedLine(id: "line-plans", text: "Let's meet at six near the station.", translation: "Confirm a simple plan", source: "Making plans lesson", note: "Reuses the station phrase from directions."),
        SavedLine(id: "line-routine", text: "I usually study English after work.", translation: "Describe a regular habit", source: "Daily routine lesson", note: "Usually means most days."),
        SavedLine(id: "line-shopping", text: "How much is this? Can I pay by card?", translation: "Ask a price and payment question", source: "Shopping lesson", note: "Use this at shops, markets, and counters."),
        SavedLine(id: "line-work-intro", text: "Hi, I'm Maya. I work in product.", translation: "Introduce yourself at work", source: "Work introduction lesson", note: "Change product to your field or team."),
        SavedLine(id: "line-work-close", text: "Nice to meet you. I look forward to working with you.", translation: "Close a workplace introduction politely", source: "Work introduction lesson", note: "Useful for first meetings with coworkers.")
    ]

    static let topics: [RoleplayTopic] = [
        RoleplayTopic(id: "everyday", title: "Everyday starts", subtitle: "Introductions, small talk, and plans", symbol: "bubble.left.and.bubble.right.fill", colorName: .mint, scenarioIDs: ["first-meeting", "make-weekend-plan"]),
        RoleplayTopic(id: "around-town", title: "Around town", subtitle: "Cafes, directions, help, and shopping", symbol: "map.fill", colorName: .blue, scenarioIDs: ["coffee-order", "station-directions", "shop-price-check", "clarify-help"]),
        RoleplayTopic(id: "work", title: "Work", subtitle: "Simple workplace introductions", symbol: "briefcase.fill", colorName: .violet, scenarioIDs: ["team-intro"])
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
                SavedLine(id: "meeting-line-1", text: "Hi, I'm Maya. Nice to meet you.", translation: "Introduce yourself", source: "Situation", note: "Swap in your own name."),
                SavedLine(id: "meeting-line-2", text: "I'm from Indonesia. How about you?", translation: "Say where you are from and ask back", source: "Situation", note: "Reuses how about you from small talk.")
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
                SavedLine(id: "plan-line-1", text: "Would you like to get coffee tomorrow?", translation: "Invite someone politely", source: "Situation", note: "Use would you like to for friendly invitations."),
                SavedLine(id: "plan-line-2", text: "Let's meet at six near the station.", translation: "Confirm time and place", source: "Situation", note: "Reuses station from the directions lesson.")
            ],
            isCommunity: true
        ),
        RoleplayScenario(
            id: "coffee-order",
            topicID: "around-town",
            title: "Order at a cafe",
            subtitle: "Choose a drink, answer the barista, and finish politely",
            setting: "Busy cafe",
            difficulty: .beginner,
            minutes: 5,
            lines: [
                SavedLine(id: "coffee-line-1", text: "Could I have a small latte, please?", translation: "Order a drink with a size", source: "Situation", note: "Small can become medium or large."),
                SavedLine(id: "coffee-line-2", text: "No, that's all. Thank you.", translation: "Say you do not need anything else", source: "Situation", note: "Use this after Anything else?")
            ],
            isCommunity: false
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
                SavedLine(id: "station-line-1", text: "Excuse me, where is the nearest station?", translation: "Ask for the closest station", source: "Situation", note: "Start with excuse me for politeness."),
                SavedLine(id: "station-line-2", text: "Go straight and turn left.", translation: "Understand simple directions", source: "Situation", note: "A common short direction answer.")
            ],
            isCommunity: true
        ),
        RoleplayScenario(
            id: "shop-price-check",
            topicID: "around-town",
            title: "Ask about a price",
            subtitle: "Ask the cost, size, and payment question",
            setting: "Small shop",
            difficulty: .beginner,
            minutes: 5,
            lines: [
                SavedLine(id: "shop-line-1", text: "How much is this?", translation: "Ask the price", source: "Situation", note: "Use this while pointing to one item."),
                SavedLine(id: "shop-line-2", text: "Do you have this in a smaller size?", translation: "Ask for another size", source: "Situation", note: "Swap smaller size for another color."),
                SavedLine(id: "shop-line-3", text: "Can I pay by card?", translation: "Ask about payment", source: "Situation", note: "Useful at shops, cafes, and counters.")
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
                SavedLine(id: "help-line-1", text: "Could you help me, please?", translation: "Ask politely for help", source: "Situation", note: "Works when you are stuck."),
                SavedLine(id: "help-line-2", text: "Could you say that again, please?", translation: "Ask someone to repeat", source: "Situation", note: "Use this when you did not understand."),
                SavedLine(id: "help-line-3", text: "Sorry, could you speak more slowly?", translation: "Ask someone to slow down", source: "Situation", note: "Helpful with fast speech.")
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
                SavedLine(id: "work-line-1", text: "Hi, I'm Maya. I work in product.", translation: "Introduce yourself at work", source: "Situation", note: "Change product to your role or team."),
                SavedLine(id: "work-line-2", text: "What team are you on?", translation: "Ask about someone's team", source: "Situation", note: "Useful for first work conversations."),
                SavedLine(id: "work-line-3", text: "Nice to meet you. I look forward to working with you.", translation: "Close politely", source: "Situation", note: "Good for new teammates and meetings.")
            ],
            isCommunity: true
        )
    ]

    static let usageSessions: [UsageSession] = [
        UsageSession(id: "usage-1", title: "Order at a cafe", detail: "Completed 5 speaking turns", minutes: 5, dateLabel: "Today"),
        UsageSession(id: "usage-2", title: "Review starter lines", detail: "Reviewed introductions, directions, and plans", minutes: 4, dateLabel: "Yesterday"),
        UsageSession(id: "usage-3", title: "Ask for help", detail: "Practiced clarification phrases", minutes: 4, dateLabel: "This week")
    ]

    static let activities: [LearningActivity] = [
        LearningActivity(id: "activity-streak", title: "Streak started", detail: "Completed a lesson today", symbol: "flame.fill", dateLabel: "Today"),
        LearningActivity(id: "activity-line", title: "Saved a line", detail: "Could you say that again, please?", symbol: "bookmark.fill", dateLabel: "Today"),
        LearningActivity(id: "activity-roleplay", title: "Finished a situation", detail: "Order at a cafe, 5 minutes", symbol: "person.2.wave.2.fill", dateLabel: "Yesterday")
    ]

    static let reviewItems: [ReviewItem] = [
        ReviewItem(id: "review-1", prompt: "Complete: Hi, I'm Maya. Nice to ___ you.", answer: "meet", source: "Introduce yourself"),
        ReviewItem(id: "review-2", prompt: "What can you say after: How's your day going?", answer: "Pretty good, thanks. How about you?", source: "Small talk"),
        ReviewItem(id: "review-3", prompt: "Translate the goal: Could I have a small coffee, please?", answer: "Order politely at a cafe", source: "Cafe lesson"),
        ReviewItem(id: "review-4", prompt: "What does nearest mean?", answer: "Closest", source: "Directions"),
        ReviewItem(id: "review-5", prompt: "Ask someone to repeat politely.", answer: "Could you say that again, please?", source: "Help lesson"),
        ReviewItem(id: "review-6", prompt: "Complete the plan: Let's meet at six ___ the station.", answer: "near", source: "Making plans"),
        ReviewItem(id: "review-7", prompt: "Choose a natural routine sentence: I ___ study English after work.", answer: "usually", source: "Daily routine"),
        ReviewItem(id: "review-8", prompt: "What do you say to ask a price?", answer: "How much is this?", source: "Shopping"),
        ReviewItem(id: "review-9", prompt: "Ask about someone's team at work.", answer: "What team are you on?", source: "Work introduction"),
        ReviewItem(id: "review-10", prompt: "Close a workplace introduction politely.", answer: "Nice to meet you. I look forward to working with you.", source: "Work introduction")
    ]

    static func roleplay(id: String) -> RoleplayScenario? {
        roleplays.first { $0.id == id }
    }

    static func topic(id: String) -> RoleplayTopic? {
        topics.first { $0.id == id }
    }
}
