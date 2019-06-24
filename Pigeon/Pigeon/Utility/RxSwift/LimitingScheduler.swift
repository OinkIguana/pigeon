//
//  LimitingScheduler.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2019-01-05.
//  Copyright © 2019 Cameron Eldridge. All rights reserved.
//

import Foundation
import RxSwift

final class LimitingScheduler: ImmediateSchedulerType {
  let period: TimeInterval
  let queue: DispatchQueue

  private var dispatchHistory: [DispatchTime] = []

  init(period: TimeInterval, queue: DispatchQueue = .main) {
    self.period = period
    self.queue = queue
  }

  func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
    let cancel = SingleAssignmentDisposable()
    queue.asyncAfter(deadline: nextDeadline()) {
      guard !cancel.isDisposed else { return }
      cancel.setDisposable(action(state))
    }
    return cancel
  }

  private func nextDeadline() -> DispatchTime {
    let lastEvent = dispatchHistory.last
    let deadline = lastEvent.map { $0 + self.period } ?? .now()
    dispatchHistory.append(deadline)
    return deadline
  }
}
