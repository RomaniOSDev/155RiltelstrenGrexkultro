//
//  RainyBreathingViewModel.swift
//  155RiltelstrenGrexkultro
//

import Foundation
import Combine

enum BreathPhase: String {
    case inhale
    case hold
    case exhale
}

final class RainyBreathingViewModel: ObservableObject {
    let difficulty: ActivityDifficulty
    private var preset: BreathingPreset

    @Published private(set) var phase: BreathPhase = .inhale
    @Published private(set) var phaseProgress: Double = 0
    @Published private(set) var cycleIndex = 0
    @Published private(set) var successfulTaps = 0
    @Published private(set) var misses = 0
    @Published private(set) var pulseScale: CGFloat = 1.0
    @Published private(set) var isFinished = false

    private var cancellable: AnyCancellable?
    private var phaseStart = Date()
    private var windowRequiresTap = false
    private var windowSatisfied = false
    private let requiredCycles = 3
    private let startedAt = Date()

    init(difficulty: ActivityDifficulty, preset: BreathingPreset = .balanced) {
        self.difficulty = difficulty
        self.preset = preset
    }

    func updatePreset(_ newPreset: BreathingPreset) {
        preset = newPreset
        if cancellable != nil {
            start()
        }
    }

    func start() {
        cancellable?.cancel()
        phase = .inhale
        phaseStart = Date()
        cycleIndex = 0
        successfulTaps = 0
        misses = 0
        isFinished = false
        windowRequiresTap = false
        windowSatisfied = false
        pulseScale = 1.0
        cancellable = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func stop() {
        cancellable?.cancel()
        cancellable = nil
    }

    private var inhaleDuration: Double { preset.inhale * difficulty.breathingMultiplier }
    private var holdDuration: Double { preset.hold * difficulty.breathingMultiplier }
    private var exhaleDuration: Double { preset.exhale * difficulty.breathingMultiplier }

    private func tick() {
        guard !isFinished else { return }
        let elapsed = Date().timeIntervalSince(phaseStart)
        let duration: Double
        switch phase {
        case .inhale: duration = inhaleDuration
        case .hold: duration = holdDuration
        case .exhale: duration = exhaleDuration
        }
        phaseProgress = min(1, elapsed / max(duration, 0.01))
        pulseScale = 1 + 0.1 * CGFloat(sin(Date().timeIntervalSince1970 * 5))

        updateWindow(elapsed: elapsed, duration: duration)

        if elapsed >= duration {
            closePhase()
        }
    }

    private func updateWindow(elapsed: Double, duration: Double) {
        switch phase {
        case .inhale:
            let start = duration * 0.45
            let end = duration * 0.85
            trackWindow(active: elapsed >= start && elapsed <= end)
        case .exhale:
            let start = duration * 0.25
            let end = duration * 0.70
            trackWindow(active: elapsed >= start && elapsed <= end)
        case .hold:
            trackWindow(active: false)
        }
    }

    private func trackWindow(active: Bool) {
        if active {
            if !windowRequiresTap {
                windowRequiresTap = true
                windowSatisfied = false
            }
        } else if windowRequiresTap {
            if !windowSatisfied {
                misses += 1
            }
            windowRequiresTap = false
            windowSatisfied = false
        }
    }

    private func closePhase() {
        if windowRequiresTap && !windowSatisfied {
            misses += 1
        }
        windowRequiresTap = false
        windowSatisfied = false

        switch phase {
        case .inhale:
            phase = .hold
        case .hold:
            phase = .exhale
        case .exhale:
            cycleIndex += 1
            if cycleIndex >= requiredCycles {
                finishSuccess()
                return
            }
            phase = .inhale
        }
        phaseStart = Date()
        phaseProgress = 0
    }

    private func finishSuccess() {
        isFinished = true
        stop()
    }

    func handleTap() {
        guard !isFinished else { return }
        guard windowRequiresTap else { return }
        guard !windowSatisfied else { return }
        windowSatisfied = true
        successfulTaps += 1
        pulseScale = 1.2
    }

    func outcome() -> (stars: Int, focusScore: Int, rhythmLabel: String, summary: String, duration: Int, taps: Int) {
        let elapsed = Int(Date().timeIntervalSince(startedAt).rounded())
        let windows = requiredCycles * 2
        let hitRate = windows == 0 ? 0 : Double(successfulTaps) / Double(windows)
        let stars: Int
        if successfulTaps >= windows && misses == 0 {
            stars = 3
        } else if hitRate >= 0.66 {
            stars = 2
        } else {
            stars = 1
        }
        let focusScore = min(100, successfulTaps * 14 + max(0, 36 - misses * 6))
        let rhythmLabel = "Synced taps \(successfulTaps)/\(windows) · calm score \(focusScore)%"
        let summary = "Completed \(requiredCycles) rainy cycles in \(elapsed)s — \(preset.title) curve at \(difficulty.title) pacing."
        return (stars, focusScore, rhythmLabel, summary, elapsed, successfulTaps)
    }
}
