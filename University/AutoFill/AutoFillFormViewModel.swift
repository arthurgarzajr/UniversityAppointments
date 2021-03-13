//
//  AutoFillFormViewModel.swift
//  University
//
//  Created by Arthur Garza on 3/12/21.
//

import Foundation

class AutoFillFormViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var middleName = ""
    @Published var lastName = ""
    @Published var gender = ""
    @Published var dateOfBirth = ""
    @Published var addressLine1 = ""
    @Published var addressLine2 = ""
    @Published var city = ""
    @Published var zipCode = ""
    @Published var mobilePhone = ""
    @Published var email = ""
    
    func savePerson() {
        var person = Person()
        person.firstName = self.firstName
        person.middleName = self.middleName
        person.lastName = self.lastName
        person.gender = self.gender
        person.dateOfBirth = self.dateOfBirth
        person.addressLine1 = self.addressLine1
        person.addressLine2 = self.addressLine2
        person.city = self.city
        person.zipCode = self.zipCode
        person.mobilePhone = self.mobilePhone
        person.email = self.email
        
        PeopleUtil.savePerson(person: person)
    }
}
