import Foundation

@MainActor // Ensures UI updates are performed on the main thread
class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    // 1. Fetch Categories
    func fetchCategories() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetching categories via APIService.shared
            let fetchedCategories = try await APIService.shared.fetchCategories()
            self.categories = fetchedCategories
        } catch {
            self.errorMessage = "Error while loading categories: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // 2. Add New Category
    func addCategory(name: String, description: String) async {
        guard !name.isEmpty else { return }
        
        let newCategory = Category(id: nil, name: name, description: description)
        
        do {
            let success = try await APIService.shared.addCategory(category: newCategory)
            if success {
                await fetchCategories() // Refresh the list after adding
            }
        } catch {
            self.errorMessage = "Category could not be added."
        }
    }
    
    // 3. Delete Category
    func deleteCategory(id: String) async {
        do {
            // Executing the delete request without a success variable
            try await APIService.shared.deleteCategory(id: id)
            
            // If the line above doesn't throw an error, proceed to remove locally
            self.categories.removeAll { $0.id == id }
        } catch {
            self.errorMessage = "Error while deleting category."
        }
    }
    
    // 4. Update Category
    func updateCategory(category: Category) async {
        isLoading = true
        do {
            try await APIService.shared.updateCategory(category: category)
            await fetchCategories() // Refresh to fetch the updated state
        } catch {
            self.errorMessage = "Error while updating category: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
