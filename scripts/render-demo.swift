import AppKit
import AVFoundation
import CoreMedia
import CoreVideo
import Foundation

private let canvasWidth = 1280
private let canvasHeight = 720
private let framesPerSecond: Int32 = 24
private let transitionSeconds = 0.55

private enum RenderError: LocalizedError {
    case failed(String)

    var errorDescription: String? {
        switch self {
        case .failed(let message): return message
        }
    }
}

private struct Slide {
    let kicker: String
    let title: String
    let narration: String
}

private struct NarrationClip {
    let url: URL
    let duration: CMTime
}

private struct RenderSummary {
    let outputURL: URL
    let duration: Double
    let fileSize: UInt64
    let videoCodec: String
    let audioCodec: String
    let dimensions: CGSize
    let usedProductionBackground: Bool
}

private let slides: [Slide] = [
    Slide(
        kicker: "OPENAI BUILD WEEK 2026",
        title: "A listing is a claim.\nCash is a fact.",
        narration: "I asked Codex to make ten thousand dollars. It quickly found four live-looking paid issues advertising more than one point one million dollars. But a listing is only a claim. Not Revenue Yet requires proof before an agent spends time, identity, or money."
    ),
    Slide(
        kicker: "THE FALSE-POSITIVE AUDIT",
        title: "$1,163,486 advertised.\n$0 settled.",
        narration: "The evidence pack looks exciting at first: four listings and one million one hundred sixty-three thousand four hundred eighty-six dollars advertised. Then canonical checks collapse the fantasy. Two targets were already complete, one reward was economically implausible, and settled revenue remained exactly zero."
    ),
    Slide(
        kicker: "REALITY GATE",
        title: "Canonical source wins.",
        narration: "Take the first eighteen hundred eighty dollar listing. The aggregator still advertised the reward. The canonical issue was closed, the implementation had merged months earlier, and duplicate attempts were rejected. The reality gate makes the repository the source of truth and blocks the work."
    ),
    Slide(
        kicker: "ADVERSARIAL ECONOMICS",
        title: "Big numbers do not\nbecome pipeline by typography.",
        narration: "The largest listing claimed more than one point one six million dollars for only nineteen characters of scope in a near-empty repository. Unknown funding, no license, vague acceptance criteria, and a huge reward-to-trust mismatch trigger a skip. Big numbers never become pipeline by typography alone."
    ),
    Slide(
        kicker: "ONE DETERMINISTIC CORE",
        title: "Four gates before action.",
        narration: "The same deterministic engine powers the browser, command line, tests, and installable Codex skill. It evaluates reality, payout, authority, and safety, then returns pursue, verify, skip, or block with timestamped evidence and the safest authorized next action."
    ),
    Slide(
        kicker: "SETTLEMENT INVARIANT",
        title: "Motion is not money.",
        narration: "The ledger is deliberately strict. Discovered, verified, building, submitted, accepted, and pending payment still count as zero revenue. Only a settled event with external payment evidence is recognized. Duplicate receipts are ignored, and refunds or chargebacks reverse the total."
    ),
    Slide(
        kicker: "BUILT WITH CODEX + GPT-5.6",
        title: "Proof before pursuit.\nSettlement before success.",
        narration: "Codex and GPT five point six helped research, verify, build, test, and present the system. Reversible zero-cost work can stay autonomous, while identity, contracts, spending, and payout remain owner controlled. Not Revenue Yet: proof before pursuit, settlement before success."
    ),
]

private enum Palette {
    static let ink = NSColor(calibratedRed: 0.035, green: 0.051, blue: 0.067, alpha: 1)
    static let panel = NSColor(calibratedRed: 0.067, green: 0.086, blue: 0.106, alpha: 0.96)
    static let panelSoft = NSColor(calibratedRed: 0.095, green: 0.118, blue: 0.139, alpha: 0.92)
    static let white = NSColor(calibratedWhite: 0.98, alpha: 1)
    static let muted = NSColor(calibratedRed: 0.63, green: 0.68, blue: 0.71, alpha: 1)
    static let lime = NSColor(calibratedRed: 0.78, green: 1.0, blue: 0.35, alpha: 1)
    static let limeSoft = NSColor(calibratedRed: 0.78, green: 1.0, blue: 0.35, alpha: 0.13)
    static let coral = NSColor(calibratedRed: 1.0, green: 0.38, blue: 0.34, alpha: 1)
    static let coralSoft = NSColor(calibratedRed: 1.0, green: 0.38, blue: 0.34, alpha: 0.13)
    static let amber = NSColor(calibratedRed: 1.0, green: 0.72, blue: 0.24, alpha: 1)
    static let cyan = NSColor(calibratedRed: 0.30, green: 0.84, blue: 0.94, alpha: 1)
}

private final class SlideRenderer {
    private let productionImagePaths: [String]
    private(set) var usedProductionBackground = false

    init(repositoryRoot: URL) {
        productionImagePaths = [
            repositoryRoot.appendingPathComponent("assets/not-revenue-yet-hero.jpg").path,
            "/private/tmp/not-revenue-yet-production.png",
        ]
    }

    func renderAll() throws -> [CGImage] {
        guard slides.count == 7 else {
            throw RenderError.failed("Expected exactly seven slide definitions.")
        }
        return try slides.indices.map(renderSlide)
    }

    private func renderSlide(index: Int) throws -> CGImage {
        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: canvasWidth,
            pixelsHigh: canvasHeight,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: canvasWidth * 4,
            bitsPerPixel: 32
        ), let graphics = NSGraphicsContext(bitmapImageRep: bitmap) else {
            throw RenderError.failed("Unable to allocate the slide canvas.")
        }

        bitmap.size = NSSize(width: canvasWidth, height: canvasHeight)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = graphics
        defer {
            NSGraphicsContext.current = nil
            NSGraphicsContext.restoreGraphicsState()
        }

