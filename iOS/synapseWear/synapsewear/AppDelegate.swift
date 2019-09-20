//
//  AppDelegate.swift
//  synapsewear
//
//  Copyright © 2017年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit
import AVFoundation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    //var scanDevices: [RFduino] = []
    var backgroundTaskID: UIBackgroundTaskIdentifier = 0
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        self.appSetting()
        self.setUserNotification(application)
        self.setRootViewController()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.

        self.backgroundTaskID = application.beginBackgroundTask() {
            [weak self] in
            application.endBackgroundTask((self?.backgroundTaskID)!)
            self?.backgroundTaskID = UIBackgroundTaskInvalid
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        application.endBackgroundTask(self.backgroundTaskID)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func appSetting() {

        // set AVAudioSession
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        }
        catch {
            print("audioSession.setCategory failed")
        }
        do {
            try audioSession.setActive(true)
        }
        catch {
            print("audioSession.setActive failed")
        }
    }

    func setRootViewController() {

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = MainViewController()
        self.window?.makeKeyAndVisible()
    }

    // MARK: mark - UserNotification methods

    func setUserNotification(_ application: UIApplication) {

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { (granted, error) in
                if let error = error {
                    print("UserNotificationCenter error : \(error.localizedDescription)")
                    return
                }
                if granted {
                    print("UserNotificationCenter granted")
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                }
                else {
                    print("UserNotificationCenter not granted")
                }
            })
            UNUserNotificationCenter.current().delegate = self
        }
        else {
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            application.registerForRemoteNotifications()
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        let deviceTokenStr: String = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
        print("didRegisterForRemoteNotificationsWithDeviceToken: \(deviceTokenStr)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {

        print("didFailToRegisterForRemoteNotificationsWithError: \(error.localizedDescription)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        print("didReceiveRemoteNotification userInfo: \(userInfo)")

        completionHandler(UIBackgroundFetchResult.newData)
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {

        print("didReceiveLocalNotification userInfo: \(String(describing: notification.userInfo))")
    }
}

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler([.badge, .sound, .alert])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        print("didReceive notification.request.identifier: \(response.notification.request.identifier)")
        if response.notification.request.trigger is UNPushNotificationTrigger {
            print("didReceive Push Notification")
        }
        else {
            print("didReceive Local Notification")
        }

        completionHandler()
    }
}
