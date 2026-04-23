import SwiftUI

struct ProfileView: View {
    @Environment(AuthService.self) private var auth
    @Environment(\.modelContext) private var modelContext
    let user: AppUser
    @State private var biometricToggle: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.surfaceBg)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Text(user.name.prefix(1))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.accent)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.name)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.textPrimary)
                            
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(footer: Text("Uses Face ID / Touch ID with passcode fallback.")) {
                    Toggle(isOn: $biometricToggle) {
                        Label("Require Authentication", systemImage: "faceid")
                            .foregroundColor(.textPrimary)
                    }
                    .tint(.accent)
                    .onChange(of: biometricToggle) { _, newValue in
                        auth.setBiometricEnabled(newValue, for: user, modelContext: modelContext)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        auth.signOut()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Sign out")
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.pageBg.ignoresSafeArea())
            .navigationTitle("Profile")
        }
        .onAppear { biometricToggle = user.isBiometricEnabled }
    }
}