        if index == 0 {
            drawHero()
        } else {
            drawBase(index: index)
            switch index {
            case 1: drawAudit()
            case 2: drawRealityGate()
            case 3: drawAdversarialEconomics()
            case 4: drawFourGates()
            case 5: drawLedger()
            case 6: drawClose()
            default: throw RenderError.failed("Unsupported slide index \(index).")
            }
        }

        drawProgress(index: index)
        guard let image = bitmap.cgImage else {
            throw RenderError.failed("Unable to materialize slide \(index + 1).")
        }
        return image
    }

    private func drawHero() {
        let bounds = NSRect(x: 0, y: 0, width: canvasWidth, height: canvasHeight)
        Palette.ink.setFill()
        bounds.fill()

        if let image = productionImagePaths.lazy.compactMap({ path -> NSImage? in
            guard FileManager.default.fileExists(atPath: path),
                  let candidate = NSImage(contentsOfFile: path),
                  candidate.size.width > 0,
                  candidate.size.height > 0 else {
                return nil
            }
            return candidate
        }).first {
            usedProductionBackground = true
            NSGraphicsContext.saveGraphicsState()
            NSBezierPath(rect: bounds).addClip()
            let scale = max(bounds.width / image.size.width, bounds.height / image.size.height)
            let size = NSSize(width: image.size.width * scale, height: image.size.height * scale)
            let destination = NSRect(
                x: (bounds.width - size.width) / 2,
                y: (bounds.height - size.height) / 2,
                width: size.width,
                height: size.height
            )
            image.draw(
                in: destination,
                from: .zero,
                operation: .sourceOver,
                fraction: 0.86,
                respectFlipped: false,
                hints: [.interpolation: NSImageInterpolation.high]
            )
            NSGraphicsContext.restoreGraphicsState()
        } else {
            drawGlow(center: NSPoint(x: 1030, y: 580), radius: 380, color: Palette.lime.withAlphaComponent(0.22))
            drawGlow(center: NSPoint(x: 190, y: 80), radius: 320, color: Palette.cyan.withAlphaComponent(0.14))
        }

        let overlay = NSGradient(
            colors: [
                Palette.ink.withAlphaComponent(0.96),
                Palette.ink.withAlphaComponent(0.77),
                Palette.ink.withAlphaComponent(0.28),
            ]
        )
        overlay?.draw(in: bounds, angle: 0)

        roundedRect(
            NSRect(x: 64, y: 622, width: 245, height: 34),
            radius: 17,
            fill: Palette.lime,
            stroke: nil
        )
        drawText(
            "OPENAI BUILD WEEK 2026",
            in: NSRect(x: 78, y: 630, width: 218, height: 18),
            font: .monospacedSystemFont(ofSize: 13, weight: .semibold),
            color: Palette.ink,
            kern: 0.8
        )

        drawText(
            "NOT REVENUE YET",
            in: NSRect(x: 64, y: 547, width: 620, height: 38),
            font: .systemFont(ofSize: 25, weight: .bold),
            color: Palette.white,
            kern: 3.0
        )
        drawText(
            slides[0].title,
            in: NSRect(x: 58, y: 265, width: 720, height: 250),
            font: .systemFont(ofSize: 70, weight: .heavy),
            color: Palette.white,
            lineSpacing: -3
        )
        drawText(
            "A proof-first operating layer for autonomous earning.",
            in: NSRect(x: 64, y: 209, width: 620, height: 34),
            font: .systemFont(ofSize: 22, weight: .medium),
            color: Palette.muted
        )
        roundedRect(
            NSRect(x: 64, y: 130, width: 475, height: 54),
            radius: 14,
            fill: Palette.ink.withAlphaComponent(0.78),
            stroke: Palette.white.withAlphaComponent(0.18),
            lineWidth: 1
        )
        drawText(
            "PROOF BEFORE PURSUIT  →  SETTLEMENT BEFORE SUCCESS",
            in: NSRect(x: 84, y: 149, width: 438, height: 18),
            font: .monospacedSystemFont(ofSize: 12.5, weight: .semibold),
            color: Palette.lime,
            kern: 0.25
        )
    }

    private func drawBase(index: Int) {
        let bounds = NSRect(x: 0, y: 0, width: canvasWidth, height: canvasHeight)
        Palette.ink.setFill()
        bounds.fill()
        drawGlow(center: NSPoint(x: 1140, y: 630), radius: 390, color: Palette.lime.withAlphaComponent(0.10))
        drawGlow(center: NSPoint(x: 70, y: 40), radius: 310, color: Palette.cyan.withAlphaComponent(0.075))

        drawText(
            slides[index].kicker,
            in: NSRect(x: 64, y: 646, width: 660, height: 22),
            font: .monospacedSystemFont(ofSize: 13, weight: .bold),
            color: Palette.lime,
            kern: 1.35
        )
        drawText(
            String(format: "%02d / 07", index + 1),
            in: NSRect(x: 1120, y: 646, width: 96, height: 22),
            font: .monospacedSystemFont(ofSize: 13, weight: .medium),
            color: Palette.muted,
            alignment: .right,
            kern: 0.8
        )
        drawLine(from: NSPoint(x: 64, y: 627), to: NSPoint(x: 1216, y: 627), color: Palette.white.withAlphaComponent(0.10), width: 1)
    }

    private func drawAudit() {
        drawText(
            slides[1].title,
            in: NSRect(x: 58, y: 492, width: 820, height: 118),
            font: .systemFont(ofSize: 54, weight: .heavy),
            color: Palette.white,
            lineSpacing: -2
        )

        metricCard(x: 64, value: "4", label: "LIVE-LOOKING LISTINGS", accent: Palette.cyan)
        metricCard(x: 354, value: "$1.16M", label: "ADVERTISED VALUE", accent: Palette.amber)
        metricCard(x: 644, value: "$0", label: "SETTLED REVENUE", accent: Palette.lime)

        roundedRect(NSRect(x: 934, y: 377, width: 282, height: 213), radius: 22, fill: Palette.panel, stroke: Palette.white.withAlphaComponent(0.10))
        drawText("WHAT LIVE CHECKS FOUND", in: NSRect(x: 958, y: 548, width: 236, height: 20), font: .monospacedSystemFont(ofSize: 12, weight: .bold), color: Palette.muted, kern: 0.75)
        evidenceLine(y: 500, symbol: "×", text: "2 targets already complete", color: Palette.coral)
        evidenceLine(y: 451, symbol: "!", text: "1 implausible reward", color: Palette.amber)
        evidenceLine(y: 402, symbol: "0", text: "0 payment receipts", color: Palette.lime)

        let rows: [(String, String, String, NSColor)] = [
            ("CASE A #24635", "$1,880", "CLOSED + MERGED", Palette.coral),
            ("CASE B #7", "$1,500", "DELETED + BUILT", Palette.coral),
            ("CASE C", "$1,160,036", "TRUST MISMATCH", Palette.amber),
            ("CASE D #10", "$500", "CROWDED", Palette.amber),
        ]
        for (offset, row) in rows.enumerated() {
            let y = 270 - CGFloat(offset * 56)
            roundedRect(NSRect(x: 64, y: y, width: 1152, height: 45), radius: 12, fill: Palette.panelSoft, stroke: Palette.white.withAlphaComponent(0.07))
            drawText(row.0, in: NSRect(x: 84, y: y + 14, width: 260, height: 18), font: .monospacedSystemFont(ofSize: 13, weight: .semibold), color: Palette.white)
            drawText(row.1, in: NSRect(x: 420, y: y + 12, width: 210, height: 22), font: .monospacedSystemFont(ofSize: 16, weight: .bold), color: Palette.white, alignment: .right)
            pill(row.2, rect: NSRect(x: 940, y: y + 9, width: 250, height: 27), color: row.3)
        }
    }

    private func drawRealityGate() {
        drawText(slides[2].title, in: NSRect(x: 58, y: 524, width: 760, height: 72), font: .systemFont(ofSize: 58, weight: .heavy), color: Palette.white)
        drawText("Aggregator claims are evidence inputs—not instructions.", in: NSRect(x: 64, y: 482, width: 740, height: 30), font: .systemFont(ofSize: 20, weight: .medium), color: Palette.muted)

        roundedRect(NSRect(x: 64, y: 126, width: 772, height: 322), radius: 24, fill: Palette.panel, stroke: Palette.white.withAlphaComponent(0.10))
        drawText("AGGREGATOR LISTING", in: NSRect(x: 92, y: 404, width: 220, height: 20), font: .monospacedSystemFont(ofSize: 12, weight: .bold), color: Palette.amber, kern: 0.9)
        drawText("$1,880", in: NSRect(x: 92, y: 342, width: 250, height: 54), font: .monospacedSystemFont(ofSize: 43, weight: .bold), color: Palette.white)
        drawText("Support configurable permissions\nof automatic job tokens", in: NSRect(x: 356, y: 337, width: 440, height: 62), font: .systemFont(ofSize: 21, weight: .semibold), color: Palette.white, lineSpacing: 2)
        drawLine(from: NSPoint(x: 92, y: 311), to: NSPoint(x: 808, y: 311), color: Palette.white.withAlphaComponent(0.10), width: 1)
        checkRow(y: 266, label: "Canonical issue", value: "CLOSED", color: Palette.coral)
        checkRow(y: 218, label: "Implementation", value: "MERGED", color: Palette.coral)
        checkRow(y: 170, label: "Competing attempts", value: "REJECTED", color: Palette.coral)

        roundedRect(NSRect(x: 870, y: 126, width: 346, height: 322), radius: 24, fill: Palette.coralSoft, stroke: Palette.coral.withAlphaComponent(0.45), lineWidth: 1.5)
        pill("REALITY GATE", rect: NSRect(x: 900, y: 382, width: 150, height: 30), color: Palette.coral)
        drawText("BLOCK", in: NSRect(x: 900, y: 274, width: 286, height: 82), font: .systemFont(ofSize: 66, weight: .heavy), color: Palette.coral)
        drawText("Do not claim.\nDo not build.\nSave days of wasted work.", in: NSRect(x: 902, y: 165, width: 265, height: 94), font: .systemFont(ofSize: 20, weight: .medium), color: Palette.white, lineSpacing: 5)
    }

    private func drawAdversarialEconomics() {
        drawText(slides[3].title, in: NSRect(x: 58, y: 489, width: 805, height: 118), font: .systemFont(ofSize: 48, weight: .heavy), color: Palette.white, lineSpacing: -1)

        roundedRect(NSRect(x: 64, y: 126, width: 620, height: 325), radius: 24, fill: Palette.panel, stroke: Palette.white.withAlphaComponent(0.10))
        drawText("ADVERTISED REWARD", in: NSRect(x: 92, y: 405, width: 260, height: 20), font: .monospacedSystemFont(ofSize: 12, weight: .bold), color: Palette.muted, kern: 0.9)
        drawText("$1,160,036", in: NSRect(x: 88, y: 319, width: 560, height: 74), font: .monospacedSystemFont(ofSize: 55, weight: .bold), color: Palette.amber)
        drawText("Scope supplied:", in: NSRect(x: 92, y: 268, width: 210, height: 24), font: .systemFont(ofSize: 16, weight: .medium), color: Palette.muted)
        roundedRect(NSRect(x: 92, y: 207, width: 564, height: 50), radius: 10, fill: Palette.ink, stroke: Palette.white.withAlphaComponent(0.12))
        drawText("\"build this thing\"", in: NSRect(x: 110, y: 221, width: 520, height: 23), font: .monospacedSystemFont(ofSize: 18, weight: .semibold), color: Palette.white)
        drawText("Near-empty repository • 19 characters of scope", in: NSRect(x: 92, y: 158, width: 555, height: 24), font: .systemFont(ofSize: 17, weight: .medium), color: Palette.muted)

        let risks: [(String, String, NSColor)] = [
            ("FUNDING", "UNKNOWN", Palette.amber),
            ("LICENSE", "MISSING", Palette.coral),
            ("ACCEPTANCE", "UNCLEAR", Palette.amber),
            ("REWARD / TRUST", "EXTREME", Palette.coral),
        ]
        for (i, risk) in risks.enumerated() {
            let y = 371 - CGFloat(i * 70)
            roundedRect(NSRect(x: 720, y: y, width: 496, height: 54), radius: 14, fill: risk.2.withAlphaComponent(0.10), stroke: risk.2.withAlphaComponent(0.32))
            drawText(risk.0, in: NSRect(x: 742, y: y + 18, width: 228, height: 20), font: .monospacedSystemFont(ofSize: 12.5, weight: .semibold), color: Palette.muted, kern: 0.6)
            drawText(risk.1, in: NSRect(x: 980, y: y + 16, width: 210, height: 22), font: .monospacedSystemFont(ofSize: 15, weight: .bold), color: risk.2, alignment: .right)
        }
        pill("SKIP", rect: NSRect(x: 1034, y: 126, width: 182, height: 47), color: Palette.coral)
    }

    private func drawFourGates() {
        drawText(slides[4].title, in: NSRect(x: 58, y: 524, width: 760, height: 72), font: .systemFont(ofSize: 58, weight: .heavy), color: Palette.white)
        drawText("One evidence contract across skill, CLI, tests, and browser.", in: NSRect(x: 64, y: 482, width: 740, height: 30), font: .systemFont(ofSize: 20, weight: .medium), color: Palette.muted)

        let gates: [(String, String, NSColor)] = [
            ("01  REALITY", "Open? Current? Licensed?\nAlready completed?", Palette.cyan),
            ("02  PAYOUT", "Escrowed? Platform-backed?\nPromised? Settled?", Palette.lime),
            ("03  AUTHORITY", "Zero-cost and reversible?\nOwner identity or funds?", Palette.amber),
            ("04  SAFETY", "Injection? Credentials?\nProhibited or harmful work?", Palette.coral),
        ]
        for (i, gate) in gates.enumerated() {
            let column = i % 2
            let row = i / 2
            let x = 64 + CGFloat(column) * 386
            let y = 313 - CGFloat(row) * 166
            roundedRect(NSRect(x: x, y: y, width: 354, height: 142), radius: 20, fill: Palette.panel, stroke: gate.2.withAlphaComponent(0.30), lineWidth: 1.2)
            drawText(gate.0, in: NSRect(x: x + 22, y: y + 101, width: 310, height: 20), font: .monospacedSystemFont(ofSize: 13, weight: .bold), color: gate.2, kern: 0.7)
            drawText(gate.1, in: NSRect(x: x + 22, y: y + 39, width: 310, height: 52), font: .systemFont(ofSize: 18, weight: .medium), color: Palette.white, lineSpacing: 3)
        }

        roundedRect(NSRect(x: 836, y: 147, width: 380, height: 308), radius: 24, fill: Palette.panel, stroke: Palette.white.withAlphaComponent(0.10))
        drawText("DETERMINISTIC OUTPUT", in: NSRect(x: 864, y: 413, width: 320, height: 20), font: .monospacedSystemFont(ofSize: 12, weight: .bold), color: Palette.muted, kern: 0.8)
        let outputs: [(String, NSColor)] = [("PURSUE", Palette.lime), ("VERIFY", Palette.cyan), ("SKIP", Palette.amber), ("BLOCK", Palette.coral)]
        for (i, output) in outputs.enumerated() {
            pill(output.0, rect: NSRect(x: 864, y: 354 - CGFloat(i * 51), width: 132, height: 32), color: output.1)
            if i == 1 {
                drawText("+ safest authorized next action", in: NSRect(x: 1010, y: 309, width: 178, height: 38), font: .systemFont(ofSize: 14, weight: .medium), color: Palette.muted, lineSpacing: 2)
            }
        }
        roundedRect(NSRect(x: 864, y: 172, width: 324, height: 52), radius: 10, fill: Palette.ink, stroke: Palette.white.withAlphaComponent(0.10))
        drawText("$ not-revenue-yet vet <issue>", in: NSRect(x: 881, y: 190, width: 292, height: 18), font: .monospacedSystemFont(ofSize: 13, weight: .medium), color: Palette.lime)
    }

    private func drawLedger() {
        drawText(slides[5].title, in: NSRect(x: 58, y: 524, width: 760, height: 72), font: .systemFont(ofSize: 58, weight: .heavy), color: Palette.white)
        drawText("Revenue recognition requires settlement + external evidence.", in: NSRect(x: 64, y: 482, width: 820, height: 30), font: .systemFont(ofSize: 20, weight: .medium), color: Palette.muted)

        let stages = ["DISCOVERED", "VERIFIED", "BUILDING", "SUBMITTED", "ACCEPTED", "SETTLED"]
        let startX: CGFloat = 74
        let y: CGFloat = 365
        drawLine(from: NSPoint(x: startX + 12, y: y + 13), to: NSPoint(x: 1178, y: y + 13), color: Palette.white.withAlphaComponent(0.17), width: 3)
        for (i, stage) in stages.enumerated() {
            let x = startX + CGFloat(i) * 219
            let isSettled = i == stages.count - 1
            let color = isSettled ? Palette.lime : Palette.muted
            roundedRect(NSRect(x: x, y: y, width: 26, height: 26), radius: 13, fill: isSettled ? Palette.lime : Palette.panelSoft, stroke: color.withAlphaComponent(0.65), lineWidth: 1.5)
            drawText(stage, in: NSRect(x: x - 44, y: y - 35, width: 115, height: 19), font: .monospacedSystemFont(ofSize: 10.5, weight: .bold), color: color, alignment: .center, kern: 0.25)
            drawText(isSettled ? "$" : "$0", in: NSRect(x: x - 30, y: y + 43, width: 86, height: 25), font: .monospacedSystemFont(ofSize: isSettled ? 17 : 14, weight: .bold), color: color, alignment: .center)
        }

        let cards: [(String, String, NSColor)] = [
            ("$15,000 PROMISE", "$0 REVENUE", Palette.amber),
            ("WORK ACCEPTED", "$0 REVENUE", Palette.cyan),
            ("PAYMENT PENDING", "$0 REVENUE", Palette.coral),
        ]
        for (i, card) in cards.enumerated() {
            let x = 64 + CGFloat(i) * 388
            roundedRect(NSRect(x: x, y: 150, width: 356, height: 123), radius: 19, fill: Palette.panel, stroke: card.2.withAlphaComponent(0.26))
            drawText(card.0, in: NSRect(x: x + 22, y: 226, width: 312, height: 20), font: .monospacedSystemFont(ofSize: 12, weight: .bold), color: Palette.muted, kern: 0.4)
            drawText(card.1, in: NSRect(x: x + 22, y: 176, width: 312, height: 36), font: .monospacedSystemFont(ofSize: 25, weight: .bold), color: card.2)
        }
        drawText("Duplicate receipts are ignored  •  Refunds and chargebacks reverse the total", in: NSRect(x: 64, y: 102, width: 1152, height: 24), font: .systemFont(ofSize: 16, weight: .medium), color: Palette.muted, alignment: .center)
    }

    private func drawClose() {
        drawGlow(center: NSPoint(x: 640, y: 335), radius: 450, color: Palette.lime.withAlphaComponent(0.12))
        pill("CODEX + GPT-5.6", rect: NSRect(x: 514, y: 532, width: 252, height: 38), color: Palette.lime)
        drawText(slides[6].title, in: NSRect(x: 170, y: 310, width: 940, height: 185), font: .systemFont(ofSize: 60, weight: .heavy), color: Palette.white, alignment: .center, lineSpacing: -2)
        drawText("Reversible zero-cost work can stay autonomous.", in: NSRect(x: 250, y: 255, width: 780, height: 30), font: .systemFont(ofSize: 21, weight: .semibold), color: Palette.white, alignment: .center)
        drawText("Identity  •  contracts  •  spending  •  payout remain owner-controlled", in: NSRect(x: 210, y: 210, width: 860, height: 26), font: .monospacedSystemFont(ofSize: 14, weight: .medium), color: Palette.muted, alignment: .center, kern: 0.2)
        roundedRect(NSRect(x: 304, y: 132, width: 672, height: 49), radius: 13, fill: Palette.panel, stroke: Palette.white.withAlphaComponent(0.10))
        drawText("not-revenue-yet.austinhan.chatgpt.site", in: NSRect(x: 324, y: 147, width: 632, height: 22), font: .monospacedSystemFont(ofSize: 16, weight: .semibold), color: Palette.lime, alignment: .center)
    }

    private func metricCard(x: CGFloat, value: String, label: String, accent: NSColor) {
        roundedRect(NSRect(x: x, y: 377, width: 258, height: 101), radius: 18, fill: accent.withAlphaComponent(0.08), stroke: accent.withAlphaComponent(0.30))
        drawText(value, in: NSRect(x: x + 20, y: 422, width: 218, height: 40), font: .monospacedSystemFont(ofSize: 31, weight: .bold), color: accent)
        drawText(label, in: NSRect(x: x + 20, y: 396, width: 218, height: 17), font: .monospacedSystemFont(ofSize: 10.5, weight: .semibold), color: Palette.muted, kern: 0.35)
    }

    private func evidenceLine(y: CGFloat, symbol: String, text: String, color: NSColor) {
        roundedRect(NSRect(x: 958, y: y - 1, width: 25, height: 25), radius: 12.5, fill: color, stroke: nil)
        drawText(symbol, in: NSRect(x: 958, y: y + 4, width: 25, height: 17), font: .monospacedSystemFont(ofSize: 12, weight: .bold), color: Palette.ink, alignment: .center)
        drawText(text, in: NSRect(x: 996, y: y + 2, width: 196, height: 22), font: .systemFont(ofSize: 15, weight: .semibold), color: Palette.white)
    }

    private func checkRow(y: CGFloat, label: String, value: String, color: NSColor) {
        drawText(label, in: NSRect(x: 92, y: y, width: 270, height: 22), font: .systemFont(ofSize: 17, weight: .medium), color: Palette.muted)
        drawText(value, in: NSRect(x: 552, y: y, width: 228, height: 22), font: .monospacedSystemFont(ofSize: 15, weight: .bold), color: color, alignment: .right, kern: 0.4)
    }

    private func drawProgress(index: Int) {
        let segmentWidth: CGFloat = 38
        let gap: CGFloat = 8
        let totalWidth = CGFloat(slides.count) * segmentWidth + CGFloat(slides.count - 1) * gap
        let startX = CGFloat(canvasWidth) - 64 - totalWidth
        for i in slides.indices {
            let color = i <= index ? Palette.lime : Palette.white.withAlphaComponent(0.14)
            roundedRect(NSRect(x: startX + CGFloat(i) * (segmentWidth + gap), y: 43, width: segmentWidth, height: 4), radius: 2, fill: color, stroke: nil)
        }
        drawText("NOT REVENUE YET", in: NSRect(x: 64, y: 34, width: 240, height: 20), font: .monospacedSystemFont(ofSize: 10.5, weight: .bold), color: Palette.muted, kern: 1.2)
    }

    private func pill(_ text: String, rect: NSRect, color: NSColor) {
        roundedRect(rect, radius: rect.height / 2, fill: color, stroke: nil)
        drawText(text, in: NSRect(x: rect.minX + 10, y: rect.minY + (rect.height - 18) / 2 + 1, width: rect.width - 20, height: 18), font: .monospacedSystemFont(ofSize: 12.5, weight: .bold), color: Palette.ink, alignment: .center, kern: 0.45)
    }

    private func roundedRect(_ rect: NSRect, radius: CGFloat, fill: NSColor, stroke: NSColor?, lineWidth: CGFloat = 1) {
        let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
        fill.setFill()
        path.fill()
        if let stroke {
            stroke.setStroke()
            path.lineWidth = lineWidth
            path.stroke()
        }
    }

    private func drawLine(from: NSPoint, to: NSPoint, color: NSColor, width: CGFloat) {
        let path = NSBezierPath()
        path.move(to: from)
        path.line(to: to)
        path.lineWidth = width
        path.lineCapStyle = .round
        color.setStroke()
        path.stroke()
    }

    private func drawGlow(center: NSPoint, radius: CGFloat, color: NSColor) {
        guard let context = NSGraphicsContext.current?.cgContext,
              let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [color.cgColor, color.withAlphaComponent(0).cgColor] as CFArray,
                locations: [0, 1]
              ) else { return }
        context.saveGState()
        context.drawRadialGradient(
            gradient,
            startCenter: center,
            startRadius: 0,
            endCenter: center,
            endRadius: radius,
            options: [.drawsAfterEndLocation]
        )
        context.restoreGState()
    }

    private func drawText(
        _ text: String,
        in rect: NSRect,
        font: NSFont,
        color: NSColor,
        alignment: NSTextAlignment = .left,
        lineSpacing: CGFloat = 0,
        kern: CGFloat = 0
    ) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.lineSpacing = lineSpacing
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph,
            .kern: kern,
        ]
        (text as NSString).draw(
            with: rect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes
        )
    }
}

