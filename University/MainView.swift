//
//  ContentView.swift
//  University
//
//  Created by Arthur Garza on 3/4/21.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            VStack {

                HStack {
                    
                    Button {
                        viewModel.startChecking()
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start")
                        }
                        
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                    }
                    .cornerRadius(12.0)
                    
                    Button {
                        viewModel.stopChecking()
                    } label: {
                        HStack {
                            Image(systemName: "stop.fill")
                            Text("Stop")
                        }
                        
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                    }
                    .cornerRadius(12.0)
                    
                }
                if viewModel.appointmentsAvailable {
                    Button {
                        viewModel.showAppointmentsPage = true
                    } label: {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                            Text("Appointments Available")
                        }
                        
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                    }
                    .cornerRadius(12.0)
                    .sheet(isPresented: $viewModel.showAppointmentsPage, content: {
                        SafariView(url: URL(string: viewModel.signUpAndScheduleURL))
                    })
                }
            }
            
            .navigationTitle("University Checker")
            .navigationBarItems(trailing: viewModel.checkingForAppointments ? AnyView(ActivityIndicatorView(message: "Checking")) : AnyView(EmptyView()))
            
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
