//
//  MainView.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 24.11.2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct MainView: View {
    @StateObject private var document = ImageDocument()
    @StateObject private var editingState = EditingState()
    @State private var isFileImporterPresented = false
    @State private var isExporting = false

    var body: some View {
        HSplitView {
            // Left side - Canvas
            VStack {
                if document.processedImage != nil {
                    ImageCanvas(image: document.processedImage)
                } else {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "photo")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)
                        Text("Open a TIFF file to start")
                            .font(.headline)
                        Button("Open File") {
                            isFileImporterPresented = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .frame(minWidth: 400)

            // Right side - Tools Panel
            VStack(alignment: .leading, spacing: 20) {
                if let fileName = document.fileName {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("File:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(fileName)
                            .font(.system(.body, design: .monospaced))
                            .lineLimit(2)
                    }

                    Divider()
                }

                // Rotation controls
                VStack(alignment: .leading, spacing: 12) {
                    Text("Rotation")
                        .font(.headline)

                    HStack(spacing: 12) {
                        Button(action: {
                            editingState.rotate90CounterClockwise()
                            applyTransforms()
                        }) {
                            Image(systemName: "rotate.left")
                        }

                        Button(action: {
                            editingState.rotate90Clockwise()
                            applyTransforms()
                        }) {
                            Image(systemName: "rotate.right")
                        }
                    }

                    Text("Angle: \(Int(editingState.rotationAngle))°")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()

                // JPEG Quality
                VStack(alignment: .leading, spacing: 12) {
                    Text("JPEG Quality")
                        .font(.headline)

                    HStack {
                        Text("Low")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Slider(value: $editingState.jpegQuality, in: 0.5...1.0)
                        Text("High")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text("\(Int(editingState.jpegQuality * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Export button
                Button("Export JPEG") {
                    exportToJPEG()
                }
                .buttonStyle(.borderedProminent)
                .disabled(document.processedImage == nil)
            }
            .padding()
            .frame(width: 250)
        }
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.tiff],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let files):
                if let url = files.first {
                    document.loadImage(from: url)
                }
            case .failure(let error):
                print("Error selecting file: \(error)")
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: { isFileImporterPresented = true }) {
                    Label("Open", systemImage: "folder")
                }
            }
        }
    }

    private func applyTransforms() {
        guard let original = document.originalImage else { return }

        var processed = original

        // Apply rotation
        if editingState.rotationAngle != 0 {
            processed = ImageProcessor.shared.rotate(
                image: processed,
                angle: editingState.rotationAngle
            )
        }

        document.processedImage = processed
    }

    private func exportToJPEG() {
        guard let image = document.processedImage else { return }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.jpeg]
        panel.nameFieldStringValue = document.fileURL?.deletingPathExtension().lastPathComponent ?? "exported"
        panel.message = "Export as JPEG"

        panel.begin { response in
            if response == .OK, let url = panel.url {
                do {
                    try ImageProcessor.shared.exportToJPEG(
                        image: image,
                        to: url,
                        quality: editingState.jpegQuality
                    )
                    print("Successfully exported to: \(url)")
                } catch {
                    print("Export error: \(error)")
                }
            }
        }
    }
}

#Preview {
    MainView()
}
