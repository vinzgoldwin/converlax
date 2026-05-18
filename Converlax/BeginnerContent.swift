import Foundation

enum BeginnerContent {
    static let lessons: [BeginnerLesson] = englishLessons

    static let englishUnitCatalog: [CourseUnit] = [
        CourseUnit(id: 1, title: "Starter English", summary: "First chats, routines, likes, and simple questions."),
        CourseUnit(id: 2, title: "Everyday English", summary: "Food, shopping, directions, transport, appointments, and help."),
        CourseUnit(id: 3, title: "Social English", summary: "Small talk, hobbies, plans, invitations, stories, and follow-up questions."),
        CourseUnit(id: 4, title: "Work English", summary: "Introductions, updates, meetings, blockers, opinions, requests, and calls."),
        CourseUnit(id: 5, title: "Travel English", summary: "Airport, hotel, restaurant, pharmacy, lost items, delays, and local questions."),
        CourseUnit(id: 6, title: "Confidence Builder", summary: "Past stories, future plans, reasons, comparisons, preferences, and repairs.")
    ]

    private struct EnglishLessonSeed {
        let id: String
        let unit: Int
        let title: String
        let subtitle: String
        let icon: String
        let accent: LessonAccent
        let model: String
        let helper: String
        let speak: String
        let swap: String
        let check: String
        let answer: String
        let roleplay: String
        let followUp: String
        let phrases: [String]
    }

    private static func expandedLesson(_ seed: EnglishLessonSeed) -> BeginnerLesson {
        englishConversationLesson(
            id: seed.id,
            unit: seed.unit,
            title: seed.title,
            subtitle: seed.subtitle,
            icon: seed.icon,
            accent: seed.accent,
            minutes: seed.unit == 6 ? 7 : 6,
            goal: goalPrompt(for: seed),
            model: seed.model,
            modelHelper: seed.helper,
            speak: seed.speak,
            speakHelper: seed.swap,
            alternative: seed.followUp,
            alternativeHelper: "Use this as the next natural line after your answer.",
            mistakePrompt: seed.check,
            correctAnswer: seed.answer,
            commonMistake: seed.answer.replacingOccurrences(of: " to ", with: " "),
            roleplay: seed.roleplay,
            roleplayHelper: roleplayHelper(for: seed),
            followUp: seed.followUp,
            followUpHelper: followUpHelper(for: seed),
            savedWords: seed.phrases.map { phrase($0, savedPhraseNote(for: seed, phrase: $0), seed.model) },
            extraMistake: seed.answer.replacingOccurrences(of: "I ", with: "I am ")
        )
    }

    private static func goalPrompt(for seed: EnglishLessonSeed) -> String {
        switch seed.unit {
        case 1:
            return "Today, say \(seed.subtitle) in one clear sentence."
        case 2:
            return "Practice a real errand: \(seed.subtitle)."
        case 3:
            return "Keep a social chat moving as you \(seed.subtitle)."
        case 4:
            return "Use calm work English to \(seed.subtitle)."
        case 5:
            return "Handle a travel moment: \(seed.subtitle)."
        default:
            return "Build confidence as you \(seed.subtitle)."
        }
    }

    private static func roleplayHelper(for seed: EnglishLessonSeed) -> String {
        switch seed.unit {
        case 1:
            return "Answer warmly, then add one small true detail."
        case 2:
            return "Say the need first, then ask for one clear next step."
        case 3:
            return "React to the other person before you add your answer."
        case 4:
            return "Keep it brief: status, detail, then one request."
        case 5:
            return "Use short lines so the other person can help quickly."
        default:
            return "Use two or three connected sentences, then pause."
        }
    }

    private static func followUpHelper(for seed: EnglishLessonSeed) -> String {
        switch seed.unit {
        case 1:
            return "Swap one detail so the line is true for you."
        case 2:
            return "Change the place, item, or time to match a real errand."
        case 3:
            return "Ask it like you want the other person to keep talking."
        case 4:
            return "Keep the tone direct and low-pressure."
        case 5:
            return "Make the request specific enough for a stranger to answer."
        default:
            return "Add one reason, repair, or follow-up so the answer feels complete."
        }
    }

    private static func savedPhraseNote(for seed: EnglishLessonSeed, phrase: String) -> String {
        switch seed.unit {
        case 1:
            return "starter phrase for \(seed.subtitle)"
        case 2:
            return "practical errand phrase"
        case 3:
            return "social follow-up phrase"
        case 4:
            return "work conversation phrase"
        case 5:
            return "travel problem-solving phrase"
        default:
            return "confidence-building phrase"
        }
    }

    private static let englishExpansionLessons: [BeginnerLesson] = englishExpansionSeeds.map(expandedLesson)

