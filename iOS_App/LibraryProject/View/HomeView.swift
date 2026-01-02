import SwiftUI

struct HomeView: View {
    // MARK: - View Model
    @StateObject var viewModel = HomeViewModel()
    
    // MARK: - Navigation State
    @State private var isShowingNewBookSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                VStack {
                    if viewModel.isLoading && viewModel.books.isEmpty {
                        Spacer()
                        ProgressView("Loading Library...")
                            .scaleEffect(1.2)
                        Spacer()
                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.red)
                            Text(error)
                                .multilineTextAlignment(.center)
                            Button("Try Again") {
                                Task { await viewModel.fetchAllData() }
                            }
                        }
                        .padding()
                    } else {
                        // MARK: - Book List (Scrollable)
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.books) { book in
                                    // Navigation to Detail View
                                    NavigationLink {
                                        DetailView(viewModel: DetailViewModel(
                                            book: book,
                                            categories: viewModel.categories,
                                            isNew: false
                                        ))
                                        .onDisappear {
                                            // Refresh list when returning from detail view
                                            Task { await viewModel.fetchAllData() }
                                        }
                                    } label: {
                                        // Customized Modern Card View
                                        ModernBookCard(book: book)
                                    }
                                    .buttonStyle(PlainButtonStyle()) // Simplifies click effect
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Library")
            // MARK: - Search Bar
            .searchable(text: $viewModel.searchText, prompt: "Search by title or author...")
            .onChange(of: viewModel.searchText) { _, newValue in
                Task { await viewModel.searchBooks() }
            }
            // MARK: - Toolbar
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isShowingNewBookSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            // MARK: - Add New Book (Sheet)
            .sheet(isPresented: $isShowingNewBookSheet) {
                DetailView(viewModel: DetailViewModel(
                    categories: viewModel.categories,
                    isNew: true
                ))
                .onDisappear {
                    Task { await viewModel.fetchAllData() }
                }
            }
            // MARK: - Life Cycle and Refresh
            .onAppear {
                Task { await viewModel.fetchAllData() }
            }
            .refreshable {
                await viewModel.fetchAllData()
            }
        }
    }
}

// MARK: - Modern Book Card Component
struct ModernBookCard: View {
    let book: Book
    
    var body: some View {
        HStack(spacing: 15) {
            // Book Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 55, height: 75)
                
                Image(systemName: "book.closed.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let category = book.categoryName {
                    Text(category)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
