//
//  CategoryListView.swift
//  LibraryProject
//
//  Created by Emirhan Gökçe on 2.01.2026.
//

import SwiftUI

struct CategoryListView: View {
    @StateObject var viewModel = CategoryViewModel()
    @State private var isShowingAddSheet = false
    @State private var isShowingEditSheet = false
    @State private var selectedCategory: Category?
    
    @State private var name = ""
    @State private var description = ""

    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else {
                ForEach(viewModel.categories) { category in
                    VStack(alignment: .leading) {
                        Text(category.name).font(.headline)
                        Text(category.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .swipeActions(edge: .trailing) {
                        // Delete Button
                        Button(role: .destructive) {
                            if let id = category.id {
                                Task { await viewModel.deleteCategory(id: id) }
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        // Edit Button
                        Button {
                            selectedCategory = category
                            name = category.name
                            description = category.description
                            isShowingEditSheet = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.orange)
                    }
                }
            }
        }
        .navigationTitle("Categories")
        .toolbar {
            Button(action: { isShowingAddSheet = true }) {
                Image(systemName: "plus")
            }
        }
        // Add New Category Sheet
        .sheet(isPresented: $isShowingAddSheet) {
            CategoryEditView(title: "New Category", name: $name, description: $description) {
                Task {
                    await viewModel.addCategory(name: name, description: description)
                    resetFields()
                }
            }
        }
        // Edit Category Sheet
        .sheet(isPresented: $isShowingEditSheet) {
            CategoryEditView(title: "Edit Category", name: $name, description: $description) {
                if var updated = selectedCategory {
                    updated.name = name
                    updated.description = description
                    Task {
                        await viewModel.updateCategory(category: updated)
                        resetFields()
                    }
                }
            }
        }
        .onAppear { Task { await viewModel.fetchCategories() } }
    }
    
    private func resetFields() {
        name = ""
        description = ""
        isShowingAddSheet = false
        isShowingEditSheet = false
    }
}

// Reusable Edit View
struct CategoryEditView: View {
    let title: String
    @Binding var name: String
    @Binding var description: String
    var onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Category Name", text: $name)
                TextField("Description", text: $description)
            }
            .navigationTitle(title)
            .toolbar {
                Button("Save") { onSave() }
            }
        }
    }
}

#Preview {
    CategoryListView()
}
