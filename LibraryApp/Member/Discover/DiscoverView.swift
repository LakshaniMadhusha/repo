import SwiftUI
import SwiftData

struct DiscoverView: View {
    @Query(sort: \Book.createdAt, order: .reverse) private var books: [Book]
    @State private var vm = DiscoverViewModel()
    @StateObject private var speechRecognizer = SpeechRecognizer()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                if !vm.query.isEmpty {
                    VStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(vm.filteredBooks(from: books)) { book in
                                BookRow(book: book)
                            }
                            if vm.filteredBooks(from: books).isEmpty {
                                Text("No books found.")
                                    .foregroundColor(.textSecondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            }
                        }
                        .lightCard()
                    }
                    .padding(20)
                } else {
                    LazyVStack(spacing: 24) {
                        GenreCarousel(title: "New Arrivals & Coming Soon", books: Array(books.prefix(10)))
                        GenreCarousel(title: "Fictions", books: books.filter { $0.genre.localizedCaseInsensitiveContains("Fiction") })
                        GenreCarousel(title: "Literatures", books: books.filter { $0.genre.localizedCaseInsensitiveContains("Literature") })
                        GenreCarousel(title: "Comics", books: books.filter { $0.genre.localizedCaseInsensitiveContains("Comic") })
                        GenreCarousel(title: "Explore More", books: books.filter { 
                            !$0.genre.localizedCaseInsensitiveContains("Fiction") && 
                            !$0.genre.localizedCaseInsensitiveContains("Literature") && 
                            !$0.genre.localizedCaseInsensitiveContains("Comic") 
                        })
                    }
                    .padding(.vertical, 20)
                }
            }
            .background(Color.pageBg.ignoresSafeArea())
            .navigationTitle("Discover")
            .searchable(text: $vm.query, prompt: "Search books, authors, genres")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if speechRecognizer.isRecording {
                            speechRecognizer.stopTranscribing()
                        } else {
                            speechRecognizer.startTranscribing()
                        }
                    }) {
                        Image(systemName: speechRecognizer.isRecording ? "mic.fill" : "mic")
                            .foregroundColor(speechRecognizer.isRecording ? .red : .accent)
                            .font(.title3)
                    }
                }
            }
            .onChange(of: speechRecognizer.transcript) { newValue in
                vm.query = newValue
            }
        }
    }
}

struct GenreCarousel: View {
    let title: String
    let books: [Book]
    
    var body: some View {
        if !books.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, 20)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(books) { book in
                            BookCoverCard(book: book, width: 120, height: 180)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

