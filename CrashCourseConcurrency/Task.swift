import SwiftUI

struct TaskView: View {
  @ObservedObject var viewModel: TaskViewModel
  
  var body: some View {
    VStack {
      if let text = viewModel.text {
        Text(text)
      } else {
        ProgressView()
      }
    }
    .task {
      await viewModel.getNumber()
    }
    .font(.title)
    .padding()
  }
}

struct TaskView_Previews: PreviewProvider {
  static var previews: some View {
    TaskView(viewModel: TaskViewModel())
  }
}

@MainActor
class TaskViewModel: ObservableObject {
  let numberService = TaskNumberService()
  
  @Published var text: String?
  
  func getNumber() async {
    let number = await numberService.getNumber()
    text = String(number)
  }
}

class TaskNumberService {
  func getNumber() async -> Int {
    try? await Task.sleep(for: .seconds(1))
    return 3
  }
}
