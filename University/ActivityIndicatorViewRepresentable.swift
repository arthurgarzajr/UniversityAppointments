//
//  ActivityIndicatorViewRepresentable.swift
//  University
//
//  Created by Arthur Garza on 3/5/21.
//

import Foundation
import SwiftUI

struct ActivityIndicatorViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.startAnimating()
        return activityIndicator
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        
    }
}
