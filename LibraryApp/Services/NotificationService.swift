import Foundation
import UserNotifications
import SwiftData

class NotificationService {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()

    private init() {}

    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }

    func scheduleDueDateReminder(for loan: Loan, daysBefore: Int = 1) {
        guard let dueDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: loan.dueAt) else { return }

        let content = UNMutableNotificationContent()
        content.title = "Book Due Soon"
        content.body = "\"\(loan.book?.title ?? "Your book")\" is due in \(daysBefore) day(s)."
        content.sound = .default
        content.categoryIdentifier = "DUE_REMINDER"

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: "due-\(loan.id.uuidString)", content: content, trigger: trigger)
        center.add(request) { error in
            if let error = error {
                print("Error scheduling due reminder: \(error)")
            }
        }
    }

    func schedulePickupAlert(for reservation: Reservation) {
        let content = UNMutableNotificationContent()
        content.title = "Book Ready for Pickup"
        content.body = "\"\(reservation.book?.title ?? "Your reserved book")\" is now available for pickup."
        content.sound = .default
        content.categoryIdentifier = "PICKUP_ALERT"

        // Schedule immediately for demo; in real app, schedule when status changes
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(identifier: "pickup-\(reservation.id.uuidString)", content: content, trigger: trigger)
        center.add(request) { error in
            if let error = error {
                print("Error scheduling pickup alert: \(error)")
            }
        }
    }

    func scheduleSeatConfirmation(for reservation: Reservation) {
        let content = UNMutableNotificationContent()
        content.title = "Seat Reservation Confirmed"
        content.body = "Your seat reservation has been confirmed. Enjoy your study session!"
        content.sound = .default
        content.categoryIdentifier = "SEAT_CONFIRMATION"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(identifier: "seat-\(reservation.id.uuidString)", content: content, trigger: trigger)
        center.add(request) { error in
            if let error = error {
                print("Error scheduling seat confirmation: \(error)")
            }
        }
    }

    func scheduleChallengeMilestone(userId: UUID, milestone: String) {
        let content = UNMutableNotificationContent()
        content.title = "Reading Challenge Milestone!"
        content.body = "Congratulations! You've reached: \(milestone)"
        content.sound = .default
        content.categoryIdentifier = "CHALLENGE_MILESTONE"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(identifier: "challenge-\(userId.uuidString)-\(UUID().uuidString)", content: content, trigger: trigger)
        center.add(request) { error in
            if let error = error {
                print("Error scheduling challenge milestone: \(error)")
            }
        }
    }

    func scheduleLibrarianAnnouncement(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default
        content.categoryIdentifier = "LIBRARIAN_ANNOUNCEMENT"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(identifier: "announcement-\(UUID().uuidString)", content: content, trigger: trigger)
        center.add(request) { error in
            if let error = error {
                print("Error scheduling announcement: \(error)")
            }
        }
    }

    func cancelNotification(for identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
}