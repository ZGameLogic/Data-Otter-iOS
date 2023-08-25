//
//  MonitorsApp.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 6/20/23.
//

import SwiftUI

@main
struct MonitorsApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
//        guard let specialName = userInfo["special"] as? String,
//              let specialPriceString = userInfo["price"] as? String,
//              let specialPrice = Float(specialPriceString) else {
//            // Always call the completion handler when done.
//            completionHandler()
//            return
//        }

        // TODO open app somehow
        completionHandler()
     }
    
    func application(_ application: UIApplication,
               didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        subscribeToNotifications()
        UIApplication.shared.registerForRemoteNotifications()
        return true
    }

    func application(_ application: UIApplication,
                didRegisterForRemoteNotificationsWithDeviceToken
                    deviceToken: Data) {
        let tokenComponents = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let deviceTokenString = tokenComponents.joined()
        print("Submitting token")
        let url = URL(string: "\(Monitor.BASE_URL)/ios/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let token = iosToken(token: deviceTokenString)
        guard let encoded = try? JSONEncoder().encode(token) else {
            print("Failed to encode monitor data")
            return
        }
        
        Task {
            do {
                let (_, _) = try await URLSession.shared.upload(for: request, from: encoded)
            } catch {
                print("Failed.")
            }
        }
        
    }


    func application(_ application: UIApplication,
                didFailToRegisterForRemoteNotificationsWithError
                    error: Error) {
       // Try again later.
    }
    
    func subscribeToNotifications() {
        let userNotificationCenter = UNUserNotificationCenter.current()
        userNotificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            print("Permission granted: \(granted)")
        }
    }
    
    struct iosToken: Codable {
        let token: String
    }
}
