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
    @State private var isbn = ""
    @State private var lookupMessage: String? = nil
    @State private var isLookingUp = false
    
    @State private var isShowingScanner = false
    @State private var scannedText = ""
    @State private var scanningField: ScanField? = nil
    
    enum ScanField {
        case title
        case isbn
    }

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
                    
                    VStack(spacing: 14) {
                        Text("Quick book entry")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 12) {
                            Button(action: {
                                scanningField = .title
                                isShowingScanner = true
                            }) {
                                Label("Scan Title", systemImage: "text.viewfinder")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.purple.opacity(0.25), lineWidth: 1)
                                    )
                            }

                            Button(action: {
                                scanningField = .isbn
                                isShowingScanner = true
                            }) {
                                Label("Scan ISBN", systemImage: "barcode.viewfinder")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.green.opacity(0.25), lineWidth: 1)
                                    )
                            }
                        }
                    }

                    VStack(spacing: 16) {
                        TextField("Title", text: $title).inputStyle()
                        TextField("Author", text: $author).inputStyle()
                        TextField("Genre (e.g., Fiction, Comics)", text: $genre).inputStyle()
                        HStack(spacing: 10) {
                            ForEach(["Fiction", "Comics", "Mystery", "Sci-Fi"], id: \.self) { option in
                                Button(option) {
                                    genre = option
                                }
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(genre == option ? Color.purple.opacity(0.18) : Color(UIColor.secondarySystemFill))
                                .foregroundColor(genre == option ? .purple : .primary)
                                .cornerRadius(12)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, -8)
                        
                        TextField("ISBN / Barcode", text: $isbn)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.asciiCapableNumberPad)
                            .inputStyle()
                        Button(action: {
                            Task { await autoFillFromISBN() }
                        }) {
                            Text(isLookingUp ? "Looking up..." : "Auto-fill from ISBN")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                        }
                        .disabled(isbn.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLookingUp)

                        if let lookupMessage {
                            Text(lookupMessage)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

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
        .onChange(of: scannedText) { _, newValue in
            guard !newValue.isEmpty else { return }

            switch scanningField {
            case .title:
                title = newValue
            case .isbn:
                isbn = newValue
                Task { await autoFillFromISBN() }
            case .none:
                break
            }
            scannedText = ""
        }
        .sheet(isPresented: $isShowingScanner) {
            DataScannerView(recognizedText: $scannedText)
                .ignoresSafeArea()
                .overlay(alignment: .bottom) {
                    Text(scanningField == .isbn ? "Tap the barcode or ISBN text" : "Tap a highlighted title")
                        .font(.headline)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding(.bottom, 40)
                }
        }
    }

    @MainActor
    private func autoFillFromISBN() async {
        lookupMessage = nil
        isLookingUp = true
        defer { isLookingUp = false }

        do {
            let metadata = try await BookLookupService().lookupISBN(isbn)
            if !metadata.title.isEmpty { title = metadata.title }
            if !metadata.author.isEmpty { author = metadata.author }
            if !metadata.genre.isEmpty { genre = metadata.genre }
            if let cover = metadata.coverUrl, !cover.isEmpty { coverUrl = cover }
            if let pdf = metadata.pdfUrl, !pdf.isEmpty { pdfUrl = pdf }
            lookupMessage = "Book details loaded from ISBN lookup."
        } catch {
            lookupMessage = (error as? LocalizedError)?.errorDescription ?? "Unable to fill details."
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
