import SwiftUI

struct SearchCasesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    @State private var isSearching = false
    
    let filters = ["All", "Criminal", "Civil", "Family", "Corporate"]
    
    // Mock data for demonstration
    let sampleCases = [
        CaseItem(id: "CRL-2024-001", title: "State vs John Doe", type: "Criminal", court: "High Court", status: "Pending"),
        CaseItem(id: "CIV-2024-045", title: "Smith & Co vs ABC Ltd", type: "Civil", court: "District Court", status: "Active"),
        CaseItem(id: "FAM-2024-112", title: "Marriage Petition 112", type: "Family", court: "Family Court", status: "Scheduled"),
        CaseItem(id: "CRP-2024-067", title: "Corporate Dispute 067", type: "Corporate", court: "NCLT", status: "In Progress")
    ]
    
    var filteredCases: [CaseItem] {
        let filtered = sampleCases.filter { case_ in
            (selectedFilter == "All" || case_.type == selectedFilter) &&
            (searchText.isEmpty || 
             case_.id.localizedCaseInsensitiveContains(searchText) ||
             case_.title.localizedCaseInsensitiveContains(searchText))
        }
        return filtered
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Header
                SearchHeader(searchText: $searchText, isSearching: $isSearching)
                
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(filters, id: \.self) { filter in
                            FilterChip(
                                title: filter,
                                isSelected: filter == selectedFilter,
                                action: { selectedFilter = filter }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .background(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 5)
                
                // Results
                if isSearching && searchText.isEmpty {
                    SearchPromptView()
                } else if filteredCases.isEmpty {
                    NoResultsView(searchText: searchText)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(filteredCases) { case_ in
                                SearchResultCard(caseItem: case_)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(hex: "1a237e"))
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct SearchHeader: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search by case number or title", text: $searchText)
                    .onChange(of: searchText) { _ in
                        isSearching = true
                    }
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
        .background(Color.white)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(isSelected ? Color(hex: "1a237e") : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct SearchPromptView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("Search for cases by entering case number or title")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
        }
        .frame(maxHeight: .infinity)
    }
}

struct NoResultsView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No results found for \"\(searchText)\"")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
        }
        .frame(maxHeight: .infinity)
    }
}

struct SearchResultCard: View {
    let caseItem: CaseItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(caseItem.id)
                    .font(.headline)
                Spacer()
                Text(caseItem.status)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Text(caseItem.title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label(caseItem.type, systemImage: "folder")
                Spacer()
                Label(caseItem.court, systemImage: "building.columns")
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

// MARK: - Model
struct CaseItem: Identifiable {
    let id: String
    let title: String
    let type: String
    let court: String
    let status: String
} 