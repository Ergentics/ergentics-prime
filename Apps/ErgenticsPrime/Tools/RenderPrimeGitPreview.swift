import AppKit
import Foundation
import SwiftUI

// Excluded visual-QA helper. Only the snapshot model and PrimeGitView are linked.
// No app entry, native Hypervisor code, snapshot import, or repository operation.
@main
@MainActor
enum RenderPrimeGitPreview {
    static func main() throws {
        let application = NSApplication.shared
        application.setActivationPolicy(.prohibited)
        let size = CGSize(width: 1000, height: 720)
        let model = PrimeGitModel()
        let content = PrimeGitView(model: model, admitted: true)
            .frame(width: size.width, height: size.height)
            .environment(\.colorScheme, .dark)
        let hosting = NSHostingView(rootView: content)
        hosting.frame = CGRect(origin: .zero, size: size)
        hosting.appearance = NSAppearance(named: .darkAqua)
        hosting.layoutSubtreeIfNeeded()
        guard let bitmap = hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds) else {
            throw failure("Unable to allocate a view-only bitmap.")
        }
        hosting.cacheDisplay(in: hosting.bounds, to: bitmap)
        guard let png = bitmap.representation(using: .png, properties: [:]) else {
            throw failure("Unable to encode the view-only PNG.")
        }
        let output = URL(fileURLWithPath: "/Users/ergentics/Developer/ErgenticsProvenance/DerivedData/prime-git-preview.png")
        try png.write(to: output)
        print("Rendered empty PrimeGitView: \(bitmap.pixelsWide)×\(bitmap.pixelsHigh), \(png.count) PNG bytes")
    }

    static func failure(_ description: String) -> NSError {
        NSError(domain: "com.ergentics.PrimeGitPreview", code: 1,
                userInfo: [NSLocalizedDescriptionKey: description])
    }
}
