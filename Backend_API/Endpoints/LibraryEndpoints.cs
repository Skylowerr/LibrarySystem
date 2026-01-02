using LibraryAPI.Models;
using LibraryAPI.Services;

using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc; 

namespace LibraryAPI.Endpoints;

public static class LibraryEndpoints
{
    private static string booksRoute = "/api/books";
    private static string categoriesRoute = "/api/categories";

    public static IEndpointRouteBuilder MapLibraryEndpoints(this IEndpointRouteBuilder routes)
    {
        // =========================================================
        // A. KİTAP UÇ NOKTALARI (Home ve Details Ekranları için CRUD)
        // =========================================================
        var booksGroup = routes.MapGroup(booksRoute);

        booksGroup.MapGet("/", async (LibraryService service, [FromQuery] string? searchTerm) =>
        {
            // Service'deki GetBooksAsync metodu, searchTerm'i kullanarak ya tamamını ya da filtrelenmiş listeyi döner.
            var list = await service.GetBooksAsync(searchTerm);
            return Results.Ok(list);
        });

        // GET: Tek Bir Kitap Detayını Getir (Details Screen)
        booksGroup.MapGet("/{id}", async (LibraryService service, string id) =>
        {
            var book = await service.GetBookDetailsAsync(id);
            
            if (book is null)
                return Results.NotFound($"ID '{id}' ile kitap bulunamadı.");
                
            return Results.Ok(book);
        });

        // POST: Yeni Kitap Ekle (Details Screen -> New Button)
        booksGroup.MapPost("/", async (LibraryService service, Book newBook) =>
        {
            // MongoDB Id'si, CreateAsync metodu içinde atanacaktır.
            await service.CreateAsync(newBook);
            
            // Başarılı yanıt, oluşturulan kaynağın URL'sini döndürür.
            return Results.Created($"{booksRoute}/{newBook.Id}", newBook);
        });

        //  PUT: Kitap Güncelle (Details Screen -> Edit Butonu)
        booksGroup.MapPut("/{id}", async (LibraryService service, string id, Book updatedBook) =>
        {
            var existingBook = await service.GetBookDetailsAsync(id);

            if (existingBook is null)
                return Results.NotFound($"ID '{id}' ile kitap bulunamadı.");

            // Gelen nesneye ID'yi set et.
            updatedBook.Id = id; 

            await service.UpdateAsync(id, updatedBook);
            return Results.NoContent(); // Başarılı güncelleme için 204 No Content döndürülür.
        });

        // 5. DELETE: Kitap Sil (Details Screen -> Delete Butonu)
        booksGroup.MapDelete("/{id}", async (LibraryService service, string id) =>
        {
            var book = await service.GetBookDetailsAsync(id);

            if (book is null)
                return Results.NotFound();

            await service.RemoveAsync(id);
            return Results.NoContent(); // Başarılı silme için 204 No Content döndürülür.
        });


        var categoriesGroup = routes.MapGroup(categoriesRoute);

        categoriesGroup.MapGet("/", async (LibraryService service) =>
        {
            var list = await service.GetCategoriesAsync();
            return Results.Ok(list);
        }); 
        categoriesGroup.MapGet("/{id}", async (string id, LibraryService service) =>
        {
            var category = await service.GetCategoryAsync(id);
            
            // Eğer kategori yoksa boş bir obje dön ki Swift çökmesin
            if (category == null) {
                return Results.NotFound(new { message = "Category couldn't found" });
            }
            
            return Results.Ok(category);
        });


        // KATEGORILER
        categoriesGroup.MapPost("/", async (LibraryService service, Category newCategory) =>
        {
            await service.CreateCategoryAsync(newCategory);
            return Results.Created($"{categoriesRoute}/{newCategory.Id}", newCategory);
        });

        // PUT: Kategori Güncelle
        categoriesGroup.MapPut("/{id}", async (LibraryService service, string id, Category updatedCategory) =>
        {
            var existingCategory = await service.GetCategoryAsync(id);
            if (existingCategory is null) return Results.NotFound();

            updatedCategory.Id = id; 
            await service.UpdateCategoryAsync(id, updatedCategory);
            return Results.NoContent();
        });

        // DELETE: Kategori Sil
        categoriesGroup.MapDelete("/{id}", async (LibraryService service, string id) =>
        {
            var existingCategory = await service.GetCategoryAsync(id);
            if (existingCategory is null) return Results.NotFound();

            await service.RemoveCategoryAsync(id);
            return Results.NoContent();
        });
        

        return routes;
    }
}
