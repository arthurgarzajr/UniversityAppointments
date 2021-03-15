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
            List {
                
                ForEach(viewModel.people!) { person in
                    let autoFillEditFormViewModel = AutoFillEditFormViewModel(person: person)
                    NavigationLink(destination: AutoFillEditFormView(viewModel: autoFillEditFormViewModel) {
                        viewModel.reloadPeople()
                    }) {
                        let firstAndLastName = person.firstName + " " + person.lastName
                        Text(firstAndLastName)
                    }
                }
                .onDelete(perform: delete)
            }
            .sheet(isPresented: $showingAddPerson, content: {
                AutofillFormView(viewModel: viewModel, completed: viewModel.reloadPeople)
            })
            .navigationBarItems(leading: Button("Close", action: {
                presentationMode.wrappedValue.dismiss()
            }), trailing: Button(action: { showingAddPerson = true }, label: {
                Image(systemName: "plus")
            }))
            .navigationTitle("Autofill")
        }
    }
    
    func delete(at offsets: IndexSet) {
        viewModel.people?.remove(atOffsets: offsets)
        PeopleUtil.savePeople(people: viewModel.people!)
    }
}

struct AutoFillListView_Previews: PreviewProvider {
    static var previews: some View {
        AutoFillListView()
    }
}