private func runProcess(_ executable: String, arguments: [String]) throws {
    let process = Process()
    let stderr = Pipe()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = arguments
    process.standardOutput = FileHandle.nullDevice
    process.standardError = stderr
    try process.run()
    process.waitUntilExit()
    guard process.terminationStatus == 0 else {
        let data = stderr.fileHandleForReading.readDataToEndOfFile()
        let message = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "unknown error"
        throw RenderError.failed("\(executable) failed with status \(process.terminationStatus): \(message)")
    }
}

private func synthesizeNarration(into directory: URL) async throws -> [NarrationClip] {
    var clips: [NarrationClip] = []
    for (index, slide) in slides.enumerated() {
        let url = directory.appendingPathComponent(String(format: "narration-%02d.aiff", index + 1))
        print("[audio] Synthesizing narration \(index + 1)/\(slides.count)…")
        try runProcess("/usr/bin/say", arguments: ["-r", "176", "-o", url.path, slide.narration])
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        guard let size = attributes[.size] as? NSNumber, size.uint64Value > 0 else {
            throw RenderError.failed("Narration \(index + 1) was not created.")
        }
        let asset = AVURLAsset(url: url)
        let duration = try await asset.load(.duration)
        let seconds = CMTimeGetSeconds(duration)
        guard seconds.isFinite, seconds > 1 else {
            throw RenderError.failed("Narration \(index + 1) has an invalid duration.")
        }
        clips.append(NarrationClip(url: url, duration: duration))
    }
    guard clips.count == 7 else {
        throw RenderError.failed("Expected seven narration clips; created \(clips.count).")
    }
    return clips
}

