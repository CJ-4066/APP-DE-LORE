import AppKit
import Foundation

struct IconSpec {
  let path: String
  let size: Int
}

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

let iosIcons: [IconSpec] = [
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png", size: 20),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png", size: 40),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png", size: 60),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png", size: 29),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png", size: 58),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png", size: 87),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png", size: 40),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png", size: 80),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png", size: 120),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png", size: 120),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png", size: 180),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png", size: 76),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png", size: 152),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png", size: 167),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png", size: 1024),
]

let androidIcons: [IconSpec] = [
  .init(path: "apps/mobile/android/app/src/main/res/mipmap-mdpi/ic_launcher.png", size: 48),
  .init(path: "apps/mobile/android/app/src/main/res/mipmap-hdpi/ic_launcher.png", size: 72),
  .init(path: "apps/mobile/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png", size: 96),
  .init(path: "apps/mobile/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png", size: 144),
  .init(path: "apps/mobile/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png", size: 192),
]

let allIcons = iosIcons + androidIcons

let backgroundTop = NSColor(calibratedRed: 1.0, green: 0.965, blue: 0.925, alpha: 1.0)
let backgroundBottom = NSColor(calibratedRed: 0.955, green: 0.885, blue: 0.78, alpha: 1.0)
let warmGlow = NSColor(calibratedRed: 0.851, green: 0.604, blue: 0.384, alpha: 1.0)
let ink = NSColor(calibratedRed: 0.094, green: 0.129, blue: 0.153, alpha: 1.0)
let cut = NSColor(calibratedRed: 0.992, green: 0.979, blue: 0.957, alpha: 1.0)

func ensureParentDirectory(for url: URL) throws {
  let directory = url.deletingLastPathComponent()
  try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
}

func image(size: Int) -> NSImage {
  let image = NSImage(size: NSSize(width: size, height: size))
  image.lockFocus()

  let rect = NSRect(x: 0, y: 0, width: size, height: size)
  let gradient = NSGradient(starting: backgroundTop, ending: backgroundBottom)!
  gradient.draw(in: rect, angle: -90)

  let glowRect = NSRect(
    x: CGFloat(size) * 0.18,
    y: CGFloat(size) * 0.18,
    width: CGFloat(size) * 0.64,
    height: CGFloat(size) * 0.64
  )
  NSGradient(colors: [
    warmGlow.withAlphaComponent(0.30),
    warmGlow.withAlphaComponent(0.08),
    NSColor.clear,
  ])?.draw(in: NSBezierPath(ovalIn: glowRect), relativeCenterPosition: .zero)

  let orbRect = NSRect(
    x: CGFloat(size) * 0.62,
    y: CGFloat(size) * 0.68,
    width: CGFloat(size) * 0.18,
    height: CGFloat(size) * 0.18
  )
  NSColor.white.withAlphaComponent(0.10).setFill()
  NSBezierPath(ovalIn: orbRect).fill()

  let ringRadius = CGFloat(size) * 0.24
  let center = NSPoint(x: CGFloat(size) / 2, y: CGFloat(size) / 2)
  let ring = NSBezierPath()
  ring.appendArc(
    withCenter: center,
    radius: ringRadius,
    startAngle: 18,
    endAngle: 320,
    clockwise: false
  )
  ring.lineWidth = CGFloat(size) * 0.075
  ring.lineCapStyle = .round
  ink.setStroke()
  ring.stroke()

  let spark = NSBezierPath()
  spark.move(to: NSPoint(x: center.x, y: center.y + CGFloat(size) * 0.17))
  spark.line(to: NSPoint(x: center.x + CGFloat(size) * 0.045, y: center.y + CGFloat(size) * 0.045))
  spark.line(to: NSPoint(x: center.x + CGFloat(size) * 0.17, y: center.y))
  spark.line(to: NSPoint(x: center.x + CGFloat(size) * 0.045, y: center.y - CGFloat(size) * 0.045))
  spark.line(to: NSPoint(x: center.x, y: center.y - CGFloat(size) * 0.17))
  spark.line(to: NSPoint(x: center.x - CGFloat(size) * 0.045, y: center.y - CGFloat(size) * 0.045))
  spark.line(to: NSPoint(x: center.x - CGFloat(size) * 0.17, y: center.y))
  spark.line(to: NSPoint(x: center.x - CGFloat(size) * 0.045, y: center.y + CGFloat(size) * 0.045))
  spark.close()
  ink.setFill()
  spark.fill()

  let cutout = NSBezierPath(ovalIn: NSRect(
    x: center.x - CGFloat(size) * 0.05,
    y: center.y - CGFloat(size) * 0.05,
    width: CGFloat(size) * 0.10,
    height: CGFloat(size) * 0.10
  ))
  cut.setFill()
  cutout.fill()

  let orbit = NSBezierPath()
  orbit.appendArc(
    withCenter: NSPoint(x: center.x, y: center.y - CGFloat(size) * 0.05),
    radius: CGFloat(size) * 0.14,
    startAngle: 210,
    endAngle: 332,
    clockwise: false
  )
  orbit.lineWidth = CGFloat(size) * 0.04
  orbit.lineCapStyle = .round
  ink.withAlphaComponent(0.18).setStroke()
  orbit.stroke()

  let dot = NSBezierPath(ovalIn: NSRect(
    x: center.x + CGFloat(size) * 0.19,
    y: center.y + CGFloat(size) * 0.12,
    width: CGFloat(size) * 0.09,
    height: CGFloat(size) * 0.09
  ))
  warmGlow.setFill()
  dot.fill()

  let tiny = NSBezierPath(ovalIn: NSRect(
    x: center.x - CGFloat(size) * 0.22,
    y: center.y - CGFloat(size) * 0.18,
    width: CGFloat(size) * 0.028,
    height: CGFloat(size) * 0.028
  ))
  ink.withAlphaComponent(0.22).setFill()
  tiny.fill()

  image.unlockFocus()
  return image
}

func pngData(from image: NSImage) throws -> Data {
  guard
    let tiffData = image.tiffRepresentation,
    let bitmap = NSBitmapImageRep(data: tiffData),
    let png = bitmap.representation(using: .png, properties: [:])
  else {
    throw NSError(domain: "generate_mobile_app_icon", code: 1)
  }

  return png
}

do {
  for spec in allIcons {
    let url = root.appendingPathComponent(spec.path)
    try ensureParentDirectory(for: url)
    let data = try pngData(from: image(size: spec.size))
    try data.write(to: url)
    print("generated \(spec.path) (\(spec.size)x\(spec.size))")
  }
} catch {
  fputs("icon generation failed: \(error)\n", stderr)
  exit(1)
}
