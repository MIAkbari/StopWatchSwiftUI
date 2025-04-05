//
//  ContentView.swift
//  StopWatchSwiftUI
//
//  Created by Mohammad on 4/2/25.
//

import SwiftUI

// MARK: - PreferenceKey
struct TimeButtonPreferenceKey: PreferenceKey {
    
    static var defaultValue: [CGSize] = []
    
    static func reduce(value: inout [CGSize], nextValue: () -> [CGSize]) {
        value.append(contentsOf: nextValue())
    }
}

// MARK: - EnvironmentKey
struct TimeSizeEnvirementKey: EnvironmentKey {
    static var defaultValue: CGSize? = nil
}

extension EnvironmentValues {
    var size: CGSize? {
        get { self[TimeSizeEnvirementKey.self] }
        set { self[TimeSizeEnvirementKey.self] = newValue }
    }
}

// MARK: - ViewModifier
struct TimeButtonViewModifier: ViewModifier {
    
    let isPressed: Bool
    
    func body(content: Content) -> some View {
        let background = RoundedRectangle(cornerRadius: 5)
        
        let forground = content
            .foregroundStyle(.white)
            .padding(15)
            .fixedSize()
            .equalSize()
        
        forground.background(background)
            .shadow(color: .indigo.opacity(0.4), radius: 10, x: 0, y: 5)
            .scaleEffect(isPressed ? 0.7 : 1)
            .animation(.smooth, value: isPressed)
            
    }
}

struct EqualSize: ViewModifier {
    
    @Environment(\.size) var size
    
    func body(content: Content) -> some View {
        content.overlay {
            GeometryReader {
                Color.clear.preference(key: TimeButtonPreferenceKey.self, value: [$0.size])
            }
        }
        .frame(width: size?.width, height: 50)
    }
}

struct EqualSizes: ViewModifier {
    
    @State private var maxWidth: CGFloat?
    
    func body(content: Content) -> some View {
        content.onPreferenceChange(TimeButtonPreferenceKey.self) { value in
            maxWidth = value.map { $0.width }.max()
        }
        .environment(\.size, maxWidth.map { CGSize(width: $0, height: $0)})
    }
}

// MARK: - ButtonStyle
struct TimeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.modifier(TimeButtonViewModifier(isPressed: configuration.isPressed))
    }
}

extension ButtonStyle where Self == TimeButtonStyle {
    static var time: Self { .init() }
}

// MARK: Extension
extension View {
    func equalSize() -> some View {
        modifier(EqualSize())
    }
    
    func equalSizes() -> some View {
        modifier(EqualSizes())
    }
}

// MARK: - Views
struct ContentView: View {
    
    @StateObject var viewModel = StopWatchViewModel()
    
    var body: some View {
        VStack {
            Text(viewModel.total.formatter)
                .font(.largeTitle.weight(.thin))
                .monospacedDigit()
                .padding(.bottom, 15)
                .contentTransition(.numericText())
                .animation(.easeOut(duration: 0.1), value: viewModel.total)
            
            HStack {
                Button(viewModel.isRunning ? "Lap" : "Reset") {
                    viewModel.isRunning ? viewModel.lap() : viewModel.reset()
                }
                .foregroundStyle(viewModel.isRunning ? .orange : .gray)
                .disabled(!viewModel.isZeroTime)
                .opacity(!viewModel.isZeroTime ? 0.5 : 1)
                
                Text("Stop Watch")
                    .font(.title.weight(.heavy))
                    .foregroundStyle(.teal.gradient)
                    .frame(minWidth: 180, maxWidth: .infinity)
                
                Button(viewModel.isRunning ? "Stop" : "Start") {
                    viewModel.isRunning ? viewModel.stop() : viewModel.start()
                }
                .foregroundStyle(viewModel.isRunning ? .red : .green)
                
            }
            .padding(.horizontal, 5)
            .equalSizes()
            .buttonStyle(.time)
            
            ZStack  {
                Text("Laps History")
                    .font(.largeTitle.weight(.heavy))
                    .foregroundStyle(.orange.gradient)
                    .padding()
                    .opacity(!viewModel.isZeroTime ? 1 : 0)
                
                ScrollView {
                    ForEach(viewModel.laps.enumerated().reversed(), id: \.offset) { lap in
                        HStack {
                            Text("Lap \(lap.offset + 1)")
                                .font(.body.weight(.semibold))

                            Spacer()
                            Text(lap.element.0 .formatter)
                                .font(.body.weight(.thin))
                                .monospacedDigit()
                                .contentTransition(.numericText())
                                .animation(.easeOut(duration: 0.1), value: viewModel.total)
                        }
                        .foregroundStyle(lap.element.1.color)
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                    }
                }
                .disabled(!viewModel.isZeroTime)
                .opacity(!viewModel.isZeroTime ? 0 : 1)
                .animation(.smooth(duration: 0.3, extraBounce: 0.5), value: viewModel.laps.count)
            }
            
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.total)
        .padding()
        .dynamicTypeSize(.xSmall ... .xxLarge)
        .frame(maxWidth: UIScreen.main.bounds.width)
        .background(.orange.opacity(0.20).gradient)
    }
}

