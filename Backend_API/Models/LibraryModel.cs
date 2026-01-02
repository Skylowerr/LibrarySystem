using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System.ComponentModel.DataAnnotations; // [Required] hatasını çözer
using System.Text.Json.Serialization;       // [JsonIgnore] ve JsonIgnoreCondition hatasını çözer

namespace LibraryAPI.Models;

public class Category
{
    [BsonId]  //Matches the ID (between mongodb and in my code)
    [BsonRepresentation(BsonType.ObjectId)] //MongoDB ObjectID -> string format

    public string? Id { get; set; } = null; 

    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int YearEstablished { get; set; } = 0;
}
 
public class Book
    {
        // MongoDB ObjectId'si
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; } = string.Empty;

        [Required]
        public string Title { get; set; } = string.Empty;
        
        [Required]
        public string Author { get; set; } = string.Empty;
        
        public string? ISBN { get; set; } 
        
        // Home Screen verisi. Kitabın kütüphanede mevcut olup olmadığını gösterir.
        [BsonElement("isAvailable")] //C# IsAvailable ->MongoDB isAvailable
        public bool IsAvailable { get; set; } = true;
        
        // İlişki Alanı: Categories koleksiyonundaki Id'ye işaret eder.
        [BsonRepresentation(BsonType.ObjectId)]
        
        public string CategoryID { get; set; } = string.Empty; //null! dene olmazsa

        /*
        CategoryName alanı bizim veritabanımızdaki Books koleksiyonunda fiziksel olarak bulunmuyor. Bu alanı sadece API seviyesinde geçici bir taşıyıcı olarak kullanıyoruz.
        Buradaki [BsonIgnore] etiketi, MongoDB'ye bu alanı veritabanına kaydetmemesini söyler
        */
        [BsonIgnore] 
        // JSON çıktısında CategoryName null ise göstermez (temiz çıktı).
        [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
        public string? CategoryName { get; set; }
    }
