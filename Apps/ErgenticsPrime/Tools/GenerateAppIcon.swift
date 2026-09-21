import AppKit
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

// Original repo-owned geometry: an open-base delta and a separate amber state
// point. No font, external image, randomness, clock, network, or app/VM launch.
// Identical source and native graphics runtime produce identical PNG bytes.
// Usage: GenerateAppIcon /absolute/path/Assets.xcassets/AppIcon.appiconset
@main
enum GenerateAppIcon {
    static let outputs: [(String, Int)] = [
        ("icon_16x16.png", 16), ("icon_16x16@2x.png", 32),
        ("icon_32x32.png", 32), ("icon_32x32@2x.png", 64),
        ("icon_128x128.png", 128), ("icon_128x128@2x.png", 256),
        ("icon_256x256.png", 256), ("icon_256x256@2x.png", 512),
        ("icon_512x512.png", 512), ("icon_512x512@2x.png", 1024)
    ]

    static func main() throws {
        guard CommandLine.arguments.count == 2, CommandLine.arguments[1].hasPrefix("/") else {
            throw failure("Supply exactly one absolute AppIcon.appiconset output directory.")
        }
        let directory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        guard directory.lastPathComponent == "AppIcon.appiconset" else {
            throw failure("The output directory must be named AppIcon.appiconset.")
        }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        for (filename, side) in outputs {
            let data = try render(side: side)
            try data.write(to: directory.appendingPathComponent(filename), options: .atomic)
            print("\(filename): \(side)×\(side), opaque sRGB PNG, \(data.count) bytes")
        }
    }

    static func render(side: Int) throws -> Data {
        guard let space = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(data: nil, width: side, height: side,
                bitsPerComponent: 8, bytesPerRow: side * 4, space: space,
                bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.noneSkipLast.rawValue) else {
            throw failure("Cannot create the fixed opaque sRGB drawing surface.")
        }
        context.setAllowsAntialiasing(true)
        context.setShouldAntialias(true)
        context.scaleBy(x: CGFloat(side) / 1024, y: CGFloat(side) / 1024)
        let canvas = CGRect(x: 0, y: 0, width: 1024, height: 1024)
        context.setFillColor(color(0x07131c))
        context.fill(canvas)

        // Opaque corners and a quiet rounded inner tile retain contrast on
        // both light and dark macOS desktops without depending on an alpha mask.
        let tile = CGPath(roundedRect: CGRect(x: 48, y: 48, width: 928, height: 928),
                          cornerWidth: 218, cornerHeight: 218, transform: nil)
        context.saveGState()
        context.addPath(tile)
        context.clip()
        let background = try gradient(space: space, colors: [color(0x0c2531), color(0x143d48), color(0x0a1d29)],
                                      locations: [0, 0.64, 1])
        context.drawLinearGradient(background, start: CGPoint(x: 910, y: 120), end: CGPoint(x: 190, y: 1000),
                                   options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        let glow = try gradient(space: space, colors: [color(0x44d1bc, alpha: 0.13), color(0x44d1bc, alpha: 0)],
                                locations: [0, 1])
        context.drawRadialGradient(glow, startCenter: CGPoint(x: 480, y: 690), startRadius: 8,
                                   endCenter: CGPoint(x: 480, y: 690), endRadius: 540, options: [])
        context.restoreGState()
        context.addPath(tile)
        context.setStrokeColor(color(0xb1f3e7, alpha: 0.11))
        context.setLineWidth(2)
        context.strokePath()

        let centerline = CGMutablePath()
        centerline.move(to: CGPoint(x: 425, y: 282))
        centerline.addLine(to: CGPoint(x: 236, y: 282))
        centerline.addLine(to: CGPoint(x: 512, y: 784))
        centerline.addLine(to: CGPoint(x: 788, y: 282))
        centerline.addLine(to: CGPoint(x: 599, y: 282))
        let delta = centerline.copy(strokingWithWidth: 82, lineCap: .round, lineJoin: .round, miterLimit: 2)

        context.saveGState()
        context.setShadow(offset: CGSize(width: 0, height: -16), blur: 25, color: color(0x020c13, alpha: 0.45))
        context.addPath(delta)
        context.setFillColor(color(0x49d8bf))
        context.fillPath()
        context.restoreGState()
        context.saveGState()
        context.addPath(delta)
        context.clip()
        let mark = try gradient(space: space, colors: [color(0x38c4b3), color(0xa1f5d8)], locations: [0, 1])
        context.drawLinearGradient(mark, start: CGPoint(x: 512, y: 220), end: CGPoint(x: 512, y: 840), options: [])
        context.restoreGState()

        // Separate point signifies a bounded change/state, not another letter.
        context.setFillColor(color(0xffd08a))
        context.fillEllipse(in: CGRect(x: 484, y: 254, width: 56, height: 56))

        guard let image = context.makeImage() else { throw failure("Cannot finalize icon pixels.") }
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(output, UTType.png.identifier as CFString, 1, nil) else {
            throw failure("Cannot create PNG encoder.")
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { throw failure("PNG encoding failed.") }
        return output as Data
    }

    static func color(_ rgb: UInt32, alpha: CGFloat = 1) -> CGColor {
        CGColor(srgbRed: CGFloat((rgb >> 16) & 255) / 255,
                green: CGFloat((rgb >> 8) & 255) / 255,
                blue: CGFloat(rgb & 255) / 255, alpha: alpha)
    }

    static func gradient(space: CGColorSpace, colors: [CGColor], locations: [CGFloat]) throws -> CGGradient {
        guard let value = CGGradient(colorsSpace: space, colors: colors as CFArray, locations: locations) else {
            throw failure("Cannot create fixed icon gradient.")
        }
        return value
    }

    static func failure(_ message: String) -> NSError {
        NSError(domain: "com.ergentics.AppIconGenerator", code: 1,
                userInfo: [NSLocalizedDescriptionKey: message])
    }
}
