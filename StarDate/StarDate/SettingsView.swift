//
//  SettingsView.swift
//  StarDate
//
//  Settings view for configuring OpenAI API

import SwiftUI

struct SettingsView: View {
    @StateObject private var settingsManager = OpenAISettingsManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showApiKey = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("OpenAI API Configuration")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("API Key")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            if showApiKey {
                                TextField("sk-...", text: $settingsManager.apiKey)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                            } else {
                                SecureField("sk-...", text: $settingsManager.apiKey)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                            }
                            Button(action: {
                                showApiKey.toggle()
                            }) {
                                Image(systemName: showApiKey ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Model")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("gpt-4o", text: $settingsManager.model)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                        Text("Examples: gpt-4o, gpt-4, gpt-3.5-turbo")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Endpoint")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("https://api.openai.com/v1/chat/completions", text: $settingsManager.endpoint)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .keyboardType(.URL)
                        Text("Full URL to the chat completions endpoint")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Max Completion Tokens")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("2000", value: $settingsManager.maxCompletionTokens, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                        Text("Maximum tokens for completion. Higher values allow for longer responses. Default: 2000 (recommended for reasoning models like GPT-5)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("Status")) {
                    HStack {
                        Text("Configuration")
                        Spacer()
                        if settingsManager.isConfigured {
                            Label("Ready", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Label("Incomplete", systemImage: "exclamationmark.circle.fill")
                                .foregroundColor(.orange)
                        }
                    }
                }

                Section {
                    Button(action: {
                        settingsManager.resetToDefaults()
                        alertMessage = "Settings reset to defaults"
                        showingAlert = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Reset to Defaults")
                            Spacer()
                        }
                    }
                    .foregroundColor(.red)
                }

                Section(header: Text("About")) {
                    Text("Configure your OpenAI API settings to enable AI-powered analysis of your diary entries. Your API key is stored securely on your device.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Settings", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

#Preview {
    SettingsView()
}
