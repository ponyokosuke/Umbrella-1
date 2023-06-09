import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                // ユーザーが通知を許可した場合の処理を記述する
                self.setupNotifications()
            } else {
                // ユーザーが通知を許可しなかった場合の処理を記述する
            }
        }
        return true
    }
    
    // 通知のセットアップ
    func setupNotifications() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                // 通知の設定
                self.scheduleMorningNotification()
            }
        }
    }
    
    func scheduleMorningNotification() {
        let content = UNMutableNotificationContent()
        content.title = "おはようございます"
        content.body = "今日の天気は"

        if let weatherDescription = UserDefaults.standard.string(forKey: "WeatherDescription") {
            content.body += weatherDescription

            if weatherDescription == "雪" || weatherDescription == "雨" || weatherDescription == "小雨" || weatherDescription == "雷雨" {
                content.body += "です。傘を忘れずにお持ちください"
            }
        }

        var dateComponents = DateComponents()
        dateComponents.hour = 7
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "MorningNotification", content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            if let error = error {
                print("通知のスケジュールに失敗しました: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // ... 他のAppDelegateのメソッド

}
