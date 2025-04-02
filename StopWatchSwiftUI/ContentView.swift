//
//  ContentView.swift
//  StopWatchSwiftUI
//
//  Created by Mohammad on 4/2/25.
//

import SwiftUI

//// MARK: - PreferenceKey
//struct TimeButtonPreferenceKey: PreferenceKey {
//    
//    static var defaultValue: [CGSize] = []
//    
//    static func reduce(value: inout [CGSize], nextValue: () -> [CGSize]) {
//        value.append(contentsOf: nextValue())
//    }
//}
//
//// MARK: - EnvironmentKey
//struct TimeSizeEnvirementKey: EnvironmentKey {
//    static var defaultValue: CGSize? = nil
//}
//
//extension EnvironmentValues {
//    var size: CGSize? {
//        get { self[TimeSizeEnvirementKey.self] }
//        set { self[TimeSizeEnvirementKey.self] = newValue }
//    }
//}
//
//// MARK: - ViewModifier
//struct TimeButtonViewModifier: ViewModifier {
//    
//    let isPressed: Bool
//    
//    func body(content: Content) -> some View {
//        let background = RoundedRectangle(cornerRadius: 5)
//        
//        let forground = content
//            .foregroundStyle(.white)
//            .padding(15)
//            .fixedSize()
//            .equalSize()
//        
//        forground.background(background)
//            .scaleEffect(isPressed ? 0.7 : 1)
//            .animation(.smooth, value: isPressed)
//            
//    }
//}
//
//struct EqualSize: ViewModifier {
//    
//    @Environment(\.size) var size
//    
//    func body(content: Content) -> some View {
//        content.overlay {
//            GeometryReader {
//                Color.clear.preference(key: TimeButtonPreferenceKey.self, value: [$0.size])
//            }
//        }
//        .frame(width: size?.width, height: 50)
//    }
//}
//
//struct EqualSizes: ViewModifier {
//    
//    @State private var maxWidth: CGFloat?
//    
//    func body(content: Content) -> some View {
//        content.onPreferenceChange(TimeButtonPreferenceKey.self) { value in
//            maxWidth = value.map { $0.width }.max()
//        }
//        .environment(\.size, maxWidth.map { CGSize(width: $0, height: $0)})
//    }
//}
//
//// MARK: - ButtonStyle
//struct TimeButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label.modifier(TimeButtonViewModifier(isPressed: configuration.isPressed))
//    }
//}
//
//extension ButtonStyle where Self == TimeButtonStyle {
//    static var time: Self { .init() }
//}
//
//// MARK: Extension
//extension View {
//    func equalSize() -> some View {
//        modifier(EqualSize())
//    }
//    
//    func equalSizes() -> some View {
//        modifier(EqualSizes())
//    }
//}
//
//// MARK: - Views
//struct ContentView: View {
//    
//    @StateObject var viewModel = StopWatchViewModel()
//    
//    var body: some View {
//        VStack {
//            Text(viewModel.total.formatter)
//                .font(.largeTitle.weight(.thin))
//                .monospacedDigit()
//                .padding(.bottom, 15)
//            
//            HStack {
//                Button(viewModel.isRunning ? "Lap" : "Reset") {
//                    viewModel.isRunning ? viewModel.lap() : viewModel.reset()
//                }
//                .foregroundStyle(viewModel.isRunning ? .orange : .gray)
//                .disabled(!viewModel.isZeroTime)
//                .opacity(!viewModel.isZeroTime ? 0.5 : 1)
//                
//                Text("Stop Watch")
//                    .font(.title.weight(.heavy))
//                    .foregroundStyle(.teal.gradient)
//                    .frame(minWidth: 180, maxWidth: .infinity)
//                
//                Button(viewModel.isRunning ? "Stop" : "Start") {
//                    viewModel.isRunning ? viewModel.stop() : viewModel.start()
//                }
//                .foregroundStyle(viewModel.isRunning ? .red : .green)
//                
//            }
//            .padding(.horizontal, 5)
//            .equalSizes()
//            .buttonStyle(.time)
//            
//            ZStack  {
//                Text("Laps History")
//                    .font(.largeTitle.weight(.heavy))
//                    .foregroundStyle(.orange.gradient)
//                    .padding()
//                    .opacity(!viewModel.isZeroTime ? 1 : 0)
//                
//                List {
//                    ForEach(viewModel.laps.enumerated().reversed(), id: \.offset) { lap in
//                        HStack {
//                            Text("Lap \(lap.offset + 1)")
//                            Spacer()
//                            Text(lap.element.0 .formatter)
//                                .font(.body.weight(.semibold))
//                                .monospacedDigit()
//                        }
//                        .foregroundStyle(lap.element.1.color)
//                    }
//                }
//                .disabled(!viewModel.isZeroTime)
//                .opacity(!viewModel.isZeroTime ? 0 : 1)
//            }
//            
//        }
//        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.total)
//        .padding()
//        .dynamicTypeSize(.xSmall ... .xxLarge)
//        .frame(maxWidth: UIScreen.main.bounds.width)
//        .background(.orange.opacity(0.20))
//    }
//}
//
//// MARK: - Formater
//
//struct Helper {
//    
//    static let `default` = Helper()
//    
//    var formatter: DateComponentsFormatter {
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.minute, .second]
//        formatter.zeroFormattingBehavior = .pad
//        return formatter
//    }
//    
//    var numberFormatter: NumberFormatter {
//        let numberFormatter = NumberFormatter()
//        numberFormatter.minimumFractionDigits = 2
//        numberFormatter.maximumFractionDigits = 2
//        numberFormatter.maximumIntegerDigits = 0
//        numberFormatter.alwaysShowsDecimalSeparator = true
//        return numberFormatter
//    }
//}
//
//extension TimeInterval {
//    var formatter: String {
//        let ms = truncatingRemainder(dividingBy: 1)
//        
//        guard let startFormatter = Helper.default.formatter.string(from: self) else {
//            return ""
//        }
//        
//        guard let numberForamtter = Helper.default.numberFormatter.string(from: .init(value: ms)) else {
//            return ""
//        }
//        
//        return startFormatter + numberForamtter
//    }
//}
//
//final class StopWatchViewModel: ObservableObject {
//    @Published var data: StopWatch = .init()
//    @Published var isZeroTime: Bool = false
//
//    var isRunning: Bool { data.startTime != nil }
//    var laps: [(TimeInterval, LapType)] { data.laps}
//    var total: TimeInterval { data.totalTime }
//    
//    private var timer: DispatchSourceTimer?
//    
//    
//    func start() {
//        data.start(at: Date().timeIntervalSinceReferenceDate)
//
//        // make a new timer
//        let queue = DispatchQueue(label: "com.akbari.watchTime", qos: .userInteractive)
//        timer = DispatchSource.makeTimerSource(queue: queue)
//        
//        timer?.schedule(deadline: .now(), repeating: 0.1, leeway: .nanoseconds(0))
//        
//        timer?.setEventHandler { [weak self] in
//            guard let self = self else { return }
//            
//            
//            Task {
//                await MainActor.run {
//                    self.data.currentTime = Date().timeIntervalSinceReferenceDate
//                }
//            }
//        }
//        
//        timer?.resume()
//        
////        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { time in
////            self.data.currentTime = Date().timeIntervalSinceReferenceDate
////        })
//        isZeroTime = true
//    }
//    
//    func stop() {
//        timer?.cancel()
//        timer = nil
//        data.stop()
//        
//    }
//    
//    func reset() {
//        stop()
//        data = StopWatch()
//        isZeroTime = false
//    }
//    
//    func lap() {
//        data.lap()
//    }
//    
//    deinit {
//        stop()
//    }
//}
//
//enum LapType {
//    case reqular
//    case shortest
//    case longest
//}
//
//extension LapType {
//    var color: Color {
//        switch self {
//        case .reqular: .black
//        case .shortest: .green
//        case .longest: .red
//        }
//    }
//}
//
//struct StopWatch {
//    var startTime: TimeInterval?
//    var currentTime: TimeInterval = 0
//    private var addintinalTime: TimeInterval = 0
//    private var lastLapTime: TimeInterval = 0
//    private var _laps: [(TimeInterval, LapType)] = []
//    private var currentLapTime: TimeInterval {
//        totalTime - lastLapTime
//    }
//    
//    var totalTime: TimeInterval {
//        guard let startTime = startTime else { return addintinalTime }
//        return addintinalTime + currentTime - startTime
//    }
//    
//    var laps: [(TimeInterval, LapType)] {
//        guard totalTime > 0 else { return [] }
//        return _laps + [(currentLapTime, .reqular)]
//    }
//    
//}
//
//extension StopWatch {
//    
//    // use mutating becuse change in struct
//    mutating func start(at time: TimeInterval) {
//        startTime = time
//        currentTime = time
//    }
//    
//    mutating func stop() {
//        addintinalTime = totalTime
//        startTime = nil
//    }
//    
//    mutating func lap() {
//        let lapTime = _laps.map { $0.0 } + [currentLapTime]
//        if let shortest = lapTime.min(), let longest = lapTime.max(), shortest != longest {
//            _laps = lapTime.map {($0, $0 == shortest ? .shortest : ($0 == longest ? .longest : .reqular))}
//        } else {
//            _laps = lapTime.map {($0, .reqular)}
//        }
//        
//        lastLapTime = totalTime
//    }
//}

