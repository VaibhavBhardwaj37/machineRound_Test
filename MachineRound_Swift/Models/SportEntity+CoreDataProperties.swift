//
//  SportEntity+CoreDataProperties.swift
//  MachineRound_Swift
//
//  Created by Sanskar IOS Dev on 16/06/25.
//
//

import Foundation
import CoreData


extension SportEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SportEntity> {
        return NSFetchRequest<SportEntity>(entityName: "SportEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var sport_id: Int64
    @NSManaged public var sport_name: String?
    @NSManaged public var venue_name: String?
    @NSManaged public var start_date: String?
    @NSManaged public var end_date: String?
    @NSManaged public var status: String?

}

extension SportEntity : Identifiable {

}
