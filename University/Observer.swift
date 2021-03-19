//
//  Observer.swift
//  University
//
//  Created by Arthur Garza on 3/19/21.
//

import SwiftUI
import Foundation

class Observer: ObservableObject {

    @Published var enteredForeground = true
    
    static var fromPushNotification = false

    init() {
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIScene.willEnterForegroundNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        }
    }

    @objc func willEnterForeground() {
        enteredForeground.toggle()
    }
}
