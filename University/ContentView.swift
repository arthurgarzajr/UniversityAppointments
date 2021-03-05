//
//  ContentView.swift
//  University
//
//  Created by Arthur Garza on 3/4/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        VStack {
            if viewModel.checkingForAppointments {
                Text("Checking")
            }
            Button("Check for Appointments", action: {
                viewModel.getRequest()
            })
            .padding()
            
            if viewModel.appointmentsAvailable {
                Text("Appointments Available")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
