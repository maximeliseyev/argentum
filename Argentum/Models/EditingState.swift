//
//  EditingState.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 24.11.2025.
//

import Foundation
import Combine
import CoreGraphics

enum CropAspectRatio: Equatable {
    case free
    case original
    case custom(width: Double, height: Double)

    var displayName: String {
        switch self {
        case .free:
            return "Free"
        case .original:
            return "Original"
        case .custom(let w, let h):
            return "\(Int(w)):\(Int(h))"
        }
    }

    var ratio: CGFloat? {
        switch self {
        case .free:
            return nil
        case .original:
            return nil // Will be determined by image
        case .custom(let width, let height):
            return CGFloat(width / height)
        }
    }
}

class EditingState: ObservableObject {
    // Crop
    @Published var isCropActive: Bool = false
    @Published var cropRect: CGRect? = nil
    @Published var cropAspectRatio: CropAspectRatio = .free
    @Published var customAspectWidth: String = "16"
    @Published var customAspectHeight: String = "9"

    // Transform
    @Published var rotationAngle: Double = 0.0

    // Adjustments
    @Published var exposure: Double = 0.0      // -2.0 to 2.0
    @Published var contrast: Double = 1.0      // 0.0 to 2.0
    @Published var brightness: Double = 0.0    // -1.0 to 1.0
    @Published var saturation: Double = 1.0    // 0.0 to 2.0

    // Export
    @Published var jpegQuality: Double = 0.9

    func rotate90Clockwise() {
        rotationAngle -= 90.0
        if rotationAngle <= -360.0 {
            rotationAngle = 0.0
        }
    }

    func rotate90CounterClockwise() {
        rotationAngle += 90.0
        if rotationAngle >= 360.0 {
            rotationAngle = 0.0
        }
    }

    func reset() {
        isCropActive = false
        cropRect = nil
        cropAspectRatio = .free
        customAspectWidth = "16"
        customAspectHeight = "9"
        rotationAngle = 0.0
        exposure = 0.0
        contrast = 1.0
        brightness = 0.0
        saturation = 1.0
        jpegQuality = 0.9
    }

    func applyCrop() {
        // Apply the current crop rect and reset crop mode
        isCropActive = false
    }

    func cancelCrop() {
        // Cancel cropping without applying
        isCropActive = false
        cropRect = nil
    }
}
