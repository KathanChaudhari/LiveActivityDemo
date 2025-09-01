import ExpoModulesCore
import WidgetKit
import OSLog

private let APP_GROUP_ID = "group.com.kiyo.tennis.shared"

private let WIDGET_KIND = "widget"

private let WIDGET_PAYLOAD_KEY = "score_widget_payload"

private let widgetLog = Logger(subsystem: "com.your.app", category: "WidgetController")

public class WidgetControllerModule: Module {
  public func definition() -> ModuleDefinition {
    Name("WidgetController")

    AsyncFunction("setWidgetData") { (rawData: String) async throws -> Void in
      guard let ud = UserDefaults(suiteName: APP_GROUP_ID) else {
        widgetLog.error("App Group not found: \(APP_GROUP_ID, privacy: .public)")
        return
      }
      ud.set(rawData, forKey: WIDGET_PAYLOAD_KEY)
      widgetLog.debug("setWidgetData: wrote \(rawData.count, privacy: .public) bytes to '\(WIDGET_PAYLOAD_KEY, privacy: .public)' in group \(APP_GROUP_ID, privacy: .public)")

      #if DEBUG
      if let echo = ud.string(forKey: WIDGET_PAYLOAD_KEY) {
        widgetLog.debug("setWidgetData: echo read OK (\(echo.count) bytes)")
      } else {
        widgetLog.error("setWidgetData: echo read FAILED")
      }
      #endif
    }

    AsyncFunction("reloadWidget") { () async -> Void in
      if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadTimelines(ofKind: WIDGET_KIND)
        widgetLog.debug("reloadWidget: requested reload for kind '\(WIDGET_KIND, privacy: .public)'")
      } else {
        widgetLog.error("reloadWidget: iOS < 14.0")
      }
    }

    AsyncFunction("clearWidgetData") { () async -> Void in
      guard let ud = UserDefaults(suiteName: APP_GROUP_ID) else {
        widgetLog.error("clearWidgetData: App Group not found: \(APP_GROUP_ID, privacy: .public)")
        return
      }
      ud.removeObject(forKey: WIDGET_PAYLOAD_KEY)
      widgetLog.debug("clearWidgetData: removed '\(WIDGET_PAYLOAD_KEY, privacy: .public)'")

      if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadTimelines(ofKind: WIDGET_KIND)
        widgetLog.debug("clearWidgetData: requested reload for kind '\(WIDGET_KIND, privacy: .public)'")
      }
    }
  }
}
