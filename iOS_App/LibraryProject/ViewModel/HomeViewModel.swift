import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    // ObservableObject, View'in bu sınıftaki değişiklikleri takip etmesini sağlar.
    
    // MARK: - Published Veriler (View'e yansıyan durumlar)
    @Published var books: [Book] = []          // Listelenen kitaplar
    @Published var categories: [Category] = []  // Filtreleme için tüm kategoriler
    @Published var searchText: String = ""      // Arama kutusundaki metin
    @Published var isLoading: Bool = false      // Yükleme durumu
    @Published var errorMessage: String?        // Hata mesajı
    
    // MARK: - Servis
    private let apiService = APIService()
    
    // MARK: - Initialization
    init() {
        Task {
            // ViewModel oluşturulur oluşturulmaz verileri çekmeye başla
            await fetchAllData()
        }
    }
    
    // MARK: - Veri Çekme İşlemleri
    
    // Tüm kitapları ve kategorileri çeker
    func fetchAllData() async {
        isLoading = true //Kullanıcıya verilerin yüklendiğini bildirmek için ekranda bir yükleme göstergesi (ProgressView/Spinner) tetiklenir.
        errorMessage = nil //Eğer ekranda önceden kalmış bir hata mesajı varsa, yeni işlem başladığı için bu mesaj temizlenir.
        
        do {
            // Kitapları ve Kategorileri eş zamanlı çek Tuple şeklinde (Performans için)
            let (fetchedBooks, fetchedCategories) = try await (
                apiService.fetchBooks(searchTerm: searchText),
                apiService.fetchCategories()
            )
                        
            self.books = fetchedBooks //İnternetten gelen taze veriler, ViewModel'deki asıl listeye aktarılır ve SwiftUI ekranı anında güncellenir.
            self.categories = fetchedCategories
            self.isLoading = false //Veriler geldiği için ekrandaki yükleme çarkı gizlenir.
            
            
        } catch {
            self.errorMessage = "Fetching failed: \(error.localizedDescription)" //Hata mesajını yazdırır
            self.isLoading = false
        }
    }
    
    // Arama kutusu değiştiğinde tetiklenir
    func searchBooks() async {
        // Hızlı yazma sırasında her karakterde API'yi çağırmamak için küçük bir gecikme ekleyebiliriz (Debounce)
        // Ancak bu basit örnekte direkt çağıracağız.
        
        isLoading = true
        errorMessage = nil
        
        do {
            // API'yi güncel searchText ile çağır
            let fetchedBooks = try await apiService.fetchBooks(searchTerm: searchText)
            self.books = fetchedBooks
            self.isLoading = false
            
        } catch {
            self.errorMessage = "Search failed: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    // Silme işlemi (DetailView'dan sonra HomeView'un veriyi güncellemesi için de kullanılır)
    func deleteBook(id: String) async -> Bool {
        do {
            try await apiService.deleteBook(id: id)
            // Başarılı silme sonrası listeyi yenile
            await fetchAllData()
            return true
        } catch {
            self.errorMessage = "Deleting failed: \(error.localizedDescription)"
            return false
        }
    }
}
