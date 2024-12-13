//
//  ContentView.swift
//  Indian Judiciary
//
//  Created by Rishi on 01/12/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var showLoginSheet = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(hex: "f5f5f5").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Header
                    HeaderView(isLoggedIn: $isLoggedIn, showLoginSheet: $showLoginSheet)
                    
                    // Main Content
                    ScrollView {
                        VStack(spacing: 25) {
                            // Welcome Banner
                            WelcomeBannerView(isLoggedIn: isLoggedIn)
                            
                            // Quick Actions
                            QuickActionsGridView(isLoggedIn: isLoggedIn)
                            
                            // Recent Case Updates
                            CaseUpdatesView()
                            
                            // Contact & Support
                            ContactSupportView()
                        }
                        .padding()
                    }
                }
            }
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginView(isLoggedIn: $isLoggedIn)
        }
    }
}

// MARK: - Header View
struct HeaderView: View {
    @Binding var isLoggedIn: Bool
    @Binding var showLoginSheet: Bool
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "1a237e"), Color(hex: "0d47a1")]),
                startPoint: .leading,
                endPoint: .trailing
            )
            
            HStack {
                // Title
                Text("Indian Judiciary")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Login/Logout Button
                Button {
                    if isLoggedIn {
                        isLoggedIn = false
                    } else {
                        showLoginSheet = true
                    }
                } label: {
                    Text(isLoggedIn ? "Logout" : "Login")
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            .padding()
        }
        .frame(height: 60)
    }
}

// MARK: - Welcome Banner
struct WelcomeBannerView: View {
    let isLoggedIn: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "1a237e"), Color(hex: "0d47a1")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 10) {
                Text(isLoggedIn ? "Welcome Back!" : "Welcome to Indian Judiciary")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(isLoggedIn ? "Track your cases and file new petitions easily." : "Login to file cases and track their status.")
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 120)
    }
}

// MARK: - Quick Actions Grid
struct QuickActionsGridView: View {
    let isLoggedIn: Bool
    let columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 2)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Quick Actions")
                .font(.title3)
                .fontWeight(.bold)
            
            LazyVGrid(columns: columns, spacing: 15) {
                QuickActionCard(
                    icon: "doc.fill",
                    title: "File New Case",
                    color: Color(hex: "4CAF50"),
                    isEnabled: isLoggedIn
                )
                
                QuickActionCard(
                    icon: "magnifyingglass",
                    title: "Search Cases",
                    color: Color(hex: "2196F3"),
                    isEnabled: true
                )
                
                QuickActionCard(
                    icon: "calendar",
                    title: "Hearings",
                    color: Color(hex: "FF9800"),
                    isEnabled: isLoggedIn
                )
                
                QuickActionCard(
                    icon: "message.fill",
                    title: "AI Assistant",
                    color: Color(hex: "9C27B0"),
                    isEnabled: true
                )
            }
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    let isEnabled: Bool
    
    var body: some View {
        if title == "Search Cases" {
            NavigationLink(destination: SearchCasesView()) {
                CardContent(icon: icon, title: title, color: color)
            }
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1 : 0.6)
        } else if title == "AI Assistant" {
            NavigationLink(destination: AIChatView()) {
                CardContent(icon: icon, title: title, color: color)
            }
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1 : 0.6)
        } else {
            NavigationLink(destination: Text(title)) {
                CardContent(icon: icon, title: title, color: color)
            }
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1 : 0.6)
        }
    }
}

struct CardContent: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Case Updates View
struct CaseUpdatesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Updates")
                .font(.title3)
                .fontWeight(.bold)
            
            ForEach(1...3, id: \.self) { index in
                CaseUpdateCardView(
                    caseNumber: "CRL-\(index)2024",
                    status: ["Pending", "In Progress", "Scheduled"][index - 1],
                    date: "0\(index)/12/2024",
                    court: "High Court"
                )
            }
        }
    }
}

struct CaseUpdateCardView: View {
    let caseNumber: String
    let status: String
    let date: String
    let court: String
    
    var statusColor: Color {
        switch status {
        case "Pending": return .orange
        case "In Progress": return .blue
        case "Scheduled": return .green
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(caseNumber)
                    .font(.headline)
                Spacer()
                Text(status)
                    .font(.subheadline)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(statusColor.opacity(0.1))
                    .cornerRadius(8)
            }
            
            HStack {
                Label(date, systemImage: "calendar")
                Spacer()
                Label(court, systemImage: "building.columns")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Contact & Support View
struct ContactSupportView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Contact & Support")
                .font(.title3)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                ContactRow(icon: "phone.fill", title: "Helpline", detail: "1800-XXX-XXXX")
                Divider()
                ContactRow(icon: "envelope.fill", title: "Email", detail: "support@indianjudiciary.gov.in")
                Divider()
                ContactRow(icon: "globe", title: "Website", detail: "www.indianjudiciary.gov.in")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
    }
}

struct ContactRow: View {
    let icon: String
    let title: String
    let detail: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "1a237e"))
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(detail)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    ContentView()
}
