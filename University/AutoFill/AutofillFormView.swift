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
    
    var completed: () -> ()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("First Name", text: $formViewModel.firstName)
                    TextField("Last Name", text: $formViewModel.lastName)
                    TextField("Date of Birth (MM/DD/YYYY)", text: $formViewModel.dateOfBirth)
                    TextField("Address Line 1", text: $formViewModel.addressLine1)
                    TextField("City", text: $formViewModel.city)
                    TextField("Zip Code", text: $formViewModel.zipCode)
                    TextField("Mobile Phone", text: $formViewModel.mobilePhone)
                    TextField("Email", text: $formViewModel.email)
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
