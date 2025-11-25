//
//  ViewerArea.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 24.11.2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct ViewerArea: View {
    let image: CIImage?
    let originalImage: CIImage?
    @ObservedObject var editingState: EditingState
    let onOpenFile: () -> Void
    let onApplyCrop: () -> Void
    let onCancelCrop: () -> Void
    let onFileDrop: ((URL) -> Void)?

    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var isDropTargeted = false

    var body: some View {
        ZStack {
            Color.appBackground

            if image != nil {
                ImageCanvas(
                    image: image,
                    originalImage: originalImage,
                    editingState: editingState,
                    scale: $scale,
                    offset: $offset,
                    onResetZoom: resetZoom
                )
                .padding(Spacing.xxlarge)

                // Top toolbar overlay
                VStack {
                    HStack {
                        Spacer()

                        if editingState.isCropActive {
                            // Crop toolbar
                            CropToolbar(
                                onApply: onApplyCrop,
                                onCancel: onCancelCrop
                            )
                        } else {
                            // Normal toolbar
                            HStack(spacing: Spacing.regular) {
                                // Zoom indicator
                                Text("\(Int(scale * 100))%")
                                    .font(Typography.regularMono)
                                    .foregroundColor(.tertiaryText)
                                    .padding(.horizontal, Spacing.medium)
                                    .padding(.vertical, Spacing.small - 2)
                                    .background(Color.overlayBackground)
                                    .cornerRadius(CornerRadius.small)

                                // Fit to Window button
                                Button(action: resetZoom) {
                                    HStack(spacing: Spacing.small - 2) {
                                        Image(systemName: "arrow.down.left.and.arrow.up.right")
                                            .font(Typography.small)
                                        Text("Fit")
                                            .font(Typography.weighted(Typography.regular, .medium))
                                    }
                                    .foregroundColor(.secondaryText)
                                    .padding(.horizontal, Spacing.small + 4)
                                    .padding(.vertical, Spacing.medium - 3)
                                    .background(Color.overlayBackground)
                                    .cornerRadius(CornerRadius.regular)
                                }
                                .buttonStyle(.plain)
                                .opacity(scale == 1.0 && offset == .zero ? 0.3 : 1.0)
                            }
                            .padding(Spacing.xlarge)
                        }
                    }

                    Spacer()
                }
            } else {
                // Empty state
                VStack(spacing: Spacing.xxlarge) {
                    Image(systemName: "photo")
                        .font(.system(size: 72, weight: .ultraLight))
                        .foregroundColor(.white.opacity(0.3))

                    VStack(spacing: Spacing.medium) {
                        Text("No Image")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondaryText)

                        Text("Open a TIFF or JPEG file to start editing")
                            .font(Typography.large)
                            .foregroundColor(.quinaryText)
                    }

                    Button(action: onOpenFile) {
                        Text("Open File")
                            .font(Typography.weighted(Typography.large, .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, Spacing.xxlarge)
                            .padding(.vertical, Spacing.medium - 4)
                            .background(Color.accentColor)
                            .cornerRadius(CornerRadius.regular)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            guard let provider = providers.first else { return false }

            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { data, error in
                guard error == nil,
                      let urlData = data as? Data,
                      let url = URL(dataRepresentation: urlData, relativeTo: nil) else {
                    return
                }

                DispatchQueue.main.async {
                    onFileDrop?(url)
                }
            }

            return true
        }
        .overlay {
            if isDropTargeted {
                RoundedRectangle(cornerRadius: CornerRadius.regular)
                    .stroke(Color.accentColor, lineWidth: 2)
                    .padding(Spacing.regular)
            }
        }
    }

    private func resetZoom() {
        withAnimation(Animation.quick) {
            scale = 1.0
            offset = .zero
        }
    }
}
