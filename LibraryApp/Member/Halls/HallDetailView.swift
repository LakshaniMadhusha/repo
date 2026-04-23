import SwiftUI
import SwiftData

struct HallDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedSeat: Seat?
    @State private var showingConfirmation = false

    let hall: Hall

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Select a seat")
                    .font(.headline)
                    .foregroundColor(.textPrimary)

                SeatGridView(seats: hall.seats, selectedSeat: $selectedSeat) { seat in
                    selectedSeat = seat
                }

                Button {
                    showingConfirmation = true
                } label: {
                    Text(selectedSeat == nil ? "Select a seat" : "Reserve \(selectedSeat?.label ?? "")")
                }
                .buttonStyle(.primaryButton)
                .disabled(selectedSeat == nil || selectedSeat?.status != .available)
            }
            .padding(20)
        }
        .background(Color.pageBg.ignoresSafeArea())
        .navigationTitle(hall.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingConfirmation) {
            BiometricReservationConfirmationView(
                seatLabel: selectedSeat?.label ?? "",
                onConfirmAuthenticated: { reserveSelected() }
            )
        }
    }

    private func reserveSelected() {
        guard let selectedSeat else { return }
        selectedSeat.status = .reserved
        selectedSeat.reservedUntil = Calendar.current.date(byAdding: .hour, value: 2, to: .now)
        try? modelContext.save()
    }
}

