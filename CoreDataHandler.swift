//
//  CoreDataHandler.swift
//
//

import Foundation
import UIKit
import CoreData

class CoreDataHandler: NSObject {
  static let sharedInstance = CoreDataHandler()
  private override init() {}

  // MARK: - Core Data stack
  @available(iOS 10.0, *)
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "ApplicationSettings")
    container.loadPersistentStores(completionHandler: { (_, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()

  // iOS 9 and below
  lazy var applicationDocumentsDirectory: URL = {

    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return urls[urls.count-1]
  }()

  lazy var managedObjectModel: NSManagedObjectModel = {
    let modelURL = Bundle.main.url(forResource: "ApplicationSettings", withExtension: "momd")!
    return NSManagedObjectModel(contentsOf: modelURL)!
  }()

  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.applicationDocumentsDirectory.appendingPathComponent("ApplicationSettings.sqlite")
    var failureReason = "There was an error creating or loading the application's saved data."
    do {
      try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
    } catch {
      // Report any error we got.
      var dict = [String: AnyObject]()
      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
      dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
      dict[NSUnderlyingErrorKey] = error as NSError
      let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
      // Replace this with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
      abort()
    }
    return coordinator
  }()
  lazy var managedObjectContext: NSManagedObjectContext = {
    let coordinator = self.persistentStoreCoordinator
    var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
  }()

  // MARK: - Core Data Saving support
  func saveContext () {

    if #available(iOS 10.0, *) {

      let context = persistentContainer.viewContext
      if context.hasChanges {
        do {
          try context.save()
        } catch {
          let nserror = error as NSError
          fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
      }
    } else {
      if managedObjectContext.hasChanges {
        do {
          try managedObjectContext.save()
        } catch {
          let nserror = error as NSError
          NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
          abort()
        }
      }
    }
  }
}

extension CoreDataHandler {

  func saveApplcationSettingsinCoredata(responseArray: [ApplicationSettingsDataResponse]) {
    for settingsObj in responseArray {
      if #available(iOS 10.0, *) {
        let context = CoreDataHandler.sharedInstance.persistentContainer.viewContext
        if let applicationSettingsEntity = NSEntityDescription.insertNewObject(forEntityName: "ApplicationSettings", into: context) as? ApplicationSettings {
          applicationSettingsEntity.keyDescription = settingsObj.description
          applicationSettingsEntity.key = settingsObj.key
          applicationSettingsEntity.value = settingsObj.value
          do {
            try context.save()
          } catch let error {
            print(error)
          }

        } else {
          // Fallback on earlier versions
        }
      } else {
        let context = CoreDataHandler.sharedInstance.managedObjectContext
        if let applicationSettingsEntity = NSEntityDescription.insertNewObject(forEntityName: "ApplicationSettings", into: context) as? ApplicationSettings {
          applicationSettingsEntity.keyDescription = settingsObj.description
          applicationSettingsEntity.key = settingsObj.key
          applicationSettingsEntity.value = settingsObj.value
          do {
            try context.save()
          } catch let error {
            print(error)
          }

        } else {
          // Fallback on earlier versions
        }
      }
    }
  }

  /// Getting the value for specific key
  func getSettingsDataFor(key: String) -> [ApplicationSettings] {
    var fetchedObjects: [ApplicationSettings] = []
    if #available(iOS 10.0, *) {
      do {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ApplicationSettings")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "key == %@", key)
        try fetchedObjects = (context.fetch(fetchRequest) as? [ApplicationSettings])!
      } catch {
      }
      return fetchedObjects
    } else {
      do {
        let context = managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ApplicationSettings")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "key == %@", key)
        try fetchedObjects = (context.fetch(fetchRequest) as? [ApplicationSettings])!
      } catch {
      }
      return fetchedObjects
    }
  }

  func deleteAllRecords() {
    if #available(iOS 10.0, *) {
      let context = persistentContainer.viewContext
      let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ApplicationSettings")
      let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
      do {
        try context.execute(deleteRequest)
        try context.save()
      } catch {
        print ("There was an error")
      }
    } else {
      let context = managedObjectContext
      let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ApplicationSettings")
      let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

      do {
        try context.execute(deleteRequest)
        try context.save()
      } catch {
        print ("There was an error")
      }
    }
  }

  /// Updating the application settings
  ///
  /// - Parameter responseArray: Application settings Data response
  func updateAllRecords(responseArray: [ApplicationSettingsDataResponse]) {
    for settingsObject in responseArray {
      if #available(iOS 10.0, *) {
        let request = NSFetchRequest<ApplicationSettings>(entityName: "ApplicationSettings")

        do {
          let context = persistentContainer.viewContext
          let searchResults = try context.fetch(request)

          for settingsKeys in searchResults where settingsKeys.key == settingsObject.key {
            settingsKeys.value = settingsObject.value
            try context.save()
          }
        } catch {
          print ("There was an error")
        }

      } else {

      }
    }
  }
}
