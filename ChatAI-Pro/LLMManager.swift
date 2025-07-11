import Foundation
import Combine
import Uzu                                   // Mirai's Swift facade

struct AvailableModel: Identifiable, Hashable {
    let id: String
    let name: String
    let size: String
    let precision: String
    let isDownloaded: Bool
    let isDownloading: Bool
    let downloadProgress: Double
}

@MainActor
final class LLMManager: ObservableObject {

    // Replace with your own key, e.g. "eyJh…DmBA"
    private let engine = UzuEngine(apiKey: "")

    @Published var downloadProgress: [String: Double] = [:]
    @Published var isDownloading: [String: Bool] = [:]
    @Published var downloadComplete: [String: Bool] = [:]
    @Published var availableModels: [AvailableModel] = []
    @Published var currentModelId: String = "Alibaba-Qwen3-1.7B-float16"
    @Published var offloadingEnabled: Bool = false

    static let shared = LLMManager()        // single-ton for simplicity

    private init() {
        Task { 
            try await refreshRegistry()
            await loadAvailableModels()
        }
    }

    func refreshRegistry() async throws {
        _ = try await engine.updateRegistry()          // one quick HTTPS call
    }

    // Load available models from registry
    func loadAvailableModels() async {
        do {
            let registry = try await engine.updateRegistry()
            
            let models = registry.keys.compactMap { modelId -> AvailableModel? in
                // Parse model information from the ID
                let components = modelId.split(separator: "-")
                guard components.count >= 3 else { return nil }
                
                let vendor = String(components[0])
                let modelName = components[1..<components.count-1].joined(separator: "-")
                let precision = String(components.last ?? "unknown")
                
                // Extract size from model name if available
                let size = extractSize(from: modelName)
                
                return AvailableModel(
                    id: modelId,
                    name: "\(vendor) \(modelName)",
                    size: size,
                    precision: precision,
                    isDownloaded: downloadComplete[modelId] ?? false,
                    isDownloading: isDownloading[modelId] ?? false,
                    downloadProgress: downloadProgress[modelId] ?? 0.0
                )
            }
            
            // Add some popular models if not in registry
            var allModels = models
            let popularModels = [
                ("Alibaba-Qwen-Qwen3-1.7B-float16", "Qwen Qwen3", "1.7B", "float16"),
                ("Alibaba-Qwen-Qwen3-1.7B-int4", "Qwen Qwen3", "1.7B", "int4"),
                ("Meta-Llama-3.2-1B-Instruct-float16", "Meta Llama 3.2", "1B", "float16"),
                ("DeepSeek-R1-Distill-Qwen-1.5B-float16", "DeepSeek R1 Distill", "1.5B", "float16")
            ]
            
            for (id, name, size, precision) in popularModels {
                if !allModels.contains(where: { $0.id == id }) {
                    allModels.append(AvailableModel(
                        id: id,
                        name: name,
                        size: size,
                        precision: precision,
                        isDownloaded: downloadComplete[id] ?? false,
                        isDownloading: isDownloading[id] ?? false,
                        downloadProgress: downloadProgress[id] ?? 0.0
                    ))
                }
            }
            
            availableModels = allModels.sorted { $0.name < $1.name }
        } catch {
            print("Failed to load available models: \(error)")
        }
    }
    
    private func extractSize(from modelName: String) -> String {
        let sizePattern = #"(\d+\.?\d*[BMT])"#
        if let range = modelName.range(of: sizePattern, options: .regularExpression) {
            return String(modelName[range])
        }
        return "Unknown"
    }

    // Check if model is downloaded and ready
    func isModelReady(_ modelId: String) -> Bool {
        return downloadComplete[modelId] == true
    }

    // Get download progress for a model (0.0 to 1.0)
    func getDownloadProgress(_ modelId: String) -> Double {
        return downloadProgress[modelId] ?? 0.0
    }

    // Check if model is currently downloading
    func isModelDownloading(_ modelId: String) -> Bool {
        return isDownloading[modelId] == true
    }

    // Get current model display name
    func getCurrentModelName() -> String {
        if let model = availableModels.first(where: { $0.id == currentModelId }) {
            return "\(model.name) (\(model.precision))"
        }
        return currentModelId
    }

    // Set current model
    func setCurrentModel(_ modelId: String) {
        currentModelId = modelId
    }

    // Convenience wrapper for a one-off chat completion
    func run(model id: String,
             prompt: String,
             streaming: @escaping (String) -> Void) async throws {

        let session = try engine.createSession(identifier: id)

        let config = SessionConfig(
            preset: .general,
            samplingSeed: .default,
            contextLength: .default
        )
        try session.load(config: config)

        let input = SessionInput.messages([
            .init(role: .user, content: prompt)
        ])

        // Stream tokens into the closure as they arrive
        let output = session.run(
            input: input,
            tokensLimit: 128,
            samplingMethod: .argmax                     // deterministic
        ) { partialOutput in
            streaming(partialOutput.text)
            return true                                 // keep going
        }

        streaming(output.text)                          // send the final string
        // Session cleanup is handled automatically
    }

    // Download model with progress tracking
    func download(id: String) {
        isDownloading[id] = true
        downloadProgress[id] = 0.0
        downloadComplete[id] = false
        
        // Start the actual download
        engine.download(identifier: id)
        
        // Simulate progress tracking since we can't access engine states directly
        // In a real implementation, you'd need to find the actual progress callback
        Task {
            await simulateDownloadProgress(for: id)
        }
    }
    
    // Delete downloaded model
    func deleteModel(_ modelId: String) {
        downloadComplete[modelId] = false
        downloadProgress[modelId] = 0.0
        isDownloading[modelId] = false
        
        Task {
            await loadAvailableModels() // Refresh the models list
        }
    }
    
    // Simulate download progress - replace with actual progress tracking when available
    private func simulateDownloadProgress(for modelId: String) async {
        let steps = 20
        for i in 0...steps {
            let progress = Double(i) / Double(steps)
            await MainActor.run {
                downloadProgress[modelId] = progress
                // Update the model in availableModels
                if let index = availableModels.firstIndex(where: { $0.id == modelId }) {
                    availableModels[index] = AvailableModel(
                        id: availableModels[index].id,
                        name: availableModels[index].name,
                        size: availableModels[index].size,
                        precision: availableModels[index].precision,
                        isDownloaded: i == steps,
                        isDownloading: i < steps,
                        downloadProgress: progress
                    )
                }
            }
            
            if i == steps {
                await MainActor.run {
                    isDownloading[modelId] = false
                    downloadComplete[modelId] = true
                }
            }
            
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        }
    }
}
//
//  LLMManager.swift
//  ChatAI-Pro
//
//  Created by Pranjal on 11/07/25.
//

