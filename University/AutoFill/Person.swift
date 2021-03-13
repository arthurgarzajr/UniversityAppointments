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
    var middleName: String
    var lastName: String
    var gender: String
    var dateOfBirth: String
    var addressLine1: String
    var addressLine2: String
    var city: String
    var zipCode: String
    var mobilePhone: String
    var email: String
    
    init() {
        self.firstName = ""
        self.middleName = ""
        self.lastName = ""
        self.gender = ""
        self.dateOfBirth = ""
        self.addressLine1 = ""
        self.addressLine2 = ""
        self.city = ""
        self.zipCode = ""
        self.mobilePhone = ""
        self.email = ""
    }
}
