import Foundation
import Combine

public var subscriptions = Set<AnyCancellable>()

public func example(of description: String,
                    action: () -> Void) {
    print("\n——— Example of:", description, "———")
    action()
}
