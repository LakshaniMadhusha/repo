import SwiftUI
import SwiftData

struct BookManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Book.title) private var books: [Book]

    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(books) { book in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(book.title)
                            .foregroundColor(.textPrimary)
                        Text("\(book.author) • \(book.genre)")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
                .onDelete(perform: delete)
            }
            .scrollContentBackground(.hidden)
            .background(Color.pageBg)
            .navigationTitle("Books")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddBookView()
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for idx in offsets {
            modelContext.delete(books[idx])
        }
        try? modelContext.save()
    }
}

