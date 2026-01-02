namespace LibraryAPI.Models; //TODO BAK! LibraryAPI.Settings olabilir.

//TODO: Hata çıkarsa null! yaz karşılarına
public class LibraryDatabaseSettings
{
    public string ConnectionString { get; set; } = string.Empty;
    public string DatabaseName { get; set; } = string.Empty;
    public string BooksCollectionName { get; set; } = string.Empty;
    public string CategoriesCollectionName { get; set; } = string.Empty;
}
