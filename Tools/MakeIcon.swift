// Draws the Mac E-Mouse icon. Usage: swift Tools/MakeIcon.swift <out.png> <pixels> [round]
import AppKit

let args = CommandLine.arguments
let outPath = args[1]
let px = CGFloat(Double(args[2])!)
let round = args.count > 3 && args[3] == "round"

let cs = CGColorSpace(name: CGColorSpace.sRGB)!
let ctx = CGContext(data: nil, width: Int(px), height: Int(px), bitsPerComponent: 8, bytesPerRow: 0,
                    space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.scaleBy(x: px / 1024, y: px / 1024) // draw on a 1024 grid

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor { CGColor(srgbRed: r/255, green: g/255, blue: b/255, alpha: a) }

// Background: macOS icon grid (824pt body, 100pt margin) or a circle for the round variant
let body = round ? CGRect(x: 0, y: 0, width: 1024, height: 1024) : CGRect(x: 100, y: 100, width: 824, height: 824)
let bg = round ? CGPath(ellipseIn: body, transform: nil)
               : CGPath(roundedRect: body, cornerWidth: 185, cornerHeight: 185, transform: nil)
if !round { // soft drop shadow like system icons
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 28, color: rgb(0, 0, 0, 0.35))
    ctx.addPath(bg); ctx.setFillColor(rgb(20, 20, 40)); ctx.fillPath()
    ctx.restoreGState()
}
ctx.saveGState()
ctx.addPath(bg); ctx.clip()
let grad = CGGradient(colorsSpace: cs, colors: [rgb(18, 194, 233), rgb(98, 70, 234), rgb(40, 22, 110)] as CFArray,
                      locations: [0, 0.55, 1])!
ctx.drawLinearGradient(grad, start: CGPoint(x: body.minX, y: body.maxY), end: CGPoint(x: body.maxX, y: body.minY), options: [])
ctx.restoreGState()

// Mouse: white capsule with a button split line and a scroll wheel
let mouse = CGRect(x: 342, y: 230, width: 340, height: 520)
let mousePath = CGPath(roundedRect: mouse, cornerWidth: 170, cornerHeight: 170, transform: nil)
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -14), blur: 30, color: rgb(10, 0, 60, 0.45))
ctx.addPath(mousePath); ctx.setFillColor(rgb(250, 250, 255)); ctx.fillPath()
ctx.restoreGState()
ctx.setStrokeColor(rgb(150, 140, 200)); ctx.setLineWidth(10); ctx.setLineCap(.round)
ctx.move(to: CGPoint(x: 512, y: 750)); ctx.addLine(to: CGPoint(x: 512, y: 590)); ctx.strokePath()
ctx.move(to: CGPoint(x: 352, y: 560)); ctx.addLine(to: CGPoint(x: 672, y: 560)); ctx.strokePath()
ctx.addPath(CGPath(roundedRect: CGRect(x: 492, y: 610, width: 40, height: 90), cornerWidth: 20, cornerHeight: 20, transform: nil))
ctx.setFillColor(rgb(98, 70, 234)); ctx.fillPath()

let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: outPath))