// MARK: - Data Models
enum LapType: String, CaseIterable, Sendable {
    case regular
    case shortest
    case longest
    
    var color: Color {
        switch self {
        case .regular: return .primary
        case .shortest: return .green
        case .longest: return .red
        }
    }
}

@MainActor
final class StopwatchManager: ObservableObject {
    // MARK: - State
    @Published private(set) var totalTime: TimeInterval = 0
    @Published private(set) var laps: [(time: TimeInterval, type: LapType)] = []
    @Published private(set) var isRunning = false
    
    private var startTime: Date?
    private var accumulatedTime: TimeInterval = 0
    private var timerTask: Task<Void, Never>?
    
    // MARK: - Public Interface
    func toggleRunning() {
        isRunning ? stop() : start()
    }
    
    func recordLap() {
        guard isRunning else { return }
        let currentTotal = totalTime
        let lapTime = currentTotal - (accumulatedTime + laps.map(\.time).reduce(0, +))
        
        updateLapTypes(with: lapTime)
    }
    
    func reset() {
        timerTask?.cancel()
        totalTime = 0
        laps = []
        accumulatedTime = 0
        startTime = nil
        isRunning = false
    }
    
    // MARK: - Private Implementation
    private func start() {
        guard !isRunning else { return }
        
        // تنظیم startTime با احتساب زمان ذخیره شده
        startTime = Date().addingTimeInterval(-accumulatedTime)
        isRunning = true
        
        startTimer()
    }
    
