import AppKit
import Foundation

enum OutputFormat {
  case png
  case jpeg
}

enum RenderStyle {
  case appIcon
  case transparentMark
  case verticalLogo
}

struct RasterSpec {
  let path: String
  let width: Int
  let height: Int
  let style: RenderStyle
  let format: OutputFormat
}

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

let iosIcons: [RasterSpec] = [
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png", width: 20, height: 20, style: .appIcon, format: .png),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png", width: 40, height: 40, style: .appIcon, format: .png),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png", width: 60, height: 60, style: .appIcon, format: .png),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png", width: 29, height: 29, style: .appIcon, format: .png),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png", width: 58, height: 58, style: .appIcon, format: .png),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png", width: 87, height: 87, style: .appIcon, format: .png),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png", width: 40, height: 40, style: .appIcon, format: .png),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png", width: 80, height: 80, style: .appIcon, format: .png),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png", width: 120, height: 120, style: .appIcon, format: .png),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png", width: 120, height: 120, style: .appIcon, format: .png),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png", width: 180, height: 180, style: .appIcon, format: .png),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png", width: 76, height: 76, style: .appIcon, format: .png),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png", width: 152, height: 152, style: .appIcon, format: .png),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png", width: 167, height: 167, style: .appIcon, format: .png),
  .init(path: "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png", width: 1024, height: 1024, style: .appIcon, format: .png),
]

let androidIcons: [RasterSpec] = [
  .init(path: "apps/mobile/android/app/src/main/res/mipmap-mdpi/ic_launcher.png", width: 48, height: 48, style: .appIcon, format: .png),
  .init(path: "apps/mobile/android/app/src/main/res/mipmap-hdpi/ic_launcher.png", width: 72, height: 72, style: .appIcon, format: .png),
  .init(path: "apps/mobile/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png", width: 96, height: 96, style: .appIcon, format: .png),
  .init(path: "apps/mobile/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png", width: 144, height: 144, style: .appIcon, format: .png),
  .init(path: "apps/mobile/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png", width: 192, height: 192, style: .appIcon, format: .png),
]

let macosIcons: [RasterSpec] = [
  .init(path: "apps/mobile/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16.png", width: 16, height: 16, style: .appIcon, format: .png),
  .init(path: "apps/mobile/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png", width: 32, height: 32, style: .appIcon, format: .png),
  .init(path: "apps/mobile/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_64.png", width: 64, height: 64, style: .appIcon, format: .png),
  .init(path: "apps/mobile/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_128.png", width: 128, height: 128, style: .appIcon, format: .png),
  .init(path: "apps/mobile/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png", width: 256, height: 256, style: .appIcon, format: .png),
  .init(path: "apps/mobile/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png", width: 512, height: 512, style: .appIcon, format: .png),
  .init(path: "apps/mobile/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png", width: 1024, height: 1024, style: .appIcon, format: .png),
]

let webIcons: [RasterSpec] = [
  .init(path: "apps/mobile/web/favicon.png", width: 32, height: 32, style: .appIcon, format: .png),
  .init(path: "apps/mobile/web/icons/Icon-192.png", width: 192, height: 192, style: .appIcon, format: .png),
  .init(path: "apps/mobile/web/icons/Icon-512.png", width: 512, height: 512, style: .appIcon, format: .png),
  .init(path: "apps/mobile/web/icons/Icon-maskable-192.png", width: 192, height: 192, style: .appIcon, format: .png),
  .init(path: "apps/mobile/web/icons/Icon-maskable-512.png", width: 512, height: 512, style: .appIcon, format: .png),
]

let brandAssets: [RasterSpec] = [
  .init(path: "apps/mobile/assets/branding/lo-renaciente-app-icon.png", width: 1024, height: 1024, style: .appIcon, format: .png),
  .init(path: "apps/mobile/assets/branding/lo-renaciente-isotipo.png", width: 1024, height: 1024, style: .transparentMark, format: .png),
  .init(path: "apps/mobile/assets/branding/lo-renaciente-logo-v2.png", width: 1024, height: 1536, style: .verticalLogo, format: .png),
  .init(path: "apps/mobile/assets/branding/lo-renaciente-logo.jpeg", width: 1131, height: 1600, style: .verticalLogo, format: .jpeg),
]

let allOutputs = iosIcons + androidIcons + macosIcons + webIcons + brandAssets

