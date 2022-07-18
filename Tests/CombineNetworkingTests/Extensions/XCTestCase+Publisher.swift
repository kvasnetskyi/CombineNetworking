//
//  XCTestCase+Publisher.swift
//  
//
//  Created by Artem Kvasnetskyi on 14.06.2022.
//

import XCTest
import Combine

extension XCTestCase {
    func awaitPublisher<T: Publisher>(
        _ publisher: T,
        withAct action: @autoclosure () -> Void,
        timeout: TimeInterval = 2,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output {
        try awaitPublisher(
            publisher: publisher,
            act: action,
            timeout: timeout,
            file: file,
            line: line
        )
    }
    
    func awaitPublisher<T: Publisher>(
        _ publisher: T,
        withAct action: () -> Void,
        timeout: TimeInterval = 2,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output {
        try awaitPublisher(
            publisher: publisher,
            act: action,
            timeout: timeout,
            file: file,
            line: line
        )
    }
    
    func awaitPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 2,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output {
        try awaitPublisher(
            publisher: publisher,
            timeout: timeout,
            file: file,
            line: line
        )
    }
}

private extension XCTestCase {
    func awaitPublisher<T: Publisher>(
        publisher: T,
        act action: () -> Void = {},
        timeout: TimeInterval,
        file: StaticString,
        line: UInt
    ) throws -> T.Output {
        var result: Result<T.Output, T.Failure>?
        let expectation = self.expectation(description: "Awaiting publisher")

        let cancellable = publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        result = .failure(error)
                        expectation.fulfill()
                        
                    case .finished:
                        break
                    }
                },
                receiveValue: { value in
                    result = .success(value)
                    expectation.fulfill()
                }
            )
        
        action()
        
        // Just like before, we await the expectation that we
        // created at the top of our test, and once done, we
        // also cancel our cancellable to avoid getting any
        // unused variable warnings:
        waitForExpectations(timeout: timeout)
        cancellable.cancel()

        // Here we pass the original file and line number that
        // our utility was called at, to tell XCTest to report
        // any encountered errors at that original call site:
        let unwrappedResult = try XCTUnwrap(
            result,
            "Awaited publisher did not produce any output",
            file: file,
            line: line
        )

        return try unwrappedResult.get()
    }
}
