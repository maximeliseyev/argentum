//
//  ImageProcessor.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 24.11.2025.
//

import Foundation
import CoreImage
import AppKit
import UniformTypeIdentifiers

class ImageProcessor {
    static let shared = ImageProcessor()

    private let context: CIContext

    private init() {
        // Create CIContext with Metal for hardware acceleration
        self.context = CIContext(options: [
            .useSoftwareRenderer: false,
            .priorityRequestLow: false
        ])
    }

    // MARK: - Rotation

    func rotate(image: CIImage, angle: Double) -> CIImage {
        let radians = angle * .pi / 180.0
        let extent = image.extent

        // Calculate center of the image
        let centerX = extent.midX
        let centerY = extent.midY

        // Create transform: translate to origin, rotate, translate back
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: centerX, y: centerY)
        transform = transform.rotated(by: radians)
        transform = transform.translatedBy(x: -centerX, y: -centerY)

        return image.transformed(by: transform)
    }

    // MARK: - Export to JPEG

    func exportToJPEG(image: CIImage, to url: URL, quality: Double) throws {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!

        // Create CGImage without alpha channel to avoid warning
        guard let cgImage = context.createCGImage(image, from: image.extent, format: .RGBA8, colorSpace: colorSpace) else {
            throw NSError(domain: "ImageProcessor", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create CGImage"])
        }

        // Create new CGImage without alpha channel
        let width = cgImage.width
        let height = cgImage.height
        let bitmapInfo = CGImageAlphaInfo.noneSkipLast.rawValue

        guard let bitmapContext = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            throw NSError(domain: "ImageProcessor", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create bitmap context"])
        }

        bitmapContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let imageWithoutAlpha = bitmapContext.makeImage() else {
            throw NSError(domain: "ImageProcessor", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to create image without alpha"])
        }

        // Write JPEG
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.jpeg.identifier as CFString, 1, nil) else {
            throw NSError(domain: "ImageProcessor", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to create destination"])
        }

        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: quality
        ]

        CGImageDestinationAddImage(destination, imageWithoutAlpha, options as CFDictionary)

        if !CGImageDestinationFinalize(destination) {
            throw NSError(domain: "ImageProcessor", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to finalize image destination"])
        }
    }

    // MARK: - Preview Generation

    func generatePreview(from image: CIImage, maxSize: CGFloat = 1024) -> NSImage? {
        let extent = image.extent
        let aspectRatio = extent.width / extent.height

        var targetWidth = maxSize
        var targetHeight = maxSize

        if aspectRatio > 1 {
            targetHeight = maxSize / aspectRatio
        } else {
            targetWidth = maxSize * aspectRatio
        }

        let scale = targetWidth / extent.width

        let scaledImage = image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

        return NSImage(cgImage: cgImage, size: NSSize(width: targetWidth, height: targetHeight))
    }
}