private func makePixelBuffer(
    from layers: [(image: CGImage, alpha: CGFloat)],
    pool: CVPixelBufferPool
) throws -> CVPixelBuffer {
    var optionalBuffer: CVPixelBuffer?
    let status = CVPixelBufferPoolCreatePixelBuffer(nil, pool, &optionalBuffer)
    guard status == kCVReturnSuccess, let buffer = optionalBuffer else {
        throw RenderError.failed("Unable to allocate a video frame (CoreVideo \(status)).")
    }

    CVPixelBufferLockBaseAddress(buffer, [])
    defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
    guard let baseAddress = CVPixelBufferGetBaseAddress(buffer) else {
        throw RenderError.failed("Video frame has no writable memory.")
    }

    let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
    guard let context = CGContext(
        data: baseAddress,
        width: canvasWidth,
        height: canvasHeight,
        bitsPerComponent: 8,
        bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: bitmapInfo
    ) else {
        throw RenderError.failed("Unable to create a video-frame graphics context.")
    }

    context.setFillColor(Palette.ink.cgColor)
    context.fill(CGRect(x: 0, y: 0, width: canvasWidth, height: canvasHeight))
    for layer in layers {
        context.saveGState()
        context.setAlpha(layer.alpha)
        context.draw(layer.image, in: CGRect(x: 0, y: 0, width: canvasWidth, height: canvasHeight))
        context.restoreGState()
    }
    return buffer
}

