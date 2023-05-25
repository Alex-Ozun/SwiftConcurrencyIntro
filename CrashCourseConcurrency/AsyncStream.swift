import SwiftUI

struct AsyncStreamView: View {
  @ObservedObject var viewModel: AsyncStreamViewModel
  
  var body: some View {
    ScrollView {
      VStack {
        ForEach(viewModel.numbers, id: \.self) { number in
          Text(number)
        }
        ProgressView()
      }
    }
    .task {
      await viewModel.getNumbers()
    }
    .font(.title)
    .padding()
  }
}

struct AsyncStreamView_Previews: PreviewProvider {
  static var previews: some View {
    AsyncStreamView(viewModel: AsyncStreamViewModel())
  }
}

@MainActor
class AsyncStreamViewModel: ObservableObject {
  let numberService = AsyncStreamNumberService()
  
  @Published var numbers: [String] = []
  
  func getNumbers() async {
    for await number in numberService.numbers {
      numbers.append(String(number))
    }
  }
}

class AsyncStreamNumberService {
  var number = 0
  var numbers: AsyncStream<Int> {
    AsyncStream { stream in
      Task {
        while true {
          try? await Task.sleep(for: .seconds(1))
          number += 1
          stream.yield(number)
        }
      }
    }
  }
}
