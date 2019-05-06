//
//  ViewController.swift
//  MutedNotifications
//
//  Created by Ben Rudhart on 06.05.19.
//  Copyright © 2019 Ben Rudhart. All rights reserved.
//

import UIKit
import UserNotifications

final class Notifications: NSObject {
    static let shared = Notifications()
    private let center = UNUserNotificationCenter.current()

    private override init() {
        super.init()
        requestAuthorization()
        center.delegate = self
    }

    private func requestAuthorization() {
        center.requestAuthorization(options: [.badge, .alert, .sound], completionHandler: { granted, _ in
            assert(granted, "this example requires PN permission")
        })
    }

    func scheduleNotification(in seconds: Int) {
        let content = exampleContent(seconds: seconds)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)

        center.add(request) { error in
            assert(error == nil)
        }
    }

    private func exampleContent(seconds: Int) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Example Notification"
        content.body = "Duration: \(seconds)"
        content.sound = .defaultCriticalSound(withAudioVolume: 1)
        return content
    }
}

extension Notifications: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .badge, .alert])
    }
}