private func writeSilentVideo(
    images: [CGImage],
    slideDurations: [Double],
    outputURL: URL
) async throws {
    guard images.count == slideDurations.count, images.count == 7 else {
        throw RenderError.failed("Video input counts do not match.")
    }
    try? FileManager.default.removeItem(at: outputURL)

    let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
    let compression: [String: Any] = [
        AVVideoAverageBitRateKey: 5_500_000,
        AVVideoExpectedSourceFrameRateKey: Int(framesPerSecond),
        AVVideoMaxKeyFrameIntervalKey: Int(framesPerSecond * 2),
        AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
    ]
    let settings: [String: Any] = [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: canvasWidth,
        AVVideoHeightKey: canvasHeight,
        AVVideoCompressionPropertiesKey: compression,
    ]
    let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
    input.expectsMediaDataInRealTime = false
    let attributes: [String: Any] = [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
        kCVPixelBufferWidthKey as String: canvasWidth,
        kCVPixelBufferHeightKey as String: canvasHeight,
        kCVPixelBufferCGImageCompatibilityKey as String: true,
        kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
    ]
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(
        assetWriterInput: input,
        sourcePixelBufferAttributes: attributes
    )
    guard writer.canAdd(input) else {
        throw RenderError.failed("AVAssetWriter cannot accept the H.264 video input.")
    }
    writer.add(input)
    guard writer.startWriting() else {
        throw RenderError.failed("Unable to start H.264 encoding: \(writer.error?.localizedDescription ?? "unknown error")")
    }
    writer.startSession(atSourceTime: .zero)
    guard let pool = adaptor.pixelBufferPool else {
        throw RenderError.failed("AVAssetWriter did not create a pixel-buffer pool.")
    }

    let staticBuffers = try images.map { try makePixelBuffer(from: [($0, 1)], pool: pool) }
    let totalDuration = slideDurations.reduce(0, +)
    let frameCount = Int(ceil(totalDuration * Double(framesPerSecond)))
    var starts: [Double] = []
    var cursor = 0.0
    for duration in slideDurations {
        starts.append(cursor)
        cursor += duration
    }

    print("[video] Encoding \(frameCount) frames at \(framesPerSecond) fps…")
    var lastReported = -1
    for frame in 0..<frameCount {
        while !input.isReadyForMoreMediaData {
            if writer.status == .failed || writer.status == .cancelled {
                throw RenderError.failed("H.264 encoding stopped: \(writer.error?.localizedDescription ?? "unknown error")")
            }
            try await Task.sleep(nanoseconds: 2_000_000)
        }

        let seconds = Double(frame) / Double(framesPerSecond)
        var slideIndex = starts.count - 1
        for candidate in starts.indices where seconds < starts[candidate] + slideDurations[candidate] {
            slideIndex = candidate
            break
        }
        let localTime = seconds - starts[slideIndex]
        let transitionStart = slideDurations[slideIndex] - transitionSeconds
        let frameBuffer: CVPixelBuffer
        if slideIndex < images.count - 1, localTime >= transitionStart {
            let progress = min(1, max(0, (localTime - transitionStart) / transitionSeconds))
            frameBuffer = try autoreleasepool {
                try makePixelBuffer(
                    from: [
                        (images[slideIndex], CGFloat(1 - progress)),
                        (images[slideIndex + 1], CGFloat(progress)),
                    ],
                    pool: pool
                )
            }
        } else {
            frameBuffer = staticBuffers[slideIndex]
        }

        let presentationTime = CMTime(value: Int64(frame), timescale: framesPerSecond)
        guard adaptor.append(frameBuffer, withPresentationTime: presentationTime) else {
            throw RenderError.failed("Failed to append frame \(frame): \(writer.error?.localizedDescription ?? "unknown error")")
        }

        let percent = Int((Double(frame + 1) / Double(frameCount)) * 100)
        if percent / 10 != lastReported / 10 {
            lastReported = percent
            print("[video] \(min(percent, 100))%")
        }
    }

    input.markAsFinished()
    await writer.finishWriting()
    guard writer.status == .completed else {
        throw RenderError.failed("H.264 writer failed: \(writer.error?.localizedDescription ?? "unknown error")")
    }
}

