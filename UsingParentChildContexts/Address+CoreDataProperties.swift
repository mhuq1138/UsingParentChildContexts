//
//  Address+CoreDataProperties.swift
//  UsingParentChildContexts
//
//  Created by Mazharul Huq on 3/6/18.
//  Copyright © 2018 Mazharul Huq. All rights reserved.
//
//

import Foundation
import CoreData


extension Address {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Address> {
        return NSFetchRequest<Address>(entityName: "Address")
    }

    @NSManaged public var city: String?
    @NSManaged public var name: String?
    @NSManaged public var state: String?
    @NSManaged public var street: String?

}
