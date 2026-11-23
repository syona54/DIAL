import SwiftUI
import SwiftData

struct ModelInfoView: View {

    @Query private var records: [AnalysisRecord]

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                GlassEffectContainer {
                    VStack(spacing: 20) {

                        // Page header
                        VStack(spacing: 6) {
                            Text("Model Info")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(DS.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Architecture, performance, and training details")
                                .font(.system(size: 13))
                                .foregroundColor(DS.textSub)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 64)

                        // Model identity card
                        identityCard
                            .padding(.horizontal, 20)

                        // Performance metrics
                        sectionHeader("Performance Metrics")
                        performanceGrid
                            .padding(.horizontal, 20)

                        // Class imbalance insight
                        insightCard
                            .padding(.horizontal, 20)

                        // Training info
                        sectionHeader("Training Details")
                        trainingCard
                            .padding(.horizontal, 20)

                        // Live usage stats
                        sectionHeader("Your Usage")
                        usageCard
                            .padding(.horizontal, 20)

                        // About ALI
                        sectionHeader("About Acute Lung Injury")
                        aboutCard
                            .padding(.horizontal, 20)
                            .padding(.bottom, 50)
                    }
                }
            }
        }
    }

    // MARK: Identity Card

    private var identityCard: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [DS.indigoMid, DS.indigo],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 26, weight: .light))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("DIALClassification")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DS.textPrimary)
                Text("YOLOv8n-cls + CoreML Conversion")
                    .font(.system(size: 13))
                    .foregroundColor(DS.textSub)
                HStack(spacing: 6) {
                    TagBadge(text: "CoreML 8",        color: DS.indigoMid)
                    TagBadge(text: "On-Device",       color: DS.teal)
                    TagBadge(text: "Transfer Learning", color: DS.healthy)
                }
                .padding(.top, 2)
            }

            Spacer()
        }
        .padding(18)
        .glassEffect(.regular.tint(DS.indigoMid.opacity(0.08)), in: RoundedRectangle(cornerRadius: DS.r24))
    }

    // MARK: Performance Grid

    private var performanceGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetricTile(label: "Val Accuracy", value: 0.87,  format: .percent,  color: DS.indigoMid)
            MetricTile(label: "Train Accuracy", value: 0.88, format: .percent, color: DS.teal)
        }
    }

    // MARK: Insight Card

    private var insightCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 13))
                .foregroundColor(DS.teal)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 5) {
                Text("Model Design")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(DS.textPrimary)
                Text("DIAL uses a YOLOv8n-cls model converted to CoreML via PyTorch tracing. Trained on 389 histology images with transfer learning from ImageNet weights, the model achieved 87% validation accuracy at epoch 11 before early stopping. The lightweight YOLOv8n architecture ensures fast on-device inference without requiring cloud connectivity.")
                    .font(.system(size: 12))
                    .foregroundColor(DS.textSub)
                    .lineSpacing(4)
            }
        }
        .padding(16)
        .glassEffect(.regular.tint(DS.teal.opacity(0.06)), in: RoundedRectangle(cornerRadius: DS.r16))
        .padding(.horizontal, 20)
    }

    // MARK: Training Card

    private var trainingCard: some View {
        VStack(spacing: 0) {
            TrainingRow(icon: "photo.stack",
                        label: "Training Samples",
                        value: "389")
            Divider().opacity(0.12).padding(.horizontal, 16)
            TrainingRow(icon: "checkmark.circle",
                        label: "Validation Samples",
                        value: "92")
            Divider().opacity(0.12).padding(.horizontal, 16)
            TrainingRow(icon: "arrow.triangle.2.circlepath",
                        label: "Epochs (Early Stop)",
                        value: "11 of 20")
            Divider().opacity(0.12).padding(.horizontal, 16)
            TrainingRow(icon: "cpu",
                        label: "Architecture",
                        value: "YOLOv8n-cls")
            Divider().opacity(0.12).padding(.horizontal, 16)
            TrainingRow(icon: "arrow.up.circle",
                        label: "Training Method",
                        value: "Transfer Learning")
            Divider().opacity(0.12).padding(.horizontal, 16)
            TrainingRow(icon: "ruler",
                        label: "Input Resolution",
                        value: "224 × 224 px")
            Divider().opacity(0.12).padding(.horizontal, 16)
            TrainingRow(icon: "tag",
                        label: "Classes",
                        value: "Healthy, Injured (ALI)")
        }
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: DS.r16))
    }

    // MARK: Usage Card

    private var usageCard: some View {
        let healthyCount   = records.filter(\.isHealthy).count
        let unhealthyCount = records.count - healthyCount
        let avgConf        = records.isEmpty ? 0.0
                             : records.map(\.confidence).reduce(0, +) / Double(records.count)

        return VStack(spacing: 0) {
            TrainingRow(icon: "number",
                        label: "Total Analyses",
                        value: "\(records.count)")
            Divider().opacity(0.12).padding(.horizontal, 16)
            TrainingRow(icon: "checkmark.shield",
                        label: "Healthy Results",
                        value: "\(healthyCount)")
            Divider().opacity(0.12).padding(.horizontal, 16)
            TrainingRow(icon: "exclamationmark.triangle",
                        label: "Injured Results",
                        value: "\(unhealthyCount)")
            Divider().opacity(0.12).padding(.horizontal, 16)
            TrainingRow(icon: "chart.bar",
                        label: "Avg Confidence",
                        value: String(format: "%.1f%%", avgConf * 100))
        }
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: DS.r16))
    }

    // MARK: About Card

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("""
Acute Lung Injury (ALI) is a severe inflammatory condition of the lungs characterized by diffuse alveolar damage. It can progress to Acute Respiratory Distress Syndrome (ARDS), a life-threatening condition with significant mortality.
""")
            .font(.system(size: 13))
            .foregroundColor(DS.textSub)
            .lineSpacing(5)

            Text("""
Histological analysis of lung tissue remains a gold-standard diagnostic method. DIAL uses a deep learning classifier trained on H&E-stained histology slides via transfer learning on a YOLOv8n-cls architecture, converted to CoreML for fully on-device inference, to identify ALI-associated tissue patterns including inflammatory infiltration and alveolar disruption.
""")
            .font(.system(size: 13))
            .foregroundColor(DS.textSub)
            .lineSpacing(5)

            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 11))
                    .foregroundColor(DS.unhealthy.opacity(0.8))
                Text("DIAL is a research tool and does not constitute a clinical diagnosis.")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(DS.textMicro)
            }
            .padding(12)
            .glassEffect(.regular.tint(DS.unhealthy.opacity(0.05)), in: RoundedRectangle(cornerRadius: DS.r10))
        }
        .padding(18)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: DS.r16))
    }

    // MARK: Section Header

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 11, weight: .semibold, design: .monospaced))
            .foregroundColor(DS.textMicro)
            .tracking(1.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 4)
    }
}