private func muxNarration(
    silentVideoURL: URL,
    clips: [NarrationClip],
    slideDurations: [Double],
    outputURL: URL
) async throws {
    try? FileManager.default.removeItem(at: outputURL)
    let composition = AVMutableComposition()

    let videoAsset = AVURLAsset(url: silentVideoURL)
    guard let sourceVideo = try await videoAsset.loadTracks(withMediaType: .video).first,
          let destinationVideo = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
          ) else {
        throw RenderError.failed("Silent video does not contain a usable video track.")
    }
    let intendedDuration = CMTime(seconds: slideDurations.reduce(0, +), preferredTimescale: 600)
    let sourceDuration = try await videoAsset.load(.duration)
    let insertedDuration = CMTimeMinimum(sourceDuration, intendedDuration)
    try destinationVideo.insertTimeRange(
        CMTimeRange(start: .zero, duration: insertedDuration),
        of: sourceVideo,
        at: .zero
    )

    guard let destinationAudio = composition.addMutableTrack(
        withMediaType: .audio,
        preferredTrackID: kCMPersistentTrackID_Invalid
    ) else {
        throw RenderError.failed("Unable to create the narration track.")
    }

    var slideStart = CMTime.zero
    for (index, clip) in clips.enumerated() {
        let asset = AVURLAsset(url: clip.url)
        guard let sourceAudio = try await asset.loadTracks(withMediaType: .audio).first else {
            throw RenderError.failed("Narration \(index + 1) has no audio track.")
        }
        let insertionTime = CMTimeAdd(slideStart, CMTime(seconds: 0.65, preferredTimescale: 600))
        try destinationAudio.insertTimeRange(
            CMTimeRange(start: .zero, duration: clip.duration),
            of: sourceAudio,
            at: insertionTime
        )
        slideStart = CMTimeAdd(
            slideStart,
            CMTime(seconds: slideDurations[index], preferredTimescale: 600)
        )
    }

    guard let exporter = AVAssetExportSession(
        asset: composition,
        presetName: AVAssetExportPresetHighestQuality
    ) else {
        throw RenderError.failed("Unable to create the MP4 export session.")
    }
    exporter.shouldOptimizeForNetworkUse = true
    print("[mux] Encoding narrated H.264/AAC MP4…")
    try await exporter.export(to: outputURL, as: .mp4)
}

