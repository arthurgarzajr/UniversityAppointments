//
//  ActivityIndicatorView.swift
//  University
//
//  Created by Arthur Garza on 3/5/21.
//

import SwiftUI

struct ActivityIndicatorView: View {
    var message: String = ""
    var body: some View {
        HStack {
            ActivityIndicatorViewRepresentable()
            if message != "" {
                Text(message)
                    .font(.system(size: 17))
            }
        }
    }
}

struct ActivityIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicatorView(message: "Loading...")
    }
}

