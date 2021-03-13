//
//  AutofillFormView.swift
//  University
//
//  Created by Arthur Garza on 3/12/21.
//

import SwiftUI

struct AutofillFormView: View {
    
    @StateObject var formViewModel = AutoFillFormViewModel()
    @ObservedObject var viewModel: AutoFillListViewModel
    @Environment(\.presentationMode) var presentationMode

    let gender = ["Female", "Male"]
    
    var completed: () -> ()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("First Name", text: $formViewModel.firstName)
                        .autocapitalization(.words)
                    TextField("Middle Name", text: $formViewModel.middleName)
                        .autocapitalization(.words)
                    TextField("Last Name", text: $formViewModel.lastName)
                        .autocapitalization(.words)
                    Picker("Gender", selection: $formViewModel.gender) {
                                           ForEach(gender, id: \.self) {
                                               Text($0)
                                           }
                                       }
                    TextField("Date of Birth (MM/DD/YYYY)", text: $formViewModel.dateOfBirth)
                }
                
                Section {
                    TextField("Address Line 1", text: $formViewModel.addressLine1)
                        .autocapitalization(.words)
                    TextField("Address Line 2", text: $formViewModel.addressLine2)
                        .autocapitalization(.words)
                    TextField("City", text: $formViewModel.city)
                        .autocapitalization(.words)
                    TextField("Zip Code", text: $formViewModel.zipCode)
                        
                }
                
                Section {
                    TextField("Mobile Phone", text: $formViewModel.mobilePhone)
                        .keyboardType(.numbersAndPunctuation)
                    TextField("Email", text: $formViewModel.email)
                        .autocapitalization(.none)
                }
            }
            .navigationBarItems(leading: Button("Cancel", action: {
                presentationMode.wrappedValue.dismiss()
            }), trailing: Button("Save", action: {
                self.formViewModel.savePerson()
                presentationMode.wrappedValue.dismiss()
                completed()
            }))
            .navigationTitle("Add Person")
        }
    }
}

struct AutofillFormView_Previews: PreviewProvider {
    static var previews: some View {
        AutofillFormView(viewModel: AutoFillListViewModel(), completed: { } )
    }
}