    private static let englishExpansionSeeds: [EnglishLessonSeed] = [
        EnglishLessonSeed(id: "english-feelings-simple", unit: 1, title: "Say how you feel", subtitle: "share one feeling and one reason", icon: "heart.fill", accent: .mint, model: "I'm a little nervous, but I'm ready to try.", helper: "This is honest without sounding negative.", speak: "I'm happy because I finished work early.", swap: "Change the feeling and the reason.", check: "You want to say you feel tired today.", answer: "I'm tired today, but I'm okay.", roleplay: "A classmate asks how you feel before practice.", followUp: "How are you feeling today?", phrases: ["a little nervous", "ready to try", "because I", "how are you feeling"]),
        EnglishLessonSeed(id: "english-name-country-job", unit: 1, title: "Name, country, job", subtitle: "introduce three basic details", icon: "person.text.rectangle.fill", accent: .blue, model: "My name is Alex. I'm from Indonesia, and I work in design.", helper: "Three details are enough for a first answer.", speak: "I'm from Jakarta, and I work at a small company.", swap: "Change the city and job.", check: "You want to say your job naturally.", answer: "I work as a teacher.", roleplay: "Someone at a meetup asks you to introduce yourself.", followUp: "What do you do?", phrases: ["my name is", "I'm from", "I work in", "what do you do"]),
        EnglishLessonSeed(id: "english-basic-questions", unit: 1, title: "Ask basic questions", subtitle: "ask simple friendly questions", icon: "questionmark.bubble.fill", accent: .violet, model: "Where are you from?", helper: "Short questions keep the conversation easy.", speak: "What do you do on weekends?", swap: "Change weekends to mornings, evenings, or holidays.", check: "You need to ask about someone's job.", answer: "What do you do?", roleplay: "You meet a new person and ask two simple questions.", followUp: "How long have you lived here?", phrases: ["where are you from", "what do you do", "on weekends", "how long"]),
        EnglishLessonSeed(id: "english-family-basics", unit: 1, title: "Talk about family", subtitle: "mention family simply", icon: "house.fill", accent: .amber, model: "I live with my family.", helper: "Use live with for people in your home.", speak: "My brother lives nearby.", swap: "Change brother to friend, sister, or parents.", check: "You want to say your parents are in another city.", answer: "My parents live in another city.", roleplay: "A friend asks if your family lives nearby.", followUp: "Do you live with family or friends?", phrases: ["live with", "lives nearby", "another city", "family or friends"]),
        EnglishLessonSeed(id: "english-food-likes", unit: 1, title: "Food likes", subtitle: "say likes and dislikes", icon: "fork.knife", accent: .mint, model: "I like spicy food, but I don't eat it every day.", helper: "But helps you add a limit.", speak: "I don't really like sweet drinks.", swap: "Change sweet drinks to one food or drink.", check: "You want to say you enjoy noodles.", answer: "I like eating noodles.", roleplay: "A coworker asks what food you like.", followUp: "What kind of food do you like?", phrases: ["spicy food", "don't really like", "every day", "what kind of food"]),
        EnglishLessonSeed(id: "english-review-starter-week", unit: 1, title: "Starter week check", subtitle: "combine first-week phrases", icon: "checkmark.seal.fill", accent: .blue, model: "Hi, I'm Alex. I'm from Jakarta, and I'm learning English for work.", helper: "This pulls together name, place, and reason.", speak: "I'm a little nervous, but I want to practice.", swap: "Change the name, place, and reason.", check: "You explain your learning reason.", answer: "I'm learning English because I want to speak confidently.", roleplay: "Start a short first conversation with name, feeling, and one question.", followUp: "How about you?", phrases: ["learning English for work", "want to practice", "speak confidently", "how about you"]),
        EnglishLessonSeed(id: "english-appointment-time", unit: 2, title: "Make an appointment", subtitle: "choose and confirm a time", icon: "calendar", accent: .blue, model: "Do you have any openings on Friday morning?", helper: "Openings means available appointment times.", speak: "Could I come in at three?", swap: "Change the day and time.", check: "You need to move an appointment.", answer: "Can I move my appointment to Monday?", roleplay: "A clinic asks what time works for you.", followUp: "Friday morning works for me.", phrases: ["any openings", "come in at three", "move my appointment", "works for me"]),
        EnglishLessonSeed(id: "english-simple-service-problem", unit: 2, title: "Report a simple problem", subtitle: "say what is wrong and ask for help", icon: "wrench.adjustable.fill", accent: .amber, model: "Sorry, this isn't working.", helper: "Start with the problem before details.", speak: "The card reader isn't accepting my card.", swap: "Change card reader to machine, app, or door.", check: "You need help with a machine.", answer: "Could you help me with this machine?", roleplay: "A staff member asks what happened.", followUp: "What should I try next?", phrases: ["isn't working", "accepting my card", "help me with", "try next"]),
        EnglishLessonSeed(id: "english-return-item", unit: 2, title: "Return an item", subtitle: "explain a return politely", icon: "arrow.uturn.backward.circle.fill", accent: .violet, model: "I'd like to return this shirt.", helper: "I'd like to is polite and direct.", speak: "It doesn't fit me.", swap: "Change the reason: too small, damaged, wrong color.", check: "You need a different size.", answer: "Could I exchange it for a larger size?", roleplay: "A shop assistant asks why you want to return it.", followUp: "Do I need the receipt?", phrases: ["I'd like to return", "doesn't fit me", "exchange it for", "need the receipt"]),
        EnglishLessonSeed(id: "english-bank-payment", unit: 2, title: "Payment questions", subtitle: "ask about cards and receipts", icon: "creditcard.fill", accent: .mint, model: "Can I pay by card?", helper: "Use by card, in cash, or with this app.", speak: "Could I get a receipt, please?", swap: "Change receipt to bag, copy, or invoice.", check: "You ask if cash is accepted.", answer: "Do you accept cash?", roleplay: "The cashier says the card machine is down.", followUp: "Is there another way to pay?", phrases: ["pay by card", "get a receipt", "accept cash", "another way to pay"]),
        EnglishLessonSeed(id: "english-ask-local-recommendation", unit: 2, title: "Ask for a recommendation", subtitle: "ask for one local suggestion", icon: "mappin.and.ellipse", accent: .blue, model: "Do you know a good place for lunch nearby?", helper: "Good place for is useful for local questions.", speak: "I'm looking for a quiet cafe.", swap: "Change quiet cafe to pharmacy, ATM, or bookstore.", check: "You want a place that is not expensive.", answer: "Is there an affordable restaurant nearby?", roleplay: "A hotel worker asks what kind of place you need.", followUp: "Is it easy to walk there?", phrases: ["good place for", "nearby", "looking for", "easy to walk there"]),
        EnglishLessonSeed(id: "english-everyday-review", unit: 2, title: "Everyday review", subtitle: "handle errands in short lines", icon: "checkmark.seal.fill", accent: .amber, model: "Excuse me, I'm looking for the station. Is it far from here?", helper: "This combines attention, need, and distance.", speak: "Could you say that again more slowly?", swap: "Change station to one useful place.", check: "You ask for help after missing directions.", answer: "Could you repeat the directions?", roleplay: "You need to buy something, ask directions, and clarify one answer.", followUp: "Thanks, that helps.", phrases: ["looking for the station", "far from here", "more slowly", "repeat the directions"]),
        EnglishLessonSeed(id: "english-hobbies-detail", unit: 3, title: "Add hobby details", subtitle: "describe a hobby with one detail", icon: "paintpalette.fill", accent: .violet, model: "I like photography because it helps me slow down.", helper: "Because makes the hobby more personal.", speak: "I started running last year.", swap: "Change running to your hobby.", check: "You want to say you enjoy cooking at home.", answer: "I enjoy cooking at home.", roleplay: "A friend asks why you like your hobby.", followUp: "How did you get into it?", phrases: ["because it helps me", "started last year", "enjoy cooking", "get into it"]),
        EnglishLessonSeed(id: "english-weekend-plans", unit: 3, title: "Weekend plans", subtitle: "say plans and ask back", icon: "sun.max.fill", accent: .amber, model: "I'm going to visit my cousins this weekend.", helper: "Going to is simple future for plans.", speak: "I might stay home if it rains.", swap: "Change stay home to another backup plan.", check: "You ask about Saturday plans.", answer: "What are you doing on Saturday?", roleplay: "A coworker asks about your weekend.", followUp: "Do you have any plans?", phrases: ["going to visit", "this weekend", "might stay home", "any plans"]),
        EnglishLessonSeed(id: "english-invitation-accept", unit: 3, title: "Accept an invitation", subtitle: "accept and confirm details", icon: "envelope.open.fill", accent: .mint, model: "That sounds nice. What time should I come?", helper: "Accept first, then ask one detail.", speak: "I'd love to join.", swap: "Change join to come, help, or try it.", check: "You accept dinner politely.", answer: "I'd love to come for dinner.", roleplay: "A friend invites you to a small dinner.", followUp: "Should I bring anything?", phrases: ["sounds nice", "what time should I come", "I'd love to", "bring anything"]),
        EnglishLessonSeed(id: "english-invitation-decline", unit: 3, title: "Decline gently", subtitle: "say no without closing the relationship", icon: "hand.raised.fill", accent: .blue, model: "I can't make it tonight, but thank you for inviting me.", helper: "Give a clear no and appreciation.", speak: "Maybe another time?", swap: "Change tonight to tomorrow, Friday, or this weekend.", check: "You are busy this weekend.", answer: "I'm busy this weekend, but I'd like to join next time.", roleplay: "A friend invites you when you already have plans.", followUp: "Please invite me next time.", phrases: ["can't make it", "thank you for inviting me", "another time", "next time"]),
        EnglishLessonSeed(id: "english-short-story-yesterday", unit: 3, title: "Tell a short story", subtitle: "tell three past actions", icon: "book.closed.fill", accent: .violet, model: "Yesterday I went to the market, bought fruit, and cooked dinner.", helper: "Three past verbs make a simple story.", speak: "I met a friend and we talked for an hour.", swap: "Change the verbs to your real day.", check: "You say you went to work yesterday.", answer: "I went to work yesterday.", roleplay: "A friend asks what you did yesterday.", followUp: "What did you do after that?", phrases: ["yesterday I went", "bought fruit", "talked for an hour", "after that"]),
        EnglishLessonSeed(id: "english-social-review", unit: 3, title: "Social review", subtitle: "keep a friendly conversation moving", icon: "person.2.wave.2.fill", accent: .mint, model: "That sounds nice. How did you get into it?", helper: "React first, then ask a follow-up.", speak: "I'd love to join, but I need to check my schedule.", swap: "Change join to one social plan.", check: "You ask a follow-up about a hobby.", answer: "How long have you been doing that?", roleplay: "Talk with a new friend about hobbies, plans, and one invitation.", followUp: "Let's talk again soon.", phrases: ["that sounds nice", "check my schedule", "how long have you", "talk again soon"]),
        EnglishLessonSeed(id: "english-work-clarify-task", unit: 4, title: "Clarify a task", subtitle: "ask what needs to happen next", icon: "list.bullet.clipboard.fill", accent: .blue, model: "Just to clarify, what should I send first?", helper: "Just to clarify makes the question feel careful.", speak: "Do you need the full report or just the summary?", swap: "Change report and summary to your task.", check: "You ask who owns the next task.", answer: "Who is responsible for the next step?", roleplay: "Your manager gives a task with missing details.", followUp: "I'll send the summary first.", phrases: ["just to clarify", "send first", "full report", "next step"]),
        EnglishLessonSeed(id: "english-work-blocker", unit: 4, title: "Explain a blocker", subtitle: "name a blocker and request help", icon: "exclamationmark.triangle.fill", accent: .amber, model: "I'm blocked because I don't have access to the file.", helper: "Blocked is common at work when progress stops.", speak: "I can continue after I get the login details.", swap: "Change file and login details to your situation.", check: "You need access before you can start.", answer: "I need access before I can start.", roleplay: "A teammate asks why the task is not moving.", followUp: "Could you add me to the folder?", phrases: ["I'm blocked because", "don't have access", "can continue after", "add me to the folder"]),
        EnglishLessonSeed(id: "english-polite-request", unit: 4, title: "Make a polite request", subtitle: "ask for help without pressure", icon: "hand.point.up.left.fill", accent: .mint, model: "Could you take a quick look when you have time?", helper: "When you have time lowers pressure.", speak: "Could you check this before Friday?", swap: "Change check this to review this, approve this, or send this.", check: "You ask for a short review.", answer: "Could you review this quickly?", roleplay: "You need a teammate to look at your draft.", followUp: "No rush if today is busy.", phrases: ["take a quick look", "when you have time", "before Friday", "no rush"]),
        EnglishLessonSeed(id: "english-meeting-clarification", unit: 4, title: "Clarify in a meeting", subtitle: "interrupt gently and check meaning", icon: "person.3.fill", accent: .violet, model: "Sorry, can I check one thing?", helper: "This is a gentle way to enter the meeting.", speak: "Do you mean we should launch this week?", swap: "Change launch this week to the decision you heard.", check: "You missed the deadline.", answer: "Sorry, what is the deadline?", roleplay: "In a meeting, you missed one important detail.", followUp: "Thanks, that makes sense.", phrases: ["check one thing", "do you mean", "what is the deadline", "makes sense"]),
        EnglishLessonSeed(id: "english-video-call-issues", unit: 4, title: "Video call phrases", subtitle: "handle call problems calmly", icon: "video.fill", accent: .blue, model: "Sorry, my audio is cutting out.", helper: "Name the technical problem clearly.", speak: "Could you repeat the last point?", swap: "Change audio to connection, camera, or screen.", check: "You cannot hear the speaker.", answer: "Sorry, I can't hear you clearly.", roleplay: "Your video call has a connection problem.", followUp: "I'll reconnect and join again.", phrases: ["audio is cutting out", "repeat the last point", "hear you clearly", "join again"]),
        EnglishLessonSeed(id: "english-work-review", unit: 4, title: "Work review", subtitle: "combine update, blocker, and request", icon: "checkmark.seal.fill", accent: .amber, model: "The draft is ready, but I'm blocked on the final numbers.", helper: "This gives status plus blocker.", speak: "Could you review the summary when you have time?", swap: "Change draft, numbers, and summary.", check: "You need feedback by tomorrow.", answer: "Could you send feedback by tomorrow?", roleplay: "Give a short work update with one request.", followUp: "After that, I can finish the next version.", phrases: ["draft is ready", "blocked on", "review the summary", "next version"]),
        EnglishLessonSeed(id: "english-airport-checkin", unit: 5, title: "Airport check-in", subtitle: "check in and ask about bags", icon: "airplane.circle.fill", accent: .blue, model: "Hi, I'd like to check in for my flight to Singapore.", helper: "Use flight to plus the destination.", speak: "Can I check this bag?", swap: "Change Singapore and bag details.", check: "You ask where to drop your bag.", answer: "Where should I drop off my bag?", roleplay: "An airline agent asks for your passport and destination.", followUp: "Is the flight still on time?", phrases: ["check in for my flight", "check this bag", "drop off my bag", "on time"]),
        EnglishLessonSeed(id: "english-flight-delay", unit: 5, title: "Flight delay", subtitle: "ask about a delay and next step", icon: "clock.badge.exclamationmark.fill", accent: .amber, model: "My flight is delayed. What should I do now?", helper: "Ask for the next action, not all details.", speak: "Will I miss my connection?", swap: "Change connection to bus, train, or meeting.", check: "You ask for the new boarding time.", answer: "What is the new boarding time?", roleplay: "Staff announces a delay and you need clear next steps.", followUp: "Do I need to go to a different gate?", phrases: ["flight is delayed", "what should I do now", "miss my connection", "different gate"]),
        EnglishLessonSeed(id: "english-hotel-problem", unit: 5, title: "Hotel problem", subtitle: "report one room issue", icon: "bed.double.circle.fill", accent: .violet, model: "Excuse me, the air conditioning isn't working.", helper: "Name the object and the problem.", speak: "Could someone check it, please?", swap: "Change air conditioning to shower, key card, or light.", check: "Your key card does not work.", answer: "My key card isn't working.", roleplay: "You return to reception with a room problem.", followUp: "Is another room available?", phrases: ["isn't working", "someone check it", "key card", "another room available"]),
        EnglishLessonSeed(id: "english-restaurant-travel", unit: 5, title: "Restaurant while traveling", subtitle: "order and ask local questions", icon: "fork.knife.circle.fill", accent: .mint, model: "Could I have the local special, please?", helper: "Local special is a simple restaurant question.", speak: "Is it spicy?", swap: "Change spicy to vegetarian, sweet, or popular.", check: "You ask for the bill.", answer: "Could I have the bill, please?", roleplay: "A server recommends a local dish.", followUp: "What do people usually order here?", phrases: ["local special", "is it spicy", "have the bill", "usually order"]),
        EnglishLessonSeed(id: "english-lost-item", unit: 5, title: "Lost item", subtitle: "describe a lost item", icon: "questionmark.folder.fill", accent: .blue, model: "I think I left my phone in the taxi.", helper: "I think I left is useful when you are not sure.", speak: "It's a black phone with a blue case.", swap: "Change the item and color.", check: "You ask if anyone found your bag.", answer: "Has anyone found a small black bag?", roleplay: "You are at a hotel desk and your item is missing.", followUp: "Where is the lost and found?", phrases: ["left my phone", "in the taxi", "blue case", "lost and found"]),
        EnglishLessonSeed(id: "english-pharmacy-travel", unit: 5, title: "Pharmacy abroad", subtitle: "ask for medicine advice", icon: "cross.vial.fill", accent: .amber, model: "Do you have something for a headache?", helper: "Something for is simple when you need medicine.", speak: "I took this medicine this morning.", swap: "Change headache and timing.", check: "You ask how often to take medicine.", answer: "How often should I take this?", roleplay: "A pharmacist asks what symptoms you have.", followUp: "Should I take it with food?", phrases: ["something for", "headache", "how often", "with food"]),
        EnglishLessonSeed(id: "english-local-transport", unit: 5, title: "Local transport", subtitle: "ask the best way to travel", icon: "bus.fill", accent: .mint, model: "What's the best way to get to the museum?", helper: "Best way lets the local person choose transport.", speak: "Should I take a bus or a taxi?", swap: "Change museum and transport options.", check: "You ask how long it takes.", answer: "How long does it take to get there?", roleplay: "A local gives you two transport options.", followUp: "Which option is easier?", phrases: ["best way to get to", "take a bus", "how long does it take", "which option"]),
        EnglishLessonSeed(id: "english-travel-emergency", unit: 5, title: "Travel emergency", subtitle: "ask for urgent travel help", icon: "cross.case.circle.fill", accent: .violet, model: "I need urgent help. I lost my passport.", helper: "Short sentences are best when the situation is urgent.", speak: "Where is the nearest police station?", swap: "Change passport to wallet, phone, or bag.", check: "You need an embassy.", answer: "How can I contact my embassy?", roleplay: "A hotel worker asks what kind of help you need.", followUp: "Can you call someone who speaks English?", phrases: ["urgent help", "lost my passport", "police station", "contact my embassy"]),
        EnglishLessonSeed(id: "english-travel-review", unit: 5, title: "Travel review", subtitle: "handle a travel day", icon: "checkmark.seal.fill", accent: .blue, model: "My flight is delayed, and I might miss my connection.", helper: "This joins problem and consequence.", speak: "Could you help me find another option?", swap: "Change the delay and option.", check: "You explain a lost phone.", answer: "I left my phone in the taxi.", roleplay: "Handle check-in, a delay, and one local question.", followUp: "Thanks for helping me.", phrases: ["miss my connection", "another option", "left my phone", "thanks for helping"]),
        EnglishLessonSeed(id: "english-past-story", unit: 6, title: "Past story builder", subtitle: "tell a three-sentence past story", icon: "book.fill", accent: .violet, model: "Last weekend I visited my friend. We cooked dinner. Then we watched a movie.", helper: "Three short sentences are clearer than one long sentence.", speak: "Yesterday I finished work, went home, and rested.", swap: "Change the day and three actions.", check: "You talk about last night.", answer: "Last night I stayed home and studied English.", roleplay: "Tell a friend what you did last weekend.", followUp: "What did you do last weekend?", phrases: ["last weekend", "then we", "yesterday I", "last night"]),
        EnglishLessonSeed(id: "english-future-plans-confidence", unit: 6, title: "Future plans", subtitle: "explain a plan and reason", icon: "calendar.circle.fill", accent: .blue, model: "Next month I'm going to start a new project because I want a challenge.", helper: "Plan plus reason makes the answer stronger.", speak: "This year I want to speak English more at work.", swap: "Change month, project, and reason.", check: "You say your plan for tomorrow.", answer: "Tomorrow I'm going to practice for ten minutes.", roleplay: "A coworker asks about your goals for this month.", followUp: "What are you planning to do next?", phrases: ["next month", "going to start", "because I want", "planning to do"]),
        EnglishLessonSeed(id: "english-explain-reasons", unit: 6, title: "Explain reasons", subtitle: "give two simple reasons", icon: "text.bubble.fill", accent: .amber, model: "I prefer the morning because it's quiet and I can focus.", helper: "Because plus two short reasons sounds complete.", speak: "I chose this class because it fits my schedule.", swap: "Change morning and reasons.", check: "You explain why you like online lessons.", answer: "I like online lessons because they are flexible.", roleplay: "Someone asks why you chose this option.", followUp: "The main reason is time.", phrases: ["I prefer", "because it's quiet", "fits my schedule", "main reason"]),
        EnglishLessonSeed(id: "english-compare-options", unit: 6, title: "Compare options", subtitle: "compare two choices", icon: "arrow.left.arrow.right.circle.fill", accent: .mint, model: "The train is cheaper, but the taxi is faster.", helper: "Cheaper but faster is a useful comparison frame.", speak: "This room is quieter than the first one.", swap: "Change the items and comparison words.", check: "You compare two restaurants.", answer: "This restaurant is cheaper than that one.", roleplay: "A friend asks which option you prefer and why.", followUp: "Which one would you choose?", phrases: ["cheaper but faster", "quieter than", "which option", "would you choose"]),
        EnglishLessonSeed(id: "english-give-preference", unit: 6, title: "Give preferences", subtitle: "state a preference politely", icon: "slider.horizontal.3", accent: .blue, model: "I'd rather meet in the afternoon if that works for you.", helper: "I'd rather is clear but polite.", speak: "I prefer a quiet place because it's easier to talk.", swap: "Change afternoon and quiet place.", check: "You prefer tea instead of coffee.", answer: "I'd rather have tea, please.", roleplay: "A friend offers two meeting times.", followUp: "Does that work for you?", phrases: ["I'd rather", "if that works", "I prefer", "easier to talk"]),
        EnglishLessonSeed(id: "english-repair-misunderstanding", unit: 6, title: "Repair misunderstandings", subtitle: "fix meaning during a conversation", icon: "arrow.triangle.2.circlepath.circle.fill", accent: .violet, model: "Sorry, I mean Friday morning, not Friday night.", helper: "I mean lets you repair the message quickly.", speak: "Let me say that again more clearly.", swap: "Change Friday morning to the detail you need.", check: "You correct a wrong time.", answer: "Sorry, I meant three o'clock, not two.", roleplay: "Someone misunderstood your plan.", followUp: "Is that clearer?", phrases: ["I mean", "not Friday night", "say that again", "is that clearer"]),
        EnglishLessonSeed(id: "english-longer-answer", unit: 6, title: "Longer answer practice", subtitle: "answer in three to five sentences", icon: "text.alignleft", accent: .amber, model: "I like my neighborhood. It is quiet in the morning. There are small shops nearby. I usually walk there after work.", helper: "Short connected sentences build confidence.", speak: "My English goal is simple. I want to speak at work. I practice a little every day.", swap: "Change the topic and three details.", check: "You give a three-sentence answer about your city.", answer: "I live in Jakarta. It is busy, but I like it. There is always good food nearby.", roleplay: "Answer a familiar question with three or four short sentences.", followUp: "Can you tell me a little more?", phrases: ["my neighborhood", "small shops nearby", "my English goal", "a little every day"]),
        EnglishLessonSeed(id: "english-weekly-speaking-check-1", unit: 6, title: "Weekly speaking check", subtitle: "answer a familiar prompt clearly", icon: "waveform.circle.fill", accent: .mint, model: "This week I practiced introductions, travel questions, and work updates.", helper: "A weekly check should be short and familiar.", speak: "One phrase I want to keep is, Could you say that again?", swap: "Change the phrase and topics.", check: "You name one next focus.", answer: "Next week I want to answer more naturally.", roleplay: "Give a short weekly summary: what improved, one phrase to keep, and one next focus.", followUp: "One thing that improved is my confidence.", phrases: ["this week I practiced", "want to keep", "next week", "one thing that improved"]),
        EnglishLessonSeed(id: "english-confidence-final", unit: 6, title: "Confidence conversation", subtitle: "hold a longer realistic exchange", icon: "checkmark.seal.fill", accent: .blue, model: "Hi, I'm Alex. I'm here for work, but I'm also exploring the city this weekend.", helper: "This combines identity, reason, and plan.", speak: "Yesterday I had a small problem with my hotel room, but the staff helped me.", swap: "Change the situation and outcome.", check: "You repair a misunderstanding in conversation.", answer: "Sorry, I mean tomorrow morning, not tonight.", roleplay: "Have a three-turn conversation about travel, work, and a small problem.", followUp: "Thanks for your help. I feel more confident now.", phrases: ["here for work", "exploring the city", "staff helped me", "feel more confident"])
    ]

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
                LessonStep(id: "\(id)-mistake", kind: .choice, title: "Common mistake", prompt: mistakePrompt, helper: "Say the clear line out loud.", choices: [], correctAnswer: correctAnswer),
                LessonStep(id: "\(id)-roleplay", kind: .roleplay, title: "Roleplay", prompt: roleplay, helper: roleplayHelper, choices: [], correctAnswer: nil),
                LessonStep(id: "\(id)-follow-up", kind: .freeResponse, title: "Follow-up practice", prompt: followUp, helper: followUpHelper, choices: [], correctAnswer: nil)
            ],
            savedWords: savedWords,
            visualAssetKind: icon,
            primarySkill: goal.replacingOccurrences(of: "My goal is to ", with: ""),
            modelPhrase: model,
            helperText: modelHelper,
            savedPhrases: savedWords.map(\.term),
            reviewPrompts: [
                correctAnswer,
                followUp,
                "Change one detail: \(speak)"
            ],
            roleplayPrompt: roleplay,
            expectedLearnerAction: roleplayHelper,
            naturalVersionExamples: [model, speak, alternative, followUp],
            aiVariationPrompts: aiVariationPrompts(for: unit)
        )
    }

    private static func aiVariationPrompts(for unit: Int) -> [String] {
        switch unit {
        case 1:
            return [
                "Keep the answer to one friendly sentence before asking back.",
                "Change only one personal detail at a time.",
                "If the learner freezes, offer a two-word starter."
            ]
        case 2:
            return [
                "Use one practical place, item, time, or problem.",
                "Ask for the next step after the learner states the need.",
                "Keep the roleplay realistic for a shop, counter, clinic, or street."
            ]
        case 3:
            return [
                "React naturally before asking a follow-up.",
                "Invite the learner to add one feeling, reason, or plan.",
                "Make the second turn social, not transactional."
            ]
        case 4:
            return [
                "Keep work replies concise: status, blocker, request.",
                "Use polite pressure only when a deadline is part of the prompt.",
                "Ask one clarifying question before adding complexity."
            ]
        case 5:
            return [
                "Keep travel problem lines short and specific.",
                "Ask for one useful detail such as time, place, gate, or next step.",
                "Use calm repair phrases when the learner did not understand."
            ]
        default:
            return [
                "Ask for a longer answer only after a clear short answer.",
                "Invite one reason, comparison, preference, or repair.",
                "End with a practical next speaking prompt, not a score."
            ]
        }
    }

    private static func frenchConversationLesson(
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
        nextLine: String,
        nextLineHelper: String,
        checkPrompt: String,
        correctAnswer: String,
        commonMistake: String,
        extraMistake: String,
        roleplay: String,
        roleplayHelper: String,
        followUp: String,
        followUpHelper: String,
        savedWords: [SavedWord]
    ) -> BeginnerLesson {
        return BeginnerLesson(
            id: id,
            unit: unit,
            title: title,
            subtitle: subtitle,
            icon: icon,
            accent: accent,
            minutes: minutes,
            steps: [
                LessonStep(id: "\(id)-goal", kind: .teach, title: "Speaking goal", prompt: goal, helper: "Keep the line short so it is easy to say.", choices: [], correctAnswer: nil),
                LessonStep(id: "\(id)-model", kind: .teach, title: "Listen and repeat", prompt: model, helper: modelHelper, choices: [], correctAnswer: nil),
                LessonStep(id: "\(id)-speak", kind: .speak, title: "Say it your way", prompt: speak, helper: speakHelper, choices: [], correctAnswer: nil),
                LessonStep(id: "\(id)-next-line", kind: .speak, title: "Natural next line", prompt: nextLine, helper: nextLineHelper, choices: [], correctAnswer: nil),
                LessonStep(id: "\(id)-check", kind: .choice, title: "Clear answer", prompt: checkPrompt, helper: "Say the natural French line out loud.", choices: [], correctAnswer: correctAnswer),
                LessonStep(id: "\(id)-roleplay", kind: .speak, title: "Roleplay", prompt: roleplay, helper: roleplayHelper, choices: [], correctAnswer: nil),
                LessonStep(id: "\(id)-follow-up", kind: .speak, title: "Follow-up practice", prompt: followUp, helper: followUpHelper, choices: [], correctAnswer: nil)
            ],
            savedWords: savedWords
        )
    }

    private static let englishLessons: [BeginnerLesson] = {
        let baseLessons: [BeginnerLesson] = [
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
            alternative: "You can call me Alex.",
            alternativeHelper: "Use this when you prefer a short name.",
            mistakePrompt: "You want to say where you live.",
            correctAnswer: "I live in Jakarta.",
            commonMistake: "I am live in Jakarta.",
            roleplay: "A new classmate says, Hi, I'm Sara. What should I call you?",
            roleplayHelper: "Answer with your preferred name, then add one small detail.",
            followUp: "I'm learning English because I want to speak more confidently.",
            followUpHelper: "Swap the reason: for work, for travel, for my studies, or for friends.",
            savedWords: [
                phrase("nice to meet you", "polite phrase for a first meeting", "Hi, I'm Maya. Nice to meet you."),
                phrase("I'm from", "use this to say your city or country", "I'm from Indonesia."),
                phrase("you can call me", "say the name you prefer", "You can call me Alex."),
                phrase("I'm learning English because", "explain your reason simply", "I'm learning English because I want to travel.")
            ],
            extraMistake: "I live at Jakarta."
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
            speak: "I'm doing well. I had a quiet morning.",
            speakHelper: "Add one tiny detail if you want to sound natural.",
            alternative: "A little tired, but I'm okay.",
            alternativeHelper: "Use this when the answer is honest but still friendly.",
            mistakePrompt: "Someone asks, How are you today?",
            correctAnswer: "I'm doing well, thanks.",
            commonMistake: "I doing well, thanks.",
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
            extraMistake: "I am well doing."
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
            mistakePrompt: "You want to say when you sleep.",
            correctAnswer: "I go to bed at ten.",
            commonMistake: "I go bed in ten.",
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
            extraMistake: "I am go to bed at ten."
        ),
        englishConversationLesson(
            id: "english-free-time",
            unit: 1,
            title: "Talk about free time",
            subtitle: "Share likes and ask a follow-up",
            icon: "figure.walk",
            accent: .violet,
            minutes: 5,
            goal: "My goal is to say what I like and ask about the other person.",
            model: "I like watching movies when I have free time.",
            modelHelper: "This is easy, personal, and useful for friendly conversation.",
            speak: "I like walking around the city on weekends.",
            speakHelper: "Change walking around the city to your real activity.",
            alternative: "I'm into cooking these days.",
            alternativeHelper: "I'm into means I like it right now.",
            mistakePrompt: "You want to say you enjoy music.",
            correctAnswer: "I like listening to music.",
            commonMistake: "I like listen music.",
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
            extraMistake: "I am like music."
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
            speak: "Are you free after class?",
            speakHelper: "Use are you free to check availability first.",
            alternative: "Does Saturday afternoon work for you?",
            alternativeHelper: "This checks if the time is okay for the other person.",
            mistakePrompt: "You want to suggest meeting at six.",
            correctAnswer: "Let's meet at six.",
            commonMistake: "Let's meeting at six.",
            roleplay: "A classmate says, I'd like to practice English more. Suggest a time.",
            roleplayHelper: "Ask if they are free, give a time, and check if it works.",
            followUp: "Great, see you there at six.",
            followUpHelper: "Close the plan with the time or place.",
            savedWords: [
                phrase("would you like to", "polite way to invite someone", "Would you like to meet tomorrow?"),
                phrase("are you free", "ask if someone has time", "Are you free after class?"),
                phrase("does Saturday work for you", "ask if a day is okay", "Does Saturday work for you?"),
                phrase("see you there", "confirm the meeting place", "Great, see you there at six.")
            ],
            extraMistake: "We meet on six?"
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
            speak: "I'm here for the language meetup.",
            speakHelper: "Use I'm here for to explain the situation.",
            alternative: "I only started recently, so I'm a little nervous.",
            alternativeHelper: "This is honest and easy to say.",
            mistakePrompt: "You want to explain why you are learning English.",
            correctAnswer: "I'm learning English for work.",
            commonMistake: "I learning English for work.",
            roleplay: "You meet a new person at a language meetup. Start the conversation.",
            roleplayHelper: "Use your name, one detail, and one question.",
            followUp: "Would you like to practice together sometime?",
            followUpHelper: "End by making a simple future plan.",
            savedWords: [
                phrase("I'm here for", "explain why you are in a place", "I'm here for the language meetup."),
                phrase("for work", "explain a practical reason", "I'm learning English for work."),
                phrase("sometime", "not a fixed time yet", "Would you like to practice together sometime?"),
                phrase("language meetup", "a place where people practice languages", "I met Sara at a language meetup.")
            ],
            extraMistake: "I learn English because for work."
        ),
        englishConversationLesson(
            id: "english-ordering",
            unit: 2,
            title: "Order food and drinks",
            subtitle: "Order clearly and answer counter questions",
            icon: "cup.and.saucer.fill",
            accent: .amber,
            minutes: 6,
            goal: "My goal is to order at a cafe and answer one follow-up question.",
            model: "Hi, can I get a latte and a croissant, please?",
            modelHelper: "Can I get sounds natural at a cafe counter.",
            speak: "For here, please.",
            speakHelper: "Use this when they ask if you will eat or drink inside.",
            alternative: "That's all for me, thanks.",
            alternativeHelper: "Use this after the worker asks if you want anything else.",
            mistakePrompt: "The cashier asks, For here or to go?",
            correctAnswer: "To go, please.",
            commonMistake: "I go please.",
            roleplay: "The cashier says, We don't have croissants today. Would a muffin be okay?",
            roleplayHelper: "Accept the replacement or choose another item.",
            followUp: "A muffin is fine, thanks.",
            followUpHelper: "Use fine when the replacement works for you.",
            savedWords: [
                phrase("can I get", "natural way to order at a counter", "Can I get a latte, please?"),
                phrase("for here", "say you will eat or drink inside", "For here, please."),
                phrase("to go", "say you will take it away", "To go, please."),
                phrase("that's all for me", "say you do not want more", "That's all for me, thanks.")
            ],
            extraMistake: "For go, please."
        ),
        englishConversationLesson(
            id: "english-restaurant-check",
            unit: 2,
            title: "Ask restaurant questions",
            subtitle: "Check a menu, allergies, and the bill",
            icon: "fork.knife",
            accent: .violet,
            minutes: 6,
            goal: "My goal is to check a dish before I order it.",
            model: "Does this come with rice or salad?",
            modelHelper: "Use come with to ask what is included.",
            speak: "Is there any meat in this soup?",
            speakHelper: "Use is there any when you need to check one ingredient.",
            alternative: "Can you make it without onions?",
            alternativeHelper: "Use without to remove one ingredient.",
            mistakePrompt: "You have an allergy and need to ask about peanuts.",
            correctAnswer: "Does this have peanuts in it?",
            commonMistake: "This has peanuts in it?",
            roleplay: "The server says, It comes with rice. Is that okay?",
            roleplayHelper: "Answer yes or ask for a change before ordering.",
            followUp: "Yes, rice is fine. I'll have that, please.",
            followUpHelper: "Confirm the answer, then place the order.",
            savedWords: [
                phrase("does this come with", "ask what is included", "Does this come with rice or salad?"),
                phrase("is there any", "ask if one thing is inside", "Is there any meat in this soup?"),
                phrase("without onions", "ask to remove an ingredient", "Can you make it without onions?"),
                phrase("rice is fine", "say the option is okay", "Yes, rice is fine.")
            ],
            extraMistake: "This food has peanut?"
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
            model: "Excuse me, how do I get to the train station?",
            modelHelper: "Use how do I get to when you need the route, not just the place.",
            speak: "Is it far from here?",
            speakHelper: "Ask this before you decide to walk.",
            alternative: "Should I turn left at the traffic lights?",
            alternativeHelper: "Use should I to check one step in the route.",
            mistakePrompt: "You missed the street name.",
            correctAnswer: "Could you say the street name again?",
            commonMistake: "Could say street name again?",
            roleplay: "A local says, Walk two blocks and turn right after the bank.",
            roleplayHelper: "Repeat the route in your own words, then thank them.",
            followUp: "Two blocks, then right after the bank. Thanks.",
            followUpHelper: "Repeat only the key landmarks so the check stays quick.",
            savedWords: [
                phrase("excuse me", "polite way to get attention", "Excuse me, where is the station?"),
                phrase("how do I get to", "ask for the route to a place", "How do I get to the train station?"),
                phrase("is it far from here", "ask about distance", "Is it far from here?"),
                phrase("turn right after", "direction using a landmark", "Turn right after the bank.")
            ],
            extraMistake: "Again the street name please you?"
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
            model: "One adult ticket to City Hall, please.",
            modelHelper: "This works at a station counter or ticket window.",
            speak: "Which platform does it leave from?",
            speakHelper: "Use this after you buy the ticket and need the next step.",
            alternative: "Can I use this ticket on the bus too?",
            alternativeHelper: "Ask this when one ticket might cover another ride.",
            mistakePrompt: "You need to know where to get off for the airport.",
            correctAnswer: "Which stop should I get off at for the airport?",
            commonMistake: "Airport is which stop I get off?",
            roleplay: "The ticket agent says, The next train leaves from platform three at 10:20.",
            roleplayHelper: "Confirm the platform and time, then thank them.",
            followUp: "Platform three at 10:20. Thank you.",
            followUpHelper: "Repeating the detail helps you avoid missing the ride.",
            savedWords: [
                phrase("one adult ticket to", "ask for one ticket to a place", "One adult ticket to City Hall, please."),
                phrase("which platform", "ask where a train leaves", "Which platform does it leave from?"),
                phrase("get off at", "leave a bus or train at a stop", "Which stop should I get off at?"),
                phrase("platform three", "a platform number", "The train leaves from platform three.")
            ],
            extraMistake: "Where I get down for airport?"
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
            model: "How much is this jacket?",
            modelHelper: "Use this when you point to one item.",
            speak: "Do you have it in medium?",
            speakHelper: "Change medium to your size or the color you want.",
            alternative: "Can I try it on?",
            alternativeHelper: "Ask this before you go to the fitting room.",
            mistakePrompt: "The shirt is too small and you need a bigger one.",
            correctAnswer: "Do you have a larger size?",
            commonMistake: "You have more big size?",
            roleplay: "The assistant says, This one is 30 dollars, but the blue one is on sale.",
            roleplayHelper: "Ask about the sale item or name the one you want.",
            followUp: "I'll take the blue one, please.",
            followUpHelper: "Use I'll take when you have decided to buy.",
            savedWords: [
                phrase("how much is this", "ask the price of one thing", "How much is this jacket?"),
                phrase("in medium", "ask for a size", "Do you have it in medium?"),
                phrase("try it on", "put on clothes before buying", "Can I try it on?"),
                phrase("on sale", "available at a lower price", "The blue one is on sale.")
            ],
            extraMistake: "Have this more large?"
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
            model: "Sorry, can you say that again?",
            modelHelper: "This is a simple way to ask for a repeat without freezing.",
            speak: "Could you speak more slowly, please?",
            speakHelper: "Use this when you hear the words but need more time.",
            alternative: "Can you show me where to press?",
            alternativeHelper: "Use this when a person can point or demonstrate.",
            mistakePrompt: "You understood most of the sentence but missed the final step.",
            correctAnswer: "What should I do after that?",
            commonMistake: "What I do after that?",
            roleplay: "A ticket-machine helper says, First choose the station, then tap your card. You do not see the station name.",
            roleplayHelper: "Explain what you cannot find and ask them to show you.",
            followUp: "I can't find the station name. Can you show me?",
            followUpHelper: "Say the exact problem so the other person can help quickly.",
            savedWords: [
                phrase("can you say that again", "ask someone to repeat", "Can you say that again?"),
                phrase("could you speak more slowly", "ask someone to slow down", "Could you speak more slowly, please?"),
                phrase("show me where to press", "ask someone to demonstrate", "Can you show me where to press?"),
                phrase("what should I do after that", "ask for the next step", "What should I do after that?")
            ],
            extraMistake: "After that what I should do?"
        ),
        englishConversationLesson(
            id: "english-work-chat",
            unit: 4,
            title: "Start a work chat",
            subtitle: "Share your role and find the next step",
            icon: "briefcase.fill",
            accent: .blue,
            minutes: 6,
            goal: "My goal is to start a work chat with my role and one useful next step.",
            model: "Hi, I'm Maya. I joined the product team this week.",
            modelHelper: "Use joined to give quick context when you are new.",
            speak: "I work on onboarding, so I'll be helping with the app flow.",
            speakHelper: "Use I work on plus a project, task, or area.",
            alternative: "I'm still getting settled, but it's good to meet you.",
            alternativeHelper: "This sounds friendly without giving a long story.",
            mistakePrompt: "You tell someone the project you work on.",
            correctAnswer: "I'm helping with the onboarding project.",
            commonMistake: "I helping with the onboarding project.",
            roleplay: "A teammate says, Welcome. What will you be working on?",
            roleplayHelper: "Say your area, then ask where to find the current notes.",
            followUp: "Where can I find the latest project notes?",
            followUpHelper: "This moves the chat toward useful work information.",
            savedWords: [
                phrase("joined the product team", "say you recently became part of a team", "I joined the product team this week."),
                phrase("I work on", "say the project or task you handle", "I work on onboarding."),
                phrase("getting settled", "still learning a new workplace", "I'm still getting settled."),
                phrase("latest project notes", "the newest shared information about work", "Where can I find the latest project notes?")
            ],
            extraMistake: "I am help onboarding project."
        ),
        englishConversationLesson(
            id: "english-meeting-check-in",
            unit: 4,
            title: "Give a meeting update",
            subtitle: "Join the check-in and move work forward",
            icon: "person.2.fill",
            accent: .mint,
            minutes: 6,
            goal: "My goal is to give a short meeting update and ask who should act next.",
            model: "Hi everyone. I have a quick update on the timeline.",
            modelHelper: "Name the topic before you give details.",
            speak: "The draft is ready for review.",
            speakHelper: "Give one clear status before you ask for feedback.",
            alternative: "Before we move on, can we choose the next owner?",
            alternativeHelper: "Use this when the meeting needs a clear next person.",
            mistakePrompt: "You need feedback before Thursday.",
            correctAnswer: "I need feedback by Thursday.",
            commonMistake: "I need feedback until Thursday.",
            roleplay: "Your manager says, Let's start with your update.",
            roleplayHelper: "Say what is ready, then say what you need next.",
            followUp: "Who should review the draft next?",
            followUpHelper: "This turns your update into a clear next action.",
            savedWords: [
                phrase("quick update", "a short work status", "I have a quick update on the timeline."),
                phrase("the draft is ready", "say a work item is finished enough to review", "The draft is ready for review."),
                phrase("feedback by Thursday", "a clear deadline for comments", "I need feedback by Thursday."),
                phrase("review the draft", "read and comment on a work item", "Who should review the draft next?")
            ],
            extraMistake: "I need the feedback on Thursday before."
        ),
        englishConversationLesson(
            id: "english-phone-call",
            unit: 4,
            title: "Make a work call",
            subtitle: "Open the call and state the purpose",
            icon: "phone.fill",
            accent: .violet,
            minutes: 6,
            goal: "My goal is to make a short work call and explain why I am calling.",
            model: "Hi, this is Alex from Converlax.",
            modelHelper: "Use this is when you introduce yourself on a call.",
            speak: "I'm calling about the invoice you sent yesterday.",
            speakHelper: "Use I'm calling about plus the topic of the call.",
            alternative: "I only need two minutes.",
            alternativeHelper: "Use this when the call should be short.",
            mistakePrompt: "You check if the person can talk now.",
            correctAnswer: "Is now still a good time to talk?",
            commonMistake: "Now still good time for talk?",
            roleplay: "A supplier answers the phone. Introduce yourself and say why you are calling.",
            roleplayHelper: "Give your name, company, and one clear call topic.",
            followUp: "Could you send the updated time by email?",
            followUpHelper: "End with the exact information you need after the call.",
            savedWords: [
                phrase("this is Alex from", "introduce yourself and your company on a call", "Hi, this is Alex from Converlax."),
                phrase("I'm calling about", "state the purpose of a call", "I'm calling about the invoice."),
                phrase("good time to talk", "ask if someone can talk now", "Is now still a good time to talk?"),
                phrase("send the updated time", "ask for the new schedule", "Could you send the updated time by email?")
            ],
            extraMistake: "It is good time talking now?"
        ),
        englishConversationLesson(
            id: "english-explain-problem",
            unit: 4,
            title: "Explain a problem",
            subtitle: "Report the issue and the next blocker",
            icon: "exclamationmark.bubble.fill",
            accent: .amber,
            minutes: 6,
            goal: "My goal is to explain a work problem with the symptom and what is blocked.",
            model: "I'm having trouble uploading the file.",
            modelHelper: "Use having trouble plus an -ing verb for a simple issue.",
            speak: "The upload stops at 80 percent, so I can't send the report.",
            speakHelper: "Say what happens, then explain why it matters.",
            alternative: "It may be a small issue, but it's blocking my next step.",
            alternativeHelper: "This sounds calm and shows the impact.",
            mistakePrompt: "You report a problem with a work file.",
            correctAnswer: "The report won't open on my laptop.",
            commonMistake: "The report can't open in my laptop.",
            roleplay: "IT asks, What is happening when you upload the file?",
            roleplayHelper: "Name the symptom, then say what you already tried.",
            followUp: "Can I send you a screenshot and the file name?",
            followUpHelper: "Offer the information that helps someone investigate.",
            savedWords: [
                phrase("having trouble uploading", "having a problem sending a file", "I'm having trouble uploading the file."),
                phrase("stops at 80 percent", "describe exactly where a process fails", "The upload stops at 80 percent."),
                phrase("blocking my next step", "preventing the next work action", "It's blocking my next step."),
                phrase("send you a screenshot", "share a picture of the issue", "Can I send you a screenshot?")
            ],
            extraMistake: "The upload stop in 80 percent."
        ),
        englishConversationLesson(
            id: "english-give-opinion",
            unit: 4,
            title: "Give a simple opinion",
            subtitle: "Share a choice and one useful reason",
            icon: "lightbulb.fill",
            accent: .blue,
            minutes: 6,
            goal: "My goal is to give a work opinion with one reason and one next test.",
            model: "I have a small suggestion about the plan.",
            modelHelper: "This opens your opinion gently before you choose.",
            speak: "Option B is clearer for new users.",
            speakHelper: "Give the option and the reason in one short sentence.",
            alternative: "My concern is the launch timing, not the idea itself.",
            alternativeHelper: "This keeps the tone respectful when you raise a concern.",
            mistakePrompt: "You suggest a small test.",
            correctAnswer: "Should we test it with one customer first?",
            commonMistake: "Should we testing it with one customer first?",
            roleplay: "A teammate asks, Which plan should we choose for the first version?",
            roleplayHelper: "Name one option and give one short work reason.",
            followUp: "What do you think?",
            followUpHelper: "Ask back so the conversation becomes a decision.",
            savedWords: [
                phrase("small suggestion", "a gentle way to offer an idea", "I have a small suggestion."),
                phrase("option B is clearer", "say one choice is easier to understand", "I think option B is clearer."),
                phrase("my concern is", "introduce a worry politely", "My concern is the launch timing."),
                phrase("test it with one customer", "try an idea with one real user first", "Should we test it with one customer first?")
            ],
            extraMistake: "Should test with one customer first?"
        ),
        englishConversationLesson(
            id: "english-agree-disagree",
            unit: 4,
            title: "Agree and disagree politely",
            subtitle: "Support the goal and adjust the plan",
            icon: "hand.thumbsup.fill",
            accent: .mint,
            minutes: 6,
            goal: "My goal is to agree with the goal, explain a concern, and suggest a better next step.",
            model: "I agree with the goal, but I have a concern about the deadline.",
            modelHelper: "Agree with the shared goal before you explain the problem.",
            speak: "Friday gives us one more day to test.",
            speakHelper: "Give a practical reason before you suggest a change.",
            alternative: "That makes sense. I just want to be careful with the timing.",
            alternativeHelper: "This is a softer way to disagree in a team conversation.",
            mistakePrompt: "You suggest a later launch date.",
            correctAnswer: "Can we move the launch to Friday?",
            commonMistake: "Can we moving launch to Friday?",
            roleplay: "A teammate wants to finish the project today, but you think it is too rushed.",
            roleplayHelper: "Support the goal, name the deadline concern, then suggest one change.",
            followUp: "Can we decide the final timeline after we see the draft?",
            followUpHelper: "This keeps the conversation moving toward a team decision.",
            savedWords: [
                phrase("agree with the goal", "support the main purpose", "I agree with the goal."),
                phrase("concern about the deadline", "a worry about timing", "I have a concern about the deadline."),
                phrase("move the launch", "change the launch date", "Maybe we can move the launch to Friday."),
                phrase("final timeline", "the agreed schedule", "Can we decide the final timeline?")
            ],
            extraMistake: "Can we move the launch in Friday?"
        ),
        englishConversationLesson(
            id: "english-hotel-check-in",
            unit: 5,
            title: "Check in at a hotel",
            subtitle: "Give your name and ask practical questions",
            icon: "bed.double.fill",
            accent: .violet,
            minutes: 6,
            goal: "My goal is to check in and handle one practical detail.",
            model: "Good evening. I have a room booked under Alex Tan.",
            modelHelper: "Room booked under names the person on the hotel booking.",
            speak: "I arrived a little early. Is the room ready yet?",
            speakHelper: "Use this when you arrive before the normal check-in time.",
            alternative: "What time does breakfast start?",
            alternativeHelper: "Ask for one useful hotel detail before you leave the desk.",
            mistakePrompt: "You ask reception to write the Wi-Fi password.",
            correctAnswer: "Could you write down the Wi-Fi password?",
            commonMistake: "Can you write the Wi-Fi password down me?",
            roleplay: "The receptionist asks, May I see your passport and card?",
            roleplayHelper: "Give the documents, then ask one practical hotel question.",
            followUp: "Thank you. What time is checkout?",
            followUpHelper: "Ask one final practical detail before leaving the desk.",
            savedWords: [
                phrase("room booked under", "say the hotel booking name", "I have a room booked under Alex Tan."),
                phrase("check in now", "ask if you can start check-in", "Could I check in now?"),
                phrase("not ready yet", "say the room is not available now", "The room is not ready yet."),
                phrase("write down", "ask someone to put information on paper", "Could you write down the Wi-Fi password?")
            ],
            extraMistake: "Could write down Wi-Fi password for me?"
        ),
        englishConversationLesson(
            id: "english-travel-plans",
            unit: 5,
            title: "Talk about travel plans",
            subtitle: "Say where you are going and what you plan to do",
            icon: "airplane.departure",
            accent: .blue,
            minutes: 6,
            goal: "My goal is to explain where I am going, when, and why.",
            model: "I'm staying in Bangkok until Friday.",
            modelHelper: "Use staying in for a temporary visit to a city.",
            speak: "Tomorrow I'm taking the train to the old town.",
            speakHelper: "Use tomorrow plus taking when the travel plan is already arranged.",
            alternative: "I'm here for work, but I have one free evening.",
            alternativeHelper: "Useful when travel is not only for vacation.",
            mistakePrompt: "The plan might change if it rains.",
            correctAnswer: "If it rains, I might visit the market instead.",
            commonMistake: "If rains, I maybe visit the market instead.",
            roleplay: "A hotel guest asks, What are your plans while you're here?",
            roleplayHelper: "Say the city, the day or length, and one flexible activity.",
            followUp: "Is there a quiet place nearby for dinner?",
            followUpHelper: "Ask for one specific local suggestion.",
            savedWords: [
                phrase("I'm staying in", "say where you are visiting now", "I'm staying in Bangkok until Friday."),
                phrase("until Friday", "say when a visit ends", "I'm here until Friday."),
                phrase("taking the train", "say planned transport", "Tomorrow I'm taking the train."),
                phrase("I might", "talk about a possible plan", "I might visit the market instead.")
            ],
            extraMistake: "If it rain, I might visit market."
        ),
        englishConversationLesson(
            id: "english-airport-travel",
            unit: 5,
            title: "Handle airport moments",
            subtitle: "Ask about gates, bags, and delays",
            icon: "airplane",
            accent: .amber,
            minutes: 6,
            goal: "My goal is to ask one clear airport question at a time.",
            model: "Which gate should I go to for flight 218?",
            modelHelper: "Use which gate when you need the gate number for a flight.",
            speak: "The screen says delayed. What is the new boarding time?",
            speakHelper: "Name the delay first, then ask for the updated time.",
            alternative: "My bag did not arrive. Where should I report it?",
            alternativeHelper: "Use report it when baggage is missing or damaged.",
            mistakePrompt: "You need to confirm the boarding time.",
            correctAnswer: "Just to confirm, boarding is at 6:40, right?",
            commonMistake: "Confirm, boarding at 6:40, yes?",
            roleplay: "An airline staff member asks, How can I help you?",
            roleplayHelper: "Name one issue: gate, delay, baggage, or confirmation.",
            followUp: "Thanks. I'll go to the gate now.",
            followUpHelper: "Close with the next action after you confirm.",
            savedWords: [
                phrase("which gate should I go to", "ask for the correct flight gate", "Which gate should I go to for flight 218?"),
                phrase("the screen says delayed", "say the flight board shows a delay", "The screen says delayed."),
                phrase("my bag did not arrive", "say baggage is missing", "My bag did not arrive."),
                phrase("just to confirm", "check information one more time", "Just to confirm, boarding is at 6:40, right?")
            ],
            extraMistake: "Just confirm boarding 6:40 right?"
        ),
        englishConversationLesson(
            id: "english-emergency-help",
            unit: 5,
            title: "Emergency help phrases",
            subtitle: "Ask for urgent help and say what is wrong",
            icon: "cross.case.fill",
            accent: .blue,
            minutes: 6,
            goal: "My goal is to ask for urgent help in short, direct lines.",
            model: "I need help now. My wallet was stolen.",
            modelHelper: "Use short sentences so the main problem is clear.",
            speak: "My bag is missing.",
            speakHelper: "Say what is wrong before you ask for help.",
            alternative: "Someone is hurt. We need a doctor.",
            alternativeHelper: "Say what happened, then name the help you need.",
            mistakePrompt: "You need security.",
            correctAnswer: "Please call security.",
            commonMistake: "Please call to security.",
            roleplay: "You are at a station and your bag is missing.",
            roleplayHelper: "Say you need help, what is wrong, and who should be called.",
            followUp: "Can you stay here until help comes?",
            followUpHelper: "Ask one person to stay if you need support.",
            savedWords: [
                phrase("I need help now", "direct urgent request", "I need help now."),
                phrase("was stolen", "say someone took something", "My wallet was stolen."),
                phrase("please call security", "ask someone to contact help", "Please call security."),
                phrase("someone is hurt", "say a person needs medical help", "Someone is hurt. We need a doctor.")
            ],
            extraMistake: "Call security please you."
        ),
        englishConversationLesson(
            id: "english-doctor-pharmacy",
            unit: 5,
            title: "Doctor and pharmacy",
            subtitle: "Describe symptoms and ask for medicine",
            icon: "pills.fill",
            accent: .mint,
            minutes: 6,
            goal: "My goal is to explain symptoms, timing, advice, and dosage.",
            model: "I have a fever and a sore throat.",
            modelHelper: "Use I have plus the symptom or symptoms.",
            speak: "It started two days ago.",
            speakHelper: "Say when the symptoms started before asking for medicine.",
            alternative: "Should I see a doctor, or can I take medicine for this?",
            alternativeHelper: "Ask for advice before choosing medicine.",
            mistakePrompt: "You describe stomach pain.",
            correctAnswer: "My stomach hurts.",
            commonMistake: "My stomach is pain.",
            roleplay: "A pharmacist asks, What symptoms do you have?",
            roleplayHelper: "Say your symptoms, how long, and ask what they recommend.",
            followUp: "How many tablets should I take each day?",
            followUpHelper: "Ask the dosage before you leave the pharmacy.",
            savedWords: [
                phrase("I have a fever", "describe a high temperature", "I have a fever."),
                phrase("it started", "say when a problem began", "It started two days ago."),
                phrase("should I see a doctor", "ask if medical care is needed", "Should I see a doctor?"),
                phrase("how many tablets", "ask about medicine dosage", "How many tablets should I take each day?")
            ],
            extraMistake: "I am stomach hurt."
        ),
        englishConversationLesson(
            id: "english-course-wrap-up",
            unit: 5,
            title: "Full conversation practice",
            subtitle: "Use the course phrases in one realistic exchange",
            icon: "checkmark.seal.fill",
            accent: .violet,
            minutes: 8,
            goal: "My goal is to open, ask, clarify, and close a real exchange.",
            model: "Hi, I'm Alex. I'm here for a short work trip.",
            modelHelper: "This gives your name and reason without a long story.",
            speak: "Could I ask where the airport train leaves from?",
            speakHelper: "Ask one practical question with could I ask where.",
            alternative: "Do you know a quiet cafe nearby?",
            alternativeHelper: "Ask for a specific recommendation so the answer is easier to follow.",
            mistakePrompt: "You did not catch the answer and need it again.",
            correctAnswer: "I missed the last part. Could you say it once more?",
            commonMistake: "I didn't hear all. Say again one more?",
            roleplay: "You meet someone near a station. Introduce yourself, ask one practical question, clarify one answer, and close.",
            roleplayHelper: "Use four short lines: who you are, your question, your clarification, and thanks.",
            followUp: "Thanks, that helps. Have a good day.",
            followUpHelper: "Close the exchange without adding extra explanation.",
            savedWords: [
                phrase("short work trip", "brief visit for work", "I'm here for a short work trip."),
                phrase("could I ask where", "start a practical location question", "Could I ask where the train leaves from?"),
                phrase("I missed the last part", "say you did not catch everything", "I missed the last part."),
                phrase("that helps", "say the answer was useful", "Thanks, that helps.")
            ],
            extraMistake: "I missed last part. Could say once more?"
        )
        ]

        return (1...6).flatMap { unit in
            baseLessons.filter { $0.unit == unit } + englishExpansionLessons.filter { $0.unit == unit }
        }
    }()

    private static let frenchLessons: [BeginnerLesson] = [
        frenchConversationLesson(
            id: "beginner-introductions",
            unit: 1,
            title: "Introduce yourself",
            subtitle: "Name, origin, and a polite reply",
            icon: "person.wave.2.fill",
            accent: .blue,
            minutes: 5,
            goal: "My goal is to greet someone and introduce myself in French.",
            model: "Bonjour. Je m'appelle Maya.",
            modelHelper: "Hello. My name is Maya.",
            speak: "Bonjour. Je m'appelle Alex.",
            speakHelper: "Change Alex to your real name.",
            nextLine: "Je viens d'Indonesie.",
            nextLineHelper: "Use je viens de to say where you are from.",
            checkPrompt: "Someone says, Bonjour, je m'appelle Sara.",
            correctAnswer: "Enchante, Sara.",
            commonMistake: "Je voudrais Sara.",
            extraMistake: "Ou est Sara ?",
            roleplay: "You meet a classmate. Say hello, your name, and where you are from.",
            roleplayHelper: "Use Bonjour, je m'appelle..., then Je viens de...",
            followUp: "Et vous ?",
            followUpHelper: "Ask the other person politely.",
            savedWords: [
                phrase("bonjour", "hello", "Bonjour, je m'appelle Maya."),
                phrase("je m'appelle", "my name is", "Je m'appelle Alex."),
                phrase("je viens de", "I come from", "Je viens d'Indonesie."),
                phrase("enchante", "nice to meet you", "Enchante, Sara.")
            ]
        ),
        frenchConversationLesson(
            id: "beginner-greetings",
            unit: 1,
            title: "Greet someone",
            subtitle: "Answer a check-in and ask back",
            icon: "bubble.left.fill",
            accent: .mint,
            minutes: 5,
            goal: "My goal is to answer a simple greeting and keep the exchange moving.",
            model: "Bonjour, comment ca va ?",
            modelHelper: "This means hello, how are you?",
            speak: "Ca va bien, merci.",
            speakHelper: "A simple answer when you are doing well.",
            nextLine: "Et vous ?",
            nextLineHelper: "Use this polite line to ask the same question back.",
            checkPrompt: "A shopkeeper asks, Comment ca va ?",
            correctAnswer: "Tres bien, merci. Et vous ?",
            commonMistake: "Je suis bien merci vous.",
            extraMistake: "Au revoir, ca va gare.",
            roleplay: "A neighbor says, Bonjour.",
            roleplayHelper: "Greet them, ask how they are, and answer simply.",
            followUp: "Au revoir. Bonne journee.",
            followUpHelper: "Use this to close the short exchange politely.",
            savedWords: [
                phrase("comment ca va", "how are you", "Bonjour, comment ca va ?"),
                phrase("ca va bien", "I am doing well", "Ca va bien, merci."),
                phrase("et vous", "and you", "Tres bien, merci. Et vous ?"),
                phrase("au revoir", "goodbye", "Au revoir. Bonne journee.")
            ]
        ),
        frenchConversationLesson(
            id: "beginner-ordering",
            unit: 1,
            title: "Order coffee",
            subtitle: "A short cafe order",
            icon: "cup.and.saucer.fill",
            accent: .amber,
            minutes: 5,
            goal: "My goal is to order one drink politely.",
            model: "Un cafe, s'il vous plait.",
            modelHelper: "A short cafe order: a coffee, please.",
            speak: "Je voudrais un cafe, s'il vous plait.",
            speakHelper: "Je voudrais means I would like.",
            nextLine: "Je voudrais de l'eau, s'il vous plait.",
            nextLineHelper: "Swap the item while keeping the polite frame.",
            checkPrompt: "You want juice.",
            correctAnswer: "Je voudrais un jus, s'il vous plait.",
            commonMistake: "Je suis un jus, s'il vous plait.",
            extraMistake: "Ou est un jus ?",
            roleplay: "The server says, Bonjour, vous desirez ?",
            roleplayHelper: "Order one drink and say merci.",
            followUp: "Merci. C'est tout.",
            followUpHelper: "Use this when you are done ordering.",
            savedWords: [
                phrase("je voudrais", "I would like", "Je voudrais un cafe."),
                phrase("un cafe", "a coffee", "Un cafe, s'il vous plait."),
                phrase("de l'eau", "some water", "Je voudrais de l'eau."),
                phrase("s'il vous plait", "please", "Un cafe, s'il vous plait.")
            ]
        ),
        frenchConversationLesson(
            id: "beginner-directions",
            unit: 1,
            title: "Ask for directions",
            subtitle: "Find a place politely",
            icon: "map.fill",
            accent: .violet,
            minutes: 5,
            goal: "My goal is to ask where a useful place is.",
            model: "Ou est la gare ?",
            modelHelper: "Where is the station?",
            speak: "Excusez-moi, ou est la gare ?",
            speakHelper: "Start with excusez-moi to sound polite.",
            nextLine: "C'est a gauche ?",
            nextLineHelper: "Ask if the place is on the left.",
            checkPrompt: "You need the hotel.",
            correctAnswer: "Excusez-moi, ou est l'hotel ?",
            commonMistake: "Excusez-moi, je suis l'hotel ?",
            extraMistake: "La gare est un cafe.",
            roleplay: "You are near the station and need the hotel.",
            roleplayHelper: "Start with Excusez-moi, then ask where the hotel is.",
            followUp: "Merci, c'est pres ?",
            followUpHelper: "Ask if it is nearby.",
            savedWords: [
                phrase("ou est", "where is", "Ou est la gare ?"),
                phrase("la gare", "the station", "Ou est la gare ?"),
                phrase("a gauche", "on the left", "C'est a gauche."),
                phrase("c'est pres", "it is nearby", "C'est pres ?")
            ]
        ),
        frenchConversationLesson(
            id: "beginner-hotel",
            unit: 1,
            title: "Check in at a hotel",
            subtitle: "Reservation, name, and one question",
            icon: "building.2.fill",
            accent: .blue,
            minutes: 5,
            goal: "My goal is to check in with a reservation.",
            model: "J'ai une reservation.",
            modelHelper: "I have a reservation.",
            speak: "Bonjour, j'ai une reservation.",
            speakHelper: "Say it calmly at the reception desk.",
            nextLine: "Pour deux nuits.",
            nextLineHelper: "Use this to say the stay is for two nights.",
            checkPrompt: "Reception asks for the name on the reservation.",
            correctAnswer: "La reservation est au nom de Martin.",
            commonMistake: "Je suis au nom de Martin.",
            extraMistake: "La gare est au nom de Martin.",
            roleplay: "Reception says, Bonjour, vous avez une reservation ?",
            roleplayHelper: "Answer yes, then give the name on the reservation.",
            followUp: "Est-ce que le petit dejeuner est inclus ?",
            followUpHelper: "Ask one practical hotel question.",
            savedWords: [
                phrase("j'ai", "I have", "J'ai une reservation."),
                phrase("une reservation", "a reservation", "J'ai une reservation."),
                phrase("au nom de", "under the name of", "La reservation est au nom de Martin."),
                phrase("pour deux nuits", "for two nights", "Pour deux nuits.")
            ]
        ),
        frenchConversationLesson(
            id: "beginner-review",
            unit: 1,
            title: "Beginner review",
            subtitle: "One simple travel exchange",
            icon: "checkmark.seal.fill",
            accent: .mint,
            minutes: 6,
            goal: "My goal is to combine greetings, ordering, directions, and hotel check-in.",
            model: "Bonjour. Je m'appelle Alex. Je voudrais un cafe, s'il vous plait.",
            modelHelper: "This combines a greeting, name, and cafe order.",
            speak: "Bonjour. Je m'appelle Alex. Je viens d'Indonesie.",
            speakHelper: "Change the name and place to fit you.",
            nextLine: "Excusez-moi, ou est l'hotel ?",
            nextLineHelper: "Use this when you arrive and need the hotel.",
            checkPrompt: "You are at a cafe and want a croissant.",
            correctAnswer: "Je voudrais un croissant, s'il vous plait.",
            commonMistake: "Je suis un croissant.",
            extraMistake: "Ou est un croissant, merci ?",
            roleplay: "You arrive in a new city. Introduce yourself, order water, then ask for the hotel.",
            roleplayHelper: "Use three short lines. Pause between them.",
            followUp: "Merci. Au revoir.",
            followUpHelper: "Close the exchange simply.",
            savedWords: [
                phrase("merci", "thank you", "Merci. Au revoir."),
                phrase("un croissant", "a croissant", "Je voudrais un croissant."),
                phrase("ou est l'hotel", "where is the hotel", "Ou est l'hotel ?"),
                phrase("j'ai une reservation", "I have a reservation", "J'ai une reservation.")
            ]
        )
    ]
}
