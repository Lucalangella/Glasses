import Foundation

// MARK: - Walkthrough Step Definition

struct WalkthroughStep {
    let id: String
    let title: String
    let body: String
    let icon: String
    /// The task label shown while the step is incomplete.
    let task: String?
    /// When true, the "Next" button stays disabled until the task is done.
    let requiresCompletion: Bool
}
