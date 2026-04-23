import Foundation
import SwiftData

enum UserRole: String, Codable, CaseIterable {
    case member = "Member"
    case librarian = "Librarian"
}

@Model
final class AppUser: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var email: String
    var password: String // Mandatory DB parameter
    var roleRaw: String
    var isBiometricEnabled: Bool
    
    // Core Registration Form Analytics
    var membershipId: String?
    var phoneNumber: String?
    var address: String?
    
    var createdAt: Date

    init(id: UUID = UUID(), name: String, email: String, password: String = "", role: UserRole, isBiometricEnabled: Bool = false, membershipId: String? = nil, phoneNumber: String? = nil, address: String? = nil, createdAt: Date = .now) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.roleRaw = role.rawValue
        self.isBiometricEnabled = isBiometricEnabled
        self.membershipId = membershipId
        self.phoneNumber = phoneNumber
        self.address = address
        self.createdAt = createdAt
    }

    var role: UserRole {
        get { UserRole(rawValue: roleRaw) ?? .member }
        set { roleRaw = newValue.rawValue }
    }
}

enum BookStatus: String, Codable, CaseIterable {
    case available = "Available"
    case reserved = "Reserved"
    case onLoan = "On Loan"
}

@Model
final class Book: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var author: String
    var genre: String
    var status: BookStatus
    var rating: Double
    var createdAt: Date

    init(id: UUID = UUID(), title: String, author: String, genre: String, status: BookStatus = .available, rating: Double = 0, createdAt: Date = .now) {
        self.id = id
        self.title = title
        self.author = author
        self.genre = genre
        self.status = status
        self.rating = rating
        self.createdAt = createdAt
    }
}

@Model
final class Loan: Identifiable {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var dueAt: Date
    var returnedAt: Date?

    var user: AppUser?
    var book: Book?

    init(id: UUID = UUID(), createdAt: Date = .now, dueAt: Date, returnedAt: Date? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.dueAt = dueAt
        self.returnedAt = returnedAt
    }

    var isActive: Bool { returnedAt == nil }
    var isOverdue: Bool { isActive && dueAt < .now }
}

enum ReservationStatus: String, Codable, CaseIterable {
    case pending = "Pending"
    case approved = "Approved"
    case cancelled = "Cancelled"
    case fulfilled = "Fulfilled"
}

@Model
final class Reservation: Identifiable {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var status: ReservationStatus

    var user: AppUser?
    var book: Book?

    init(id: UUID = UUID(), createdAt: Date = .now, status: ReservationStatus = .pending) {
        self.id = id
        self.createdAt = createdAt
        self.status = status
    }
}

enum SeatStatus: String, Codable, CaseIterable {
    case available = "Available"
    case occupied = "Occupied"
    case reserved = "Reserved"
}

@Model
final class Hall: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var floor: Int

    @Relationship(deleteRule: .cascade) var seats: [Seat]

    init(id: UUID = UUID(), name: String, floor: Int, seats: [Seat] = []) {
        self.id = id
        self.name = name
        self.floor = floor
        self.seats = seats
    }
}

@Model
final class Seat: Identifiable {
    @Attribute(.unique) var id: UUID
    var label: String
    var row: Int
    var column: Int
    var status: SeatStatus
    var reservedUntil: Date?

    init(id: UUID = UUID(), label: String, row: Int, column: Int, status: SeatStatus = .available, reservedUntil: Date? = nil) {
        self.id = id
        self.label = label
        self.row = row
        self.column = column
        self.status = status
        self.reservedUntil = reservedUntil
    }
}

@Model
final class ReadingSession: Identifiable {
    @Attribute(.unique) var id: UUID
    var startedAt: Date
    var minutes: Int
    var userId: UUID

    var user: AppUser?
    var book: Book?

    init(id: UUID = UUID(), startedAt: Date = .now, minutes: Int, userId: UUID) {
        self.id = id
        self.startedAt = startedAt
        self.minutes = minutes
        self.userId = userId
    }
}

@Model
final class Badge: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var earnedAt: Date

    var user: AppUser?

    init(id: UUID = UUID(), title: String, earnedAt: Date = .now) {
        self.id = id
        self.title = title
        self.earnedAt = earnedAt
    }
}

