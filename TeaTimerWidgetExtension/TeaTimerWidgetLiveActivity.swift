import ActivityKit
import SwiftUI
import WidgetKit

struct TeaTimerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TeaTimerActivityAttributes.self) { context in
            LockScreenTeaTimerActivityView(context: context)
                .activityBackgroundTint(TeaTimerActivityStyle.background)
                .activitySystemActionForegroundColor(TeaTimerActivityStyle.gold)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        TeaTimerActivityGlyph(size: 30)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("TeaTimer")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(TeaTimerActivityStyle.gold)

                            Text(context.state.brewingLabel.replacingOccurrences(of: "...", with: ""))
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.white.opacity(0.68))
                        }
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    CountdownText(endDate: context.state.endDate)
                        .font(.headline.monospacedDigit().weight(.semibold))
                        .foregroundStyle(.white)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack(alignment: .center, spacing: 10) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(activityTitle(for: context.state))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                                .lineLimit(1)

                            Text(context.state.brewingMessage)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.66))
                        }

                        Spacer(minLength: 8)

                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 21, weight: .semibold))
                            .foregroundStyle(TeaTimerActivityStyle.gold)
                            .accessibilityHidden(true)
                    }
                    .padding(.top, 2)
                }
            } compactLeading: {
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundStyle(TeaTimerActivityStyle.gold)
            } compactTrailing: {
                CountdownText(endDate: context.state.endDate)
                    .font(.caption2.monospacedDigit().weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: 42)
            } minimal: {
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundStyle(TeaTimerActivityStyle.gold)
            }
            .widgetURL(URL(string: "teatimer://timer"))
            .keylineTint(TeaTimerActivityStyle.gold)
        }
    }
}

private enum TeaTimerActivityStyle {
    static let gold = Color(red: 0.96, green: 0.67, blue: 0.29)
    static let leaf = Color(red: 0.52, green: 0.78, blue: 0.50)
    static let cream = Color(red: 0.97, green: 0.91, blue: 0.78)
    static let softCream = Color(red: 0.90, green: 0.96, blue: 0.84)
    static let ink = Color(red: 0.15, green: 0.11, blue: 0.07)
    static let mutedInk = Color(red: 0.44, green: 0.36, blue: 0.26)
    static let background = Color(red: 0.93, green: 0.89, blue: 0.76).opacity(0.98)
}

private struct LockScreenTeaTimerActivityView: View {
    let context: ActivityViewContext<TeaTimerActivityAttributes>

    var body: some View {
        HStack(alignment: .center, spacing: 11) {
            TeaTimerActivityGlyph(size: 34)

            VStack(alignment: .leading, spacing: 3) {
                Text("TeaTimer")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(TeaTimerActivityStyle.ink.opacity(0.78))

                Text(context.state.brewingLabel)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(TeaTimerActivityStyle.leaf.opacity(0.92))

                Text(activityTitle(for: context.state))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(TeaTimerActivityStyle.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 3) {
                CountdownText(endDate: context.state.endDate)
                    .font(.title3.monospacedDigit().weight(.bold))
                    .foregroundStyle(TeaTimerActivityStyle.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text(context.state.remainingLabel)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(TeaTimerActivityStyle.mutedInk)
                    .lineLimit(1)
            }
            .frame(minWidth: 66, alignment: .trailing)
            .padding(.trailing, 6)
        }
        .padding(.vertical, 9)
        .padding(.leading, 10)
        .padding(.trailing, 12)
        .background(
            LinearGradient(
                colors: [
                    TeaTimerActivityStyle.cream.opacity(0.34),
                    TeaTimerActivityStyle.softCream.opacity(0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

private struct TeaTimerActivityGlyph: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            TeaTimerActivityStyle.gold.opacity(0.22),
                            TeaTimerActivityStyle.leaf.opacity(0.16)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: max(11, size * 0.37), weight: .semibold))
                .foregroundStyle(TeaTimerActivityStyle.gold)
                .offset(y: 0.5)
        }
        .frame(width: size, height: size)
        .overlay(
            Circle()
                .stroke(TeaTimerActivityStyle.gold.opacity(0.35), lineWidth: 1)
        )
        .accessibilityLabel("TeaTimer")
    }
}

private struct CountdownText: View {
    let endDate: Date

    var body: some View {
        if endDate > Date() {
            Text(timerInterval: Date()...endDate, countsDown: true)
        } else {
            Text("0:00")
        }
    }
}

private func activityTitle(for state: TeaTimerActivityAttributes.ContentState) -> String {
    let teaName = state.teaName.trimmingCharacters(in: .whitespacesAndNewlines)
    let teaType = state.teaType.trimmingCharacters(in: .whitespacesAndNewlines)

    if !teaName.isEmpty {
        return teaName
    }

    return teaType.isEmpty ? "Tea Timer" : teaType
}

@main
struct TeaTimerWidgetBundle: WidgetBundle {
    var body: some Widget {
        TeaTimerWidgetLiveActivity()
    }
}
