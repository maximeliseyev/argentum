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
    @StateObject private var fileManagerService = FileManagerService()

    @State private var selectedFile: URL?
    @State private var columnVisibility = NavigationSplitViewVisibility.all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // SIDEBAR - File Browser
            SidebarView(
                selectedFile: $selectedFile,
                fileManager: fileManagerService
            )
            .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 350)

        } content: {
            // CANVAS - Image Viewer
            ViewerArea(
                image: document.processedImage,
                originalImage: document.originalImage,
                editingState: editingState,
                onOpenFile: openFileImporter,
                onApplyCrop: applyCrop,
                onCancelCrop: cancelCrop,
                onFileDrop: { url in
                    selectedFile = url
                }
            )
            .navigationSplitViewColumnWidth(min: 400, ideal: 800)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar) {
                        Label("Toggle Sidebar", systemImage: "sidebar.left")
                    }
                }

                ToolbarItem(placement: .automatic) {
                    Button(action: toggleInspector) {
                        Label("Toggle Inspector", systemImage: "sidebar.right")
                    }
                }
            }

        } detail: {
            // INSPECTOR - Editing Controls
            InspectorPanel(
                fileName: document.fileName,
                editingState: editingState,
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
                onApplyCrop: applyCrop,
                onCancelCrop: cancelCrop,
                onCloseFile: closeFile,
                onOpenFile: openFileImporter,
                onExport: exportToJPEG
            )
            .navigationSplitViewColumnWidth(min: 250, ideal: 280, max: 350)
        }
        .navigationSplitViewStyle(.balanced)
        .onChange(of: selectedFile) { _, newFile in
            if let url = newFile {
                loadFile(url)
            }
        }
    }

    // MARK: - File Operations

    private func loadFile(_ url: URL) {
        document.loadImage(from: url)
        fileManagerService.addToRecent(url)
        editingState.reset()
    }

    private func openFileImporter() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.tiff, .jpeg]
        panel.allowsMultipleSelection = false
        panel.message = "Select an image to edit"

        if panel.runModal() == .OK, let url = panel.url {
            selectedFile = url
        }
    }

    private func closeFile() {
        document.originalImage = nil
        document.processedImage = nil
        document.fileURL = nil
        selectedFile = nil
        editingState.reset()
    }

    // MARK: - UI Controls

    private func toggleSidebar() {
        withAnimation {
            if columnVisibility == .detailOnly {
                // Currently sidebar is hidden, show it
                columnVisibility = .all
            } else {
                // Hide sidebar (show only content + inspector)
                columnVisibility = .detailOnly
            }
        }
    }

    private func toggleInspector() {
        withAnimation {
            if columnVisibility == .doubleColumn {
                // Currently inspector is hidden, show it
                columnVisibility = .all
            } else {
                // Hide inspector (show only sidebar + content)
                columnVisibility = .doubleColumn
            }
        }
    }

    // MARK: - Image Processing

    private func applyTransforms() {
        guard let original = document.originalImage else { return }

        // Apply all edits using the centralized pipeline
        document.processedImage = ImageProcessor.shared.applyAllEdits(
            to: original,
            editingState: editingState
        )
    }

    private func applyCrop() {
        editingState.applyCrop()
        applyTransforms()
    }

    private func cancelCrop() {
        editingState.cancelCrop()
    }

    // MARK: - Export

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