let backgroundTop = NSColor(calibratedRed: 0.385, green: 0.314, blue: 0.659, alpha: 1)
let backgroundMid = NSColor(calibratedRed: 0.643, green: 0.478, blue: 0.580, alpha: 1)
let backgroundBottom = NSColor(calibratedRed: 0.090, green: 0.102, blue: 0.243, alpha: 1)
let butterflyInk = NSColor(calibratedRed: 0.071, green: 0.090, blue: 0.184, alpha: 1)
let wingViolet = NSColor(calibratedRed: 0.404, green: 0.314, blue: 0.659, alpha: 1)
let paleFlame = NSColor(calibratedRed: 1.0, green: 0.972, blue: 0.925, alpha: 1)

func ensureParentDirectory(for url: URL) throws {
  let directory = url.deletingLastPathComponent()
  try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
}

func scaledPoint(_ x: CGFloat, _ y: CGFloat, in frame: NSRect) -> NSPoint {
  let scale = min(frame.width, frame.height) / 1024
  let offsetX = frame.minX + (frame.width - (1024 * scale)) / 2
  let offsetY = frame.minY + (frame.height - (1024 * scale)) / 2
  return NSPoint(x: offsetX + x * scale, y: offsetY + (1024 - y) * scale)
}

func scaledRect(centerX: CGFloat, centerY: CGFloat, width: CGFloat, height: CGFloat, in frame: NSRect) -> NSRect {
  let scale = min(frame.width, frame.height) / 1024
  let center = scaledPoint(centerX, centerY, in: frame)
  return NSRect(
    x: center.x - width * scale / 2,
    y: center.y - height * scale / 2,
    width: width * scale,
    height: height * scale
  )
}

func makePath(in frame: NSRect, _ build: (NSBezierPath, (CGFloat, CGFloat) -> NSPoint) -> Void) -> NSBezierPath {
  let path = NSBezierPath()
  let point = { (x: CGFloat, y: CGFloat) -> NSPoint in
    scaledPoint(x, y, in: frame)
  }
  build(path, point)
  return path
}

func fillPath(_ color: NSColor, in frame: NSRect, _ build: (NSBezierPath, (CGFloat, CGFloat) -> NSPoint) -> Void) {
  color.setFill()
  makePath(in: frame, build).fill()
}

func strokePath(_ color: NSColor, lineWidth: CGFloat, in frame: NSRect, _ build: (NSBezierPath, (CGFloat, CGFloat) -> NSPoint) -> Void) {
  let scale = min(frame.width, frame.height) / 1024
  let path = makePath(in: frame, build)
  path.lineWidth = lineWidth * scale
  path.lineCapStyle = .round
  path.lineJoinStyle = .round
  color.setStroke()
  path.stroke()
}

func drawBackground(in rect: NSRect) {
  NSGradient(colors: [backgroundTop, backgroundMid, backgroundBottom])?.draw(in: rect, angle: -90)

  NSGradient(colors: [
    paleFlame.withAlphaComponent(0.16),
    paleFlame.withAlphaComponent(0.06),
    NSColor.clear,
  ])?.draw(
    in: NSBezierPath(ovalIn: NSRect(
      x: rect.midX - rect.width * 0.38,
      y: rect.midY - rect.height * 0.36,
      width: rect.width * 0.76,
      height: rect.height * 0.76
    )),
    relativeCenterPosition: .zero
  )
}

