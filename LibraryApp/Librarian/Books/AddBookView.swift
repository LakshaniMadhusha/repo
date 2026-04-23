import SwiftUI
import SwiftData

struct AddBookView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var author = ""
    @State private var genre = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                TextField("Title", text: $title).inputStyle()
                TextField("Author", text: $author).inputStyle()
                TextField("Genre", text: $genre).inputStyle()

                Button("Add Book") {
                    let book = Book(title: title, author: author, genre: genre, status: .available, rating: 0)
                    modelContext.insert(book)
                    try? modelContext.save()
                    
                    // Push simultaneously to the Firebase Cloud via our new Daemon Engine!
                    FirebaseSyncService.shared.pushBookToCloud(book)
                    
                    dismiss()
                }
                .buttonStyle(.primaryButton)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer()
            }
            .padding(20)
            .background(Color.pageBg.ignoresSafeArea())
            .navigationTitle("Add book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

