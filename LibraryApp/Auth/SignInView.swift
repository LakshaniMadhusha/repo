import SwiftUI
import SwiftData
import LocalAuthentication

struct SignInView: View {
    @Environment(AuthService.self) private var auth
    @Environment(\.modelContext) private var modelContext

    @State private var vm = SignInViewModel()
    var onGoToSignUp: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Role Tabs
            HStack(spacing: 0) {
                RoleTabButton(title: "Member Login", isSelected: vm.selectedRole == .member) {
                    withAnimation { vm.selectedRole = .member }
                }
                RoleTabButton(title: "Librarian Login", isSelected: vm.selectedRole == .librarian) {
                    withAnimation { vm.selectedRole = .librarian }
                }
            }
            .padding(.bottom, 24)

            VStack(spacing: 16) {
                VStack(spacing: 12) {
                    TextField("Email Address", text: $vm.email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .inputStyle()
                    
                    SecureField("Password", text: $vm.password)
                        .inputStyle()
                }

                if let msg = auth.errorMessage ?? vm.errorMessage {
                    Text(msg)
                        .font(.caption)
                        .foregroundColor(.coral)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    Task { await vm.submit(auth: auth, modelContext: modelContext) }
                } label: {
                    if auth.isLoading || vm.isSubmitting {
                        ProgressView().tint(.white)
                    } else {
                        Text("Sign In Securely")
                    }
                }
                .buttonStyle(.primaryButton)
                .padding(.top, 4)

                Button("Create a new account", action: onGoToSignUp)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.accent)
                    .buttonStyle(.plain)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .padding(.top, 10)
        .lightCard()
        .padding(.horizontal, 20)
    }
}

struct RoleTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline.weight(isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .accent : .textSecondary)
                
                Rectangle()
                    .fill(isSelected ? Color.accent : Color.clear)
                    .frame(height: 3)
                    .cornerRadius(1.5)
            }
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.plain)
    }
}

