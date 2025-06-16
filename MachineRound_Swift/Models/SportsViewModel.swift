//
//  SportsViewModel.swift
//  MachineRound_Swift
//
//  Created by Sanskar IOS Dev on 16/06/25.
//

import Foundation
import UIKit
import CoreData

class SportsViewModel {
    
    var sports: [SportsAPI] = []
    var errorMessage: String?
    
    func fetchSportsData(completion: @escaping (Bool) -> Void) {
        if NetworkMonitor.shared.isConnected {
            // Online: Fetch from API and update Core Data
            Task {
                do {
                    let result = try await NetworkManager.shared.fetchSportsData()
                    self.sports = result
                    saveToCoreData(result)
                    completion(true)
                } catch {
                    self.errorMessage = "API Error: \(error.localizedDescription)"
                    loadFromCoreData()
                    completion(!self.sports.isEmpty)
                }
            }
        } else {
            // Offline: Load from Core Data
            loadFromCoreData()
            completion(!self.sports.isEmpty)
        }
    }
    
    private func saveToCoreData(_ sportsList: [SportsAPI]) {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return }
        
        // First, delete existing entries
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "SportEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? context.execute(deleteRequest)
        
        // Save new entries
        for sport in sportsList {
            let entity = SportEntity(context: context)
            entity.id = Int64(sport.id ?? 0)
            entity.sport_id = Int64(sport.sport_id ?? 0)
            entity.sport_name = sport.sport_name
            entity.venue_name = sport.venue_name
            entity.start_date = sport.start_date
            entity.end_date = sport.end_date
            entity.status = sport.status
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save Core Data: \(error)")
        }
    }
    
    private func loadFromCoreData() {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return }

        let fetchRequest: NSFetchRequest<SportEntity> = SportEntity.fetchRequest()
        
        do {
            let savedEntities = try context.fetch(fetchRequest)
            self.sports = savedEntities.map { entity in
                SportsAPI(
                    id: Int(entity.id),
                    sport_id: Int(entity.sport_id),
                    nsrs_sport_id: 0,
                    sport_name: entity.sport_name,
                    start_date: entity.start_date,
                    end_date: entity.end_date,
                    cluster_name: "",
                    venue_name: entity.venue_name,
                    status: entity.status,
                    rf_sport_db_name: "",
                    sport_image_url: "",
                    sport_icon_url: "",
                    mascot_image_url: ""
                )
            }
        } catch {
            self.errorMessage = "Failed to load from Core Data"
        }
    }
    
    func deleteSport(byId id: Int?, completion: @escaping (Bool) -> Void) {
        guard let id = id else {
            completion(false)
            return
        }

        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            completion(false)
            return
        }

        let fetchRequest: NSFetchRequest<SportEntity> = SportEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)

        do {
            let results = try context.fetch(fetchRequest)
            if let entityToDelete = results.first {
                context.delete(entityToDelete)
                try context.save()

                // Remove from array safely
                if let index = sports.firstIndex(where: { $0.id == id }) {
                    sports.remove(at: index)
                }

                completion(true)
            } else {
                completion(false)
            }
        } catch {
            print("Failed to delete sport: \(error)")
            completion(false)
        }
    }

}