func drawButterfly(in frame: NSRect, includePetal: Bool) {
  if includePetal {
    fillPath(paleFlame.withAlphaComponent(0.78), in: frame) { path, p in
      path.move(to: p(512, 188))
      path.curve(to: p(512, 448), controlPoint1: p(406, 276), controlPoint2: p(392, 370))
      path.curve(to: p(512, 188), controlPoint1: p(632, 370), controlPoint2: p(618, 276))
      path.close()
    }
  }

  fillPath(butterflyInk, in: frame) { path, p in
    path.move(to: p(494, 506))
    path.curve(to: p(112, 253), controlPoint1: p(412, 382), controlPoint2: p(237, 257))
    path.curve(to: p(274, 586), controlPoint1: p(72, 343), controlPoint2: p(139, 535))
    path.curve(to: p(494, 506), controlPoint1: p(374, 625), controlPoint2: p(454, 575))
    path.close()
  }

  fillPath(butterflyInk, in: frame) { path, p in
    path.move(to: p(530, 506))
    path.curve(to: p(912, 253), controlPoint1: p(612, 382), controlPoint2: p(787, 257))
    path.curve(to: p(750, 586), controlPoint1: p(952, 343), controlPoint2: p(885, 535))
    path.curve(to: p(530, 506), controlPoint1: p(650, 625), controlPoint2: p(570, 575))
    path.close()
  }

  fillPath(butterflyInk, in: frame) { path, p in
    path.move(to: p(489, 536))
    path.curve(to: p(253, 762), controlPoint1: p(414, 582), controlPoint2: p(337, 662))
    path.curve(to: p(151, 591), controlPoint1: p(163, 738), controlPoint2: p(119, 657))
    path.curve(to: p(489, 536), controlPoint1: p(190, 511), controlPoint2: p(355, 501))
    path.close()
  }

  fillPath(butterflyInk, in: frame) { path, p in
    path.move(to: p(535, 536))
    path.curve(to: p(771, 762), controlPoint1: p(610, 582), controlPoint2: p(687, 662))
    path.curve(to: p(873, 591), controlPoint1: p(861, 738), controlPoint2: p(905, 657))
    path.curve(to: p(535, 536), controlPoint1: p(834, 511), controlPoint2: p(669, 501))
    path.close()
  }

  let inset = wingViolet.withAlphaComponent(0.90)
  let insetPaths: [((NSBezierPath, (CGFloat, CGFloat) -> NSPoint) -> Void)] = [
    { path, p in
      path.move(to: p(203, 343))
      path.curve(to: p(427, 454), controlPoint1: p(272, 334), controlPoint2: p(354, 374))
      path.curve(to: p(174, 401), controlPoint1: p(333, 433), controlPoint2: p(239, 407))
      path.curve(to: p(203, 343), controlPoint1: p(165, 376), controlPoint2: p(176, 351))
      path.close()
    },
    { path, p in
      path.move(to: p(821, 343))
      path.curve(to: p(597, 454), controlPoint1: p(752, 334), controlPoint2: p(670, 374))
      path.curve(to: p(850, 401), controlPoint1: p(691, 433), controlPoint2: p(785, 407))
      path.curve(to: p(821, 343), controlPoint1: p(859, 376), controlPoint2: p(848, 351))
      path.close()
    },
    { path, p in
      path.move(to: p(191, 474))
      path.curve(to: p(432, 514), controlPoint1: p(274, 462), controlPoint2: p(350, 478))
      path.curve(to: p(191, 516), controlPoint1: p(345, 523), controlPoint2: p(263, 524))
      path.curve(to: p(191, 474), controlPoint1: p(175, 503), controlPoint2: p(175, 486))
      path.close()
    },
    { path, p in
      path.move(to: p(833, 474))
      path.curve(to: p(592, 514), controlPoint1: p(750, 462), controlPoint2: p(674, 478))
      path.curve(to: p(833, 516), controlPoint1: p(679, 523), controlPoint2: p(761, 524))
      path.curve(to: p(833, 474), controlPoint1: p(849, 503), controlPoint2: p(849, 486))
      path.close()
    },
    { path, p in
      path.move(to: p(252, 640))
      path.curve(to: p(438, 547), controlPoint1: p(301, 597), controlPoint2: p(358, 569))
      path.curve(to: p(282, 722), controlPoint1: p(383, 619), controlPoint2: p(337, 680))
      path.curve(to: p(252, 640), controlPoint1: p(253, 710), controlPoint2: p(239, 681))
      path.close()
    },
    { path, p in
      path.move(to: p(772, 640))
      path.curve(to: p(586, 547), controlPoint1: p(723, 597), controlPoint2: p(666, 569))
      path.curve(to: p(742, 722), controlPoint1: p(641, 619), controlPoint2: p(687, 680))
      path.curve(to: p(772, 640), controlPoint1: p(771, 710), controlPoint2: p(785, 681))
      path.close()
    },
  ]

  for insetPath in insetPaths {
    fillPath(inset, in: frame, insetPath)
  }

  strokePath(butterflyInk, lineWidth: 19, in: frame) { path, p in
    path.move(to: p(511, 347))
    path.line(to: p(511, 718))
  }
  strokePath(butterflyInk, lineWidth: 19, in: frame) { path, p in
    path.move(to: p(507, 340))
    path.curve(to: p(400, 293), controlPoint1: p(459, 284), controlPoint2: p(430, 273))
  }
  strokePath(butterflyInk, lineWidth: 19, in: frame) { path, p in
    path.move(to: p(517, 340))
    path.curve(to: p(624, 293), controlPoint1: p(565, 284), controlPoint2: p(594, 273))
  }

  butterflyInk.setFill()
  NSBezierPath(ovalIn: scaledRect(centerX: 512, centerY: 512, width: 68, height: 132, in: frame)).fill()
  NSBezierPath(ovalIn: scaledRect(centerX: 512, centerY: 429, width: 52, height: 72, in: frame)).fill()
}