    private func stop() {
        guard isRunning else { return }
        
        // ذخیره زمان کل در accumulatedTime
        accumulatedTime = totalTime
        timerTask?.cancel()
        isRunning = false
        startTime = nil
    }
    
    private func startTimer() {
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self, let startTime else { return }
                
                // محاسبه زمان با احتساب زمان ذخیره شده
                totalTime = Date().timeIntervalSince(startTime)
                
                try? await Task.sleep(for: .milliseconds(10))
            }
        }
    }
    
    private func updateLapTypes(with newLap: TimeInterval) {
        let allLaps = laps.map(\.time) + [newLap]
        guard let min = allLaps.min(), let max = allLaps.max() else { return }
        
        laps = allLaps.map {
            switch $0 {
            case min: return ($0, .shortest)
            case max: return ($0, .longest)
            default: return ($0, .regular)
            }
        }
    }
}

struct TimeDisplayView: View {
    let time: TimeInterval
    
    var body: some View {
        Text(formattedTime(time))
            .font(.system(size: 60, weight: .thin, design: .monospaced))
            .foregroundStyle(.white)
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.1), value: time)
    }
    
    private func formattedTime(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        
        let milliseconds = String(format: "%.2f", interval.truncatingRemainder(dividingBy: 1))
            .dropFirst(2)
        
        return "\(formatter.string(from: interval)!).\(milliseconds)"
    }
}

