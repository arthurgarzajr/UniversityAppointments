//
//  Person.swift
//  University
//
//  Created by Arthur Garza on 3/12/21.
//

import Foundation

struct Person: Codable, Identifiable {
    var id = UUID()
    var firstName: String
    var lastName: String
    var dateOfBirth: String
    var addressLine1: String
    var city: String
    var zipCode: String
    var mobilePhone: String
    var email: String
    
    init() {
        self.firstName = ""
        self.lastName = ""
        self.dateOfBirth = ""
        self.addressLine1 = ""
        self.city = ""
        self.zipCode = ""
        self.mobilePhone = ""
        self.email = ""
    }
}
