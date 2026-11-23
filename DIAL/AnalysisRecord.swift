import Foundation
import SwiftData

@Model
final class AnalysisRecord {
    var id: UUID
    var date: Date
    var prediction: String
    var confidence: Double
    var imageData: Data

    init(prediction: String, confidence: Double, imageData: Data) {
        self.id         = UUID()
        self.date       = Date()
        self.prediction = prediction
        self.confidence = confidence
        self.imageData  = imageData
    }

    // Convenience
    var isHealthy: Bool { prediction.lowercased() == "healthy" }

    var confidencePercent: String {
        String(format: "%.1f%%", confidence * 100)
    }

    var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}
