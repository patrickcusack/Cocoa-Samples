//
//  Placeholder.swift
//  TableViewDragDrop
//
//  Created by Patrick Cusack on 1/7/22.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation

class PlaceholderObject: NSObject {
    @objc dynamic var firstName: String
    @objc dynamic var lastName: String
    @objc dynamic var mobileNumber: String
    
    init(firstName: String, lastName: String, mobileNumber: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.mobileNumber = mobileNumber
    }
}
