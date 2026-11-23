import SwiftUI

// MARK: - Design Tokens

enum DS {
    static let indigo      = Color(red: 49/255,  green: 3/255,   blue: 126/255)
    static let indigoMid   = Color(red: 88/255,  green: 54/255,  blue: 196/255)
    static let teal        = Color(red: 48/255,  green: 209/255, blue: 188/255)

    static let bgTop       = Color(red: 10/255,  green:  8/255,  blue:  28/255)
    static let bgBottom    = Color(red: 16/255,  green: 10/255,  blue:  38/255)

    static let textPrimary = Color.white
    static let textSub     = Color.white.opacity(0.50)
    static let textMicro   = Color.white.opacity(0.32)

    static let healthy     = Color(red: 52/255,  green: 211/255, blue: 153/255)
    static let unhealthy   = Color(red: 251/255, green:  99/255, blue: 107/255)

    static let r24: CGFloat = 24
    static let r16: CGFloat = 16
    static let r10: CGFloat = 10
}

// MARK: - Shared Background

struct AppBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [DS.bgTop, DS.bgBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Ambient orbs
            ZStack {
                Ellipse()
                    .fill(DS.indigo.opacity(0.35))
                    .blur(radius: 80)
                    .frame(width: 300, height: 200)
                    .offset(x: -70, y: -50)

                Ellipse()
                    .fill(DS.teal.opacity(0.10))
                    .blur(radius: 90)
                    .frame(width: 240, height: 190)
                    .offset(x: 110, y: 440)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }
}

// MARK: - Prediction Color Helper

extension String {
    var predictionColor: Color {
        self.lowercased() == "healthy" ? DS.healthy : DS.unhealthy
    }
}

// MARK: - InfoChip

struct InfoChip: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(DS.indigoMid)
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - SpinnerRing

struct SpinnerRing: View {
    @State private var angle: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 2.5)
            Circle()
                .trim(from: 0, to: 0.65)
                .stroke(
                    LinearGradient(
                        colors: [DS.teal, DS.indigoMid],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
                .rotationEffect(.degrees(angle))
                .animation(.linear(duration: 0.85).repeatForever(autoreverses: false), value: angle)
                .onAppear { angle = 360 }
        }
    }
}

// MARK: - ScanBrackets

struct ScanBrackets: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let l: CGFloat = 18
        p.move(to: .init(x: rect.minX, y: rect.minY + l))
        p.addLine(to: .init(x: rect.minX, y: rect.minY))
        p.addLine(to: .init(x: rect.minX + l, y: rect.minY))
        p.move(to: .init(x: rect.maxX - l, y: rect.minY))
        p.addLine(to: .init(x: rect.maxX, y: rect.minY))
        p.addLine(to: .init(x: rect.maxX, y: rect.minY + l))
        p.move(to: .init(x: rect.minX, y: rect.maxY - l))
        p.addLine(to: .init(x: rect.minX, y: rect.maxY))
        p.addLine(to: .init(x: rect.minX + l, y: rect.maxY))
        p.move(to: .init(x: rect.maxX - l, y: rect.maxY))
        p.addLine(to: .init(x: rect.maxX, y: rect.maxY))
        p.addLine(to: .init(x: rect.maxX, y: rect.maxY - l))
        return p
    }
}

// MARK: - Animated Confidence Bar

struct ConfidenceBar: View {
    let confidence: Double
    let color: Color

    @State private var animated: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("MODEL CONFIDENCE")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(DS.textMicro)
                    .tracking(1.5)
                Spacer()
                Text(tier)
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(color)
                    .tracking(1)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.white.opacity(0.07))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 5)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.55), color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * animated, height: 8)
                        .shadow(color: color.opacity(0.35), radius: 6)
                }
            }
            .frame(height: 8)

            HStack {
                Text("0%"); Spacer(); Text("50%"); Spacer(); Text("100%")
            }
            .font(.system(size: 9, design: .monospaced))
            .foregroundColor(DS.textMicro)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.1).delay(0.15)) {
                animated = confidence
            }
        }
        .onChange(of: confidence) { val in
            withAnimation(.easeOut(duration: 1.0)) { animated = val }
        }
    }

    private var tier: String {
        switch animated {
        case 0.90...: return "VERY HIGH"
        case 0.75...: return "HIGH"
        case 0.60...: return "MODERATE"
        default:      return "LOW"
        }
    }
}
