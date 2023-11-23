//
//  Foods+CoreDataProperties.swift
//  cafoll
//
//  Created by mücahit öztürk on 23.11.2023.
//
//

import Foundation
import CoreData


extension Foods {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Foods> {
        return NSFetchRequest<Foods>(entityName: "Foods")
    }

    @NSManaged public var carbon: String
    @NSManaged public var fat: String
    @NSManaged public var calori: String
    @NSManaged public var protein: String
    @NSManaged public var title: String

}

extension Foods : Identifiable {

}
