//
//  SettingsView.swift
//  ChatAI-Pro
//
//  Created by Pranjal on 11/07/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var llm = LLMManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("General Settings") {
                    HStack {
                        Image(systemName: "cpu")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Memory Offloading")
                                .font(.headline)
                            Text("Reduce memory usage by offloading layers")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: $llm.offloadingEnabled)
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Available Models") {
                    ForEach(llm.availableModels) { model in
                        ModelRowView(model: model)
                    }
                }
                
                Section("Current Model") {
                    HStack {
                        Image(systemName: "brain")
                            .foregroundColor(.green)
                        VStack(alignment: .leading) {
                            Text("Active Model")
                                .font(.headline)
                            Text(llm.getCurrentModelName())
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if llm.isModelReady(llm.currentModelId) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else if llm.isModelDownloading(llm.currentModelId) {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Refresh") {
                        Task {
                            try? await llm.refreshRegistry()
                            await llm.loadAvailableModels()
                        }
                    }
                }
            }
        }
    }
}

struct ModelRowView: View {
    let model: AvailableModel
    @StateObject private var llm = LLMManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(model.name)
                        .font(.headline)
                    HStack {
                        Text(model.size)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                        
                        Text(model.precision)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(model.precision == "int4" ? Color.orange.opacity(0.2) : Color.green.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    if model.isDownloaded {
                        Button("Use") {
                            llm.setCurrentModel(model.id)
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .cornerRadius(8)
                        
                        Button("Delete") {
                            llm.deleteModel(model.id)
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    } else if model.isDownloading {
                        Button("Cancel") {
                            // TODO: Implement cancel download
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    } else {
                        Button("Download") {
                            llm.download(id: model.id)
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                }
            }
            
            // Progress bar for downloading models
            if model.isDownloading {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Downloading...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(model.downloadProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: model.downloadProgress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .frame(height: 4)
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsView()
} 