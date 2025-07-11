//
//  ContentView.swift
//  ChatAI-Pro
//
//  Created by Pranjal on 11/07/25.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var llm = LLMManager.shared
    @State private var input = ""
    @State private var transcript: [Message] = []
    @FocusState private var focused: Bool
    @State private var showingSettings = false

    var body: some View {
        VStack(spacing: 0) {
            // Header with model info and settings
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ChatAI Pro")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 6) {
                        // Model status indicator
                        Circle()
                            .fill(modelStatusColor)
                            .frame(width: 8, height: 8)
                        
                        Text(llm.getCurrentModelName())
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if llm.isModelDownloading(llm.currentModelId) {
                            ProgressView()
                                .scaleEffect(0.6)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            
            // Chat area
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(transcript) { msg in
                                HStack {
                                    if msg.isUser { Spacer() }
                                    Text(msg.text)
                                        .padding(10)
                                        .background(msg.isUser ? .blue.opacity(0.2) : .gray.opacity(0.2))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    if !msg.isUser { Spacer() }
                                }
                            }
                        }
                        .padding()
                    }
                    .onChange(of: transcript) { _ in
                        if let last = transcript.last?.id {
                            withAnimation { proxy.scrollTo(last, anchor: .bottom) }
                        }
                    }
                }

                // Download Progress Section
                if llm.isModelDownloading(llm.currentModelId) {
                    VStack(spacing: 8) {
                        Text("Downloading \(llm.getCurrentModelName())...")
                            .font(.headline)
                        
                        ProgressView(value: llm.getDownloadProgress(llm.currentModelId), total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .frame(height: 8)
                        
                        Text("\(Int(llm.getDownloadProgress(llm.currentModelId) * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // Input area
                HStack {
                    TextField("Say something…", text: $input)
                        .textFieldStyle(.roundedBorder)
                        .focused($focused)
                        .onSubmit(send)
                    Button("Send", action: send)
                        .disabled(input.isEmpty || !llm.isModelReady(llm.currentModelId))
                }
                .padding()
            }
        }
        .onAppear {
            downloadModelIfNeeded()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    private var modelStatusColor: Color {
        if llm.isModelReady(llm.currentModelId) {
            return .green
        } else if llm.isModelDownloading(llm.currentModelId) {
            return .orange
        } else {
            return .red
        }
    }

    private func downloadModelIfNeeded() {
        if !llm.isModelReady(llm.currentModelId) && !llm.isModelDownloading(llm.currentModelId) {
            llm.download(id: llm.currentModelId)
        }
    }

    private func send() {
        guard llm.isModelReady(llm.currentModelId) else {
            // Show error message if model isn't ready
            let errorMessage = Message(text: "Model is not ready yet. Please wait for download to complete or select a different model in settings.", isUser: false)
            transcript.append(errorMessage)
            return
        }

        let userMessage = Message(text: input, isUser: true)
        transcript.append(userMessage)
        let index = transcript.count      // capture array position
        let tokenMessage = Message(text: "", isUser: false)
        transcript.append(tokenMessage)
        input = ""
        focused = false

        Task {
            do {
                try await llm.run(model: llm.currentModelId, prompt: userMessage.text) { chunk in
                    Task { @MainActor in
                        transcript[index].text = chunk
                    }
                }
            } catch {
                Task { @MainActor in
                    transcript[index].text = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}
