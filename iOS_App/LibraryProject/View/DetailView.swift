import SwiftUI

struct DetailView: View {
    @StateObject var viewModel: DetailViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // MARK: - Header Section
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.2), .blue.opacity(0.05)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: viewModel.isNew ? "plus.circle.fill" : "book.closed.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                    }
                    
                    Text(viewModel.isNew ? "Add New Book" : viewModel.book.title)
                        .font(.system(.title2, design: .rounded).bold())
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 25)

                // MARK: - Input Information (Card Layout)
                VStack(spacing: 20) {
                    Group {
                        customTextField(title: "Book Title", text: $viewModel.book.title, icon: "text.book.closed.fill")
                        customTextField(title: "Author Name", text: $viewModel.book.author, icon: "person.crop.circle.fill")
                        customTextField(title: "ISBN Number", text: $viewModel.book.isbn, icon: "barcode.viewfinder")
                    }
                    
                    // Category Picker Card
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Category", systemImage: "line.3.horizontal.decrease.circle.fill")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        
                        Picker("Select Category", selection: $viewModel.selectedCategoryIndex) {
                            ForEach(0..<viewModel.categories.count, id: \.self) { index in
                                Text(viewModel.categories[index].name).tag(index)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(15)
                    }
                    
                    // Availability Toggle
                    HStack {
                        Label("Available for Loan", systemImage: "clock.fill")
                            .font(.headline.weight(.medium))
                        Spacer()
                        Toggle("", isOn: $viewModel.book.isAvailable)
                            .labelsHidden()
                            .tint(.green)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                }
                .padding(.horizontal)

                // MARK: - Action Buttons
                VStack(spacing: 15) {
                    // Save Button
                    Button {
                        Task {
                            if await viewModel.saveBook() {
                                dismiss()
                            }
                        }
                    } label: {
                        HStack {
                            if viewModel.isProcessing {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "checkmark.seal.fill")
                                Text(viewModel.isNew ? "Save Book" : "Update Details")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(viewModel.book.title.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(18)
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .disabled(viewModel.isProcessing || viewModel.book.title.isEmpty)

                    // Delete Button
                    if !viewModel.isNew {
                        Button {
                            showDeleteAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Remove from Library")
                            }
                            .font(.subheadline.bold())
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        
        // MARK: - Alerts
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "An unexpected error occurred.")
        }
        
        .alert("Are you sure?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    if await viewModel.deleteBook() {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("This action cannot be undone. This book will be permanently removed.")
        }
    }

    // MARK: - Custom Component: Styled TextField
    private func customTextField(title: String, text: Binding<String>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.caption.bold())
                .foregroundColor(.secondary)
            
            TextField("Enter \(title.lowercased())", text: text)
                .padding(.vertical, 15)
                .padding(.horizontal)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                )
        }
    }
}