func drawVerticalLogo(in rect: NSRect) {
  drawBackground(in: rect)
  let iconSize = min(rect.width * 0.78, rect.height * 0.54)
  let iconFrame = NSRect(
    x: rect.midX - iconSize / 2,
    y: rect.maxY - rect.height * 0.13 - iconSize,
    width: iconSize,
    height: iconSize
  )
  drawButterfly(in: iconFrame, includePetal: false)

  let paragraph = NSMutableParagraphStyle()
  paragraph.alignment = .center
  let title = "Lo Renaciente" as NSString
  let subtitle = "Claridad, símbolo y dirección" as NSString
  let titleFont = NSFont(name: "IowanOldStyle-Roman", size: rect.width * 0.092)
    ?? NSFont(name: "Georgia", size: rect.width * 0.092)
    ?? NSFont.systemFont(ofSize: rect.width * 0.092, weight: .semibold)
  let subtitleFont = NSFont.systemFont(ofSize: rect.width * 0.032, weight: .semibold)

  title.draw(
    in: NSRect(x: rect.width * 0.08, y: rect.height * 0.20, width: rect.width * 0.84, height: rect.height * 0.10),
    withAttributes: [
      .font: titleFont,
      .foregroundColor: paleFlame,
      .paragraphStyle: paragraph,
    ]
  )
  subtitle.draw(
    in: NSRect(x: rect.width * 0.12, y: rect.height * 0.155, width: rect.width * 0.76, height: rect.height * 0.055),
    withAttributes: [
      .font: subtitleFont,
      .foregroundColor: paleFlame.withAlphaComponent(0.78),
      .paragraphStyle: paragraph,
      .kern: 1.2,
    ]
  )
}

func renderImage(width: Int, height: Int, style: RenderStyle) -> NSImage {
  let image = NSImage(size: NSSize(width: width, height: height))
  image.lockFocus()

  let rect = NSRect(x: 0, y: 0, width: width, height: height)
  switch style {
  case .appIcon:
    drawBackground(in: rect)
    drawButterfly(in: rect.insetBy(dx: rect.width * 0.035, dy: rect.height * 0.035), includePetal: false)
  case .transparentMark:
    drawButterfly(in: rect.insetBy(dx: rect.width * 0.035, dy: rect.height * 0.035), includePetal: false)
  case .verticalLogo:
    drawVerticalLogo(in: rect)
  }

  image.unlockFocus()
  return image
}

func bitmapRepresentation(from image: NSImage) throws -> NSBitmapImageRep {
  guard
    let tiffData = image.tiffRepresentation,
    let bitmap = NSBitmapImageRep(data: tiffData)
  else {
    throw NSError(domain: "generate_mobile_app_icon", code: 1)
  }
  return bitmap
}

func data(from image: NSImage, format: OutputFormat) throws -> Data {
  let bitmap = try bitmapRepresentation(from: image)
  switch format {
  case .png:
    guard let png = bitmap.representation(using: .png, properties: [:]) else {
      throw NSError(domain: "generate_mobile_app_icon", code: 2)
    }
    return png
  case .jpeg:
    guard let jpeg = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.92]) else {
      throw NSError(domain: "generate_mobile_app_icon", code: 3)
    }
    return jpeg
  }
}

do {
  for spec in allOutputs {
    let url = root.appendingPathComponent(spec.path)
    try ensureParentDirectory(for: url)
    let image = renderImage(width: spec.width, height: spec.height, style: spec.style)
    try data(from: image, format: spec.format).write(to: url)
    print("generated \(spec.path) (\(spec.width)x\(spec.height))")
  }
} catch {
  fputs("icon generation failed: \(error)\n", stderr)
  exit(1)
}
