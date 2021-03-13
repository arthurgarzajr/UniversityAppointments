//
//  AutoFillListViewModel.swift
//  University
//
//  Created by Arthur Garza on 3/12/21.
//

import Foundation

class AutoFillListViewModel: ObservableObject {
    
    @Published var people: [Person]?
    
    init() {
        people = PeopleUtil.readPeople()
    }
    
    func reloadPeople() {
        people = PeopleUtil.readPeople()
    }
    
    func savePeople() {
        
    }
}
