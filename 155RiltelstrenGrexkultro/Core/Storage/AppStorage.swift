//
//  AppStorage.swift
//  155RiltelstrenGrexkultro
//

import Foundation
import Combine

extension Notification.Name {
    static let userDataDidReset = Notification.Name("userDataDidResetNotification")
}

struct ChallengeCompletionRecord: Codable, Identifiable, Equatable {
    let id: UUID
    let challengeId: String
    let title: String
    let starsEarned: Int
    let completedAt: Date
    let summaryLine: String

    init(
        id: UUID = UUID(),
        challengeId: String,
        title: String,
        starsEarned: Int,
        completedAt: Date = .now,
        summaryLine: String
    ) {
        self.id = id
        self.challengeId = challengeId
        self.title = title
        self.starsEarned = starsEarned
        self.completedAt = completedAt
        self.summaryLine = summaryLine
    }
}

@MainActor
final class UserData: ObservableObject {
    fileprivate enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let collectedStars = "collectedStars"
        static let completedChallengeIds = "completedChallengeIds"
        static let levelKey = "currentLevel"
        static let recordsJSON = "challengeRecordsJSON"
        static let totalActivitySeconds = "totalActivitySeconds"
        static let diversityScore = "diversityScore"
        static let selectedScenarioRaw = "selectedScenarioRaw"
        static let diaryJSON = "diaryEntriesJSON"
        static let scenarioMarksJSON = "scenarioMarksJSON"
        static let lastDiscoverDayKey = "lastDiscoverDayKey"
        static let discoverStreak = "discoverStreak"
        static let reminderAlbum = "reminderAlbum"
        static let reminderBreath = "reminderBreath"
        static let reminderPack = "reminderPack"
        static let reminderHour = "reminderHour"
        static let reminderMinute = "reminderMinute"
        static let rainyHaptics = "rainyHaptics"
    }

    private let defaults = UserDefaults.standard

    @Published private(set) var hasSeenOnboarding: Bool
    @Published private(set) var collectedStars: Int
    @Published private(set) var completedChallengeIds: [String]
    @Published private(set) var currentLevel: Int
    @Published private(set) var records: [ChallengeCompletionRecord]
    @Published private(set) var totalActivitySeconds: Int
    @Published private(set) var diversityScore: Int

    @Published private(set) var selectedScenario: DayScenario?
    @Published private(set) var diaryEntries: [DiaryEntry]
    @Published private(set) var scenarioMarks: [ScenarioDayMark]
    @Published private(set) var lastDiscoverDayKey: String?
    @Published private(set) var discoverStreak: Int
    @Published private(set) var reminderAlbumEnabled: Bool
    @Published private(set) var reminderBreathEnabled: Bool
    @Published private(set) var reminderPackEnabled: Bool
    @Published private(set) var reminderHour: Int
    @Published private(set) var reminderMinute: Int
    @Published private(set) var rainyHapticsEnabled: Bool

    var completedChallengesCount: Int {
        completedChallengeIds.count
    }

    var hasSeasonedExplorerAchievement: Bool {
        records.count >= 5
    }

    var hasDiscoverStreak7: Bool {
        discoverStreak >= 7
    }

    var hasWeatherMixAchievement: Bool {
        uniqueScenarioTypesInRollingWeek >= 3
    }

    var uniqueScenarioTypesInRollingWeek: Int {
        let keys = Self.lastSevenDayKeys()
        let raw = Set(scenarioMarks.filter { keys.contains($0.dayKey) }.map(\.scenarioRaw))
        return raw.count
    }

    /// Diary mood counts over last 14 days for simple chart
    var diaryMoodCountsLastFortnight: [(mood: ReflectionMood, count: Int)] {
        let cal = Calendar.current
        guard let start = cal.date(byAdding: .day, value: -14, to: Date()) else { return [] }
        let filtered = diaryEntries.filter { $0.recordedAt >= start }
        return ReflectionMood.allCases.map { mood in
            (mood, filtered.filter { $0.mood == mood }.count)
        }
    }

    init() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        collectedStars = defaults.integer(forKey: Keys.collectedStars)
        if let data = defaults.data(forKey: Keys.completedChallengeIds),
           let ids = try? JSONDecoder().decode([String].self, from: data) {
            completedChallengeIds = ids
        } else {
            completedChallengeIds = []
        }
        currentLevel = max(1, defaults.integer(forKey: Keys.levelKey))
        if let rData = defaults.data(forKey: Keys.recordsJSON),
           let decoded = try? JSONDecoder().decode([ChallengeCompletionRecord].self, from: rData) {
            records = decoded.sorted { $0.completedAt > $1.completedAt }
        } else {
            records = []
        }
        totalActivitySeconds = defaults.integer(forKey: Keys.totalActivitySeconds)
        diversityScore = defaults.integer(forKey: Keys.diversityScore)

        if let raw = defaults.string(forKey: Keys.selectedScenarioRaw),
           let s = DayScenario(rawValue: raw) {
            selectedScenario = s
        } else {
            selectedScenario = nil
        }

        if let dData = defaults.data(forKey: Keys.diaryJSON),
           let d = try? JSONDecoder().decode([DiaryEntry].self, from: dData) {
            diaryEntries = d.sorted { $0.recordedAt > $1.recordedAt }
        } else {
            diaryEntries = []
        }

        if let sData = defaults.data(forKey: Keys.scenarioMarksJSON),
           let s = try? JSONDecoder().decode([ScenarioDayMark].self, from: sData) {
            scenarioMarks = s
        } else {
            scenarioMarks = []
        }

        lastDiscoverDayKey = defaults.string(forKey: Keys.lastDiscoverDayKey)
        discoverStreak = defaults.integer(forKey: Keys.discoverStreak)
        reminderAlbumEnabled = defaults.bool(forKey: Keys.reminderAlbum)
        reminderBreathEnabled = defaults.bool(forKey: Keys.reminderBreath)
        reminderPackEnabled = defaults.bool(forKey: Keys.reminderPack)
        reminderHour = max(0, min(23, defaults.integer(forKey: Keys.reminderHour)))
        reminderMinute = max(0, min(59, defaults.integer(forKey: Keys.reminderMinute)))
        rainyHapticsEnabled = defaults.object(forKey: Keys.rainyHaptics) as? Bool ?? true
    }

    static func calendarDayKey(_ date: Date) -> String {
        let cal = Calendar.current
        let c = cal.dateComponents([.year, .month, .day], from: cal.startOfDay(for: date))
        let y = c.year ?? 0
        let m = c.month ?? 0
        let d = c.day ?? 0
        return String(format: "%04d-%02d-%02d", y, m, d)
    }

    private static func lastSevenDayKeys() -> Set<String> {
        let cal = Calendar.current
        var keys = Set<String>()
        for i in 0..<7 {
            if let dt = cal.date(byAdding: .day, value: -i, to: Date()) {
                keys.insert(calendarDayKey(cal.startOfDay(for: dt)))
            }
        }
        return keys
    }

    func setSelectedScenario(_ scenario: DayScenario?) {
        selectedScenario = scenario
        if let scenario {
            defaults.set(scenario.rawValue, forKey: Keys.selectedScenarioRaw)
            let key = Self.calendarDayKey(Date())
            var marks = scenarioMarks
            marks.append(ScenarioDayMark(dayKey: key, scenarioRaw: scenario.rawValue))
            if marks.count > 200 {
                marks.removeFirst(marks.count - 200)
            }
            scenarioMarks = marks
            if let encoded = try? JSONEncoder().encode(marks) {
                defaults.set(encoded, forKey: Keys.scenarioMarksJSON)
            }
        } else {
            defaults.removeObject(forKey: Keys.selectedScenarioRaw)
        }
        objectWillChangeRelay()
    }

    func recordDiscoverVisit() {
        let today = Self.calendarDayKey(Date())
        if lastDiscoverDayKey == today {
            return
        }

        if let last = lastDiscoverDayKey,
           let yesterdayDate = Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: Date())) {
            let yKey = Self.calendarDayKey(yesterdayDate)
            if last == yKey {
                discoverStreak += 1
            } else {
                discoverStreak = 1
            }
        } else {
            discoverStreak = 1
        }

        lastDiscoverDayKey = today
        defaults.set(today, forKey: Keys.lastDiscoverDayKey)
        defaults.set(discoverStreak, forKey: Keys.discoverStreak)
        objectWillChangeRelay()
    }

    func addDiaryEntry(mood: ReflectionMood, note: String, challengeTitle: String) {
        let trimmed = String(note.trimmingCharacters(in: .whitespacesAndNewlines).prefix(240))
        let entry = DiaryEntry(mood: mood, note: trimmed, challengeTitle: challengeTitle)
        diaryEntries.insert(entry, at: 0)
        if let encoded = try? JSONEncoder().encode(diaryEntries) {
            defaults.set(encoded, forKey: Keys.diaryJSON)
        }
        objectWillChangeRelay()
    }

    func setRainyHapticsEnabled(_ value: Bool) {
        rainyHapticsEnabled = value
        defaults.set(value, forKey: Keys.rainyHaptics)
        objectWillChangeRelay()
    }

    func setReminderPrefs(
        album: Bool,
        breath: Bool,
        pack: Bool,
        hour: Int,
        minute: Int,
        rescheduleNotifications: Bool
    ) {
        reminderAlbumEnabled = album
        reminderBreathEnabled = breath
        reminderPackEnabled = pack
        reminderHour = max(0, min(23, hour))
        reminderMinute = max(0, min(59, minute))
        defaults.set(album, forKey: Keys.reminderAlbum)
        defaults.set(breath, forKey: Keys.reminderBreath)
        defaults.set(pack, forKey: Keys.reminderPack)
        defaults.set(reminderHour, forKey: Keys.reminderHour)
        defaults.set(reminderMinute, forKey: Keys.reminderMinute)
        if rescheduleNotifications {
            ReminderScheduler.reschedule(
                album: album,
                breath: breath,
                pack: pack,
                hour: reminderHour,
                minute: reminderMinute
            )
        }
        objectWillChangeRelay()
    }

    func requestNotificationAccessAndReschedule() {
        ReminderScheduler.requestAuthorization { ok in
            guard ok else { return }
            ReminderScheduler.reschedule(
                album: self.reminderAlbumEnabled,
                breath: self.reminderBreathEnabled,
                pack: self.reminderPackEnabled,
                hour: self.reminderHour,
                minute: self.reminderMinute
            )
        }
    }

    func markOnboardingSeen() {
        hasSeenOnboarding = true
        defaults.set(true, forKey: Keys.hasSeenOnboarding)
        objectWillChangeRelay()
    }

    func recordChallengeCompletion(
        challengeId: String,
        title: String,
        starsEarned: Int,
        summaryLine: String,
        durationSeconds: Int,
        uniquenessPoints: Int
    ) {
        let cappedStars = min(3, max(1, starsEarned))
        var nextIds = completedChallengeIds
        if !nextIds.contains(challengeId) {
            nextIds.append(challengeId)
        }
        completedChallengeIds = nextIds
        collectedStars += cappedStars
        totalActivitySeconds += max(0, durationSeconds)
        diversityScore += max(0, uniquenessPoints)

        let record = ChallengeCompletionRecord(
            challengeId: challengeId,
            title: title,
            starsEarned: cappedStars,
            summaryLine: summaryLine
        )
        records.insert(record, at: 0)

        let distinct = Set(nextIds)
        currentLevel = min(3, max(currentLevel, distinct.count))

        persist()
        objectWillChangeRelay()
    }

    func isUnlocked(challengeId: ChallengeId) -> Bool {
        switch challengeId {
        case .sunnyCollections:
            return true
        case .rainyRejuvenation:
            return completedChallengeIds.contains(ChallengeId.sunnyCollections.rawValue)
        case .winterWardrobe:
            return completedChallengeIds.contains(ChallengeId.rainyRejuvenation.rawValue)
        }
    }

    func resetAll() {
        if let bundleId = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: bundleId)
        }
        UserDefaults.standard.synchronize()

        ReminderScheduler.cancelAll()

        hasSeenOnboarding = true
        defaults.set(true, forKey: Keys.hasSeenOnboarding)
        collectedStars = 0
        completedChallengeIds = []
        currentLevel = 1
        records = []
        totalActivitySeconds = 0
        diversityScore = 0
        selectedScenario = nil
        diaryEntries = []
        scenarioMarks = []
        lastDiscoverDayKey = nil
        discoverStreak = 0
        reminderAlbumEnabled = false
        reminderBreathEnabled = false
        reminderPackEnabled = false
        reminderHour = 9
        reminderMinute = 30
        rainyHapticsEnabled = true

        defaults.set(false, forKey: Keys.reminderAlbum)
        defaults.set(false, forKey: Keys.reminderBreath)
        defaults.set(false, forKey: Keys.reminderPack)
        defaults.set(9, forKey: Keys.reminderHour)
        defaults.set(30, forKey: Keys.reminderMinute)
        defaults.set(true, forKey: Keys.rainyHaptics)

        NotificationCenter.default.post(name: .userDataDidReset, object: nil)
        objectWillChangeRelay()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(completedChallengeIds) {
            defaults.set(data, forKey: Keys.completedChallengeIds)
        }
        defaults.set(collectedStars, forKey: Keys.collectedStars)
        defaults.set(currentLevel, forKey: Keys.levelKey)
        if let rData = try? JSONEncoder().encode(records) {
            defaults.set(rData, forKey: Keys.recordsJSON)
        }
        defaults.set(totalActivitySeconds, forKey: Keys.totalActivitySeconds)
        defaults.set(diversityScore, forKey: Keys.diversityScore)
    }

    private func objectWillChangeRelay() {
        objectWillChange.send()
    }
}
