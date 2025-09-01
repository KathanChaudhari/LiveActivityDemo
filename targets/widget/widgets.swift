import WidgetKit
import SwiftUI
import ActivityKit

private let APP_GROUP_ID = "group.com.kiyo.tennis.shared"

struct ScorePayload: Codable, Hashable {
  let playerOneName: String
  let playerTwoName: String
  let setScores: [TennisAttributes.ContentState.SetScore]
}

struct SimpleEntry: TimelineEntry {
  let date: Date
  let payload: ScorePayload
}

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

struct SmallScoreView: View {
  let entry: SimpleEntry

  var body: some View {
    let last = entry.payload.setScores.last ?? .init(playerOne: "0", playerTwo: "0")

    HStack(alignment: .center, spacing: 12) {
      // Left: names (vertical) with "vs" between
      VStack(alignment: .leading, spacing: 2) {
        Text(entry.payload.playerOneName)
          .font(.caption)
          .lineLimit(1)
          .truncationMode(.tail)
        Text("vs")
          .font(.caption2)
          .foregroundColor(.secondary)
        Text(entry.payload.playerTwoName)
          .font(.caption)
          .lineLimit(1)
          .truncationMode(.tail)
      }

      Spacer(minLength: 0)

      // Right: scores (vertical) with "-" between
      VStack(alignment: .trailing, spacing: 2) {
        Text(last.playerOne)
          .font(.headline)
          .monospacedDigit()
          .bold()
        Text(" ")
          .font(.caption2)
          .foregroundColor(.secondary)
        Text(last.playerTwo)
          .font(.headline)
          .monospacedDigit()
          .bold()
      }
    }
    .padding()
  }
}


struct MediumScoreView: View {
  let entry: SimpleEntry

  var body: some View {
    let sets = Array(entry.payload.setScores.prefix(3))

    VStack(alignment: .leading, spacing: 8) {
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
      .frame(maxWidth: .infinity, alignment: .center)

      // Row: icon in-line with scores
      HStack(spacing: 12) {
        Image(systemName: "tennisball.fill")
          .resizable()
          .scaledToFit()
          .frame(width: 26, height: 26)
          .foregroundColor(.primary)

        // Three set “cards” spread across width
        HStack(spacing: 0) {
          Spacer(minLength: 0)
          ForEach(Array(sets.enumerated()), id: \.offset) { idx, s in
            VStack(spacing: 2) {
              Text("Set \(idx + 1)")
                .font(.caption2)
                .foregroundColor(.secondary)
              Text("\(s.playerOne)–\(s.playerTwo)")
                .font(.headline)
                .monospacedDigit()
                .bold()
            }
            if idx < sets.count - 1 { Spacer(minLength: 0) }
          }
          Spacer(minLength: 0)
        }
      }
    }
    .padding()
  }
}



struct LargeScoreView: View {
  let entry: SimpleEntry

  var body: some View {
    let sets = Array(entry.payload.setScores.prefix(3))

    HStack(alignment: .top, spacing: 12) {
      // Icon stays top-left
      Image(systemName: "tennisball.fill")
        .resizable()
        .scaledToFit()
        .frame(width: 40, height: 40)
        .foregroundColor(.primary)

      // Everything else right-justified
      Spacer(minLength: 0)

      VStack(alignment: .trailing, spacing: 10) {
        // Player names line (right-aligned)
        HStack(spacing: 6) {
          Text(entry.payload.playerOneName)
            .font(.headline)
            .lineLimit(1)
          Text("vs")
            .font(.caption2)
            .foregroundColor(.secondary)
          Text(entry.payload.playerTwoName)
            .font(.headline)
            .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)

        // Per-set rows (right-aligned)
        VStack(alignment: .trailing, spacing: 6) {
          ForEach(Array(sets.enumerated()), id: \.offset) { idx, s in
            HStack(spacing: 8) {
              Text("Set \(idx + 1):")
                .font(.caption2)
                .foregroundColor(.secondary)
              Text("\(s.playerOne)–\(s.playerTwo)")
                .font(.body)
                .monospacedDigit()
                .bold()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
          }
        }
      }
      .frame(maxWidth: .infinity, alignment: .trailing)
    }
    .padding()
  }
}



struct widget: Widget {
  let kind: String = "widget" 

  var body: some WidgetConfiguration {
    AppIntentConfiguration(kind: kind,
                           intent: ConfigurationAppIntent.self,
                           provider: Provider()) { entry in
      ScoreWidgetEntryView(entry: entry)
        .containerBackground(.clear, for: .widget) 
    }
    .configurationDisplayName("Tennis Score")
    .description("Shows the latest sets and scores.")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
  }
}

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