private func fourCC(_ value: FourCharCode) -> String {
    let scalars = [24, 16, 8, 0].map { shift -> UnicodeScalar in
        let byte = UInt8((value >> FourCharCode(shift)) & 0xff)
        return UnicodeScalar(byte >= 32 && byte <= 126 ? byte : 63)
    }
    return String(String.UnicodeScalarView(scalars))
}

private func verifyOutput(_ url: URL, usedProductionBackground: Bool) async throws -> RenderSummary {
    let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
    guard let size = attributes[.size] as? NSNumber, size.uint64Value > 500_000 else {
        throw RenderError.failed("Final MP4 is missing or unexpectedly small.")
    }

    let asset = AVURLAsset(url: url)
    let durationTime = try await asset.load(.duration)
    let duration = CMTimeGetSeconds(durationTime)
    guard duration.isFinite, duration > 1, duration < 180 else {
        throw RenderError.failed(String(format: "Final duration %.2f seconds is not under three minutes.", duration))
    }

    guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else {
        throw RenderError.failed("Final MP4 has no video track.")
    }
    guard let audioTrack = try await asset.loadTracks(withMediaType: .audio).first else {
        throw RenderError.failed("Final MP4 has no audio track.")
    }

    let dimensions = try await videoTrack.load(.naturalSize)
    guard Int(abs(dimensions.width.rounded())) == canvasWidth,
          Int(abs(dimensions.height.rounded())) == canvasHeight else {
        throw RenderError.failed("Final video is \(dimensions.width)x\(dimensions.height), expected 1280x720.")
    }

    let videoDescriptions = try await videoTrack.load(.formatDescriptions)
    let audioDescriptions = try await audioTrack.load(.formatDescriptions)
    guard let videoDescription = videoDescriptions.first,
          let audioDescription = audioDescriptions.first else {
        throw RenderError.failed("Final MP4 format descriptions are unavailable.")
    }
    let videoCodec = fourCC(CMFormatDescriptionGetMediaSubType(videoDescription))
    let audioCodec = fourCC(CMFormatDescriptionGetMediaSubType(audioDescription))
    guard videoCodec == "avc1" || videoCodec == "avc3" else {
        throw RenderError.failed("Final video codec is \(videoCodec), expected H.264.")
    }
    // Core Media exposes MPEG-4 AAC as `aac `, while some containers surface the
    // equivalent MP4 sample-entry FourCC `mp4a`.
    guard audioCodec == "aac " || audioCodec == "mp4a" else {
        throw RenderError.failed("Final audio codec is \(audioCodec), expected AAC.")
    }

    return RenderSummary(
        outputURL: url,
        duration: duration,
        fileSize: size.uint64Value,
        videoCodec: videoCodec,
        audioCodec: audioCodec,
        dimensions: dimensions,
        usedProductionBackground: usedProductionBackground
    )
}