// MARK: - Supporting Views

enum MetricFormat { case percent, decimal2 }

struct MetricTile: View {
    let label: String
    var value: Double? = nil
    var format: MetricFormat = .percent
    var rawValue: String? = nil
    let color: Color

    @State private var animated: Double = 0

    private var displayString: String {
        if let raw = rawValue { return raw }
        guard let val = value else { return "—" }
        switch format {
        case .percent:  return String(format: "%.0f%%", val * 100)
        case .decimal2: return String(format: "%.2f",   val)
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(displayString)
                .font(.system(size: 26, weight: .bold, design: .monospaced))
                .foregroundColor(DS.textPrimary)

            if let val = value {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.07))
                            .frame(height: 5)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(color)
                            .frame(width: geo.size.width * animated, height: 5)
                    }
                }
                .frame(height: 5)
                .onAppear {
                    withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                        animated = val
                    }
                }
            }

            Text(label)
                .font(.system(size: 11))
                .foregroundColor(DS.textSub)
        }
        .padding(16)
        .glassEffect(.regular.tint(color.opacity(0.06)), in: RoundedRectangle(cornerRadius: DS.r16))
    }
}

struct ClassBar: View {
    let label: String
    let precision: Double
    let recall: Double
    let f1: Double
    let color: Color

    @State private var precisionAnim: Double = 0
    @State private var recallAnim: Double    = 0
    @State private var f1Anim: Double        = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Label row
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(color)
                        .frame(width: 7, height: 7)
                    Text(label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(DS.textPrimary)
                }
                Spacer()
                HStack(spacing: 12) {
                    StatLabel(title: "P", value: precision, color: color)
                    StatLabel(title: "R", value: recall,    color: color)
                    StatLabel(title: "F1", value: f1,       color: color)
                }
            }

            // Three bars: precision, recall, f1
            VStack(spacing: 6) {
                MiniBar(label: "Precision", value: precisionAnim, color: color)
                MiniBar(label: "Recall",    value: recallAnim,    color: color.opacity(0.7))
                MiniBar(label: "F1 Score",  value: f1Anim,        color: color.opacity(0.45))
            }
        }
        .padding(16)
        .glassEffect(.regular.tint(color.opacity(0.05)), in: RoundedRectangle(cornerRadius: DS.r16))
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
                precisionAnim = precision
                recallAnim    = recall
                f1Anim        = f1
            }
        }
    }
}

struct StatLabel: View {
    let title: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(spacing: 1) {
            Text(String(format: "%.0f%%", value * 100))
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 9))
                .foregroundColor(DS.textMicro)
        }
    }
}

struct MiniBar: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(DS.textMicro)
                .frame(width: 58, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geo.size.width * value, height: 6)
                        .shadow(color: color.opacity(0.3), radius: 4)
                }
            }
            .frame(height: 6)

            Text(String(format: "%.2f", value))
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(DS.textMicro)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

struct TrainingRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(DS.indigoMid)
                .frame(width: 20)
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(DS.textSub)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(DS.textPrimary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
}

struct TagBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}
