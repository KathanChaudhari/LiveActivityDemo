import ActivityKit
import WidgetKit
import SwiftUI

struct WidgetLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: TennisAttributes.self) { context in
      let sets = context.state.setScores
      let count = min(3, sets.count)

      HStack(spacing: 12) {
        Image(systemName: "tennisball.fill")
          .resizable()
          .scaledToFit()
          .frame(width: 30, height: 30)
          .foregroundColor(.primary) 

        HStack(spacing: 0) {
          Spacer(minLength: 0)
          ForEach(0..<count, id: \.self) { i in
            let score = sets[i]
            VStack(spacing: 2) {
              Text("Set \(i + 1)")
                .font(.caption2)
                .foregroundColor(.secondary)
              Text("\(score.playerOne)–\(score.playerTwo)")
                .font(.headline)
                .monospacedDigit()
                .bold()
            }
            if i < count - 1 { Spacer(minLength: 0) }
          }
          Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)

        VStack(alignment: .trailing, spacing: 2) {
          Text(context.attributes.playerOneName)
            .font(.caption)
            .lineLimit(1)
            .truncationMode(.tail)
          Text(context.attributes.playerTwoName)
            .font(.caption)
            .lineLimit(1)
            .truncationMode(.tail)
        }
      }
      .padding()

    } dynamicIsland: { context in
      return DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          VStack(spacing: 0) {
            Spacer(minLength: 0)
            Image(systemName: "tennisball.fill")
              .resizable()
              .frame(width: 32, height: 32)
              .foregroundColor(.white)
            Spacer(minLength: 0)
          }
          .frame(maxHeight: .infinity, alignment: .center)
          .padding(.top, 10) 
        }

        DynamicIslandExpandedRegion(.trailing) {
          VStack(spacing: 0) {
            Spacer(minLength: 0)
            Text("Demo")
              .font(.caption2)
              .foregroundColor(.secondary)
            Spacer(minLength: 0)
          }
          .frame(maxHeight: .infinity, alignment: .center)
          .padding(.top, 10)
        }

        DynamicIslandExpandedRegion(.bottom) {
          let sets = context.state.setScores
          let count = min(3, sets.count)

          HStack(spacing: 0) {
            Spacer(minLength: 0)
            ForEach(0..<count, id: \.self) { i in
              let score = sets[i]
              VStack(spacing: 2) {
                Text("Set \(i + 1)")
                  .font(.caption2)
                Text("\(score.playerOne)–\(score.playerTwo)")
                  .font(.subheadline)
                  .monospacedDigit()
                  .bold()
              }
              if i < count - 1 { Spacer(minLength: 0) }
            }
            Spacer(minLength: 0)
          }
        }

      } compactLeading: {
        Image(systemName: "tennisball.fill")
          .foregroundColor(.white)

      } compactTrailing: {
        let last = context.state.setScores.last
          ?? TennisAttributes.ContentState.SetScore(playerOne: "0", playerTwo: "0")
        Text("\(last.playerOne)-\(last.playerTwo)")
          .font(.caption2)
          .monospacedDigit()

      } minimal: {
        Image(systemName: "tennisball.fill")
          .foregroundColor(.white)
      }
      .widgetURL(URL(string: "myapp://live-tennis"))
    }
  }
}
