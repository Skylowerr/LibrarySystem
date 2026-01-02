namespace LibraryAPI.Models;

public class LibraryDatabaseSettings
{
    public string ConnectionString { get; set; } = string.Empty;
    public string DatabaseName { get; set; } = string.Empty;
    public string BooksCollectionName { get; set; } = string.Empty;
    public string CategoriesCollectionName { get; set; } = string.Empty;
}
