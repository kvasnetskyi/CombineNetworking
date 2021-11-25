# Combine Networking
**Combine Networking** is a convenient and flexible networking layer based on Apple's native Combine and URLSession technologies.

It does not use any third-party dependencies, so there is nothing superfluous in it.

# Components
1. [CNPlugin](#CNPlugin)
2. [CNReachabilityManager](#CNReachabilityManager)
3. [CNErrorHandler](#CNErrorHandler)
4. [CNRequestBuilder](#CNRequestBuilder)
5. [CNProvider](#CNProvider)
6. [CNProviderProtocol](#CNProviderProtocol)

# CNPlugin
```Ruby
public protocol CNPlugin {
    func modifyRequest(_ request: inout URLRequest)
}
```

An object protocol that can modify a URLRequest. Most often you will use it to add certain headers:

```Ruby
struct AuthPlugin: CNPlugin {
    let token: String
    
    init(token: String) {
        self.token = token
    }
    
    func modifyRequest(_ request: inout URLRequest) {
        request.setValue(token, forHTTPHeaderField: "x-api-key")
    }
}
```

# CNReachabilityManager
###### You can use the default implementation - CNReachabilityManagerImpl

```Ruby
public protocol CNReachabilityManager: AnyObject {
    var isInternetConnectionAvailable: Bool { get }
}
```

Protocol object that monitors the internet connection before running the request.

You can write your own manager that will subscribe to this protocol, or use the default implementation - **CNReachabilityManagerImpl**.

# CNErrorHandler
###### You can use the default implementation - CNErrorHandlerImpl

```Ruby
public protocol CNErrorHandler {
    associatedtype ErrorType: CNErrorProtocol
    
    func outputHandling(
        _ output: NetworingOutput,
        _ retryMethod: @autoclosure () -> AnyPublisher<Data, ErrorType>
    ) -> AnyPublisher<Data, ErrorType>
    
    func convert(error: NSError) -> ErrorType
}
```

Manager protocol for handling errors resulting from Combine Networking.

You can use the standard implementation of CNErrorHandler - **CNErrorHandlerImpl**. But if you need to handle errors specifically, you will use your own.

It contains:
* ErrorType *associatedtype* <br/>
The error type that your Combine Networking will work with. You can use your own error type, but it must be signed to CNErrorProtocol, which contains the main errors.

* outputHandling *method* <br/>
A method for processing the response from the server. Gets a server response that you can process the way you want, and a retryMethod block that can be used to retry the request after it has been processed. 

* convert *method* <br/>
It often happens that a request to the network fails. For example, while launching the request, the Internet on the device has disappeared. 

This method takes such errors as NSError, and serves to convert it into your custom error.

# CNRequestBuilder
The request builder protocol contains variables that are used to build the request step by step.

```Ruby
public protocol CNRequestBuilder {
    var path: String { get }
    var query: QueryItems? { get }
    var body: Data? { get }
    var method: HTTPMethod { get }
    var baseURL: URL? { get }
    var headerFields: HTTPHeaderFields? { get }
    var multipartBody: CNMultipartFormDataModel? { get }
}

// MARK: - Public Methods
extension CNRequestBuilder {
    public var baseURL: URL? { nil }
    public var headerFields: HTTPHeaderFields? { nil }
    public var multipartBody: CNMultipartFormDataModel? { nil }
    
    public func makeRequest(baseURL: URL, plugins: [CNPlugin]) -> URLRequest { ... }
}
```

It is convenient to use with Enums, which will describe each individual request as a separate enum case.

RequestBuilder includes:
* path <br/>
The path that will be added to the base URL when creating a request.

* query <br/>
Query items as keys and values which will be added to the request. If request shouldn't contain them, it should return nil.

* body <br/>
Data to be added to the body of the request. If the request should not contain a body - return nil.

* method <br/>
HTTP Method which will be added to the reques.

* baseURL <br/>
A base URL that can be added to your request. Serves as an exception to the rule. In most cases the base URL will be taken from the [CNProvider](#CNProvider).

Specify this variable only when the base URL of a particular request differs from the base URL injected by Networking Provider. You can ignore this variable when creating an object. By default it returns nil.

* headerFields <br/>
Header fields that can be added to the request.

Used only if you want to specify additional header fields in addition to those specified in the [CNPlugin](#CNPlugin) array. You can ignore this variable when creating an object. By default it returns nil.

* multipartBody <br/>
Variable that can return CNMultipartFormDataModel. Used to create multipart form requests.

If the variable does not return nil, the body created by the CNMultipartFormDataModel will be added to the request. Do not use this and body variable at the same time. You can ignore this variable when creating an object. By default it returns nil.

# CNProvider
A class that serves as a provider to run requests to the server.

CNProvider is an implementation of the [CNProviderProtocol](#CNProviderProtocol). In this section you will learn about the accepted CNProvider parameters. You can learn more about its methods and generic types in [CNProviderProtocol](#CNProviderProtocol).

CNProvider has several initializers. One of them uses the standard implementation of the [CNErrorHandler](#CNErrorHandler) protocol - CNErrorHandlerImpl.

```Ruby
public init(
    baseURL: URL,
    reachability: CNReachabilityManager = CNReachabilityManagerImpl(),
    session: URLSession = .shared,
    requestBuilder: RequestBuilder.Type,
    plugins: [CNPlugin] = [],
    decoder: JSONDecoder = JSONDecoder()
) where ErrorHandler == CNErrorHandlerImpl {...}

public required init(
    baseURL: URL,
    reachability: CNReachabilityManager = CNReachabilityManagerImpl(),
    session: URLSession = .shared,
    errorHandler: ErrorHandler,
    requestBuilder: RequestBuilder.Type,
    plugins: [CNPlugin] = [],
    decoder: JSONDecoder = JSONDecoder()
) {...}
```
The init takes in:
* baseURL <br/>
Base URL where the request will be made.

* [reachability](#CNReachabilityManager) <br/>
CNReachabilityManagerImpl by default.

* session <br/>
URLSession with which the request will be executed. URLSession.shared by default.

* [errorHandler](#CNErrorHandler) <br/>
Responsible for handling errors received in CNProvider.

* [requestBuilder](#CNRequestBuilder) <br/>
The type of builder the provider will work with.

* [plugins](#CNPlugin) <br/>
Array with objects for request modification. Most often you will use it to customize request headers. Empty array by default.

* decoder <br/>
JSONDecoder with which the object will be decoded.

# CNProviderProtocol
Protocol for [CNProvider](#CNProvider).

```Ruby
public protocol CNProviderProtocol {
    associatedtype RequestBuilder: CNRequestBuilder
    associatedtype ErrorHandler: CNErrorHandler
    
    var baseURL: URL { get }
    var reachability: CNReachabilityManager { get }
    var session: URLSession { get }
    var errorHandler: ErrorHandler { get }
    var plugins: [CNPlugin] { get }
    var decoder: JSONDecoder { get }
    
    func generalPerform(
        _ builder: RequestBuilder
    ) -> AnyPublisher<Data, ErrorHandler.ErrorType>
    
    func perform<T: Decodable>(
        _ builder: RequestBuilder
    ) -> AnyPublisher<T, ErrorHandler.ErrorType>
    
    func perform<DecodableType: Decodable, Abstraction>(
        _ builder: RequestBuilder,
        decodableType: DecodableType.Type
    ) -> AnyPublisher<Abstraction, ErrorHandler.ErrorType>
    
    func perform(
        _ builder: RequestBuilder
    ) -> AnyPublisher<Never, ErrorHandler.ErrorType>
}
```

Protocol contains associatedtypes:
* RequestBuilder <br/>
Type of object subscribed to the **CNRequestBuilder** protocol. Responsible for describing and creating the URLRequest object. [Described here](#CNRequestBuilder).

* ErrorHandler <br/>
The object type subscribed to the **CNErrorHandler** protocol. Responsible for handling errors received in CNProvider. [Described here](#CNErrorHandler).


You will use the following methods to run the request to the server:
* ```generalPerform```<br/>
A method that starts a request task.

Returns the publisher with the Data, or your custom error, which type is defined in CNErrorHandler.

* ```perform<T: Decodable>```<br/>
A method that starts a request task and decodes the response into an object, relying on a generic parameter.

Returns the publisher with the decoded object, or your custom error, which type is defined in CNErrorHandler.

* ```perform<DecodableType: Decodable, Abstraction>```<br/>
A method that starts a request task and decodes the response into an object, relying on a decodableType parameter.

Returns the publisher with the generic abstraction object – protocol of the decoded object, or your custom error, which type is defined in CNErrorHandler.

* ```perform```<br/>
A method that starts a request task. Returns the publisher, which can be completed successfully or with your custom error, which type is defined in CNErrorHandler.


Developed By
------------

* Kvasnetskyi Artem, Savchenko Roman, Kosyi Vlad, CHI Software

License
--------

Copyright 2021 CHI Software.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
