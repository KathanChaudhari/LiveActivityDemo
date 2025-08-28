import ExpoModulesCore
import ActivityKit


final class ActivityUnavailableException: GenericException<Void> {
  override var reason: String { "Live activities are not available on this system." }
}
final class ActivityDataException: GenericException<String> {
  override var reason: String { "Failed to parse Live Activity data: \(param)" }
}


fileprivate struct StartParams: Decodable {
  let playerOneName: String
  let playerTwoName: String
  let setScores: [TennisAttributes.ContentState.SetScore]
}

fileprivate struct UpdateParams: Decodable {
  let setScores: [TennisAttributes.ContentState.SetScore]
}


public class ActivityControllerModule: Module {
  public func definition() -> ModuleDefinition {
    Name("ActivityController")

    Property("areLiveActivitiesEnabled") {
      if #available(iOS 16.2, *) {
        return ActivityAuthorizationInfo().areActivitiesEnabled
      }
      return false
    }

    AsyncFunction("startLiveActivity") { (rawData: String) async throws -> Void in
      guard #available(iOS 16.2, *) else {
        throw ActivityUnavailableException(())
      }
      let data = Data(rawData.utf8)
      let params: StartParams
      do {
        params = try JSONDecoder().decode(StartParams.self, from: data)
      } catch {
        throw ActivityDataException(rawData)
      }

      guard Activity<TennisAttributes>.activities.isEmpty else {
        throw ActivityUnavailableException(())
      }
      
      guard ActivityAuthorizationInfo().areActivitiesEnabled else {
        throw ActivityUnavailableException(())
      }

      let attrs = TennisAttributes(
        playerOneName: params.playerOneName,
        playerTwoName: params.playerTwoName
      )
      let state = TennisAttributes.ContentState(setScores: params.setScores)

      _ = try Activity<TennisAttributes>.request(
        attributes: attrs,
        contentState: state,
        pushType: nil
      )
    }


    AsyncFunction("updateLiveActivity") { (rawData: String) async throws -> Void in
      guard #available(iOS 16.2, *) else {
        throw ActivityUnavailableException(())
      }
      guard let activity = Activity<TennisAttributes>.activities.first else {
        throw ActivityUnavailableException(())
      }

   
      let data = Data(rawData.utf8)
      let params: UpdateParams
      do {
        params = try JSONDecoder().decode(UpdateParams.self, from: data)
      } catch {
        throw ActivityDataException(rawData)
      }

      await activity.update(using: TennisAttributes.ContentState(setScores: params.setScores))
    }

    AsyncFunction("stopLiveActivity") { () async throws -> Void in
      guard #available(iOS 16.2, *) else {
        throw ActivityUnavailableException(())
      }
      guard let activity = Activity<TennisAttributes>.activities.first else {
        throw ActivityUnavailableException(())
      }
      await activity.end(dismissalPolicy: .immediate)
    }

    Function("isLiveActivityRunning") { () -> Bool in
      if #available(iOS 16.2, *) {
        return !Activity<TennisAttributes>.activities.isEmpty
      }
      return false
    }
  }
}
