//
//  CNRequestBuilderTests.swift
//  
//
//  Created by Artem Kvasnetskyi on 16.07.2022.
//

import XCTest

@testable import CombineNetworking

class CNRequestBuilderTests: XCTestCase {
    // MARK: - Properties
    var sut: CNRequestBuilder!
    var plugin: CNPluginFake!
    var builder: CNRequestBuilderBuilder!
    
    // MARK: - Life Cycle
    override func setUp() {
        super.setUp()
        builder = .init()
    }

    override func tearDown() {
        super.tearDown()
        builder = nil
        sut = nil
        plugin = nil
    }
}

// MARK: - Test Methods
extension CNRequestBuilderTests {
    func testCNRequestBuilder_whenCreatingRequest_allPropertiesAreSet() throws {
        // Arrange
        sut = builder
            .with(
                body: getDataForTest()
            )
            .makeQuery()
            .makeBaseURL()
            .makeHeaderFields()
            .build()
        
        // Act
        let request = try sut.makeRequest()
        
        // Assert
        let body = try XCTUnwrap(request.httpBody)
        let (baseURL, path, query) = try getURLComponents(from: request)
        let headerFields = try XCTUnwrap(request.allHTTPHeaderFields)
        
        XCTAssertEqual(builder.body, body)
        XCTAssertEqual(builder.baseURL, baseURL)
        XCTAssertEqual(builder.path, path)
        XCTAssertEqual(builder.query, query)
        XCTAssertEqual(builder.headerFields, headerFields)
    }
    
    func testCNRequestBuilder_whenCreatingRequestWithInternalBaseURLAndPassedBaseURL_internalBaseURLIsSetInTheRequest() throws {
        // Arrange
        let passedURL = URL(string: "https://passedURL.test")
        
        sut = builder
            .makeBaseURL()
            .build()
        
        // Act
        let request = try sut.makeRequest(
            baseURL: passedURL
        )
        
        // Assert
        let (baseURL, _, _) = try getURLComponents(from: request)
        
        XCTAssertEqual(builder.baseURL, baseURL)
        XCTAssertNotEqual(passedURL, baseURL)
    }
    
    func testCNRequestBuilder_whenCreatingRequestWithPlugins_pluginsActionIsExecutedLast() throws {
        // Arrange
        sut = builder
            .with(
                body: getDataForTest()
            )
            .makeQuery()
            .makeBaseURL()
            .makeHeaderFields()
            .build()
        
        plugin = TestDoublesFactory.Fake.getPugin()
        
        // Act
        let request = try sut.makeRequest(plugins: [plugin])
        
        // Assert
        XCTAssertEqual(request.url, plugin.url)
        XCTAssertEqual(request.httpBody, plugin.body)
        XCTAssertEqual(request.httpMethod, plugin.method)
        plugin.headerFields.keys.forEach {
            XCTAssertNotNil(request.allHTTPHeaderFields?[$0])
        }
    }
    
    func testCNRequestBuilder_whenCreatingRequestWithGetMethodAndMultipartBody_multipartBodyIgnored() throws {
        // Arrange
        sut = builder
            .with(method: .get)
            .makeBaseURL()
            .makeMultipartBody()
            .build()
        
        // Act
        let request = try sut.makeRequest()
        
        // Assert
        XCTAssertNil(request.httpBody)
    }
    
    func testCNRequestBuilder_whenCreatingRequestWithMultipartBody_multipartBodyHeadersIsSetInTheRequest() throws {
        // Arrange
        sut = builder
            .makeBaseURL()
            .makeMultipartBody()
            .build()
        
        // Act
        let request = try sut.makeRequest()
        
        // Assert
        let headerFields = try XCTUnwrap(request.allHTTPHeaderFields)
        let contentType = try XCTUnwrap(headerFields["Content-Type"])
        let isContentTypeIsMultipart = contentType.starts(with: "multipart/form-data; boundary=")
        
        XCTAssertNotNil(headerFields["Content-Length"])
        XCTAssertTrue(isContentTypeIsMultipart)
    }
    
    func testCNRequestBuilder_whenCreatingRequestWithMultipartBodyAndDataBody_multipartBodyIsSetInTheRequest() throws {
        // Arrange
        sut = builder
            .makeBaseURL()
            .makeMultipartBody()
            .with(body: getDataForTest())
            .build()
        
        // Act
        let request = try sut.makeRequest()
        
        // Assert
        XCTAssertNotEqual(request.httpBody, builder.body)
        XCTAssertEqual(request.httpBody, builder.multipartBody?.encode())
    }
}

// MARK: - Private Methods
private extension CNRequestBuilderTests {
    func getMethod(
        from request: URLRequest,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> HTTPMethod {
        let method = try XCTUnwrap(
            request.httpMethod,
            file: file,
            line: line
        )
        
        return try XCTUnwrap(
            HTTPMethod(rawValue: method),
            file: file,
            line: line
        )
    }
    
    func getURLComponents(
        from request: URLRequest,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> (baseURL: URL, path: String, query: QueryItems?) {
        let url = try XCTUnwrap(request.url, file: file, line: line)
        let path = url.path
        let scheme = url.scheme ?? ""
        let host = url.host ?? ""
        let baseURL = try XCTUnwrap(
            URL(string: "\(scheme)://\(host)"),
            file: file,
            line: line
        )
        
        let components = try XCTUnwrap(
            URLComponents(url: url, resolvingAgainstBaseURL: false),
            file: file,
            line: line
        )
        
        var queryDict = [String: String]()
        components.queryItems?.forEach {
            queryDict[$0.name] = $0.value
        }
        
        let query: QueryItems? = queryDict.isEmpty ? nil : queryDict
        
        return (baseURL: baseURL, path: path, query: query)
    }
}
