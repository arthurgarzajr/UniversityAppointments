//
//  People.swift
//  University
//
//  Created by Arthur Garza on 3/12/21.
//

import Foundation

struct People: Codable {
    var people: [Person]
    init() {
        self.people = [Person]()
    }
}
