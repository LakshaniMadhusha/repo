import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Query private var books: [Book]
    @Query private var loans: [Loan]
    @State private var showingAnnouncement = false
    @State private var announcementTitle = ""
    @State private var announcementMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    KPIGrid(books: books, loans: loans)
                        .lightCard()

                    CirculationChartView(loans: loans)
                        .lightCard()

                    Button("Send Announcement") {
                        showingAnnouncement = true
                    }
                    .buttonStyle(.primaryButton)
                    .padding(.horizontal, 20)
                }
                .padding(20)
            }
            .background(Color.pageBg.ignoresSafeArea())
            .navigationTitle("Dashboard")
            .sheet(isPresented: $showingAnnouncement) {
                VStack(spacing: 20) {
                    Text("Send Librarian Announcement")
                        .font(.headline)
                    TextField("Title", text: $announcementTitle)
                        .textFieldStyle(.roundedBorder)
                    TextField("Message", text: $announcementMessage)
                        .textFieldStyle(.roundedBorder)
                    Button("Send") {
                        NotificationService.shared.scheduleLibrarianAnnouncement(title: announcementTitle, message: announcementMessage)
                        showingAnnouncement = false
                        announcementTitle = ""
                        announcementMessage = ""
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
    }
}

private struct KPIGrid: View {
    let books: [Book]
    let loans: [Loan]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.headline)
                .foregroundColor(.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                KPICardView(title: "Total books", value: "\(books.count)", icon: "books.vertical.fill", tint: .primary)
                KPICardView(title: "Active loans", value: "\(loans.filter(\.isActive).count)", icon: "bookmark.fill", tint: .amber)
                KPICardView(title: "Overdue", value: "\(loans.filter(\.isOverdue).count)", icon: "exclamationmark.triangle.fill", tint: .coral)
                KPICardView(title: "Available", value: "\(books.filter { $0.status == .available }.count)", icon: "checkmark.seal.fill", tint: .teal)
            }
        }
        .padding(16)
    }
}

struct KPICardView: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(tint)
                Spacer()
            }
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .padding(14)
        .background(Color.surfaceBg)
        .cornerRadius(14)
    }
}

struct CirculationChartView: View {
    struct Bucket: Identifiable {
        let id = UUID()
        let day: Date
        let count: Int
    }

    let loans: [Loan]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Circulation (last 14 days)")
                .font(.headline)
                .foregroundColor(.textPrimary)

            Chart(buckets) { b in
                BarMark(
                    x: .value("Day", b.day, unit: .day),
                    y: .value("Loans", b.count)
                )
                .foregroundStyle(Color.accent)
                .cornerRadius(4)
            }
            .frame(height: 180)
        }
        .padding(16)
    }

    private var buckets: [Bucket] {
        let start = Calendar.current.date(byAdding: .day, value: -13, to: .now) ?? .now
        let days = (0..<14).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: start) }
        let grouped = Dictionary(grouping: loans) { loan in
            Calendar.current.startOfDay(for: loan.createdAt)
        }.mapValues { $0.count }

        return days.map { day in
            Bucket(day: day, count: grouped[Calendar.current.startOfDay(for: day)] ?? 0)
        }
    }
}

