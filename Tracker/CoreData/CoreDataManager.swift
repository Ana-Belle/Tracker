//
//  CoreDataManager.swift
//  Tracker
//
//  Created by Anastasia Belyakova on 27.05.2026.
//

import CoreData

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Unresolved error \(error)")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() throws {
        let context = viewContext
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            throw StoreError.saveFailed(error)
        }
    }
    
}
