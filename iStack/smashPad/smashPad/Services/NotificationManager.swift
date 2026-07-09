//
//  NotificationManager.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 08/07/26.
//

import UserNotifications

final class NotificationManager {

    static let shared = NotificationManager()

    func requestPermission() {

        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { granted, error in

                print("Permission:", granted)

                if let error {
                    print(error)
                }
            }
    }

    func showTensionNotification() {

        let content = UNMutableNotificationContent()

        content.title = "Possible Tension Detected"

        content.body =
        "Feeling tense? Try a tension relief session."

        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current()
            .add(request)
    }
}
