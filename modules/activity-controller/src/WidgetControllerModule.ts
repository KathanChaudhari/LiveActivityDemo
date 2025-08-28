import { requireNativeModule } from "expo";
import type { ScoreWidgetPayload } from "./WidgetController.types";

const nativeModule = requireNativeModule("WidgetController");

/**
 * Save JSON for the widget (stored in App Group; read by Widget.swift).
 */
export async function setWidgetData(payload: ScoreWidgetPayload): Promise<void> {
  return nativeModule.setWidgetData(JSON.stringify(payload));
}

/**
 * Ask WidgetKit to reload timelines for your widget kind.
 */
export async function reloadWidget(): Promise<void> {
  return nativeModule.reloadWidget();
}
