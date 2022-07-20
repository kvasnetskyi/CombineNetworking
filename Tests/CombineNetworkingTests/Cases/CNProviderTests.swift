//
//  CNProviderTests.swift
//  
//
//  Created by Artem Kvasnetskyi on 18.07.2022.
//

import Foundation
import Combine
import XCTest

@testable import CombineNetworking

class CNProviderTests: XCTestCase {
    // MARK: - Properties
    var sut: CNProvider<CNRequestBuilderFake, CNErrorHandlerMock>!
    var builder: CNProviderBuilder!
    var decoder: JSONDecoderMock!
    var requestBuider: CNRequestBuilderFake!
    var errorHandler: CNErrorHandlerMock!
    
    // MARK: - Life Cycle
    override func setUp() {
        super.setUp()
        builder = .init()
        requestBuider = TestDoublesFactory.Fake.getCNRequestBuilder(
            isNeedToAddBaseURL: false
        )
    }

    override func tearDown() {
        builder = nil
        sut = nil
        decoder = nil
        requestBuider = nil
        errorHandler = nil
        
        super.tearDown()
    }
}

// MARK: - Test Methods
extension CNProviderTests {
    func testCNProvider_whenPerformRequest_urlRequestFromBuilderAreUsed() throws {
        // Arrange
        requestBuider = TestDoublesFactory
            .Fake
            .getCNRequestBuilder(isNeedToAddBaseURL: true)
        
        sut = builder.build()
        
        // Act
        let publisher = sut.generalPerform(requestBuider)
        let _ = try awaitPublisher(publisher)
        
        // Assert
        let urlFromHandlerURL = builder
            .errorHandler
            .lastOutputHandlingMethodOutputParameter?
            .response
            .url
        
        let outputURL = try XCTUnwrap(urlFromHandlerURL)
        
        XCTAssertEqual(outputURL, requestBuider.baseURL)
        XCTAssertNotEqual(outputURL, builder.baseURL)
    }
    
    func testCNProvider_whenReceivesDecodableResponse_passedDecoderAreUsed() throws {
        // Arrange
        decoder = TestDoublesFactory
            .Mock
            .getJSONDecoder()
        
        sut = builder
            .with(decoder: decoder)
            .build()
        
        // Act
        let publisher: AnyPublisher<String, CNError> = sut.perform(requestBuider)
        let _ = try awaitPublisher(publisher)
        
        // Assert
        XCTAssertTrue(decoder.decodeMethodHasBeenCalled)
    }
    
    func testCNProvider_whenReceivesResponse_outputIsHandledByErrorHandler() throws {
        // Arrange
        sut = builder.build()
        
        // Act
        let publisher = sut.generalPerform(requestBuider)
        let _ = try awaitPublisher(publisher)
        
        // Assert
        let countOfOutputHandlingMethodsCalled = builder.errorHandler.countOfOutputHandlingMethodsCalled
        let isOutputHandlingMethodCalled = countOfOutputHandlingMethodsCalled == 1
        XCTAssertTrue(isOutputHandlingMethodCalled)
    }
    
    func testCNProvider_whenReceivesErrorFromErrorHandler_resultFinishedWithThisError() throws {
        // Arrange
        errorHandler = TestDoublesFactory
            .Mock
            .getCNErrorHandler(returnAnErrorWhenHandling: .clientError)
        
        sut = builder
            .with(errorHandler: errorHandler)
            .build()

        // Act
        let publisher = sut.generalPerform(requestBuider)
        let error = try awaitErrorPublisher(publisher)

        // Assert
        XCTAssertEqual(error, .clientError)
    }
    
    func testCNProvider_whenReceivesNSError_errorIsConvertedByErrorHandler() throws {
        // Arrange
        let error = NSError(
            domain: .init(),
            code: NSURLErrorBadURL,
            userInfo: nil
        )
        
        sut = builder
            .makeResponse(.failure(error))
            .build()
        
        // Act
        let publisher = sut.perform(requestBuider)
        let _ = try awaitErrorPublisher(publisher)
        
        // Assert
        let countOfConvertMethodCalled = builder.errorHandler.countOfConvertMethodsCalled
        let isConvertMethodCalled = countOfConvertMethodCalled == 1
        XCTAssertTrue(isConvertMethodCalled)
    }
    
    func testCNProvider_whenReceivesResponseAndErrorHandlerCallRetryClosure_restartsTheRequest() throws {
        // Arrange
        let numberOfRecursiveCalls = 2
        sut = builder
            .makeRecursiveErrorInRequest(
                numberOfRecursiveCalls: numberOfRecursiveCalls
            )
            .build()
        
        // Act
        let publisher = sut.generalPerform(requestBuider)
        let _ = try awaitPublisher(publisher)
        
        // Assert
        let countOfOutputHandlingMethodsCalled = builder.errorHandler.countOfOutputHandlingMethodsCalled
        XCTAssertEqual(countOfOutputHandlingMethodsCalled, numberOfRecursiveCalls)
    }
    
    func testCNProvider_whenReceivesDecodableResponseAndCannotDecodeObject_resultFinishedWithDecodingError() throws {
        // Arrange
        decoder = TestDoublesFactory
            .Mock
            .getJSONDecoder(isErrorResult: true)
        
        sut = builder
            .with(decoder: decoder)
            .build()
        
        // Act
        let publisher: AnyPublisher<String, CNError> = sut.perform(requestBuider)
        let error = try awaitErrorPublisher(publisher)
        
        // Assert
        XCTAssertEqual(error, .decodingError)
    }
    
    func testCNProvider_whenPerformingRequestWithoutInternetConnection_resultFinishedWithReachabilityError() throws {
        // Arrange
        sut = builder
            .makeInternetConnectionUnavailable()
            .build()
        
        // Act
        let publisher = sut.generalPerform(requestBuider)
        let error = try awaitErrorPublisher(publisher)
        
        // Assert
        XCTAssertEqual(error, .reachabilityError)
    }
}
