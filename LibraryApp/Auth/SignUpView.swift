import SwiftUI
import SwiftData

struct SignUpView: View {
    @Environment(AuthService.self) private var auth
    @Environment(\.modelContext) private var modelContext

    @State private var vm = SignUpViewModel()
    var onGoToSignIn: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Role Tabs
            HStack(spacing: 0) {
                RoleTabButton(title: "Member Account", isSelected: vm.selectedRole == .member) {
                    withAnimation { vm.selectedRole = .member }
                }
                RoleTabButton(title: "Librarian Account", isSelected: vm.selectedRole == .librarian) {
                    withAnimation { vm.selectedRole = .librarian }
                }
            }
            .padding(.bottom, 24)

            VStack(spacing: 16) {
                VStack(spacing: 12) {
                    TextField("Full Name", text: $vm.name)
                        .inputStyle()
                        
                    TextField("Email Address", text: $vm.email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .inputStyle()
                        
                    SecureField("Secure Password", text: $vm.password)
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
                        Text("Register Securely")
                    }
                }
                .buttonStyle(.primaryButton)
                .padding(.top, 4)

                Button("I already have an account", action: onGoToSignIn)
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

