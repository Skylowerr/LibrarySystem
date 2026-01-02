import Foundation
import SwiftUI

// @MainActor: Bu sınıf içindeki tüm işlemlerin UI (ana) thread'de
// güvenli bir şekilde yapılmasını sağlar. Donma hatasını çözer.
@MainActor
class DetailViewModel: ObservableObject {
    
    // MARK: - Published Veriler
    @Published var book: Book
    @Published var isNew: Bool
    @Published var categories: [Category]
    @Published var errorMessage: String?
    @Published var isProcessing: Bool = false

    // MARK: - Helper Properties
    var navigationTitle: String { isNew ? "Add New Book" : "Edit Book" }
    
    var selectedCategoryIndex: Int {
        //Detay ekranı açıldığında, Picker'ın o anki kategoriyi (örneğin "Roman") seçili göstermesi için o kategorinin kaçıncı sırada (0, 1, 2...) olduğunu bilmesi gerekir
        get { categories.firstIndex(where: { $0.id == book.categoryID }) ?? 0 } //Kitabın içindeki categoryID'nin, tüm kategoriler listesinde (categories) kaçıncı sırada olduğunu bulur.Eğer kitabın kategorisi listede bulunamazsa (veya henüz atanmamışsa), varsayılan olarak listenin en başındaki (0. dizin) kategoriyi seçer.
        //Kullanıcı Picker üzerinden yeni bir kategori seçtiğinde (yani newValue değiştiğinde) çalışır.
        //Değiştirdiği veriler güncellenir
        set {
            book.categoryID = categories[newValue].id ?? ""
            book.categoryName = categories[newValue].name
        }
    }
    private let apiService = APIService()

    // MARK: - Initialization
    init(book: Book, categories: [Category], isNew: Bool) {
        self.book = book
        self.categories = categories
        self.isNew = isNew
        
        //Eğer kullanıcı mevcut bir kitaba tıklamışsa çalışır:
        if !isNew {
            // Task başlatıldığında artık MainActor garantisindeyiz
            Task {
                await fetchCategoryName()
            }
        }
    }
    
    //Yeni Ekle" diyince boş bir kitap oluşturmaya yarıyor
    convenience init(categories: [Category], isNew: Bool) {
        let initialCategoryName = categories.first?.name ?? "" //Pickerdaki ilk category'i çeker boş kalmasın diye
        let initialCategoryID = categories.first?.id ?? ""
        //It creates an empty template
        let initialBook = Book(
            id: nil,
            categoryID: initialCategoryID,
            title: "",
            author: "",
            isbn: "",
            isAvailable: true,
            categoryName: initialCategoryName
        )
        self.init(book: initialBook, categories: categories, isNew: isNew)
    }

    // MARK: - Kategori Çekme
    func fetchCategoryName() async {
        // ID içindeki gizli karakterleri temizler (Timeout hatasını engeller)
        let categoryId = book.categoryID.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !categoryId.isEmpty else {
            self.book.categoryName = "Uncategorized"
            return
        }

        do {
            let category = try await apiService.fetchCategory(id: categoryId) //APIService üzerinden C# tarafındaki /api/categories/{id} uç noktasına gider.
            // Başarılı olursa UI otomatik olarak güncellenir
            self.book.categoryName = category.name
            self.errorMessage = nil
            
        } catch {
            self.book.categoryName = "Could not load"
            // Hatanın detayını terminale basarız
            print("Category Error: \(error)")
        }
    }
    
    // MARK: - Kaydetme
    func saveBook() async -> Bool {
        //Kaydetmeden önce "Başlık boş mu?", "Yazar girilmiş mi?" gibi kontrolleri yapar
        guard validateInput() else { return false }
        self.isProcessing = true
        self.errorMessage = nil
        
        do {
            if isNew {
                try await apiService.createBook(book: book)
            } else {
                try await apiService.updateBook(book: book)
            }
            
            self.isProcessing = false //İşlem başarılı olduğunda yükleme durumu kapatılır
            return true
            
        } catch {
            self.errorMessage = "Saving Error: \(error.localizedDescription)"
            self.isProcessing = false
            return false
        }
    }
    
    // MARK: - Silme
    func deleteBook() async -> Bool {
        if isNew { return true } //Yeni oluşturulduysa API'ya gitmeye gerek kalmaz
        guard let id = book.id else { return false }
        
        self.isProcessing = true
        
        do {
            try await apiService.deleteBook(id: id)
            self.isProcessing = false
            return true
            
        } catch {
            self.errorMessage = "Deletion error: \(error.localizedDescription)"
            self.isProcessing = false
            return false
        }
    }
    
    private func validateInput() -> Bool {
        if book.title.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "The book title cannot be blank."
            return false
        }
        if book.author.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "The author name cannot be left blank."
            return false
        }
        return true
    }
}
