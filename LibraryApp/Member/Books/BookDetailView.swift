import SwiftUI
import SwiftData

struct BookDetailView: View {
    let book: Book

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Presentation
                ZStack(alignment: .bottom) {
                    if let urlString = book.coverUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity, maxHeight: 350)
                                    .clipped()
                                    .blur(radius: 8)
                            default:
                                LinearGradient(colors: [.purple, .indigo], startPoint: .top, endPoint: .bottom)
                            }
                        }
                    } else {
                        LinearGradient(colors: [.purple, .indigo], startPoint: .top, endPoint: .bottom)
                            .frame(height: 350)
                    }
                    
                    // Gradient mask for ambient transition
                    LinearGradient(colors: [.clear, Color(UIColor.systemBackground)], startPoint: .top, endPoint: .bottom)
                        .frame(height: 200)
                    
                    BookCoverCard(book: book, width: 150, height: 220)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 10)
                        .offset(y: 50)
                }
                .frame(height: 350)
                .padding(.bottom, 60)
                
                // Metadata
                VStack(spacing: 8) {
                    Text(book.title)
                        .font(.title2.weight(.bold))
                        .multilineTextAlignment(.center)
                    
                    Text(book.author)
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text(book.genre.uppercased())
                        .font(.caption2.weight(.heavy))
                        .foregroundColor(.purple)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 12)
                        .background(Color.purple.opacity(0.15))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 24)
                
                // Synopsis placeholder & explicit Read Action
                VStack(alignment: .leading, spacing: 16) {
                    Text("About this Book")
                        .font(.headline)
                    
                    Text("A captivating masterpiece combining classic literature themes into a compelling modern narrative.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                
                Spacer(minLength: 40)
                
                // Read Button
                let urlToLoad = book.pdfUrl ?? "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"
                if let url = URL(string: urlToLoad) {
                    NavigationLink {
                        EBookWebView(url: url)
                            .navigationTitle(book.title)
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        HStack {
                            Image(systemName: "book.pages.fill")
                            Text("Read E-Book")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
    }
}
