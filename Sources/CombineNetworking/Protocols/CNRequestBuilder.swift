//
//  CNRequestBuilder.swift
//  CombineNetworking
//
//  Created by Artem Kvasnetskyi on 24.09.2021.
//  Copyright © 2021 Artem Kvasnetskyi. All rights reserved.

import Foundation

public typealias QueryItems = [String: String]
public typealias HTTPHeaderFields = [String: String]

/// The Request Builder contains variables that are used to build the request step by step.
///
/// It is convenient to use with Enums, which will describe each individual request as a separate enum case.
///
/// **Request Builder includes:**
/// - **path** – the path that will be added to the base URL when creating a request.
/// - **query** – query items as keys and values which will be added to the request. If request shouldn't contain them, it should return nil.
/// - **body** – data to be added to the body of the request. If the request should not contain a body - return nil.
/// - **method** – HTTP Method which will be added to the reques.
/// - **baseURL** – a base URL that can be added to your request. Serves as an exception to the rule. In most cases the base URL will be taken from the Networking Provider.
/// Specify this variable only when the base URL of a particular request differs from the base URL injected by Networking Provider.
/// You can ignore this variable when creating an object. By default it returns nil.
/// - **headerFields** – header fields that can be added to the request.
/// Used only if you want to specify additional header fields in addition to those specified in the CNPlugin array.
/// You can ignore this variable when creating an object. By default it returns nil.
/// - **multipartBody** – variable that can return CNMultipartFormDataModel. Used to create multipart form requests.
/// If the variable does not return nil, the body created by the CNMultipartFormDataModel will be added to the request. Do not use this and body variable at the same time.
/// You can ignore this variable when creating an object. By default it returns nil.

public protocol CNRequestBuilder {
    /// The path that will be added to the base URL when creating a request.
    var path: String { get }
    
    /// Query items as keys and values which will be added to the request. If request shouldn't contain them, it should return nil.
    var query: QueryItems? { get }
    
    /// Data to be added to the body of the request. If the request should not contain a body - return nil.
    var body: Data? { get }
    
    /// HTTP Method which will be added to the reques.
    var method: HTTPMethod { get }
    
    /// A base URL that can be added to your request. Serves as an exception to the rule. In most cases the base URL will be taken from the Networking Provider.
    /// Specify this variable only when the base URL of a particular request differs from the base URL injected by Networking Provider.
    /// You can ignore this variable when creating an object. By default it returns nil.
    var baseURL: URL? { get }
    
    /// Header fields that can be added to the request.
    /// Used only if you want to specify additional header fields in addition to those specified in the CNPlugin array.
    /// You can ignore this variable when creating an object. By default it returns nil.
    var headerFields: HTTPHeaderFields? { get }
    
    /// Variable that can return CNMultipartFormDataModel. Used to create multipart form requests.
    /// If the variable does not return nil, the body created by the CNMultipartFormDataModel will be added to the request.
    /// Do not use this and body variable in a CNRequestBuilder at the same time.
    /// You can ignore this variable when creating an object. By default it returns nil.
    var multipartBody: CNMultipartFormDataModel? { get }
}

// MARK: - Public Methods
extension CNRequestBuilder {
    public var baseURL: URL? { nil }
    public var headerFields: HTTPHeaderFields? { nil }
    public var multipartBody: CNMultipartFormDataModel? { nil }
    
    /// Creates a URLRequest based on the specified variables within the CNRequestBuilder, and the parameters passed: Base URL and CNPlugin array.
    ///
    /// When creating a URLRequest, the method checks if the CNRequestBuilder has baseURL and headerFields, and if not, takes them from the parameters.
    /// Also, the method checks if the CNRequestBuilder has a multipartBody variable.
    /// If it is, it substitutes it in the body of the request, if not, it substitutes the body variable in the body.
    public func makeRequest(baseURL: URL, plugins: [CNPlugin]) -> URLRequest {
        var request = makeRequestWithoutBody(baseURL: baseURL, plugins: plugins)
        
        guard let multipartBody = multipartBody,
              method != .get else {
                  
            request.httpBody = body
            CNLogManager.log(request)
            return request
        }
        
        let body = multipartBody.encode()
        let length = (body as NSData).length
        
        setMultipartHeaders(
            toRequest: &request,
            contentLength: length,
            boundary: multipartBody.boundary
        )
        
        request.httpBody = body
        CNLogManager.log(request)
        
        return request
    }
}

// MARK: - Private Methods
private extension CNRequestBuilder {
    func makeRequestWithoutBody(baseURL: URL, plugins: [CNPlugin]) -> URLRequest {
        let baseURL = self.baseURL ?? baseURL
        let url = getURL(baseURL: baseURL)
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        plugins.forEach { $0.modifyRequest(&request) }
        
        headerFields?.forEach {
            request.addValue(
                $0.value,
                forHTTPHeaderField: $0.key
            )
        }
        
        return request
    }
    
    func setMultipartHeaders(toRequest request: inout URLRequest,
                             contentLength: Int,
                             boundary: String) {
        
        request.setValue(
            "multipart/form-data; boundary=" + boundary,
            forHTTPHeaderField: "Content-Type"
        )
        
        request.setValue(
            String(contentLength),
            forHTTPHeaderField: "Content-Length"
        )
    }
    
    func getURL(baseURL: URL) -> URL {
        let url = baseURL.appendingPathComponent(path)
        
        guard let query = query else { return url }
        guard var components = URLComponents(string: url.absoluteString) else {
            fatalError(
                CNFatalError
                    .pathIncorrect(path)
                    .localizedDescription
            )
        }
        
        components.queryItems = convert(query)
        
        guard let url = components.url else {
            fatalError(
                CNFatalError
                    .pathOrQueryIncorrect(path, query)
                    .localizedDescription
            )
        }
                             
        return url
    }
    
    func convert(_ items: QueryItems?) -> [URLQueryItem]? {
        items?.map {
            URLQueryItem(
                name: $0.key,
                value: $0.value
            )
        }
    }
}
