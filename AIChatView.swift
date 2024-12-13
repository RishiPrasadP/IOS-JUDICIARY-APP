import SwiftUI

struct AIChatView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hello! I'm your legal assistant. How can I help you today?", isUser: false),
    ]
    @State private var isTyping = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var isDragging = false
    @State private var dragOffset: CGFloat = 0
    @FocusState private var isFocused: Bool
    
    let suggestedQuestions = [
        "What documents do I need to file a case?",
        "How long does a civil case typically take?",
        "What are the court fees?",
        "How can I get legal aid?"
    ]
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Chat Messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 15) {
                                ForEach(messages) { message in
                                    ChatBubble(message: message)
                                        .transition(.asymmetric(
                                            insertion: .slide.combined(with: .opacity),
                                            removal: .opacity))
                                }
                                
                                if isTyping {
                                    TypingIndicator()
                                        .id("typing")
                                        .transition(.opacity)
                                }
                            }
                            .padding()
                        }
                        .onChange(of: messages.count) { _ in
                            withAnimation(.spring()) {
                                proxy.scrollTo(messages.last?.id, anchor: .bottom)
                            }
                        }
                        .onChange(of: isTyping) { _ in
                            withAnimation(.spring()) {
                                proxy.scrollTo("typing", anchor: .bottom)
                            }
                        }
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    if isFocused {
                                        let delta = gesture.translation.height
                                        if delta > 0 {
                                            isDragging = true
                                            dragOffset = delta
                                        }
                                    }
                                }
                                .onEnded { _ in
                                    if dragOffset > 50 {
                                        isFocused = false
                                    }
                                    withAnimation(.spring()) {
                                        isDragging = false
                                        dragOffset = 0
                                    }
                                }
                        )
                    }
                    
                    // Suggested Questions
                    if messages.count == 1 {
                        SuggestedQuestionsView(questions: suggestedQuestions) { question in
                            withAnimation {
                                sendMessage(question)
                            }
                        }
                        .transition(.move(edge: .bottom))
                    }
                    
                    // Input Area
                    VStack(spacing: 0) {
                        Divider()
                        HStack(spacing: 15) {
                            // Message Input
                            TextField("Type your question...", text: $messageText)
                                .padding(10)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(20)
                                .focused($isFocused)
                                .submitLabel(.send)
                                .onSubmit {
                                    if !messageText.isEmpty {
                                        sendMessage(messageText)
                                    }
                                }
                            
                            // Send Button
                            Button(action: {
                                if !messageText.isEmpty {
                                    withAnimation {
                                        sendMessage(messageText)
                                    }
                                }
                            }) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(messageText.isEmpty ? .gray : Color(hex: "1a237e"))
                                    .scaleEffect(messageText.isEmpty ? 1.0 : 1.1)
                                    .animation(.spring(response: 0.3), value: messageText.isEmpty)
                            }
                            .disabled(messageText.isEmpty)
                        }
                        .padding()
                    }
                    .background(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 5, y: -5)
                    .offset(y: isDragging ? dragOffset : 0)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("AI Legal Assistant")
                            .font(.headline)
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(Color(hex: "1a237e"))
                        }
                    }
                }
                .onAppear {
                    NotificationCenter.default.addObserver(
                        forName: UIResponder.keyboardWillShowNotification,
                        object: nil,
                        queue: .main
                    ) { notification in
                        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                            keyboardHeight = keyboardFrame.height
                        }
                    }
                    
                    NotificationCenter.default.addObserver(
                        forName: UIResponder.keyboardWillHideNotification,
                        object: nil,
                        queue: .main
                    ) { _ in
                        keyboardHeight = 0
                    }
                }
            }
        }
    }
    
    private func sendMessage(_ text: String) {
        let userMessage = ChatMessage(text: text, isUser: true)
        withAnimation(.spring()) {
            messages.append(userMessage)
        }
        messageText = ""
        
        // Simulate AI typing
        withAnimation {
            isTyping = true
        }
        
        // Simulate AI response after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring()) {
                isTyping = false
                let response = generateAIResponse(for: text)
                messages.append(ChatMessage(text: response, isUser: false))
            }
        }
    }
    
    private func generateAIResponse(for question: String) -> String {
        // This is a mock response. In a real app, you would integrate with an AI API
        let responses = [
            "To file a case, you'll need: 1) A detailed petition 2) Supporting documents 3) Identity proof 4) Address proof. The exact requirements may vary based on the type of case.",
            "Civil cases typically take 2-3 years, but the duration can vary significantly based on complexity and court backlog.",
            "Court fees depend on the case value and type. For specific information, please visit the court's website or consult a lawyer.",
            "Legal aid is available for individuals with annual income below ₹3 lakhs. You can apply through the State Legal Services Authority."
        ]
        
        return responses.randomElement() ?? "I apologize, but I couldn't understand your question. Could you please rephrase it?"
    }
}

// MARK: - Supporting Views
struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 5) {
                Text(message.text)
                    .padding(15)
                    .background(message.isUser ? Color(hex: "1a237e") : Color.gray.opacity(0.1))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(20)
                    .cornerRadius(message.isUser ? 20 : 20)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser { Spacer() }
        }
    }
}

struct TypingIndicator: View {
    @State private var numberOfDots = 0
    
    var body: some View {
        HStack {
            Text("AI is typing")
                .foregroundColor(.gray)
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 4, height: 4)
                    .opacity(numberOfDots >= index + 1 ? 1 : 0.3)
            }
        }
        .padding(10)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                withAnimation {
                    numberOfDots = (numberOfDots + 1) % 4
                }
            }
        }
    }
}

struct SuggestedQuestionsView: View {
    let questions: [String]
    let onTap: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Suggested Questions")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(questions, id: \.self) { question in
                        Button(action: { onTap(question) }) {
                            Text(question)
                                .font(.subheadline)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.1))
                                .foregroundColor(.primary)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color.white)
    }
}

// MARK: - Model
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp = Date()
} 