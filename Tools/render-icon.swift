import AppKit
import Foundation

let outputPath = CommandLine.arguments.dropFirst().first ?? "Resources/AppIcon-1024.png"
let size = 1024
let canvas = NSSize(width: size, height: size)

func color(_ hex: UInt32, alpha: CGFloat = 1) -> NSColor {
    NSColor(
        calibratedRed: CGFloat((hex >> 16) & 0xff) / 255,
        green: CGFloat((hex >> 8) & 0xff) / 255,
        blue: CGFloat(hex & 0xff) / 255,
        alpha: alpha
    )
}

func rounded(_ rect: NSRect, _ radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func drawBar(x: CGFloat, y: CGFloat, filled: Int, fillStart: UInt32, fillEnd: UInt32) {
    let outer = NSRect(x: x, y: y, width: 528, height: 92)
    color(0x091016).setFill()
    rounded(outer, 28).fill()
    color(0x3d4b5c).setStroke()
    let border = rounded(outer.insetBy(dx: 4, dy: 4), 24)
    border.lineWidth = 8
    border.stroke()

    for index in 0..<9 {
        let rect = NSRect(x: x + 28 + CGFloat(index * 50), y: y + 28, width: 35, height: 36)
        let t = CGFloat(index) / 8
        let active = index < filled
        let fill = active ? blend(fillStart, fillEnd, t) : color(0x26313f)
        fill.setFill()
        rounded(rect, 9).fill()
    }
}

func blend(_ a: UInt32, _ b: UInt32, _ t: CGFloat) -> NSColor {
    let ar = CGFloat((a >> 16) & 0xff), ag = CGFloat((a >> 8) & 0xff), ab = CGFloat(a & 0xff)
    let br = CGFloat((b >> 16) & 0xff), bg = CGFloat((b >> 8) & 0xff), bb = CGFloat(b & 0xff)
    return NSColor(calibratedRed: (ar + (br - ar) * t) / 255,
                   green: (ag + (bg - ag) * t) / 255,
                   blue: (ab + (bb - ab) * t) / 255,
                   alpha: 1)
}

let image = NSImage(size: canvas)
image.lockFocus()
NSGraphicsContext.current?.imageInterpolation = .high

let background = NSGradient(colors: [color(0x101820), color(0x18222d), color(0x0a0f16)])!
background.draw(in: rounded(NSRect(x: 64, y: 64, width: 896, height: 896), 210), angle: -45)

let panelRect = NSRect(x: 196, y: 158, width: 632, height: 708)
NSShadow.shadow(with: color(0x000000, alpha: 0.42), offset: NSSize(width: 0, height: -32), blurRadius: 36) {
    NSGradient(colors: [color(0x253447), color(0x101821)])!
        .draw(in: rounded(panelRect, 102), angle: -45)
}

color(0x34445a, alpha: 0.72).setFill()
rounded(NSRect(x: 196, y: 737, width: 632, height: 129), 104).fill()
color(0xff5f57).setFill(); NSBezierPath(ovalIn: NSRect(x: 264, y: 782, width: 36, height: 36)).fill()
color(0xffbd2e).setFill(); NSBezierPath(ovalIn: NSRect(x: 326, y: 782, width: 36, height: 36)).fill()
color(0x28c840).setFill(); NSBezierPath(ovalIn: NSRect(x: 388, y: 782, width: 36, height: 36)).fill()

let attrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 54, weight: .heavy),
    .foregroundColor: color(0xe8f2ff)
]
("5H" as NSString).draw(at: NSPoint(x: 248, y: 681), withAttributes: attrs)
drawBar(x: 248, y: 588, filled: 7, fillStart: 0x63f6a7, fillEnd: 0x18d9d2)

("W" as NSString).draw(at: NSPoint(x: 248, y: 519), withAttributes: attrs)
drawBar(x: 248, y: 426, filled: 8, fillStart: 0x7cb7ff, fillEnd: 0x8b7cff)

let gaugeBase = NSBezierPath()
gaugeBase.appendArc(withCenter: NSPoint(x: 512, y: 242), radius: 112, startAngle: 0, endAngle: 180, clockwise: false)
color(0x4b5d74).setStroke()
gaugeBase.lineWidth = 28
gaugeBase.lineCapStyle = .round
gaugeBase.stroke()

let gauge = NSBezierPath()
gauge.appendArc(withCenter: NSPoint(x: 512, y: 242), radius: 112, startAngle: 0, endAngle: 146, clockwise: false)
color(0x19dbc2).setStroke()
gauge.lineWidth = 28
gauge.lineCapStyle = .round
gauge.stroke()

color(0xe8f2ff, alpha: 0.95).setFill()
let needle = NSBezierPath()
needle.move(to: NSPoint(x: 512, y: 354))
needle.line(to: NSPoint(x: 624, y: 242))
needle.line(to: NSPoint(x: 576, y: 242))
needle.curve(to: NSPoint(x: 512, y: 306), controlPoint1: NSPoint(x: 576, y: 277), controlPoint2: NSPoint(x: 547, y: 306))
needle.curve(to: NSPoint(x: 448, y: 242), controlPoint1: NSPoint(x: 477, y: 306), controlPoint2: NSPoint(x: 448, y: 277))
needle.line(to: NSPoint(x: 400, y: 242))
needle.close()
needle.fill()
color(0x19dbc2).setFill()
NSBezierPath(ovalIn: NSRect(x: 484, y: 214, width: 56, height: 56)).fill()

color(0xffffff, alpha: 0.11).setStroke()
let shine = NSBezierPath()
shine.move(to: NSPoint(x: 238, y: 318))
shine.line(to: NSPoint(x: 238, y: 706))
shine.curve(to: NSPoint(x: 272, y: 740), controlPoint1: NSPoint(x: 238, y: 725), controlPoint2: NSPoint(x: 253, y: 740))
shine.line(to: NSPoint(x: 786, y: 740))
shine.lineWidth = 6
shine.lineCapStyle = .round
shine.stroke()

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let png = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("无法生成 PNG")
}

try FileManager.default.createDirectory(
    at: URL(fileURLWithPath: outputPath).deletingLastPathComponent(),
    withIntermediateDirectories: true
)
try png.write(to: URL(fileURLWithPath: outputPath))

extension NSShadow {
    static func shadow(with color: NSColor, offset: NSSize, blurRadius: CGFloat, draw: () -> Void) {
        let shadow = NSShadow()
        shadow.shadowColor = color
        shadow.shadowOffset = offset
        shadow.shadowBlurRadius = blurRadius
        shadow.set()
        draw()
        NSShadow().set()
    }
}
