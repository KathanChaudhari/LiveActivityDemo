import { requireNativeModule } from "expo";
import type { ScoreWidgetPayload } from "./WidgetController.types";

const nativeModule = requireNativeModule("WidgetController");

export async function setWidgetData(payload: ScoreWidgetPayload): Promise<void> {
  return nativeModule.setWidgetData(JSON.stringify(payload));
}

export async function reloadWidget(): Promise<void> {
  return nativeModule.reloadWidget();
}
