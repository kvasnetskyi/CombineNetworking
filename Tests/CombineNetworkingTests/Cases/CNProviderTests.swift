//
//  CNProviderTests.swift
//  
//
//  Created by Artem Kvasnetskyi on 18.07.2022.
//

import Foundation
import XCTest

@testable import CombineNetworking

class CNProviderTests: XCTestCase {
    // MARK: - Properties
    
    // MARK: - Life Cycle
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
}

// MARK: - Test Methods
extension CNProviderTests {
    func testCNProvider_whenReceivesDecodableResponse_passedDecoderAreUsed() throws {
        
    }
    
    func testCNProvider_whenReceivesDecodableResponseAndCannotDecodeObject_resultFinishedWithDecodingError() throws {
        
    }
    
    func testCNProvider_whenPerformRequest_urlRequestFromBuilderAreUsed() throws {
        
    }
    
    func testCNProvider_whenReceivesResponse_outputIsHandledByOutputHandler() throws {
        
    }
    
    func testCNProvider_whenReceivesErrorFromOutputHandler_resultFinishedWithThisError() throws {
        
    }
    
    func testCNProvider_whenReceivesNSError_errorIsConvertedByOutputHandler() throws {
        
    }
    
    func testCNProvider_whenReceivesResponseAndOutputHandlerCallRetryClosure_restartsTheRequest() throws {
        
    }
    
    func testCNProvider_whenPerformingRequestWithoutInternetConnection_resultFinishedWithReachabilityError() throws {
        
    }
    
    func testCNProvider_whenReceivesResponseFromRequestWithOutputIgnoring_resultIsFinishedSuccessfully() throws {
        
    }
}
