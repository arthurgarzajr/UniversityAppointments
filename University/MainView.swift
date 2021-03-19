//
//  ContentView.swift
//  University
//
//  Created by Arthur Garza on 3/4/21.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel: ViewModel = ViewModel()
    @ObservedObject var observer = Observer()
    
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
                    Spacer()
                }
                .padding()
                
                HStack {
                    Stepper("Delay in seconds", value: $viewModel.delay, in: 0...60)
                        .padding([.leading, .trailing])
                    Text(String(describing: viewModel.delay))
                        .padding(.trailing)
                }
                
                
                
                if viewModel.appointmentsAvailable {
                    Spacer()
                    VStack {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                                .font(.headline)
                            Text("APPOINTMENTS DETECTED")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .padding()
                        Text(viewModel.appointmentsAvailableMessage)
                    }
                }
                
                Spacer()
                
                Button {
                    viewModel.waitForCheckerToStopBeforeShowingWebpage()
                } label: {
                    HStack {
                        Image(systemName: "safari")
                        Text("Open Scheduling Page")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                }
                .cornerRadius(12.0)
                .padding()
                .sheet(isPresented: $viewModel.showAppointmentsPage, content: {
                    WebViewUI(url: viewModel.signUpAndScheduleURL, dismissAction: viewModel.webViewDismissed)
                })
            }
            
            .navigationTitle("University Checker")
            .navigationBarItems(
                leading: Button("Autofill", action: {
                    self.viewModel.showAutofillPage = true
                })
                .sheet(isPresented: $viewModel.showAutofillPage, content: {
                    AutoFillListView()
                }),
                trailing: viewModel.checkingForAppointments ? AnyView(ActivityIndicatorView(message: "Checking")) : AnyView(EmptyView()))
        }
        .onReceive(self.observer.$enteredForeground) { _ in
            print("App entered foreground!")
            if Observer.fromPushNotification {
                viewModel.waitForCheckerToStopBeforeShowingWebpage()
                Observer.fromPushNotification = false
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
