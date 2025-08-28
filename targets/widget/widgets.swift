// targets/widget/Widget.swift
import WidgetKit
import SwiftUI
import ActivityKit // for TennisAttributes.ContentState.SetScore

// CHANGE THIS to your App Group ID (must match App + Widget extension)
private let APP_GROUP_ID = "group.com.your.app.shared"

// Timeline payload (reuses your SetScore type)
struct ScorePayload: Codable, Hashable {
  let playerOneName: String
  let playerTwoName: String
  let setScores: [TennisAttributes.ContentState.SetScore]
}

// Timeline entry
struct SimpleEntry: TimelineEntry {
  let date: Date
  let payload: ScorePayload
}

// Provider reading from App Group user defaults
struct Provider: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(date: .now, payload: .placeholder)
  }

  func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
    readEntry() ?? SimpleEntry(date: .now, payload: .placeholder)
  }

  func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
    let entry = readEntry() ?? SimpleEntry(date: .now, payload: .placeholder)
    let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
    return Timeline(entries: [entry], policy: .after(next))
  }

  private func readEntry() -> SimpleEntry? {
    let ud = UserDefaults(suiteName: APP_GROUP_ID)
    guard
      let raw = ud?.string(forKey: "score_widget_payload"),
      let data = raw.data(using: .utf8),
      let payload = try? JSONDecoder().decode(ScorePayload.self, from: data)
    else {
      return nil
    }
    return SimpleEntry(date: .now, payload: payload)
  }
}

// MARK: - Views

struct ScoreWidgetEntryView: View {
  @Environment(\.widgetFamily) var family
  let entry: SimpleEntry

  var body: some View {
    switch family {
    case .systemSmall:
      SmallScoreView(entry: entry)
    case .systemMedium:
      MediumScoreView(entry: entry)
    case .systemLarge:
      LargeScoreView(entry: entry)
    default:
      MediumScoreView(entry: entry)
    }
  }
}

// SMALL: tennis ball icon + last set score
struct SmallScoreView: View {
  let entry: SimpleEntry

  var body: some View {
    let lastText: String = {
      if let last = entry.payload.setScores.last {
        return "\(last.playerOne)–\(last.playerTwo)"
      } else { return "0–0" }
    }()

    VStack(spacing: 6) {
      Image(systemName: "tennisball.fill")
        .resizable()
        .scaledToFit()
        .frame(width: 28, height: 28)
        .foregroundColor(.primary)

      Text(lastText)
        .font(.headline)
        .monospacedDigit()
        .bold()
    }
    .padding()
  }
}

// MEDIUM: vertical list — Set 1 score, Set 2 score, Set 3 score
struct MediumScoreView: View {
  let entry: SimpleEntry

  var body: some View {
    let sets = Array(entry.payload.setScores.prefix(3))
    VStack(alignment: .leading, spacing: 8) {
      ForEach(Array(sets.enumerated()), id: \.offset) { idx, s in
        HStack {
          Text("Set \(idx + 1)")
            .font(.caption2)
            .foregroundColor(.secondary)
          Spacer(minLength: 8)
          Text("\(s.playerOne)–\(s.playerTwo)")
            .font(.headline)
            .monospacedDigit()
            .bold()
        }
      }
    }
    .padding()
  }
}

// LARGE: icon, then three set scores horizontally, then player names
struct LargeScoreView: View {
  let entry: SimpleEntry

  var body: some View {
    let sets = Array(entry.payload.setScores.prefix(3))
    VStack(alignment: .leading, spacing: 12) {
      // Icon
      Image(systemName: "tennisball.fill")
        .resizable()
        .scaledToFit()
        .frame(width: 34, height: 34)
        .foregroundColor(.primary)

      // Three sets horizontally
      HStack(spacing: 16) {
        ForEach(Array(sets.enumerated()), id: \.offset) { idx, s in
          VStack(alignment: .leading, spacing: 2) {
            Text("Set \(idx + 1)")
              .font(.caption2)
              .foregroundColor(.secondary)
            Text("\(s.playerOne)–\(s.playerTwo)")
              .font(.title3)
              .monospacedDigit()
              .bold()
          }
        }
        Spacer(minLength: 0)
      }

      // Player names
      HStack(spacing: 6) {
        Text(entry.payload.playerOneName)
          .font(.caption)
          .lineLimit(1)
        Text("vs")
          .font(.caption2)
          .foregroundColor(.secondary)
        Text(entry.payload.playerTwoName)
          .font(.caption)
          .lineLimit(1)
      }
    }
    .padding()
  }
}

// MARK: - Widget (name must match your WidgetBundle's `widget()`)
struct widget: Widget {
  let kind: String = "widget" // keep this string stable

  var body: some WidgetConfiguration {
    AppIntentConfiguration(kind: kind,
                           intent: ConfigurationAppIntent.self,
                           provider: Provider()) { entry in
      ScoreWidgetEntryView(entry: entry)
        .containerBackground(.clear, for: .widget) // iOS 17+
    }
    .configurationDisplayName("Tennis Score")
    .description("Shows the latest sets and scores.")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
  }
}

// MARK: - Placeholder payload for previews/fallback
extension ScorePayload {
  static let placeholder = ScorePayload(
    playerOneName: "Player A",
    playerTwoName: "Player B",
    setScores: [
      .init(playerOne: "6", playerTwo: "4"),
      .init(playerOne: "5", playerTwo: "7"),
      .init(playerOne: "3", playerTwo: "6"),
    ]
  )
}

// MARK: - Previews
#Preview(as: .systemSmall) {
  widget()
} timeline: {
  SimpleEntry(date: .now, payload: .placeholder)
}

#Preview(as: .systemMedium) {
  widget()
} timeline: {
  SimpleEntry(date: .now, payload: .placeholder)
}

#Preview(as: .systemLarge) {
  widget()
} timeline: {
  SimpleEntry(date: .now, payload: .placeholder)
}
