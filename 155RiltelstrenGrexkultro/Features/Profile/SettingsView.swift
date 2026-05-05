//
//  SettingsView.swift
//  155RiltelstrenGrexkultro
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var userData: UserData
    @State private var confirmReset = false
    @State private var reminderTime: Date = .now

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Reminders")
                        .font(.title3.bold())
                        .foregroundStyle(Color.appTextPrimary)

                    Text("Local notifications for album frames, breathing, and packing—separate from location. Grant permission when prompted.")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Toggle("Sunny album nudge", isOn: albumBinding)
                        .foregroundStyle(Color.appTextPrimary)

                    Toggle("Rainy breathing nudge", isOn: breathBinding)
                        .foregroundStyle(Color.appTextPrimary)

                    Toggle("Winter pack checklist", isOn: packBinding)
                        .foregroundStyle(Color.appTextPrimary)

                    DatePicker("Daily time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .tint(Color.appAccent)
                        .onChange(of: reminderTime) { newValue in
                            applyReminderTime(newValue)
                        }

                    PrimaryPressButton(title: "Allow notifications & apply schedule") {
                        userData.requestNotificationAccessAndReschedule()
                    }

                    Divider()
                        .background(Color.appAccent.opacity(0.2))

                    Toggle("Rainy breathing tap feedback", isOn: hapticsBinding)
                        .foregroundStyle(Color.appTextPrimary)

                    Text("Light haptic when you tap the breathing circle.")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCardChrome(cornerRadius: 18)

                Text("Insights")
                    .font(.title3.bold())
                    .foregroundStyle(Color.appTextPrimary)

                VStack(alignment: .leading, spacing: 10) {
                    statRow(title: "Total stars", value: "\(userData.collectedStars)")
                    statRow(title: "Routes finished", value: "\(userData.completedChallengeIds.count)")
                    statRow(title: "Journey level", value: "\(userData.currentLevel)")
                    statRow(title: "Active minutes logged", value: minutesText)
                    statRow(title: "Variety points", value: "\(userData.diversityScore)")
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCardChrome(cornerRadius: 18)

                PrimaryPressButton(title: "Reset all progress") {
                    confirmReset = true
                }

                Text("Clears stars, routes, and history. Onboarding stays completed.")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .appScreenBackground()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationChrome()
        .onAppear {
            reminderTime = Self.timeFrom(userData: userData)
        }
        .confirmationDialog(
            "Reset all progress?",
            isPresented: $confirmReset,
            titleVisibility: .visible
        ) {
            Button("Reset everything", role: .destructive) {
                userData.resetAll()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
    }

    private var minutesText: String {
        let minutes = userData.totalActivitySeconds / 60
        return "\(minutes) min"
    }

    private static func timeFrom(userData: UserData) -> Date {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: Date())
        comps.hour = userData.reminderHour
        comps.minute = userData.reminderMinute
        return cal.date(from: comps) ?? Date()
    }

    private func applyReminderTime(_ date: Date) {
        let cal = Calendar.current
        let h = cal.component(.hour, from: date)
        let m = cal.component(.minute, from: date)
        userData.setReminderPrefs(
            album: userData.reminderAlbumEnabled,
            breath: userData.reminderBreathEnabled,
            pack: userData.reminderPackEnabled,
            hour: h,
            minute: m,
            rescheduleNotifications: true
        )
    }

    private var albumBinding: Binding<Bool> {
        Binding(
            get: { userData.reminderAlbumEnabled },
            set: { newValue in
                userData.setReminderPrefs(
                    album: newValue,
                    breath: userData.reminderBreathEnabled,
                    pack: userData.reminderPackEnabled,
                    hour: userData.reminderHour,
                    minute: userData.reminderMinute,
                    rescheduleNotifications: true
                )
            }
        )
    }

    private var breathBinding: Binding<Bool> {
        Binding(
            get: { userData.reminderBreathEnabled },
            set: { newValue in
                userData.setReminderPrefs(
                    album: userData.reminderAlbumEnabled,
                    breath: newValue,
                    pack: userData.reminderPackEnabled,
                    hour: userData.reminderHour,
                    minute: userData.reminderMinute,
                    rescheduleNotifications: true
                )
            }
        )
    }

    private var packBinding: Binding<Bool> {
        Binding(
            get: { userData.reminderPackEnabled },
            set: { newValue in
                userData.setReminderPrefs(
                    album: userData.reminderAlbumEnabled,
                    breath: userData.reminderBreathEnabled,
                    pack: newValue,
                    hour: userData.reminderHour,
                    minute: userData.reminderMinute,
                    rescheduleNotifications: true
                )
            }
        )
    }

    private var hapticsBinding: Binding<Bool> {
        Binding(
            get: { userData.rainyHapticsEnabled },
            set: { userData.setRainyHapticsEnabled($0) }
        )
    }

    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer()
            Text(value)
                .foregroundStyle(Color.appTextPrimary)
                .font(.body.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}
