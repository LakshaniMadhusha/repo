import Foundation
import FirebaseFirestore
import SwiftData

@MainActor
final class FirebaseSyncService {
    static let shared = FirebaseSyncService()
    
    private let db = Firestore.firestore()
    private var isSyncing = false
    
    private init() {}
    
    func startSyncing(context: ModelContext) {
        guard !isSyncing else { return }
        isSyncing = true
        
        // 1. Listen to Books Collection
        db.collection("books").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            
            for doc in documents {
                let data = doc.data()
                guard let idString = data["id"] as? String,
                      let id = UUID(uuidString: idString) else { continue }
                
                // Check if book already exists in local DB
                let predicate = #Predicate<Book> { $0.id == id }
                let descriptor = FetchDescriptor<Book>(predicate: predicate)
                
                do {
                    let existingBooks = try context.fetch(descriptor)
                    if existingBooks.isEmpty {
                        // Create novel local SwiftData object securely
                        let rawStatus = data["status"] as? String ?? "Available"
                        let status = BookStatus(rawValue: rawStatus) ?? .available
                        
                        let newBook = Book(
                            id: id,
                            title: data["title"] as? String ?? "Unknown Title",
                            author: data["author"] as? String ?? "Unknown Author",
                            genre: data["genre"] as? String ?? "General",
                            status: status,
                            rating: data["rating"] as? Double ?? 0.0,
                            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? .now
                        )
                        context.insert(newBook)
                    }
                } catch {
                    print("FirebaseSyncService Error: \(error.localizedDescription)")
                }
            }
            try? context.save()
        }
    }
    
    // Abstract hook for pushing SwiftData mutations directly up into Cloud!
    func pushBookToCloud(_ book: Book) {
        let payload: [String: Any] = [
            "id": book.id.uuidString,
            "title": book.title,
            "author": book.author,
            "genre": book.genre,
            "status": book.status.rawValue,
            "rating": book.rating,
            "createdAt": Timestamp(date: book.createdAt)
        ]
        db.collection("books").document(book.id.uuidString).setData(payload)
    }
    
    // Abstract hook directly pushing User Registrations formally backwards securely!
    func updateUserInCloud(_ user: AppUser) {
        var payload: [String: Any] = [:]
        
        if let membershipId = user.membershipId { payload["membershipId"] = membershipId }
        if let phone = user.phoneNumber { payload["phoneNumber"] = phone }
        if let address = user.address { payload["address"] = address }
        
        guard !payload.isEmpty else { return }
        // Securely patch strictly the precise remote configuration logically mirroring the UID token without dumping original data
        db.collection("users").document(user.id.uuidString).setData(payload, merge: true)
    }
}
