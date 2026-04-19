Library Management System (Full-Stack)
This project was developed as a term project for my OOP course at University. It aims to demonstrate the integration between a modern iOS frontend and a robust .NET backend with a NoSQL database.

🚀 Project Overview
The Library Management System is a full-stack application that allows users to manage a book collection. It supports full CRUD (Create, Read, Update, Delete) operations and provides a dynamic, user-friendly mobile experience. 

🛠 Tech Stack
Frontend: SwiftUI (iOS) - MVVM Architecture

Backend: .NET 8 / C# Web API

Database: MongoDB

Communication: RESTful API with JSON

Version Control: Git & Sourcetree

✨ Key Features
Dynamic UI: Modern card-based design with SF Symbols integrated via smart category-based icons.

Category Management: Relational data handling between Books and Categories using categoryID lookups.

Search & Filter: Real-time search functionality to filter books by title or author.

Concurrency: Asynchronous data fetching using Swift's async/await and C# Task patterns.

Validation: Input validation on both client and server sides to ensure data integrity.

📂 Repository Structure
IOS_App/: Contains the SwiftUI source code, ViewModels, and API services.

Backend_API/: Contains the .NET 8 Web API, MongoDB configurations, and Controller logic.

⚙️ How to Run
Backend: Open the solution in Visual Studio, update your MongoDB connection string in appsettings.json, and run the API.

Frontend: Open the Xcode project, ensure the ApiService.swift file points to your server's IP address, and build for your preferred iOS simulator.
