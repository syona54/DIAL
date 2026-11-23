import SwiftUI
import CoreML
import PhotosUI
import SwiftData

struct HomeView: View {

    @Environment(\.modelContext) private var modelContext

    @State private var selectedItem: PhotosPickerItem?
    @State private var inputImage: UIImage?
    @State private var prediction: String = ""
    @State private var confidence: Double = 0.0
    @State private var isAnalyzing: Bool = false
    @State private var showResult: Bool = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var scanOffset: CGFloat = -160
    @State private var scanActive: Bool = false
    @State private var showSampleSheet: Bool = false

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                GlassEffectContainer {
                    VStack(spacing: 26) {
                        header
                            .padding(.top, 52)

                        imageCard
                            .padding(.horizontal, 20)

                        sampleButton
                            .frame(maxWidth: .infinity, alignment: .center)

                        analyzeButton
                            .padding(.horizontal, 20)

                        if showResult {
                            resultCard
                                .padding(.horizontal, 20)
                                .transition(
                                    .asymmetric(
                                        insertion: .move(edge: .bottom).combined(with: .opacity),
                                        removal: .opacity
                                    )
                                )
                        }

                        disclaimer
                            .padding(.horizontal, 20)
                            .padding(.bottom, 50)
                    }
                }
            }
        }
        .onChange(of: selectedItem, perform: handleSelection)
    }

    // MARK: Header

    private var header: some View {
        HStack(alignment: .center, spacing: 14) {
            // Logo mark — transparent PNG over dark background
            Image("LogoMark")
                .resizable()
                .scaledToFit()
                .frame(width: 58, height: 58)

            // Wordmark + subtitle
            VStack(alignment: .leading, spacing: 3) {
                Text("DIAL")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(DS.textPrimary)
                    .tracking(8)

                Text("Diagnostic Image Analysis of Lungs")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(DS.textSub)
                    .tracking(0.2)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    // MARK: Image Card

    private var imageCard: some View {
        ZStack {
            Group {
                if let img = inputImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 288)
                        .clipped()
                } else {
                    emptyState.frame(height: 256)
                }
            }

            if scanActive, inputImage != nil { scanOverlay }
            if isAnalyzing                  { analyzingOverlay }
        }
        .frame(maxWidth: .infinity)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: DS.r24))
        .animation(.easeInOut(duration: 0.35), value: inputImage != nil)
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(DS.indigo.opacity(0.16))
                    .frame(width: 68, height: 68)
                    .scaleEffect(pulseScale)
                    .animation(
                        .easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                        value: pulseScale
                    )
                    .onAppear { pulseScale = 1.13 }

                Image(systemName: "lungs.fill")
                    .font(.system(size: 26, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DS.indigoMid, DS.teal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            VStack(spacing: 5) {
                Text("No Image Selected")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(DS.textPrimary)
                Text("Upload a histology slide to begin analysis")
                    .font(.system(size: 12))
                    .foregroundColor(DS.textSub)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var scanOverlay: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, DS.teal.opacity(0.80), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 2)
                .offset(y: scanOffset)
                .animation(.linear(duration: 1.6).repeatForever(autoreverses: false), value: scanOffset)

            ScanBrackets()
                .stroke(DS.teal.opacity(0.55), lineWidth: 1.5)
                .padding(18)
        }
    }

    private var analyzingOverlay: some View {
        ZStack {
            Color.clear
                .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: DS.r24))
            VStack(spacing: 11) {
                SpinnerRing().frame(width: 38, height: 38)
                Text("Analyzing")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DS.textPrimary)
                Text("Running CoreML inference")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(DS.teal)
                    .tracking(0.3)
            }
        }
    }

    // MARK: Analyze Button

    private var analyzeButton: some View {
        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
            HStack(spacing: 10) {
                Image(systemName: inputImage == nil ? "arrow.up.circle.fill" : "arrow.triangle.2.circlepath")
                    .font(.system(size: 16, weight: .semibold))
                Text(inputImage == nil ? "Select Lung Image" : "Analyze New Image")
                    .font(.system(size: 15, weight: .semibold))
                    .tracking(0.2)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: DS.r16)
                        .fill(LinearGradient(
                            colors: [DS.indigoMid, DS.indigo],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    RoundedRectangle(cornerRadius: DS.r16)
                        .fill(LinearGradient(
                            colors: [Color.white.opacity(0.13), .clear],
                            startPoint: .top,
                            endPoint: .center
                        ))
                }
            )
            .glassEffect(.regular.tint(DS.indigoMid.opacity(0.30)).interactive(), in: RoundedRectangle(cornerRadius: DS.r16))
            .shadow(color: DS.indigo.opacity(0.50), radius: 16, x: 0, y: 6)
        }
        .disabled(isAnalyzing)
        .opacity(isAnalyzing ? 0.45 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isAnalyzing)
    }

    // MARK: Result Card

    private var resultCard: some View {
        VStack(spacing: 0) {
            // Prediction row
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(prediction.predictionColor.opacity(0.14))
                        .frame(width: 44, height: 44)
                    Image(systemName: prediction.lowercased() == "healthy"
                          ? "checkmark.shield.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(prediction.predictionColor)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Classification")
                        .font(.system(size: 11))
                        .foregroundColor(DS.textSub)
                    Text(prediction.capitalized)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(prediction.predictionColor)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.1f%%", confidence * 100))
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(DS.textPrimary)
                    Text("confidence")
                        .font(.system(size: 11))
                        .foregroundColor(DS.textSub)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 18)

            Divider().opacity(0.15).padding(.horizontal, 20)

            ConfidenceBar(confidence: confidence, color: prediction.predictionColor)
                .padding(.horizontal, 20)
                .padding(.vertical, 18)

            Divider().opacity(0.15).padding(.horizontal, 20)

            HStack(spacing: 0) {
                InfoChip(icon: "cpu.fill",       title: "CoreML",  value: "On-Device")
                Divider().frame(height: 28).opacity(0.2)
                InfoChip(icon: "ruler",          title: "Input",   value: "800 × 600")
                Divider().frame(height: 28).opacity(0.2)
                InfoChip(icon: "checkmark.seal", title: "Status",  value: "Complete")
            }
            .padding(.vertical, 14)
        }
        .glassEffect(
            .regular.tint(prediction.predictionColor.opacity(0.06)),
            in: RoundedRectangle(cornerRadius: DS.r24)
        )
        .shadow(color: prediction.predictionColor.opacity(0.20), radius: 22, x: 0, y: 8)
    }

    // MARK: Disclaimer

    private var disclaimer: some View {
        HStack(spacing: 7) {
            Image(systemName: "info.circle")
                .font(.system(size: 11))
                .foregroundColor(DS.textMicro)
            Text("For research purposes only · Not a clinical diagnostic tool")
                .font(.system(size: 11))
                .foregroundColor(DS.textMicro)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 9)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: DS.r10))
    }

    // MARK: Sample Picker

    private struct SampleImage {
        let assetName: String
        let label: String
        let isHealthy: Bool
    }

    private let samples: [SampleImage] = [
        SampleImage(assetName: "sample_healthy_1", label: "Healthy Sample 1",  isHealthy: true),
        SampleImage(assetName: "sample_healthy_2", label: "Healthy Sample 2",  isHealthy: true),
        SampleImage(assetName: "sample_injured_1", label: "Injured Sample 1",  isHealthy: false),
        SampleImage(assetName: "sample_injured_2", label: "Injured Sample 2",  isHealthy: false),
    ]

    private var sampleButton: some View {
        Button {
            showSampleSheet = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 11))
                Text("Try a sample lung histology image")
                    .font(.system(size: 14, weight: .medium))
                    .underline()
            }
            .foregroundColor(DS.textSub)
        }
        .sheet(isPresented: $showSampleSheet) {
            sampleSheet
        }
    }

    private var sampleSheet: some View {
        ZStack {
            AppBackground()
            VStack(spacing: 0) {
                // Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                Text("Sample Images")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(DS.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)

                Text("Tap an image to analyze it")
                    .font(.system(size: 13))
                    .foregroundColor(DS.textSub)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                    .padding(.bottom, 20)

                VStack(spacing: 10) {
                    ForEach(samples, id: \.assetName) { sample in
                        Button {
                            showSampleSheet = false
                            if let img = UIImage(named: sample.assetName) {
                                showResult  = false
                                isAnalyzing = true
                                scanActive  = true
                                scanOffset  = -160
                                withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                                    scanOffset = 160
                                }
                                inputImage = img
                                Task {
                                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                                    runPrediction(on: img)
                                }
                            }
                        } label: {
                            HStack(spacing: 14) {
                                if let uiImg = UIImage(named: sample.assetName) {
                                    Image(uiImage: uiImg)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 56, height: 56)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                } else {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.06))
                                        .frame(width: 56, height: 56)
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(sample.label)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(DS.textPrimary)
                                    Text("Lung histology · H&E stain")
                                        .font(.system(size: 12))
                                        .foregroundColor(DS.textSub)
                                }

                                Spacer()

                                Circle()
                                    .fill((sample.isHealthy ? DS.healthy : DS.unhealthy).opacity(0.15))
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Image(systemName: sample.isHealthy ? "checkmark.shield.fill" : "exclamationmark.triangle.fill")
                                            .font(.system(size: 11))
                                            .foregroundColor(sample.isHealthy ? DS.healthy : DS.unhealthy)
                                    )
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: DS.r16))
                        }
                        .padding(.horizontal, 20)
                    }
                }
                Spacer()
            }
        }
        .presentationDetents([.medium])
        .presentationCornerRadius(28)
    }

    // MARK: Logic

    private func handleSelection(_ newItem: PhotosPickerItem?) {
        guard let newItem else { return }
        Task {
            guard let data  = try? await newItem.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else { return }
            await MainActor.run {
                inputImage  = image
                showResult  = false
                isAnalyzing = true
                scanActive  = true
                scanOffset  = -160
                withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                    scanOffset = 160
                }
            }
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            runPrediction(on: image)
        }
    }

    func runPrediction(on image: UIImage) {
        let config = MLModelConfiguration()
        #if targetEnvironment(simulator)
        config.computeUnits = .cpuOnly
        #else
        config.computeUnits = .all
        #endif

        guard let model  = try? DIALYOLOFINAL(configuration: config),
              let sized  = image.resized(to: CGSize(width: 224, height: 224)),
              let buffer = sized.toCVPixelBuffer() else {
            DispatchQueue.main.async { isAnalyzing = false; scanActive = false }
            return
        }

        guard let output = try? model.prediction(image: buffer) else {
            DispatchQueue.main.async { isAnalyzing = false; scanActive = false }
            return
        }

        let topLabel      = output.classLabel
        let topConfidence = output.classLabel_probs[output.classLabel] ?? 0.0

        DispatchQueue.main.async {
            self.prediction  = topLabel
            self.confidence  = topConfidence
            self.isAnalyzing = false
            self.scanActive  = false

            if let imageData = image.jpegData(compressionQuality: 0.7) {
                let record = AnalysisRecord(
                    prediction: topLabel,
                    confidence: topConfidence,
                    imageData: imageData
                )
                self.modelContext.insert(record)
            }

            withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                self.showResult = true
            }
        }
    }
}

// MARK: - Image Helpers

extension UIImage {
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let w = Int(size.width), h = Int(size.height)
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!
        ] as CFDictionary
        var buf: CVPixelBuffer?
        guard CVPixelBufferCreate(kCFAllocatorDefault, w, h,
                                  kCVPixelFormatType_32ARGB, attrs, &buf) == kCVReturnSuccess else { return nil }
        CVPixelBufferLockBaseAddress(buf!, .readOnly)
        let ctx = CGContext(
            data: CVPixelBufferGetBaseAddress(buf!),
            width: w, height: h, bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buf!),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        ctx?.draw(cgImage!, in: CGRect(x: 0, y: 0, width: w, height: h))
        CVPixelBufferUnlockBaseAddress(buf!, .readOnly)
        return buf
    }

    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
