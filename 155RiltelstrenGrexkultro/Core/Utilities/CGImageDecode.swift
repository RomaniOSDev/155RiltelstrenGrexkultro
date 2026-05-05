//
//  CGImageDecode.swift
//  155RiltelstrenGrexkultro
//

import Foundation
import ImageIO
import CoreGraphics

enum CGImageDecode {
    static func image(from data: Data) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }
}
