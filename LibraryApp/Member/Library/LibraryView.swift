import SwiftUI
import SwiftData

struct LibraryView: View {
    @Query(sort: \Book.title) private var books: [Book]

    var body: some View {
        NavigationStack {
            Group {
                if books.isEmpty {
                    ContentUnavailableView("Library Empty", systemImage: "books.vertical", description: Text("You don't have any books added to your library yet."))
                } else {
                    List {
                        ForEach(books) { book in
                            BookRow(book: book)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.pageBg.ignoresSafeArea())
            .navigationTitle("Library")
        }
    }
}

