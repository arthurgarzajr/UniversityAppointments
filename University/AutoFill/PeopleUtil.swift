//
//  PeopleUtil.swift
//  University
//
//  Created by Arthur Garza on 3/12/21.
//

import Foundation

class PeopleUtil {
    static func savePerson(person: Person) {
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
    
    static func savePeople(people: [Person]) {
        var peopleObject = People()
        peopleObject.people = people
        
        // Then save all people
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(peopleObject) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "SavedPeople")
        }
    }
    
    static func readPeople() -> [Person] {
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
    
    static func initPeople() {
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
