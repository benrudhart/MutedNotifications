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

    private override init() {
        super.init()
    }

    func scheduleNotification(in seconds: Int) {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "Example Notification"
        content.body = "Duration: \(seconds)"
        content.sound = .defaultCriticalSound(withAudioVolume: 1)

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds),
                                                        repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)

        center.add(request) { error in
            assert(error == nil)
        }
    }
}

extension Notifications: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound])
    }
}

