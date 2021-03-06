//
//  DemoFileAppServiceTests.swift
//  MP3BookTests
//
//  Created by Alexander Dittner on 05.02.2021.
//

import Combine
@testable import MP3Book
import XCTest

class PortAdapterTests: XCTestCase {
    func testPortNotification() throws {
        let port = OutputPort<Person>()

        var isFirstRequestProcessed = false
        var isSecondRequestProcessed = false

        let subscription = port.subject.sink { persons in
            if !isFirstRequestProcessed {
                isFirstRequestProcessed = true
                XCTAssertEqual(persons.count, 0)
            } else if !isSecondRequestProcessed {
                isSecondRequestProcessed = true
                XCTAssertEqual(persons.count, 2)
                XCTAssertEqual(persons[0].name, "Bob")
                XCTAssertEqual(persons[1].name, "John")
            } else {
                XCTFail("More notifications as required")
            }
        }

        XCTAssertTrue(isFirstRequestProcessed)

        port.write([Person(id: "1", name: "Bob"), Person(id: "2", name: "John")])

        XCTAssertTrue(isSecondRequestProcessed)

        subscription.cancel()
    }
}

struct Person {
    let id: String
    let name: String
}
