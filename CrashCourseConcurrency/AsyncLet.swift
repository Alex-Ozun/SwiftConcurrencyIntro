import SwiftUI

struct AsyncLetView: View {
  @ObservedObject var viewModel: AsyncLetViewModel
  
  var body: some View {
    VStack(spacing: 10) {
      if let number1 = viewModel.number1 {
        Text(String(number1))
      } else {
        ProgressView()
          .frame(height: 30)
      }
      if let number2 = viewModel.number2 {
        Text(String(number2))
      } else {
        ProgressView()
          .frame(height: 30)
      }
      if let number3 = viewModel.number3 {
        Text(String(number3))
      } else {
        ProgressView()
          .frame(height: 30)
      }
    }
    .task {
      await viewModel.getNumbers()
    }
    .font(.title)
    .padding()
  }
}

struct AsyncLetView_Previews: PreviewProvider {
  static var previews: some View {
    AsyncLetView(viewModel: AsyncLetViewModel())
  }
}

@MainActor
class AsyncLetViewModel: ObservableObject {
  let numberService = AsyncLetNumberService()
  
  @Published var number1: Int?
  @Published var number2: Int?
  @Published var number3: Int?
  
  func getNumbers() async {
    async let number1 = numberService.getNumber(delay: 1)
    async let number2 = numberService.getNumber(delay: 1)
    async let number3 = numberService.getNumber(delay: 1)
    
    self.number1 = await number1
    self.number2 = await number2
    self.number3 = await number3
  }
}

class AsyncLetNumberService {
  func getNumber(delay: Int = 1) async -> Int {
    try? await Task.sleep(for: .seconds(delay))
    return Int.random(in: 1...5)
  }
}
