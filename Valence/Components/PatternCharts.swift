import SwiftUI
import Charts

/// Chart 1: pleasantness (valence) and energy (arousal) over time,
/// averaged per day so several check-ins on one day don't make the lines zigzag.
struct TimelineChart: View {
    /// The check-ins to chart, in any order.
    let checkIns: [CheckIn]

    /// One day's averages.
    private struct DayAverage: Identifiable {
        let day: Date
        let valence: Double
        let arousal: Double
        var id: Date { day }
    }

    private var days: [DayAverage] {
        let calendar = Calendar.current
        let byDay = Dictionary(grouping: checkIns) { calendar.startOfDay(for: $0.timestamp) }
        return byDay.map { day, group in
            DayAverage(day: day,
                       valence: group.map(\.valence).reduce(0, +) / Double(group.count),
                       arousal: group.map(\.arousal).reduce(0, +) / Double(group.count))
        }
        .sorted { $0.day < $1.day }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Chart(days) { day in
                // One line for pleasantness...
                LineMark(x: .value("Date", day.day, unit: .day),
                         y: .value("Level", day.valence),
                         series: .value("Measure", "Pleasantness"))
                    .foregroundStyle(Color.brand)
                    .interpolationMethod(.monotone)
                PointMark(x: .value("Date", day.day, unit: .day),
                          y: .value("Level", day.valence))
                    .foregroundStyle(Color.brand)
                    .symbolSize(30)

                // ...and a dashed line for energy.
                LineMark(x: .value("Date", day.day, unit: .day),
                         y: .value("Level", day.arousal),
                         series: .value("Measure", "Energy"))
                    .foregroundStyle(Color.calmTeal)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 4]))
                    .interpolationMethod(.monotone)
                PointMark(x: .value("Date", day.day, unit: .day),
                          y: .value("Level", day.arousal))
                    .foregroundStyle(Color.calmTeal)
                    .symbol(.diamond)
                    .symbolSize(30)
            }
            .chartYScale(domain: -1...1)
            .chartYAxis {
                AxisMarks(values: [-1, 0, 1]) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        switch value.as(Double.self) ?? 0 {
                        case 1: Text("High")
                        case -1: Text("Low")
                        default: Text("Mid")
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            }
            .frame(height: 200)
            .accessibilityLabel("Daily average pleasantness and energy")

            HStack(spacing: 16) {
                LegendLine(color: .brand, label: "Pleasantness", dashed: false)
                LegendLine(color: .calmTeal, label: "Energy", dashed: true)
            }
            .font(.subheadline)
        }
        .padding(.vertical, 8)
    }
}

/// Chart 2: every check-in as a dot on the Mood Map, colored and shaped by environment.
struct MoodMapChart: View {
    let checkIns: [CheckIn]

    private let settings = CheckInSetting.allCases
    // One shape per environment, in the same order as CheckInSetting.allCases.
    private let shapes: [BasicChartSymbolShape] = [.circle, .square, .triangle, .diamond, .pentagon]

    var body: some View {
        VStack(spacing: 6) {
            Text("High energy")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.inkSoft)

            Chart(checkIns) { checkIn in
                PointMark(x: .value("Pleasantness", checkIn.valence),
                          y: .value("Energy", checkIn.arousal))
                    // "by:" lets the chart pick the color and shape from the environment.
                    .foregroundStyle(by: .value("Environment", checkIn.environment))
                    .symbol(by: .value("Environment", checkIn.environment))
                    .symbolSize(110)
                    .opacity(0.9)
                    .accessibilityLabel(checkIn.feeling)
                    .accessibilityValue("\(checkIn.environment), \(checkIn.timestamp.formatted(date: .abbreviated, time: .omitted))")
            }
            // Both axes run from -1 to 1, just like the Mood Map.
            .chartXScale(domain: -1...1)
            .chartYScale(domain: -1...1)
            // Tell the chart exactly which color and shape goes with each environment.
            .chartForegroundStyleScale(domain: settings.map(\.rawValue),
                                       range: settings.map(\.color))
            .chartSymbolScale(domain: settings.map(\.rawValue), range: shapes)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            // Paint the four soft quadrant colors behind the dots.
            .chartPlotStyle { plotArea in
                plotArea
                    .background(QuadrantBackground())
                    .overlay(centerLines)
            }
            // We draw our own key below, so the axis labels can sit right next to the map.
            .chartLegend(.hidden)
            .aspectRatio(1, contentMode: .fit)
            .accessibilityLabel("Mood Map of your check-ins")

            HStack {
                Text("← Unpleasant")
                Spacer()
                Text("Low energy")
                Spacer()
                Text("Pleasant →")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.inkSoft)
            .accessibilityHidden(true)

            legend
                .padding(.top, 8)
        }
        .padding(.vertical, 8)
    }

    /// A key matching each environment's color and dot shape.
    private var legend: some View {
        let symbols = ["circle.fill", "square.fill", "triangle.fill", "diamond.fill", "pentagon.fill"]
        return LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), alignment: .leading)],
                         alignment: .leading, spacing: 8) {
            ForEach(Array(zip(settings, symbols)), id: \.0) { setting, symbol in
                Label {
                    Text(setting.rawValue)
                } icon: {
                    Image(systemName: symbol).foregroundStyle(setting.color)
                }
                .font(.subheadline)
            }
        }
        .accessibilityHidden(true)
    }

    private var centerLines: some View {
        ZStack {
            Rectangle().fill(Color.inkSoft.opacity(0.25)).frame(width: 1.5)
            Rectangle().fill(Color.inkSoft.opacity(0.25)).frame(height: 1.5)
        }
        .allowsHitTesting(false)
    }
}

/// A small line sample with a label, used as a chart key.
struct LegendLine: View {
    let color: Color
    let label: String
    let dashed: Bool

    var body: some View {
        HStack(spacing: 6) {
            Path { path in
                path.move(to: CGPoint(x: 0, y: 2))
                path.addLine(to: CGPoint(x: 24, y: 2))
            }
            .stroke(color, style: StrokeStyle(lineWidth: 3, dash: dashed ? [5, 4] : []))
            .frame(width: 24, height: 4)
            .accessibilityHidden(true)
            Text(label)
        }
    }
}
