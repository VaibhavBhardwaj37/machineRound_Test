//
//  AppDelegate.swift
//  MachineRound_Swift
//
//  Created by Sanskar IOS Dev on 16/06/25.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NetworkMonitor.shared.startMonitoring()
        
        // Configure window
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = ViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
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

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "MachineRound_Swift")
        
        // Configure CloudKit options
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        
        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.com.InventoryAppUI.MachineRound-Swift"
        )
        
        // Enable history tracking
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Handle the error appropriately
                print("Core Data store failed to load with error: \(error.localizedDescription)")
                
                // Attempt to recover from the error
                self.handlePersistentStoreError(error)
            }
        })
        
        // Configure the view context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Core Data save failed with error: \(nserror.localizedDescription)")
                
                // Handle the error appropriately
                self.handleSaveError(nserror)
            }
        }
    }
    
    // MARK: - Error Handling
    
    private func handlePersistentStoreError(_ error: NSError) {
        // Check if it's a migration error
        if error.domain == NSCocoaErrorDomain && error.code == NSPersistentStoreIncompatibleVersionHashError {
            // Handle migration error
            print("Migration required: \(error.localizedDescription)")
            // You might want to show an alert to the user here
        } else {
            // Handle other errors
            print("Persistent store error: \(error.localizedDescription)")
            // You might want to show an alert to the user here
        }
    }
    
    private func handleSaveError(_ error: NSError) {
        // Handle save errors
        print("Save error: \(error.localizedDescription)")
        // You might want to show an alert to the user here
    }
    
    // MARK: - Application Lifecycle
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Save any pending changes when the app is about to terminate
        saveContext()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Save any pending changes when the app enters the background
        saveContext()
    }
}

