export type SetScore = {
  playerOne: string
  playerTwo: string
}

export type LiveActivityParams = {
  playerOneName: string
  playerTwoName: string
  setScores: SetScore[]      
}

export type StartLiveActivityFn = (
  params: LiveActivityParams
) => Promise<void>

export type UpdateLiveActivityFn = (
  params: { setScores: SetScore[] }
) => Promise<void>

export type StopLiveActivityFn = () => Promise<void>
export type IsLiveActivityRunningFn = () => boolean
