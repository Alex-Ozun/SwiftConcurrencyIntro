import SwiftUI

@main
struct CrashCourseConcurrencyApp: App {
    var body: some Scene {
        WindowGroup {
          RacingView(viewModel: RacingViewModel())
        }
    }
}
