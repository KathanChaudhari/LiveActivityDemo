import { requireNativeModule } from "expo";
import type {
  StartLiveActivityFn,
  UpdateLiveActivityFn,
  StopLiveActivityFn,
  IsLiveActivityRunningFn,
} from "./ActivityController.types";

const nativeModule = requireNativeModule("ActivityController");


export const startLiveActivity: StartLiveActivityFn = async (params) => {
  const stringParams = JSON.stringify(params);
  return nativeModule.startLiveActivity(stringParams);
};


export const updateLiveActivity: UpdateLiveActivityFn = async (params) => {
  const stringParams = JSON.stringify(params);
  if (typeof nativeModule.updateLiveActivity === "function") {
    return nativeModule.updateLiveActivity(stringParams);
  }
  return Promise.resolve();
};


export const stopLiveActivity: StopLiveActivityFn = async () => {
  return nativeModule.stopLiveActivity();
};


export const isLiveActivityRunning: IsLiveActivityRunningFn = () => {
  return nativeModule.isLiveActivityRunning();
};


export const areLiveActivitiesEnabled: boolean =
  nativeModule.areLiveActivitiesEnabled;
