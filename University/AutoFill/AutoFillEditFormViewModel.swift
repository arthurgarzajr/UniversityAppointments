//
//  AutoFillEditFormViewModel.swift
//  University
//
//  Created by Arthur Garza on 3/15/21.
//

import Foundation

class AutoFillEditFormViewModel: ObservableObject {
    var person: Person
    
    init(person: Person) {
        self.person = person
    }
    
    func savePerson() {
        var people = PeopleUtil.readPeople()
        
        var index = -1
        for (thisIndex, thisPerson) in people.enumerated() {
            if thisPerson.id == self.person.id {
                index = thisIndex
            }
        }
        
        if index != -1 {
            people[index] = self.person
        }
        
        PeopleUtil.savePeople(people: people)
    }
}
