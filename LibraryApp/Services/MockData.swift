import Foundation
import SwiftData

enum MockData {
    @MainActor
    static func seedIfNeeded(modelContext: ModelContext) throws {
        let existingUsers = try modelContext.fetchCount(FetchDescriptor<AppUser>())
        guard existingUsers == 0 else { return }

        let member = AppUser(name: "Sarah Evans", email: "sarah@library.com", role: .member)
        let librarian = AppUser(name: "Mike Johnson", email: "mike@library.com", role: .librarian)

        let books: [Book] = [
            Book(title: "Tick Tack", author: "James R.", genre: "Thriller", status: .onLoan, rating: 4.5),
            Book(title: "The Big Empty", author: "Sarah M.", genre: "Fiction", status: .available, rating: 4.2),
            Book(title: "Robert Craig", author: "R. Craig", genre: "Mystery", status: .available, rating: 4.7),
            Book(title: "Don't Blink", author: "K. Patterson", genre: "Thriller", status: .reserved, rating: 4.3),
        ]

        let hall = Hall(name: "Reading Room A", floor: 1, seats: generateSeats(rows: 5, cols: 8))

        modelContext.insert(member)
        modelContext.insert(librarian)
        books.forEach(modelContext.insert)
        modelContext.insert(hall)

        // Seed a few reading sessions for charts
        for daysAgo in 0..<14 {
            let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now) ?? .now
            let minutes = Int.random(in: 10...75)
            let session = ReadingSession(startedAt: date, minutes: minutes, userId: member.id)
            session.user = member
            session.book = books.randomElement()
            modelContext.insert(session)
        }

        // Seed an active loan
        let due = Calendar.current.date(byAdding: .day, value: 6, to: .now) ?? .now
        let loan = Loan(dueAt: due)
        loan.user = member
        loan.book = books.first
        modelContext.insert(loan)

        try modelContext.save()
    }

    private static func generateSeats(rows: Int, cols: Int) -> [Seat] {
        var seats: [Seat] = []
        for row in 0..<rows {
            for col in 0..<cols {
                let label = "\(Character(UnicodeScalar(65 + row)!))\(col + 1)"
                let status: SeatStatus = [.available, .available, .available, .occupied, .reserved].randomElement() ?? .available
                seats.append(Seat(label: label, row: row, column: col, status: status))
            }
        }
        return seats
    }
}

