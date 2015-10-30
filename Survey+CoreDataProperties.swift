//
//  Survey+CoreDataProperties.swift
//  Topcoder-FunSeries-SurveyApp
//
//  Created by Sugam Kalra on 29/10/15.
//  Copyright © 2015 Sugam Kalra. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Survey {

    @NSManaged var id: String?
    @NSManaged var title: String?
    @NSManaged var descriptionText: String?
    @NSManaged var isRecordDeleted: String?

}
