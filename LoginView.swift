import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var isLoggedIn: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "1a237e"), Color(hex: "0d47a1")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Logo and Title
                        VStack(spacing: 20) {
                            Image(systemName: "building.columns.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                                .shadow(radius: 10)
                            
                            Text("Indian Judiciary")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                        }
                        .padding(.top, 50)
                        
                        // Login Form
                        VStack(spacing: 25) {
                            CustomTextField(
                                icon: "envelope.fill",
                                placeholder: "Email",
                                text: $email
                            )
                            
                            CustomTextField(
                                icon: "lock.fill",
                                placeholder: "Password",
                                text: $password,
                                isSecure: true
                            )
                            
                            Button(action: handleLogin) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.white)
                                    
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "1a237e")))
                                    } else {
                                        Text("Login")
                                            .font(.headline)
                                            .foregroundColor(Color(hex: "1a237e"))
                                    }
                                }
                                .frame(height: 55)
                            }
                            .disabled(isLoading)
                        }
                        .padding(.horizontal, 25)
                        
                        // Register Option
                        VStack(spacing: 20) {
                            HStack {
                                Text("Don't have an account?")
                                    .foregroundColor(.white.opacity(0.8))
                                Button("Register") {
                                    // Handle registration
                                }
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                            }
                            
                            Button("Forgot Password?") {
                                // Handle forgot password
                            }
                            .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
            .alert("Login Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Invalid email or password")
            }
        }
    }
    
    private func handleLogin() {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if email.lowercased() == "test@example.com" && password == "password" {
                isLoggedIn = true
                dismiss()
            } else {
                showError = true
            }
            isLoading = false
        }
    }
}

// Custom TextField Component
struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.white)
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.2))
        )
        .foregroundColor(.white)
    }
}

// Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isLoggedIn: .constant(false))
    }
} 
