//
//  ReminderScheduler.swift
//  155RiltelstrenGrexkultro
//

import Foundation
import UserNotifications

enum ReminderScheduler {
    private static let albumId = "reminder.sunny.album"
    private static let breathId = "reminder.rainy.breath"
    private static let packId = "reminder.winter.pack"

    static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { ok, _ in
            DispatchQueue.main.async {
                completion(ok)
            }
        }
    }

    static func cancelAll() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            albumId, breathId, packId
        ])
    }

    static func reschedule(
        album: Bool,
        breath: Bool,
        pack: Bool,
        hour: Int,
        minute: Int
    ) {
        cancelAll()
        let h = max(0, min(23, hour))
        let m = max(0, min(59, minute))

        if album {
            scheduleDaily(
                id: albumId,
                title: "Sunny album",
                body: "Add a few frames to your outdoor album when the light feels right.",
                hour: h,
                minute: m
            )
        }
        if breath {
            scheduleDaily(
                id: breathId,
                title: "Rainy rhythm",
                body: "Take a calm breathing loop while the sky is soft.",
                hour: h,
                minute: min(59, m + 2)
            )
        }
        if pack {
            scheduleDaily(
                id: packId,
                title: "Pack checklist",
                body: "Drag your cold-weather layers into place before you head out.",
                hour: h,
                minute: min(59, m + 4)
            )
        }
    }

    private static func scheduleDaily(id: String, title: String, body: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var dc = DateComponents()
        dc.hour = hour
        dc.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
