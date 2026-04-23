import SwiftUI

struct BookCoverCard: View {
    let book: Book
    let width: CGFloat
    let height: CGFloat
    
    init(book: Book, width: CGFloat = 120, height: CGFloat = 180) {
        self.book = book
        self.width = width
        self.height = height
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.surfaceBg)
                    .frame(width: width, height: height)
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                
                VStack(spacing: 4) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.accent)
                    
                    Text(book.title)
                        .font(.caption)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 8)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(book.title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                Text(book.author)
                    .font(.caption2)
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
            }
            .frame(width: width, alignment: .leading)
        }
    }
}
