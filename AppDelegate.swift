//
//  AppDelegate.swift
//  vanpool-passenger-ios
//
//  Created by sarat on 29/06/17.
//  Copyright © 2017 Sarath C. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase
import FBSDKCoreKit
import FirebaseAuth
import UserNotifications
import Fabric
import Crashlytics
import Siren

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    let locationManager = CLLocationManager()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    Fabric.with([Crashlytics.self])
    initializeFirebase()
    locationManager.requestWhenInUseAuthorization()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    UIApplication.shared.statusBarStyle = .lightContent
    // Override point for customization after application launch.
    GMSServices.provideAPIKey("AIzaSyDLlskLqvF8VoYCTs_j5PCMkW5CiPR-hvU")
    GMSPlacesClient.provideAPIKey("AIzaSyDLlskLqvF8VoYCTs_j5PCMkW5CiPR-hvU")
    _ = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let splashViewController = SplashViewController()
    self.window?.rootViewController = splashViewController
    self.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
    self.window?.makeKeyAndVisible()
    FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    if #available(iOS 10, *) {
      setupSiren()
    } else {
      // Fallback on earlier versions
    }
    return true
  }

  class func sharedInstance() -> AppDelegate {
    return (UIApplication.shared.delegate as? AppDelegate)!
  }

  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {

    let facebookDidHandle = FBSDKApplicationDelegate.sharedInstance().application(app,
                                                                                  open: url,
                                                                                  sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                                                  annotation: options[UIApplicationOpenURLOptionsKey.annotation])

    return  facebookDidHandle
  }

    func initializeFirebase() {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self

        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }

        UIApplication.shared.registerForRemoteNotifications()

    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken

        print("APNs token retrieved: \(deviceToken)")
        var token: String = ""
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        print("token = \(token)")
        UserDefaultsManager.deviceToken = token
        // With swizzling disabled you must set the APNs token here.
        // FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
    }

  private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    switch status {
    case .notDetermined:
      locationManager.requestAlwaysAuthorization()
      break
    case .authorizedWhenInUse:
      locationManager.startUpdatingLocation()
      break
    case .authorizedAlways:
      locationManager.startUpdatingLocation()
      break
    case .restricted:
      // restricted by e.g. parental controls. User can't enable Location Services
      break
    case .denied:
      // user denied your app access to Location Services, but can grant access from Settings.app
      break

    }
  }
    func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state.
    // This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message)
    // or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers,
    // and store enough application state information to restore your application to its
    // current state in case it is terminated later.
    // If your application supports background execution, this method is called
    // instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    Siren.shared.checkVersion(checkType: .immediately)

  }

  func applicationDidBecomeActive(_ application: UIApplication) {
     // FBSDKAppEvents.activateApp()
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    Siren.shared.checkVersion(checkType: .daily)
  }

  func applicationWillTerminate(_ application: UIApplication) {
    UserDefaultsManager.isLoginHasParentController = false
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  // Support for background fetch
  func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: bgNotificationKey), object: nil)
  }
}

// [START ios_10_message_handling]
@available(iOS 10, *)

extension AppDelegate : UNUserNotificationCenterDelegate {

    //Foreground State
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        // Print full message.
        print(userInfo)

        //RemoteNotificationManager.handleForegroundPushNotification(userinfo: userInfo)
        // Change this to your preferred presentation option
        completionHandler([.alert, .badge, .sound])
    }

    //Background State
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)

        RemoteNotificationManager.handleBackgroundPushNotification(userinfo: userInfo)
        completionHandler()
    }

    func setupSiren() {
      let siren = Siren.shared

      // Optional
      siren.delegate = self

      // Optional
      siren.debugEnabled = true

        // Optional - Change the name of your app. Useful if you have a long app name and want to display a shortened version in the update dialog (e.g., the UIAlertController).
      siren.appName = "CITYVAN"

      siren.majorUpdateAlertType = .option
      siren.minorUpdateAlertType = .option
      siren.patchUpdateAlertType = .option
      siren.revisionUpdateAlertType = .option
      siren.showAlertAfterCurrentVersionHasBeenReleasedForDays = 3
      siren.checkVersion(checkType: .immediately)
    }
  }

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        UserDefaultsManager.fcmAccessToken = fcmToken
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}

extension AppDelegate: SirenDelegate {
    func sirenDidShowUpdateDialog(alertType: Siren.AlertType) {
        print(#function, alertType)
    }

    func sirenUserDidCancel() {
        print(#function)
    }

    func sirenUserDidSkipVersion() {
        print(#function)
    }

    func sirenUserDidLaunchAppStore() {
        print(#function)
    }

    func sirenDidFailVersionCheck(error: Error) {
        print(#function, error)
    }

    func sirenLatestVersionInstalled() {
        print(#function, "Latest version of app is installed")
    }

    // This delegate method is only hit when alertType is initialized to .none
    func sirenDidDetectNewVersionWithoutAlert(message: String) {
        print(#function, "\(message)")
    }
}
