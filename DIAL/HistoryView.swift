import SwiftUI
import SwiftData

struct HistoryView: View {

    @Query(sort: \AnalysisRecord.date, order: .reverse)
    private var records: [AnalysisRecord]

    @Environment(\.modelContext) private var modelContext
    @State private var selectedRecord: AnalysisRecord?
    @State private var showDeleteAlert = false
    @State private var recordToDelete: AnalysisRecord?

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 6) {
                    Text("History")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(DS.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("\(records.count) analysis\(records.count == 1 ? "" : "es") stored on-device")
                        .font(.system(size: 13))
                        .foregroundColor(DS.textSub)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 24)
                .padding(.top, 64)
                .padding(.bottom, 20)

                if records.isEmpty {
                    emptyState
                } else {
                    // Stats strip
                    statsStrip
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)

                    ScrollView(showsIndicators: false) {
                        GlassEffectContainer {
                            LazyVStack(spacing: 12) {
                                ForEach(records) { record in
                                    HistoryRow(record: record)
                                        .onTapGesture { selectedRecord = record }
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                recordToDelete = record
                                                showDeleteAlert = true
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 50)
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedRecord) { record in
            HistoryDetailSheet(record: record)
        }
        .alert("Delete Analysis?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let r = recordToDelete { modelContext.delete(r) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This analysis will be permanently removed from your device.")
        }
    }

    // MARK: Stats Strip

    private var statsStrip: some View {
        let healthyCount   = records.filter(\.isHealthy).count
        let unhealthyCount = records.count - healthyCount
        let avgConfidence  = records.isEmpty ? 0.0 : records.map(\.confidence).reduce(0, +) / Double(records.count)

        return HStack(spacing: 10) {
            StatChip(
                value: "\(healthyCount)",
                label: "Healthy",
                color: DS.healthy,
                icon: "checkmark.shield.fill"
            )
            StatChip(
                value: "\(unhealthyCount)",
                label: "Unhealthy",
                color: DS.unhealthy,
                icon: "exclamationmark.triangle.fill"
            )
            StatChip(
                value: String(format: "%.0f%%", avgConfidence * 100),
                label: "Avg Confidence",
                color: DS.indigoMid,
                icon: "chart.bar.fill"
            )
        }
    }

    // MARK: Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 44, weight: .ultraLight))
                .foregroundColor(DS.textMicro)
            Text("No Analyses Yet")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(DS.textSub)
            Text("Run your first analysis on the home tab\nto see results here.")
                .font(.system(size: 13))
                .foregroundColor(DS.textMicro)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            Spacer()
        }
    }
}

// MARK: - History Row

struct HistoryRow: View {
    let record: AnalysisRecord

    var body: some View {
        HStack(spacing: 14) {
            // Thumbnail
            Group {
                if let image = UIImage(data: record.imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(DS.indigo.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(DS.textMicro)
                        )
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(record.prediction.capitalized)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(record.prediction.predictionColor)

                Text(record.formattedDate)
                    .font(.system(size: 12))
                    .foregroundColor(DS.textSub)
            }

            Spacer()

            // Confidence badge
            VStack(alignment: .trailing, spacing: 2) {
                Text(record.confidencePercent)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(DS.textPrimary)

                // Mini bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.07))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(record.prediction.predictionColor)
                            .frame(width: geo.size.width * record.confidence, height: 4)
                    }
                }
                .frame(width: 60, height: 4)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(DS.textMicro)
        }
        .padding(16)
        .glassEffect(
            .regular.tint(record.prediction.predictionColor.opacity(0.04)),
            in: RoundedRectangle(cornerRadius: DS.r16)
        )
    }
}

// MARK: - History Detail Sheet

struct HistoryDetailSheet: View {
    let record: AnalysisRecord
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                GlassEffectContainer {
                    VStack(spacing: 20) {
                        // Handle
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 36, height: 4)
                            .padding(.top, 12)

                        // Image
                        if let image = UIImage(data: record.imageData) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: DS.r16))
                                .padding(.horizontal, 20)
                        }

                        // Result card
                        VStack(spacing: 0) {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(record.prediction.predictionColor.opacity(0.14))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: record.isHealthy
                                          ? "checkmark.shield.fill"
                                          : "exclamationmark.triangle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(record.prediction.predictionColor)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Classification")
                                        .font(.system(size: 11))
                                        .foregroundColor(DS.textSub)
                                    Text(record.prediction.capitalized)
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(record.prediction.predictionColor)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(record.confidencePercent)
                                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                                        .foregroundColor(DS.textPrimary)
                                    Text("confidence")
                                        .font(.system(size: 11))
                                        .foregroundColor(DS.textSub)
                                }
                            }
                            .padding(20)

                            Divider().opacity(0.15).padding(.horizontal, 20)

                            ConfidenceBar(
                                confidence: record.confidence,
                                color: record.prediction.predictionColor
                            )
                            .padding(.horizontal, 20)
                            .padding(.vertical, 18)

                            Divider().opacity(0.15).padding(.horizontal, 20)

                            HStack {
                                Image(systemName: "calendar")
                                    .font(.system(size: 12))
                                    .foregroundColor(DS.indigoMid)
                                Text(record.formattedDate)
                                    .font(.system(size: 13))
                                    .foregroundColor(DS.textSub)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                        }
                        .glassEffect(
                            .regular.tint(record.prediction.predictionColor.opacity(0.06)),
                            in: RoundedRectangle(cornerRadius: DS.r24)
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Stat Chip

struct StatChip: View {
    let value: String
    let label: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .monospaced))
                .foregroundColor(DS.textPrimary)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(DS.textMicro)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .glassEffect(.regular.tint(color.opacity(0.06)), in: RoundedRectangle(cornerRadius: DS.r16))
    }
}
