//
//  AppStateTracker.swift
//  StarDate
//
//  Tracks app state including time since last button click
//

import Foundation
import Combine

class AppStateTracker: ObservableObject {
    @Published var secondsSinceLastButtonClick: Int = 0
    @Published var lastButtonClickTime: Date?

    private var timer: Timer?

    init() {
        startTimer()
    }

    func buttonClicked() {
        lastButtonClickTime = Date()
        secondsSinceLastButtonClick = 0
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if let lastClick = self.lastButtonClickTime {
                let elapsed = Int(Date().timeIntervalSince(lastClick))
                DispatchQueue.main.async {
                    self.secondsSinceLastButtonClick = elapsed
                }
            }
        }
    }

    deinit {
        timer?.invalidate()
    }
}
