// modules/ios/WidgetControllerModule.swift
import ExpoModulesCore
import WidgetKit

// ⚠️ Update to your real App Group (must match App target + Widget extension)
private let APP_GROUP_ID = "group.com.your.app.shared"

// Must match the `kind` in your `struct widget: Widget { let kind = "widget" }`
private let WIDGET_KIND = "widget"

// Key used to store JSON payload for the widget
private let WIDGET_PAYLOAD_KEY = "score_widget_payload"

public class WidgetControllerModule: Module {
  public func definition() -> ModuleDefinition {
    Name("WidgetController")

    // Save JSON string for the widget to read from App Group storage
    AsyncFunction("setWidgetData") { (rawData: String) async throws -> Void in
      let ud = UserDefaults(suiteName: APP_GROUP_ID)
      ud?.set(rawData, forKey: WIDGET_PAYLOAD_KEY)
    }

    // Ask WidgetKit to reload your widget timelines
    AsyncFunction("reloadWidget") { () async -> Void in
      if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadTimelines(ofKind: WIDGET_KIND)
      }
    }

    // Optional: clear stored payload (useful during testing)
    AsyncFunction("clearWidgetData") { () async -> Void in
      let ud = UserDefaults(suiteName: APP_GROUP_ID)
      ud?.removeObject(forKey: WIDGET_PAYLOAD_KEY)
      if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadTimelines(ofKind: WIDGET_KIND)
      }
    }
  }
}
