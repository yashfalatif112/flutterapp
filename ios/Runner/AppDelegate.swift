import UIKit
import Flutter
import Firebase
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Firebase
    FirebaseApp.configure()

    // Register for remote notifications
    UNUserNotificationCenter.current().delegate = self

    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions,
      completionHandler: { _, _ in }
    )

    application.registerForRemoteNotifications()

    // Define custom call notification category
    let acceptAction = UNNotificationAction(
      identifier: "ACCEPT_ACTION",
      title: "Accept",
      options: [.foreground]
    )

    let declineAction = UNNotificationAction(
      identifier: "DECLINE_ACTION",
      title: "Decline",
      options: [.destructive, .foreground]
    )

    let callCategory = UNNotificationCategory(
      identifier: "INCOMING_CALL",
      actions: [acceptAction, declineAction],
      intentIdentifiers: [],
      options: .customDismissAction
    )

    UNUserNotificationCenter.current().setNotificationCategories([callCategory])

    // Set FCM delegate
    Messaging.messaging().delegate = self

    // Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle background push notification
  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    if let type = userInfo["type"] as? String, type == "video_call" {
      let state = application.applicationState
      if state == .background || state == .inactive {
        if let channelName = userInfo["channelName"] as? String {
          UserDefaults.standard.set(channelName, forKey: "pendingCallChannel")
          UserDefaults.standard.set(Date(), forKey: "pendingCallTime")
        }
      }
    }

    completionHandler(.newData)
  }

  // Handle user interaction with notification
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo

    if let type = userInfo["type"] as? String, type == "video_call" {
      let controller = window?.rootViewController as? FlutterViewController
      let channel = FlutterMethodChannel(
        name: "com.homease.app/call_actions",
        binaryMessenger: controller!.binaryMessenger
      )

      if let channelName = userInfo["channelName"] as? String {
        if response.actionIdentifier == "ACCEPT_ACTION" {
          channel.invokeMethod("acceptCall", arguments: ["channelName": channelName])
        } else if response.actionIdentifier == "DECLINE_ACTION" {
          channel.invokeMethod("declineCall", arguments: ["channelName": channelName])
        }
      }
    }

    completionHandler()
  }
}

// MARK: - FCM Token Handling
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )
  }
}
