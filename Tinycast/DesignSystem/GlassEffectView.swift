import AppKit
import SwiftUI

struct GlassEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .hudWindow

    func makeNSView(context: Context) -> NSView {
        if #available(macOS 26, *) {
            return NSGlassEffectView()
        }
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let effectView = nsView as? NSVisualEffectView {
            effectView.material = material
        }
    }
}

extension View {
    @ViewBuilder
    func glassSurface(
        in shape: some Shape,
        tint: Color? = nil,
        interactive: Bool = false,
        inWindow: Bool = false,
        bordered: Bool = true
    ) -> some View {
        if #available(macOS 26, *) {
            switch (tint, interactive) {
            case let (tint?, true):
                glassEffect(.regular.tint(tint).interactive(), in: shape)
            case let (tint?, false):
                glassEffect(.regular.tint(tint), in: shape)
            case (nil, true):
                glassEffect(.regular.interactive(), in: shape)
            case (nil, false):
                glassEffect(.regular, in: shape)
            }
        } else {
            background {
                ZStack {
                    if inWindow {
                        shape.fill(.regularMaterial)
                    } else {
                        GlassEffectView()
                    }
                    if let tint { tint }
                }
                .clipShape(shape)
            }
            .overlay {
                if bordered {
                    shape.stroke(Theme.Colors.border, lineWidth: 0.5)
                        .clipShape(shape)
                        .allowsHitTesting(false)
                }
            }
        }
    }
}