// MARK: - Formater

struct Helper {
    
    static let `default` = Helper()
    
    var formatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }
    
    var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.maximumIntegerDigits = 0
        numberFormatter.alwaysShowsDecimalSeparator = true
        return numberFormatter
    }
}

extension TimeInterval {
    var formatter: String {
        let ms = truncatingRemainder(dividingBy: 1)
        
        guard let startFormatter = Helper.default.formatter.string(from: self) else {
            return ""
        }
        
        guard let numberForamtter = Helper.default.numberFormatter.string(from: .init(value: ms)) else {
            return ""
        }
        
        return startFormatter + numberForamtter
    }
}

final class StopWatchViewModel: ObservableObject {
    @Published var data: StopWatch = .init()
    @Published var isZeroTime: Bool = false

    var isRunning: Bool { data.startTime != nil }
    var laps: [(TimeInterval, LapType)] { data.laps}
    var total: TimeInterval { data.totalTime }
    
    private var timer: DispatchSourceTimer?
    
    
    func start() {
        data.start(at: Date().timeIntervalSinceReferenceDate)

        // make a new timer
        let queue = DispatchQueue(label: "com.akbari.watchTime", qos: .userInteractive)
        timer = DispatchSource.makeTimerSource(queue: queue)
        
        timer?.schedule(deadline: .now(), repeating: 0.1, leeway: .nanoseconds(0))
        
        timer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            
            
            Task {
                await MainActor.run {
                    self.data.currentTime = Date().timeIntervalSinceReferenceDate
                }
            }
        }
        
        timer?.resume()
        
//        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { time in
//            self.data.currentTime = Date().timeIntervalSinceReferenceDate
//        })
        isZeroTime = true
    }
    
    func stop() {
        timer?.cancel()
        timer = nil
        data.stop()
        
    }
    
    func reset() {
        stop()
        data = StopWatch()
        isZeroTime = false
    }
    
    func lap() {
        data.lap()
    }
    
    deinit {
        stop()
    }
}

enum LapType {
    case reqular
    case shortest
    case longest
}

extension LapType {
    var color: Color {
        switch self {
        case .reqular: .black
        case .shortest: .green
        case .longest: .red
        }
    }
}

struct StopWatch {
    var startTime: TimeInterval?
    var currentTime: TimeInterval = 0
    private var addintinalTime: TimeInterval = 0
    private var lastLapTime: TimeInterval = 0
    private var _laps: [(TimeInterval, LapType)] = []
    private var currentLapTime: TimeInterval {
        totalTime - lastLapTime
    }
    
    var totalTime: TimeInterval {
        guard let startTime = startTime else { return addintinalTime }
        return addintinalTime + currentTime - startTime
    }
    
    var laps: [(TimeInterval, LapType)] {
        guard totalTime > 0 else { return [] }
        return _laps + [(currentLapTime, .reqular)]
    }
    
}

extension StopWatch {
    
    // use mutating becuse change in struct
    mutating func start(at time: TimeInterval) {
        startTime = time
        currentTime = time
    }
    
    mutating func stop() {
        addintinalTime = totalTime
        startTime = nil
    }
    
    mutating func lap() {
        let lapTime = _laps.map { $0.0 } + [currentLapTime]
        if let shortest = lapTime.min(),
           let longest = lapTime.max(),
           shortest != longest {
            _laps = lapTime.map {($0, $0 == shortest ? .shortest : ($0 == longest ? .longest : .reqular))}
        } else {
            _laps = lapTime.map {($0, .reqular)}
        }
        
        lastLapTime = totalTime
    }
}


#Preview {
    ContentView()
}
