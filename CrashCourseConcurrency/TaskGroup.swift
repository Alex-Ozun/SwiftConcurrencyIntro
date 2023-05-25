import SwiftUI

struct TaskGroupView: View {
  @ObservedObject var viewModel: TaskGroupViewModel
  
  var body: some View {
    ScrollView {
      VStack {
        ForEach(viewModel.numbers, id: \.self) { number in
          if let number {
            Text(String(number))
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
    .font(.title)
    .padding()
  }
}

struct TaskGroupView_Previews: PreviewProvider {
  static var previews: some View {
    TaskGroupView(viewModel: TaskGroupViewModel())
  }
}

@MainActor
class TaskGroupViewModel: ObservableObject {
  let numberService = TaskGroupNumberService()
  
  @Published var numbers: [Int?] = []
  
  init() {
    let numbersCount = Int.random(in: (3...10))
    numbers = Array(repeating: nil, count: numbersCount)
  }
  
  func getNumbers() async {
    await withTaskGroup(of: IndexedNumber.self) { taskGroup in
      for index in (0..<self.numbers.count) {
        taskGroup.addTask {
          return await self.numberService.getNumber(for: index, delay: Int.random(in: (1...4)))
        }
      }
      for await number in taskGroup {
        setNumber(number)
      }
    }
  }
  
  func setNumber(_ indexedNumber: IndexedNumber) {
    numbers[indexedNumber.index] = indexedNumber.number
  }
}

@MainActor
class TaskGroupNumberService {
  func getNumber(for index: Int, delay: Int) async -> IndexedNumber {
    try? await Task.sleep(for: .seconds(delay))
    return IndexedNumber(
      number: Int.random(in: 1...50),
      index: index
    )
  }
}

struct IndexedNumber: Identifiable, Hashable {
  var id: Int { index }
  let number: Int
  let index: Int
}
