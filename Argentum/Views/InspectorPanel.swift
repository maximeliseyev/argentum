//
//  InspectorPanel.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 24.11.2025.
//

import SwiftUI

struct InspectorPanel: View {
    let fileName: String?
    @ObservedObject var editingState: EditingState
    let hasImage: Bool
    let onRotateLeft: () -> Void
    let onRotateRight: () -> Void
    let onAdjustmentChanged: () -> Void
    let onApplyCrop: () -> Void
    let onCancelCrop: () -> Void
    let onCloseFile: () -> Void
    let onOpenFile: () -> Void
    let onExport: () -> Void

    @State private var debounceTask: Task<Void, Never>?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xxlarge) {
                // File Info Section
                if let fileName = fileName {
                    FileInfoSection(
                        fileName: fileName,
                        onClose: onCloseFile,
                        onOpenNew: onOpenFile
                    )
                }

                // Crop Section
                CropSection(
                    isCropActive: $editingState.isCropActive,
                    aspectRatio: $editingState.cropAspectRatio,
                    customWidth: $editingState.customAspectWidth,
                    customHeight: $editingState.customAspectHeight
                )

                // Transform Section
                TransformSection(
                    rotationAngle: $editingState.rotationAngle,
                    onRotateLeft: onRotateLeft,
                    onRotateRight: onRotateRight
                )

                // Adjustments Section
                AdjustmentsSection(
                    exposure: $editingState.exposure,
                    contrast: $editingState.contrast,
                    brightness: $editingState.brightness,
                    saturation: $editingState.saturation
                )
                .onChange(of: editingState.exposure) { _, _ in debouncedAdjustmentChanged() }
                .onChange(of: editingState.contrast) { _, _ in debouncedAdjustmentChanged() }
                .onChange(of: editingState.brightness) { _, _ in debouncedAdjustmentChanged() }
                .onChange(of: editingState.saturation) { _, _ in debouncedAdjustmentChanged() }

                // Export Section
                ExportSection(
                    jpegQuality: $editingState.jpegQuality,
                    isEnabled: hasImage,
                    onExport: onExport
                )

                Spacer()
            }
            .padding(Spacing.large)
        }
        .background(Color.panelBackground)
        .frame(width: Sizing.Panel.inspectorWidth)
    }

    private func debouncedAdjustmentChanged() {
        // Cancel previous debounce task
        debounceTask?.cancel()

        // Create new debounce task with 150ms delay
        debounceTask = Task {
            try? await Task.sleep(for: .milliseconds(150))

            // Check if task was cancelled
            guard !Task.isCancelled else { return }

            await MainActor.run {
                onAdjustmentChanged()
            }
        }
    }
}
