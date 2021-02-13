//
//  XCTestCase.swift
//  MP3BookTests
//
//  Created by Alexander Dittner on 13.02.2021.
//

import XCTest

extension XCTestCase {
    func waitSec(duration: TimeInterval) {
        let waitExpectation = expectation(description: "Waiting")

        let when = DispatchTime.now() + duration
        DispatchQueue.main.asyncAfter(deadline: when) {
            waitExpectation.fulfill()
        }

        // We use a buffer here to avoid flakiness with Timer on CI
        waitForExpectations(timeout: duration + 0.5)
    }
}
