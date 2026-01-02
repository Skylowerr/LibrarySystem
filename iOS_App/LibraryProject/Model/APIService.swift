import Foundation

// MARK: - Hata Yönetimi
enum APIError: Error {
    case invalidURL //URL adresi hatalıysa
    case invalidID //MongoDB ID'si boş veya geçersizse
    case failedToCreate //CR
    case failedToUpdate //U
    case failedToDelete //D
    case invalidServerResponse //sunucudan hata kodu dönerse
    case unknown // Idk
}

class APIService: ObservableObject {
    
    private let baseURL = "https://vigilant-space-trout-j7gj7ggpvqwfp574-5075.app.github.dev/api"
    //Bu URL'nin sonuna ekleyerek gidecegiz
    
    //Sunucudan gelen karmaşık JSON verisini (Data), Swift modellerine (Book veya Category) dönüştüren genel bir fonksiyondur
    private func decode<T: Decodable>(data: Data, type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return try decoder.decode(type, from: data)
    }
    
    // =========================================================
    // GET (Listeleme ve Arama)
    // =========================================================
    
    //Ana ekrandaki kitap listesini getirir.Eğer arama kutusuna bir şey yazılırsa, URL'nin sonuna ?searchTerm=... ekleyerek C# tarafındaki Text Index aramasını tetikler.
    func fetchBooks(searchTerm: String = "") async throws -> [Book] {
        var urlString = "\(baseURL)/books"
        
        if !searchTerm.isEmpty {
            let encodedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            urlString += "?searchTerm=\(encodedTerm)"
        }
        
        guard let url = URL(string: urlString) else { throw APIError.invalidURL }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try decode(data: data, type: [Book].self)
    }
    
    func fetchCategories() async throws -> [Category] {
        guard let url = URL(string: "\(baseURL)/categories") else { throw APIError.invalidURL }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try decode(data: data, type: [Category].self)
    }
    
    // =========================================================
    // GET Kategori ID ile
    // =========================================================
    func fetchCategory(id: String) async throws -> Category {
        let cleanID = id.trimmingCharacters(in: .whitespacesAndNewlines)
        // ID boşsa hiç istek atma, direkt hata fırlat
        guard !cleanID.isEmpty else { throw APIError.invalidID }
        
        guard let url = URL(string: "\(baseURL)/categories/\(cleanID)") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidServerResponse
        }
        
        //Kategori çekerken sunucu ne dönüyor diye
        print("DEBUG Kategori Yanıt Kodu: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode != 200 {
            throw APIError.invalidServerResponse
        }
        
        return try JSONDecoder().decode(Category.self, from: data)
    }
    
    // =========================================================
    // CRUD Metotları
    // =========================================================
    
    func createBook(book: Book) async throws {
        guard let url = URL(string: "\(baseURL)/books") else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var bookWithoutID = book
        bookWithoutID.id = nil //MongoDB'ye yeni bir kayıt gönderirken ID göndermeyiz çünkü ID'yi MongoDB kendi içinde otomatik (ObjectId) olarak oluşturur.
        
        let jsonData = try JSONEncoder().encode(bookWithoutID)
        let (_, response) = try await URLSession.shared.upload(for: request, from: jsonData)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw APIError.failedToCreate
        }
    }
    
    func updateBook(book: Book) async throws {
        guard let id = book.id, !id.isEmpty else { throw APIError.invalidID }
        
        let urlString = "\(baseURL)/books/\(id)"
        guard let url = URL(string: urlString) else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try JSONEncoder().encode(book)
        
        let (_, response) = try await URLSession.shared.upload(for: request, from: jsonData)
        
        guard let httpResponse = response as? HTTPURLResponse,
              //Güncelleme (PUT) işlemlerinde sunucular genellikle ya 200 (OK) ya da 204 (No Content) döner
              (200...204).contains(httpResponse.statusCode) else {
            throw APIError.failedToUpdate
        }
    }
    
    func deleteBook(id: String) async throws {
        let cleanID = id.trimmingCharacters(in: .whitespacesAndNewlines)
        let urlString = "\(baseURL)/books/\(cleanID)"
        
        guard let url = URL(string: urlString) else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidServerResponse
        }
        
        print("DEBUG: Backend'den gelen yanıt kodu -> \(httpResponse.statusCode)")
        // 200 ile 299 arasındaki tüm kodlar başarılı kabul edilir
        guard (200...299).contains(httpResponse.statusCode) else {
            print("DEBUG: Silme başarısız. Hata kodu: \(httpResponse.statusCode)")
            throw APIError.failedToDelete
        }
        print("Swift kısmı başarılı")
    }
}
