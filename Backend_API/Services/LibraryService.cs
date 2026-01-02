using MongoDB.Driver;
using Microsoft.Extensions.Options;
using LibraryAPI.Models;

namespace LibraryAPI.Services;

public class LibraryService
{
    private readonly IMongoCollection<Book> booksCollection;
    private readonly IMongoCollection<Category> categoriesCollection;

    // Constructor: Dependency Injection ile ayarları alır ve koleksiyonları başlatır.
    public LibraryService(IOptions<LibraryDatabaseSettings> settings)
    {
        var client = new MongoClient(settings.Value.ConnectionString);
        var db = client.GetDatabase(settings.Value.DatabaseName); 
        
        booksCollection = db.GetCollection<Book>(settings.Value.BooksCollectionName); //Veritabanı içindeki Books tablosuna (koleksiyonuna) erişir ve bu tablodaki her bir dokümanın C# tarafındaki Book modeliyle eşleşeceğini belirtir.
        categoriesCollection = db.GetCollection<Category>(settings.Value.CategoriesCollectionName); 
    }

    // =================================================================
    // CRUD ve Arama
    // =================================================================

    // GET: Tüm kitapları getirir VEYA arama terimine göre filtreler (Home Screen)
    public async Task<List<Book>> GetBooksAsync(string? searchTerm = null) //Parameters can be empty
    {
        if (string.IsNullOrWhiteSpace(searchTerm))
        {
            return await booksCollection.Find(item => true).ToListAsync(); //return all books
        }

        // Text Index kullanarak arama yapma (Title ve Author)
        var filter = Builders<Book>.Filter.Text(searchTerm); //MongoDB'ye daha önce tanımladığımız "Text Index" (Title ve Author alanları) üzerinde bir arama filtresi hazırlar.
        return await booksCollection.Find(filter).ToListAsync(); //hazırlanan filtreyi kullanarak veritabanında arama yapar ve sadece eşleşen kitapları döndürür
    }


    // GET: Tek bir kitabın detaylarını getirir ve Kategori adını ilişkilendirir.
    public async Task<Book?> GetBookDetailsAsync(string id)
    {
        var book = await booksCollection.Find(x => x.Id == id).FirstOrDefaultAsync(); //Books koleksiyonunda, gönderilen id ile eşleşen ilk kitabı arar.

        if (book != null && !string.IsNullOrWhiteSpace(book.CategoryID)) // Kitap bulunduysa
        {
            // İlişkili Kategori verisini çek (Lookup / Join operasyonu)
            var category = await categoriesCollection
                .Find(c => c.Id == book.CategoryID) //Kitabın içindeki CategoryID değerini alır ve bu kez Categories koleksiyonuna giderek bu ID'ye sahip olan kategoriyi arar.
                .FirstOrDefaultAsync();
            
            book.CategoryName = category?.Name; //kategorinin ismini kitabın içindeki geçici CategoryName alanına yazar.
        }

        return book;
    }
    
    //POST: Yeni kitap ekler (NEW Butonu)
    public async Task CreateAsync(Book newBook) =>
        await booksCollection.InsertOneAsync(newBook);

    // PUT: Kitabı güncelle (Edit Butonu)
    public async Task UpdateAsync(string id, Book updatedBook) =>
        await booksCollection.ReplaceOneAsync(x => x.Id == id, updatedBook);

    //DELETE: Kitabı Siler (Delete Butonu)
    // public async Task RemoveAsync(string id) =>
    //     await booksCollection.DeleteOneAsync(x => x.Id == id);
    public async Task RemoveAsync(string id)
    {
        var cleanId = id.Trim();
        await booksCollection.DeleteOneAsync(x => x.Id == cleanId);
    }

    // =================================================================
    // KATEGORİ OPERASYONLARI (Form Doldurma İçin)
    // =================================================================

    // GET: Yeni kitap ekleme/düzenleme formunda kullanılmak üzere tüm kategorileri getirir.
    public async Task<List<Category>> GetCategoriesAsync() =>
        await categoriesCollection.Find(item => true).ToListAsync();

    // LibraryService.cs dosyasında, GetCategoryAsync metodunu bulun ve değiştirin:

//Bu kısım, kitabın detay sayfasındaki o boş "Kategori Adı" alanını veritabanından gelen gerçek verilerle doldurmaya yarayan köprüdür. Bu köprüyü kurmazsan iki koleksiyon arasındaki bağ kopuk kalır.
    public async Task<Category?> GetCategoryAsync(string id)
    {
        var cleanId = id.Trim();
        
        // MongoDB'deki 'Categories' koleksiyonunda bu ID'yi ara ve bulduğun ilk sonucu getir
        return await categoriesCollection
            .Find(x => x.Id == cleanId)
            .FirstOrDefaultAsync();
    }

}
