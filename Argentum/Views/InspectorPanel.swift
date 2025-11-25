//
//  InspectorPanel.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 24.11.2025.
//

import SwiftUI

struct InspectorPanel: View {
    let fileName: String?
    @Binding var rotationAngle: Double
    @Binding var exposure: Double
    @Binding var contrast: Double
    @Binding var brightness: Double
    @Binding var saturation: Double
    @Binding var jpegQuality: Double
    let hasImage: Bool
    let onRotateLeft: () -> Void
    let onRotateRight: () -> Void
    let onAdjustmentChanged: () -> Void
    let onCloseFile: () -> Void
    let onOpenFile: () -> Void
    let onExport: () -> Void

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

                // Transform Section
                TransformSection(
                    rotationAngle: $rotationAngle,
                    onRotateLeft: onRotateLeft,
                    onRotateRight: onRotateRight
                )

                // Adjustments Section
                AdjustmentsSection(
                    exposure: $exposure,
                    contrast: $contrast,
                    brightness: $brightness,
                    saturation: $saturation
                )
                .onChange(of: exposure) { _, _ in onAdjustmentChanged() }
                .onChange(of: contrast) { _, _ in onAdjustmentChanged() }
                .onChange(of: brightness) { _, _ in onAdjustmentChanged() }
                .onChange(of: saturation) { _, _ in onAdjustmentChanged() }

                // Export Section
                ExportSection(
                    jpegQuality: $jpegQuality,
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
}
