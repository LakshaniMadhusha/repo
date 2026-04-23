import SwiftUI
import SwiftData

struct AddBookView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var author = ""
    @State private var genre = ""
    @State private var coverUrl = ""
    @State private var pdfUrl = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Cover Preview
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.secondarySystemBackground))
                            .frame(width: 140, height: 210)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        if let url = URL(string: coverUrl), !coverUrl.isEmpty {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 140, height: 210)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                case .failure(_):
                                    FallbackPreview()
                                @unknown default:
                                    FallbackPreview()
                                }
                            }
                        } else {
                            FallbackPreview()
                        }
                    }
                    .padding(.top, 20)

                    VStack(spacing: 16) {
                        TextField("Title", text: $title).inputStyle()
                        TextField("Author", text: $author).inputStyle()
                        TextField("Genre (e.g., Fiction, Comics)", text: $genre).inputStyle()
                        TextField("Cover Image URL(Google Image Link)", text: $coverUrl)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .inputStyle()
                        TextField("E-Book PDF Link (Optional)", text: $pdfUrl)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .inputStyle()

                        Button(action: {
                            let finalUrl = coverUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : coverUrl
                            let finalPdf = pdfUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : pdfUrl
                            let book = Book(title: title, author: author, genre: genre, status: .available, rating: 0, coverUrl: finalUrl, pdfUrl: finalPdf)
                            modelContext.insert(book)
                            try? modelContext.save()
                            
                            // Push simultaneously to the Firebase Cloud via our new Daemon Engine!
                            FirebaseSyncService.shared.pushBookToCloud(book)
                            
                            dismiss()
                        }) {
                            Text("Add Book")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing)
                                )
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(title.isEmpty ? 0.6 : 1.0)
                    }
                    .padding(20)
                }
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Add book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.purple)
                }
            }
        }
    }
}

fileprivate struct FallbackPreview: View {
    var body: some View {
        VStack {
            Image(systemName: "photo")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("No Cover Image")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
    }
}
