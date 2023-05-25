import SwiftUI

struct RacingView: View {
  @ObservedObject var viewModel: RacingViewModel
  
  var body: some View {
    ScrollView {
      VStack {
        ForEach(viewModel.numbers, id: \.self) { number in
          if let number {
            Text(String(number.number))
              .font(.title)
          } else {
            ProgressView()
              .frame(height: 20)
          }
        }
      }
    }
    .task {
      await viewModel.getNumbers()
    }
    .padding()
  }
}

struct RacingView_Previews: PreviewProvider {
  static var previews: some View {
    RacingView(viewModel: RacingViewModel())
  }
}

@MainActor
class RacingViewModel: ObservableObject {
  let numberService = RacingNumberService()
  
  @Published var numbers: [IndexedNumber?] = []
  
  init() {
    let numbersCount = 50
    numbers = Array(repeating: nil, count: numbersCount)
  }
  
  func getNumbers() async {
    await withTaskGroup(of: IndexedNumber.self) { taskGroup in
      for index in (0..<numbers.count) {
        taskGroup.addTask {
          let indexedNumber = await self.numberService.getNumber(
            for: index,
            delay: Int.random(in: 1...4)
          )
          return indexedNumber
        }
      }
      Task {
        await logger.deactivate()
      }
      for await indexedNumber in taskGroup {
        setNumber(indexedNumber)
      }
      await print(logger.logs.count)
    }
  }
  
  func setNumber(_ indexedNumber: IndexedNumber) {
    numbers[indexedNumber.index] = indexedNumber
  }
}

class RacingNumberService {
  func getNumber(for index: Int, delay: Int) async -> IndexedNumber {
    await logger.writeLog(
      "generating a number..."
    )
    try? await Task.sleep(for: .seconds(delay))
    let indexedNumber = IndexedNumber(
      number: Int.random(in: 1...100),
      index: index
    )
  
    return indexedNumber
  }
}

let logger = Logger()
actor Logger {
  var isActive: Bool = true
  var logs: [String] = []
  
  func deactivate() async {
    isActive = false
  }
  
  func writeLog(_ log: String) async {
    let shouldWrite = isActive
    try? await Task.sleep(for: .seconds(1))
    
    if shouldWrite { // replace with isActive to fix reentrancy
      logs.append(log)
    }
  }
}
