import ActivityKit

public struct TennisAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    public struct SetScore: Codable, Hashable {
      public var playerOne: String
      public var playerTwo: String
    }
    public var setScores: [SetScore]
  }

  public let playerOneName: String
  public let playerTwoName: String
}
