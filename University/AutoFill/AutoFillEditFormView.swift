//
//  AutoFillEditFormView.swift
//  University
//
//  Created by Arthur Garza on 3/15/21.
//

import SwiftUI

struct AutoFillEditFormView: View {
    @ObservedObject var viewModel: AutoFillEditFormViewModel
    
    let gender = ["Female", "Male"]
    
    var completed: () -> ()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            Section {
                TextField("First Name", text: $viewModel.person.firstName)
                    .autocapitalization(.words)
                TextField("Middle Name", text: $viewModel.person.middleName)
                    .autocapitalization(.words)
                TextField("Last Name", text: $viewModel.person.lastName)
                    .autocapitalization(.words)
                Picker("Gender", selection: $viewModel.person.gender) {
                                       ForEach(gender, id: \.self) {
                                           Text($0)
                                       }
                                   }
                TextField("Date of Birth (MM/DD/YYYY)", text: $viewModel.person.dateOfBirth)
            }
            
            Section {
                TextField("Address Line 1", text: $viewModel.person.addressLine1)
                    .autocapitalization(.words)
                TextField("Address Line 2", text: $viewModel.person.addressLine2)
                    .autocapitalization(.words)
                TextField("City", text: $viewModel.person.city)
                    .autocapitalization(.words)
                TextField("Zip Code", text: $viewModel.person.zipCode)

            }

            Section {
                TextField("Mobile Phone", text: $viewModel.person.mobilePhone)
                    .keyboardType(.numbersAndPunctuation)
                TextField("Email", text: $viewModel.person.email)
                    .autocapitalization(.none)
            }
        }
        .navigationBarItems(trailing: Button("Save", action: {
            viewModel.savePerson()
            completed()
            presentationMode.wrappedValue.dismiss()
        }))
        .navigationTitle("\(viewModel.person.firstName) \(viewModel.person.lastName)")
    }
}
