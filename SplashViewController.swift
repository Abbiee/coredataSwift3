//
//  SplashViewController.swift
//  vanpool-passenger-ios
//
//  Created by abhijeet on 01/08/17.
//
//

import UIKit
import CoreData

let bgNotificationKey = "backgroundFetch"

class SplashViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    getApplicationSettings()
    UserDefaultsManager.timeStamp = false
    NotificationCenter.default.addObserver(self, selector: #selector(getApplicationSettings), name: NSNotification.Name(rawValue: bgNotificationKey), object: nil)

    let launchImage = UIImageView(image: UIImage(named: "newlaunchImage"))
    launchImage.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
    self.view.addSubview(launchImage)
//    let animationView = SplashAnimation.createSplashAnimationView(size: self.view.bounds)
//    self.view.addSubview(animationView)
  }

    override var prefersStatusBarHidden: Bool {
        return true
    }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  /// Gets the Application settings
  func getApplicationSettings() {
    if Utility.isConnectedToInternet {
      Utility.startActivityIdicator()
      VanpoolAPI.getApplicationSettings(completionHandler: { (response) in
        Utility.stopActivityIndicator()

        if response == nil {
          Utility.showAlert(title: Constants.error, message: Constants.someThingWrong, delegate: self)
        } else {
          if response?.status == ResponseCode.success.code {
          let timestamp = Int(NSDate().timeIntervalSince1970)
            print(response?.data as Any )
            if response?.data?.count ?? 0 > 0 {
                if UserDefaults.standard.object(forKey: "lastUpdatedTime") == nil {
                CoreDataHandler.sharedInstance.saveApplcationSettingsinCoredata(responseArray: (response?.data)!)
                UserDefaults.standard.set(timestamp, forKey: "lastUpdatedTime")
                } else {
                  CoreDataHandler.sharedInstance.updateAllRecords(responseArray: (response?.data)!)
                }
            }
          }
        }
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
          self.splashTimeOut()
        })
      })
    } else {
      Utility.showAlert(title: Constants.appName, message: Constants.noNetwork, delegate: self)
    }
  }

  func splashTimeOut() {
    if !UserDefaultsManager.isIntroShown {
      let introViewController = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "introScreen") as? IntroViewController
      AppDelegate.sharedInstance().window?.rootViewController = introViewController
      UserDefaultsManager.isIntroShown = true
      return
    }

    if UserDefaultsManager.isUserLoggedIn {
      let homeViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "homeLandingIdentifier") as? HomeLandingViewController
      let leftViewController = UIStoryboard(name: "SideBar", bundle: nil).instantiateViewController(withIdentifier: "sideBar") as? SideBarViewController
      let mainNavigationController: UINavigationController = UINavigationController(rootViewController: homeViewController!)
      if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
        //RTL
        let slideMenuController = SlideMenuTrackerController(mainViewController: mainNavigationController, rightMenuViewController: leftViewController!)
        AppDelegate.sharedInstance().window?.rootViewController = slideMenuController
        leftViewController?.mainViewController = mainNavigationController
        slideMenuController.automaticallyAdjustsScrollViewInsets = true
        AppDelegate.sharedInstance().window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
        AppDelegate.sharedInstance().window?.makeKeyAndVisible()
      } else {
        //LTR
        print("Left")
        let slideMenuController = SlideMenuTrackerController(mainViewController: mainNavigationController, leftMenuViewController: leftViewController!)
        AppDelegate.sharedInstance().window?.rootViewController = slideMenuController
        leftViewController?.mainViewController = mainNavigationController
        slideMenuController.automaticallyAdjustsScrollViewInsets = true
        AppDelegate.sharedInstance().window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
        AppDelegate.sharedInstance().window?.makeKeyAndVisible()
        }
      UIApplication.shared.setMinimumBackgroundFetchInterval(7200)
    } else {
    let loginstoryboard = UIStoryboard(name: "Login", bundle: nil)
    let loginController = loginstoryboard.instantiateViewController(withIdentifier: "loginViewIdentifier") as? LoginViewController
    let navController = UINavigationController(rootViewController: loginController!)
    let transition = CATransition()
    transition.duration = 1.0
    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    transition.type = kCATransitionReveal
    navController.view.layer.add(transition, forKey: kCATransition)
    AppDelegate.sharedInstance().window?.rootViewController = navController
  }
  }
}
