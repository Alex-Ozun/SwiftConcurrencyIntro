import SwiftUI

struct TaskDelegateView: View {
  @ObservedObject var viewModel: TaskDelegateViewModel
  
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

struct TaskDelegateView_Previews: PreviewProvider {
  static var previews: some View {
    TaskDelegateView(viewModel: TaskDelegateViewModel())
  }
}

@MainActor
class TaskDelegateViewModel: ObservableObject, TaskDelegateNumberServiceDelegate {
  let numberService = TaskDelegateNumberService()
  
  @Published var text: String?
  
  init() {
    numberService.delegate = self
  }
  
  var continuation: CheckedContinuation<Int, Never>?
  
  func getNumber() async {
    let number = await withCheckedContinuation { continuation in
      numberService.getNumber()
      self.continuation = continuation
    }
    text = String(number)
  }
  
  func didCreateNumber(_ number: Int) {
    continuation?.resume(returning: number)
    continuation = nil
  }
}

@MainActor
protocol TaskDelegateNumberServiceDelegate: AnyObject {
  func didCreateNumber(_ number: Int)
}

final class TaskDelegateNumberService {
  weak var delegate: TaskDelegateNumberServiceDelegate?
  
  func getNumber() {
    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
      DispatchQueue.main.async {
        let number = Int.random(in: 1...5)
        self.delegate?.didCreateNumber(number)
      }
    }
  }
}
