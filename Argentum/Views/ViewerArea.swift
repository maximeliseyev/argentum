//
//  ViewerArea.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 24.11.2025.
//

import SwiftUI

struct ViewerArea: View {
    let image: CIImage?
    let onOpenFile: () -> Void

    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    var body: some View {
        ZStack {
            Color.appBackground

            if image != nil {
                ImageCanvas(
                    image: image,
                    scale: $scale,
                    offset: $offset,
                    onResetZoom: resetZoom
                )
                .padding(Spacing.xxlarge)

                // Fit to Window button overlay
                VStack {
                    HStack {
                        Spacer()

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

                        Text("Open a TIFF file to start editing")
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
    }

    private func resetZoom() {
        withAnimation(Animation.quick) {
            scale = 1.0
            offset = .zero
        }
    }
}
