//
//  AutoFillListView.swift
//  University
//
//  Created by Arthur Garza on 3/12/21.
//

import SwiftUI

struct AutoFillListView: View {
    @StateObject var viewModel = AutoFillListViewModel()
    
    @State var showingAddPerson = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List(viewModel.people!) { person in
                Text(person.firstName)
            }
            .sheet(isPresented: $showingAddPerson, content: {
                AutofillFormView()
            })
            .navigationBarItems(leading: Button("Close", action: {
                presentationMode.wrappedValue.dismiss()
            }), trailing: Button(action: { showingAddPerson = true }, label: {
                Image(systemName: "plus")
            }))
            .navigationTitle("Autofill")
        }
    }
}

struct AutoFillListView_Previews: PreviewProvider {
    static var previews: some View {
        AutoFillListView()
    }
}
