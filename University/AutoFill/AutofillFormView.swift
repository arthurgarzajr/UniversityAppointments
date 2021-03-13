//
//  AutofillFormView.swift
//  University
//
//  Created by Arthur Garza on 3/12/21.
//

import SwiftUI

struct AutofillFormView: View {
    
    @StateObject var viewModel = AutoFillListViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("First Name", text: $viewModel.firstName)
                    TextField("Last Name", text: $viewModel.lastName)
                    TextField("Date of Birth (MM/DD/YYYY)", text: $viewModel.dateOfBirth)
                    TextField("Address Line 1", text: $viewModel.addressLine1)
                    TextField("City", text: $viewModel.city)
                    TextField("Zip Code", text: $viewModel.zipCode)
                    TextField("Mobile Phone", text: $viewModel.mobilePhone)
                    TextField("Email", text: $viewModel.email)
                }
            }
            .navigationBarItems(leading: Button("Cancel", action: {
                presentationMode.wrappedValue.dismiss()
            }), trailing: Button("Done", action: {
                
            }))
            .navigationTitle("Add Person")
        }
    }
}

struct AutofillFormView_Previews: PreviewProvider {
    static var previews: some View {
        AutofillFormView()
    }
}