// MARK: - Custom Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.title3, weight: .semibold))
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .background(
                LinearGradient(
                    colors: [Color.indigo, Color.purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .shadow(color: .indigo.opacity(0.4), radius: 10, x: 0, y: 5)
            .animation(.interactiveSpring(response: 0.3), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.title3, weight: .medium))
            .foregroundColor(Color(.systemBackground))
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(
                LinearGradient(
                    colors: [Color(.systemGray3), Color(.systemGray5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
            .animation(.interactiveSpring(response: 0.3), value: configuration.isPressed)
    }
}

// MARK: - Color Scheme
extension Color {
    static let primaryBackground = LinearGradient(
        colors: [Color.indigo.opacity(0.15), Color.teal.opacity(0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentTeal = Color(red: 0, green: 0.8, blue: 0.8)
    static let dynamicText = Color(.label)
}

// MARK: - Updated Main View
struct StopwatchView: View {
    @StateObject private var manager = StopwatchManager()
    
    var body: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                TimeDisplayView(time: manager.totalTime)
                    .padding(.top, 40)
                
                ControlPanelView(manager: manager)
                    .padding(.horizontal)
                
                LapListView(laps: manager.laps)
                    .padding(.bottom)
            }
        }
    }
}

// MARK: - Redesigned Components
struct ControlPanelView: View {
    @ObservedObject var manager: StopwatchManager
    
    var body: some View {
        HStack(spacing: 20) {
            Button {
                manager.isRunning ? manager.recordLap() : manager.reset()
            } label: {
                Label(manager.isRunning ? "Lap" : "Reset", systemImage: "clock.arrow.circlepath")
            }
            .buttonStyle(SecondaryButtonStyle())
            .disabled(!manager.isRunning && manager.laps.isEmpty)
            
            Button {
                manager.toggleRunning()
            } label: {
                Label(manager.isRunning ? "Stop" : "Start", systemImage: manager.isRunning ? "stop.fill" : "play.fill")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .labelStyle(.iconOnly)
        .imageScale(.large)
    }
}

struct LapListView: View {
    let laps: [(TimeInterval, LapType)]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(laps.indices.reversed(), id: \.self) { index in
                    LapRowView(lap: laps[index], index: index + 1)
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
        .animation(.smooth(duration: 0.3, extraBounce: 0.5), value: laps.count)
    }
}

struct LapRowView: View {
    let lap: (time: TimeInterval, type: LapType)
    let index: Int
    
    var body: some View {
        HStack {
            Text("\(index)")
                .font(.body.monospacedDigit())
                .foregroundColor(.dynamicText.opacity(0.7))
                .frame(width: 40, alignment: .leading)
            
            Text(lap.type.rawValue)
                .font(.caption)
                .foregroundColor(lap.type.color)
                .padding(6)
                .background(lap.type.color.opacity(0.2))
                .clipShape(Capsule())
            
            Spacer()
            
            Text(formattedTime(lap.time))
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.dynamicText)
        }
        .padding()
        .background(
            Color(.systemBackground)
                .opacity(0.9)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        )
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
    }
    
    private func formattedTime(_ interval: TimeInterval) -> String {
        String(format: "%02d:%02d.%02d",
               Int(interval) / 60,
               Int(interval) % 60,
               Int(interval.truncatingRemainder(dividingBy: 1) * 100))
    }
}

// MARK: - Preview
struct StopwatchView_Previews: PreviewProvider {
    static var previews: some View {
        StopwatchView()
            .previewDisplayName("Light Mode")
        
        StopwatchView()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
    }
}
