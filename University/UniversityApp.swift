//
//  UniversityApp.swift
//  University
//
//  Created by Arthur Garza on 3/4/21.
//

import SwiftUI

@main
struct UniversityApp: App {
    @StateObject var viewModel: ViewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
