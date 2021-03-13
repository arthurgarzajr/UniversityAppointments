//
//  AutoFillListViewModel.swift
//  University
//
//  Created by Arthur Garza on 3/12/21.
//

import Foundation

class AutoFillListViewModel: ObservableObject {
    
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var dateOfBirth = ""
    @Published var addressLine1 = ""
    @Published var city = ""
    @Published var zipCode = ""
    @Published var mobilePhone = ""
    @Published var email = ""
    
    @Published var people: [Person]?
    
    init() {
        people = self.readPeople()
    }
    
    func savePerson(person: Person) {
        // First get all people
        var allPeople = readPeople()
        
        // Then add this new person
        allPeople.append(person)
        
        var peopleObject = People()
        peopleObject.people = allPeople
        
        // Then save all people
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(peopleObject) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "SavedPeople")
        }
    }
    
    func readPeople() -> [Person] {
        var people = [Person]()
        let defaults = UserDefaults.standard
        if let savedPeople = defaults.object(forKey: "SavedPeople") as? Data {
            let decoder = JSONDecoder()
            if let loadedPeople = try? decoder.decode(People.self, from: savedPeople) {
                print(loadedPeople)
                people = loadedPeople.people
            } else {
                // Initialize the People Object in UserDefaults because it doesn't exist yet
                initPeople()
            }
        }
        return people
    }
    
    func initPeople() {
        var peopleObject = People()
        peopleObject.people = [Person]()
        // Then save all people
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(peopleObject) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "SavedPeople")
        }
    }
}