private func locateRepositoryRoot() throws -> URL {
    var candidate = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
    for _ in 0..<8 {
        if FileManager.default.fileExists(atPath: candidate.appendingPathComponent("package.json").path),
           FileManager.default.fileExists(atPath: candidate.appendingPathComponent("scripts/render-demo.swift").path) {
            return candidate
        }
        candidate.deleteLastPathComponent()
    }
    throw RenderError.failed("Run the renderer from the not-revenue-yet repository or one of its subdirectories.")
}

private func renderDemo() async throws -> RenderSummary {
    let root = try locateRepositoryRoot()
    let artifacts = root.appendingPathComponent("artifacts", isDirectory: true)
    try FileManager.default.createDirectory(at: artifacts, withIntermediateDirectories: true)

    let temporary = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        .appendingPathComponent("not-revenue-yet-render-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: temporary, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: temporary) }

    let clips = try await synthesizeNarration(into: temporary)
    let slideDurations = clips.map { max(10.0, CMTimeGetSeconds($0.duration) + 1.3) }
    let totalDuration = slideDurations.reduce(0, +)
    guard totalDuration < 178 else {
        throw RenderError.failed(String(format: "Narration requires %.2f seconds, leaving no safe margin below three minutes.", totalDuration))
    }
    print(String(format: "[timing] Planned duration: %.2f seconds", totalDuration))

    let renderer = SlideRenderer(repositoryRoot: root)
    print("[slides] Drawing seven 1280x720 slides…")
    let images = try renderer.renderAll()
    print("[slides] Production screenshot background: \(renderer.usedProductionBackground ? "yes" : "no (fallback artwork used)")")

    let silentVideo = temporary.appendingPathComponent("silent.mp4")
    try await writeSilentVideo(images: images, slideDurations: slideDurations, outputURL: silentVideo)

    let output = artifacts.appendingPathComponent("not-revenue-yet-build-week-demo.mp4")
    try await muxNarration(
        silentVideoURL: silentVideo,
        clips: clips,
        slideDurations: slideDurations,
        outputURL: output
    )
    return try await verifyOutput(output, usedProductionBackground: renderer.usedProductionBackground)
}

@main
private struct DemoRenderer {
    static func main() async {
        do {
            let summary = try await renderDemo()
            print("\n✓ Demo rendered successfully")
            print("  Path: \(summary.outputURL.path)")
            print(String(format: "  Duration: %.2f seconds", summary.duration))
            print(String(format: "  Size: %.2f MB", Double(summary.fileSize) / 1_000_000.0))
            print("  Video: \(summary.videoCodec) \(Int(summary.dimensions.width))x\(Int(summary.dimensions.height))")
            print("  Audio: \(summary.audioCodec)")
            print("  Production background: \(summary.usedProductionBackground ? "used" : "fallback")")
            Foundation.exit(EXIT_SUCCESS)
        } catch {
            FileHandle.standardError.write(Data("render-demo: \(error.localizedDescription)\n".utf8))
            Foundation.exit(EXIT_FAILURE)
        }
    }
}
