//
//  Utility.swift
//  vanpool-passenger-ios
//

import Foundation
import UIKit
import Alamofire
import FirebaseDatabase

var customActivityIndicator = UIActivityIndicatorView()
let ref = Database.database().reference()
var tripHandler = UInt()
var statusHandler = UInt()
var promotionHandler = UInt()

class Utility {

  /// To Display UIAlertController
  ///
  /// - Parameters:
  ///   - title: Title of alertController
  ///   - message: Message of alertController
  ///   - delegate: Delegate
  class func showAlert(title: String, message: String, delegate: AnyObject) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: Constants.ok, style: .default, handler:nil))
    let viewController = delegate as? UIViewController ?? UIViewController()
    viewController.present(alert, animated: true, completion: nil)
  }

  class func settingsUrlAlert(title: String, message: String, delegate: AnyObject) {
    let alertController = UIAlertController (title: title, message: message, preferredStyle: .alert)
    let settingsAction = UIAlertAction(title: Constants.Settings, style: .default) { (_) -> Void in
      guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
        return
      }
        let bundleID = Bundle.main.bundleIdentifier!
      if UIApplication.shared.canOpenURL(settingsUrl) {
        if #available(iOS 10.0, *) {
          if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
          }
          if let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION/\(bundleID)") {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
          }
        } else {
          UIApplication.shared.openURL(URL(string: "Prefs:root=Privacy&path=LOCATION/\(bundleID)")!)
        }
      }
    }
    alertController.addAction(settingsAction)
    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
    alertController.addAction(cancelAction)
    let viewController = delegate as? UIViewController ?? UIViewController()
    viewController.present(alertController, animated: true, completion: nil)
  }
  /// To check the reachability status. Will return 'true' if network is reachable.
  class  var isConnectedToInternet: Bool {
    return NetworkReachabilityManager()!.isReachable
  }

  /// To start ActivityIndicator
  class func startActivityIdicator() {
    customActivityIndicator.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    customActivityIndicator.backgroundColor = CustomColor.transparentBlack.color
    customActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
    customActivityIndicator.color = UIColor.white
    customActivityIndicator.hidesWhenStopped = true
    UIApplication.shared.delegate?.window!!.addSubview(customActivityIndicator)
    customActivityIndicator.startAnimating()
  }

  /// To stop ActivityIndicator
  class func stopActivityIndicator() {
    customActivityIndicator.stopAnimating()
    customActivityIndicator.removeFromSuperview()
  }

  /// To validate email id
  ///
  /// - Parameter email: email id
  /// - Returns: returns 'true' for valid email id
  class func isValidEmail(email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: email)  }

  /// To validate phone number
  ///
  /// - Parameter phone: phone number
  /// - Returns: returns 'true' for valid phone number
  class func isValidPhone(phone: String) -> Bool {
    var isSuccess = false
    if phone.characters.count == 8 {
      isSuccess = true
    }
    return isSuccess
  }
  /// To validate civilId
  /// - Parameter civilId: CivilId
  /// - Returns: returns 'true' for valid CivilId
  class func isValidCivilId(civilId: String) -> Bool {
    var isSuccess = false
    if civilId.characters.count == 12 {
      do {

          let expression = "^([0-9]+)?(\\.([0-9]{1,2})?)?$"
          let regex = try NSRegularExpression(pattern: expression, options: .caseInsensitive)
          let numberOfMatches = regex.numberOfMatches(in: civilId as String, options: [], range: NSRange(location: 0, length: (civilId.characters.count)))

          if numberOfMatches == 0 {
            return isSuccess == false
          }
        } catch let error {
        print(error)
        isSuccess = false
      }
     isSuccess = true
    }
    return isSuccess
  }

  /// To validate password and confirm password is same
  ///
  /// - Parameter Password: Password
  /// - Parameter confirmPassword: confirmPassword
  /// - Returns: returns 'true' for samePassword
  class func isPasswordSame(password: String, confirmPassword: String) -> Bool {
    var isSuccess = false
    if password == confirmPassword {
      isSuccess = true
    }
    return isSuccess
  }

  /// To check strings are empty or not
  ///
  /// - Parameter text: string
  /// - Returns: returns 'true' for string has value
  class func isStringEmpty(text: String) -> Bool {
    if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      return true
    }
    return false
  }

  class func getTimestampAfter(daysInterval: Int) -> Int {
    let interval = daysInterval*60*60*24
    let date = Date(timeIntervalSinceNow:TimeInterval(interval))
    let timeStamp = Int(date.timeIntervalSince1970)
    return timeStamp
  }

  /// Returns abbreviation of day's name according to operating status. If isOperating is true will return a bold sized text else returns regular sized text
  /// eg:- 's' for sunday, 'm' for monday etc
  ///
  /// - Parameters:
  ///   - day: corresponding day name
  ///   - isOperating: isOperating or not
  /// - Returns: abbreviation of day's name
  class func getformattedString(day: String?, isOperating: Bool?) -> NSAttributedString? {
    var attributes: [String: Any]?
    if isOperating! {
      attributes = [NSForegroundColorAttributeName: CustomColor.blackText.color, NSFontAttributeName: UIFont().setSystemFontBold(withFontSize: 13)]
    } else {
      attributes = [NSForegroundColorAttributeName: CustomColor.grey.color, NSFontAttributeName: UIFont().setSystemFontBold(withFontSize: 13)]
    }
    let formattedString =  NSAttributedString(string: day ?? "", attributes: attributes)
    return formattedString
  }

  /// Return's attributed text with abbreviation's of day's name
  ///eg: - 'S M T W T F S'
  /// - Parameter operatingDays: is operating or not
  /// - Returns: 
  class func getOperatingDays(operatingDays: [OperatingDays]?) -> NSAttributedString? {
    let daysOfOperation = NSMutableAttributedString()
    for operatingDay in operatingDays! {
      var operatingDayName: String?
      switch operatingDay.daysId ?? 0 {
      case 1:
        operatingDayName = NSLocalizedString("Sunday", comment: "")
      case 2:
        operatingDayName = NSLocalizedString("Monday", comment: "")
      case 3:
        operatingDayName = NSLocalizedString("Tuesday", comment: "")
      case 4:
        operatingDayName = NSLocalizedString("Wednesday", comment: "")
      case 5:
        operatingDayName = NSLocalizedString("Thursday", comment: "")
      case 6:
        operatingDayName = NSLocalizedString("Friday", comment: "")
      case 7:
        operatingDayName = NSLocalizedString("Saturday", comment: "")
      default:
        break
      }

      let dayName = Utility.getformattedString(day: operatingDayName, isOperating: operatingDay.isOperating)
      daysOfOperation.append(dayName!)
    }
    return daysOfOperation
  }

  class func getProposedOperatingDays(operatingDays: [OperatingDays]?) -> NSAttributedString? {
    let daysOfOperation = NSMutableAttributedString()
    for operatingDay in operatingDays! {
      var operatingDayName: String?
      switch operatingDay.daysId ?? 0 {

      case 1:
        operatingDayName = NSLocalizedString("Sun", comment: "")
      case 2:
        operatingDayName = NSLocalizedString("Mon", comment: "")
      case 3:
        operatingDayName = NSLocalizedString("Tue", comment: "")
      case 4:
        operatingDayName = NSLocalizedString("Wed", comment: "")
      case 5:
        operatingDayName = NSLocalizedString("Thu", comment: "")
      case 6:
        operatingDayName = NSLocalizedString("Fri", comment: "")
      case 7:
        operatingDayName = NSLocalizedString("Sat", comment: "")
      default:
        break
      }

      let dayName = Utility.getformattedString(day: operatingDayName, isOperating: operatingDay.isOperating)
      daysOfOperation.append(dayName!)
    }
    return daysOfOperation
  }

  /// Will convert Date to string
  ///
  /// - Parameter date: Date
  /// - Returns: string value corresponding to Date
  class func getFormattedDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = ApplicationSettingsKey.defaultDateFormat.key ?? "dd-MMM-yyyy"
    return dateFormatter.string(from: date)
  }

  /// Will convert Time to string
  ///
  /// - Parameter time: Time component of Date
  /// - Returns: string value corresponding to Time
  class func getFormattedTime(time: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "hh:mm a"
    return dateFormatter.string(from: time)
  }

  /// will convert string[Time string] to Time
  ///
  /// - Parameter timeString: string [In time format]
  /// - Returns: Time corresponding to string value.
  class func getTimeFrom(timeString: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "hh:mm a"
    if let date = dateFormatter.date(from: timeString) {
      return date
    }
    return nil
  }

  class func getTimeFromUTC(dateString: String) -> String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    let dt = dateFormatter.date(from: dateString)
    if let formattedDate = dt {
        let today = Calendar.current.isDateInToday(formattedDate)
        if today {
          return "Today"
        } else {
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "dd-MMM-yyyy  h:mm a"//ApplicationSettingsKey.defaultDateFormat.key ?? "dd-MMM-yyyy h:mm a"
        if let date = dt {
          let time = dateFormatter.string(from: date)
          return time
        }
      }
    }
    return ""
  }

    /// To retrieve location title from userdefaults
  ///
  /// - Parameter locationDict: locationDictionary
  /// - Returns: string value of location

 class func getLocDetails(locationDict: [String: String]) -> String {
     var locationDetails: String?
    if let title = locationDict["title"] {
      locationDetails = title
      return locationDetails ?? ""
    }
  if let address = locationDict["address"] {
     locationDetails = address
  }
   return locationDetails ?? ""
  }

  class func getLocAddress(locationDict: [String: String]) -> String! {
    var locationDetails: String?
    if let address = locationDict["address"] {
      locationDetails = address
    }
    return locationDetails ?? ""
  }

  class func appendString(data: Int) -> String {
    let value = data
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 3 // for float
    formatter.maximumFractionDigits = 3 // for float
    formatter.minimumIntegerDigits = 1
    formatter.paddingPosition = .afterPrefix
    formatter.paddingCharacter = "0"
    return formatter.string(from: NSNumber(floatLiteral: Double(value)))!
  }

  class func appendDecimals(data: Double) -> String {
    let value = data
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 3
    formatter.maximumFractionDigits = 3
    formatter.minimumIntegerDigits = 1
    formatter.paddingPosition = .afterPrefix
    formatter.paddingCharacter = "0"
    return formatter.string(from: NSNumber(floatLiteral: Double(value)))!
  }

  class func subscriptionDate(date: Int) -> String {
    let date = NSDate(timeIntervalSince1970: TimeInterval(date) )
    let dayTimePeriodFormatter = DateFormatter()
    dayTimePeriodFormatter.dateFormat = ApplicationSettingsKey.defaultDateFormat.key ?? "dd-MMM-yyyy"
    let dateString = dayTimePeriodFormatter.string(from: date as Date)
    return dateString
  }

  class func showAlertWith(title: String?, message: String, duration: Double, delegate: AnyObject, completion: @escaping () -> Void) {
    let alert = UIAlertController(title: title ?? "", message: message, preferredStyle: .alert)
    let viewController = delegate as? UIViewController ?? UIViewController()
    viewController.present(alert, animated: true, completion: nil)
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(duration * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {() -> Void in
      alert.dismiss(animated: true) { _ in
        completion()
      }
    })
  }
}
