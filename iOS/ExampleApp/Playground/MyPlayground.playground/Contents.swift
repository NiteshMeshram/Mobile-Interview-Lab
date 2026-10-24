import UIKit

var greeting = "Hello, playground"

func DispatchQueueExample() {

    let queue = DispatchQueue(
        label: "concurrent",
        attributes: .concurrent
    )

    queue.async {
        print("Task 1 START")

        sleep(3)

        print("Task 1 END")
    }

    queue.async {
        print("Task 2 START")

        sleep(1)

        print("Task 2 END")
    }

    queue.async {
        print("Task 3 START")

        sleep(2)

        print("Task 3 END")
    }

}

DispatchQueueExample()



