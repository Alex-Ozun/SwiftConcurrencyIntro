import SwiftUI

struct TaskClosureView: View {
  @ObservedObject var viewModel: TaskClosureViewModel
  
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

struct TaskClosureView_Previews: PreviewProvider {
  static var previews: some View {
    TaskClosureView(viewModel: TaskClosureViewModel())
  }
}

@MainActor
class TaskClosureViewModel: ObservableObject {
  let numberService = TaskClosureNumberService()
  
  @Published var text: String?
  
  func getNumber() async {
    let number = await withCheckedContinuation { continuation in
      numberService.getNumber { number in
        continuation.resume(returning: number)
      }
    }
    text = String(number)
  }
}

class TaskClosureNumberService {
  func getNumber(_ completion: @escaping (Int) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
      let number = Int.random(in: 1...5)
      completion(number)
    }
  }
}
