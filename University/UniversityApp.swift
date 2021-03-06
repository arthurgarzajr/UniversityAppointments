//
//  UniversityApp.swift
//  University
//
//  Created by Arthur Garza on 3/4/21.
//

import SwiftUI

@main
struct UniversityApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
