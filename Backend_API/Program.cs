using LibraryAPI.Endpoints;  // StudentAPI.Endpoints yerine
using LibraryAPI.Models;     // StudentAPI.Models yerine
using LibraryAPI.Services;   // StudentAPI.Services yerine
//using LibraryAPI.Settings;   // Yeni ayarlar namespace'imiz

var builder = WebApplication.CreateBuilder(args);

// =========================================================
// MARK: Yapılandırma ve Servis Kaydı
// =========================================================

// StudentDatabaseSettings yerine LibraryDatabaseSettings kullanıldı.
// appsettings.json dosyasında "StudentDatabase" yerine "LibraryDatabaseSettings" kullanılmalı.
builder.Services.Configure<LibraryDatabaseSettings>(builder.Configuration.GetSection("LibraryDatabaseSettings"));

// StudentService yerine LibraryService kullanıldı.
builder.Services.AddSingleton<LibraryService>();

// Swagger ve Endpoint Explorer ekleniyor
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Öğrenme amaçlı yorum satırındaki OpenApi/Swagger kodları temizlendi.
// builder.Services.AddOpenApi();

var app = builder.Build();

// =========================================================
// HTTP İstek Ortamının Ayarları
// =========================================================

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    // app.MapOpenApi(); // Silindi
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// Öğrenci uç noktaları yerine Kütüphane uç noktaları haritalanıyor.
app.MapLibraryEndpoints();

// =========================================================
// DİĞER UÇ NOKTALAR (WeatherForecast)
// =========================================================

// Hava durumu örneği (Minimal API'nin default içeriği, bırakılabilir)
var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", () =>
{
    var forecast =  Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecast");

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}