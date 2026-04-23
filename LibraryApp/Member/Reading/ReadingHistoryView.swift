import SwiftUI
import SwiftData

struct ReadingHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var sessions: [ReadingSession]
    
    init(userId: UUID) {
        self._sessions = Query(
            filter: #Predicate<ReadingSession> { $0.userId == userId },
            sort: [SortDescriptor(\.startedAt, order: .reverse)]
        )
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                if sessions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary.opacity(0.5))
                        Text("No Reading History")
                            .font(.title3.weight(.bold))
                        Text("Start a reading session from your dashboard to begin tracking your journey.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 100)
                } else {
                    LazyVStack(spacing: 24) {
                        // Group sessions by day
                        let grouped = Dictionary(grouping: sessions) { session in
                            Calendar.current.startOfDay(for: session.startedAt)
                        }
                        let sortedDays = grouped.keys.sorted(by: >)
                        
                        ForEach(sortedDays, id: \.self) { day in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(day.formatted(date: .complete, time: .omitted))
                                    .font(.subheadline.weight(.heavy))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 20)
                                
                                VStack(spacing: 12) {
                                    ForEach(grouped[day]!) { session in
                                        HStack(spacing: 16) {
                                            MiniCoverView(book: session.book)
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(session.book?.title ?? "Unknown Book")
                                                    .font(.headline)
                                                    .lineLimit(2)
                                                Text("Read for \(session.minutes) minutes")
                                                    .font(.subheadline)
                                                    .foregroundColor(.purple)
                                                Text(session.startedAt.formatted(date: .omitted, time: .shortened))
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            
                                            // Points earned
                                            VStack {
                                                Text("+\((session.minutes / 10) * 10)") // Adjust according to HomeViewModel logic natively!
                                                    .font(.caption.weight(.bold))
                                                    .foregroundColor(.orange)
                                                Text("Pts")
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(16)
                                        .background(Color(UIColor.secondarySystemBackground))
                                        .cornerRadius(16)
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Reading History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.purple)
                }
            }
        }
    }
}

fileprivate struct MiniCoverView: View {
    let book: Book?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.tertiarySystemGroupedBackground))
                .frame(width: 50, height: 75)
            
            if let book = book, let urlString = book.coverUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 75)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    default:
                        Image(systemName: "book.closed.fill")
                            .foregroundColor(.purple)
                    }
                }
            } else {
                Image(systemName: "book.closed.fill")
                    .foregroundColor(.purple)
            }
        }
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
