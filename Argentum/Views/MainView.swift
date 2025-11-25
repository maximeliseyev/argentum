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
            // Viewer
            ViewerArea(
                image: document.processedImage,
                onOpenFile: { isFileImporterPresented = true }
            )
            .frame(minWidth: Sizing.Panel.viewerMinWidth)

            // Inspector
            InspectorPanel(
                fileName: document.fileName,
                rotationAngle: $editingState.rotationAngle,
                exposure: $editingState.exposure,
                contrast: $editingState.contrast,
                brightness: $editingState.brightness,
                saturation: $editingState.saturation,
                jpegQuality: $editingState.jpegQuality,
                hasImage: document.processedImage != nil,
                onRotateLeft: {
                    editingState.rotate90CounterClockwise()
                    applyTransforms()
                },
                onRotateRight: {
                    editingState.rotate90Clockwise()
                    applyTransforms()
                },
                onAdjustmentChanged: applyTransforms,
                onCloseFile: closeFile,
                onOpenFile: { isFileImporterPresented = true },
                onExport: exportToJPEG
            )
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

        // Apply exposure
        if editingState.exposure != 0.0 {
            processed = ImageProcessor.shared.applyExposure(
                image: processed,
                exposure: editingState.exposure
            )
        }

        // Apply color controls (brightness, contrast, saturation)
        if editingState.brightness != 0.0 || editingState.contrast != 1.0 || editingState.saturation != 1.0 {
            processed = ImageProcessor.shared.applyColorControls(
                image: processed,
                brightness: editingState.brightness,
                contrast: editingState.contrast,
                saturation: editingState.saturation
            )
        }

        document.processedImage = processed
    }

    private func closeFile() {
        document.originalImage = nil
        document.processedImage = nil
        document.fileURL = nil
        editingState.reset()
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
