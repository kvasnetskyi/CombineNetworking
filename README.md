# Combine Networking
**Combine Networking** is a convenient and flexible networking layer based on Apple's native Combine and URLSession technologies.

It does not use any third-party dependencies, so there is nothing superfluous in it.

1. [Components](#Components)
2. [Example of usage](#Example-of-usage)
3. [Multipart request](#Multipart-request)
4. [Installation](#Installation)

# Components
1. [CNPlugin](#CNPlugin)
2. [CNReachabilityManager](#CNReachabilityManager)
3. [CNErrorHandler](#CNErrorHandler)
4. [CNRequestBuilder](#CNRequestBuilder)
5. [CNProvider](#CNProvider)
6. [CNProviderProtocol](#CNProviderProtocol)

# CNPlugin
```swift
public protocol CNPlugin {
    func modifyRequest(_ request: inout URLRequest)
}
```

An object protocol that can modify a URLRequest. Most often you will use it to add certain headers:

```swift
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

```swift
public protocol CNReachabilityManager: AnyObject {
    var isInternetConnectionAvailable: Bool { get }
}
```

Protocol object that monitors the internet connection before running the request.

You can write your own manager that will subscribe to this protocol, or use the default implementation - **CNReachabilityManagerImpl**.

# CNErrorHandler
###### You can use the default implementation - CNErrorHandlerImpl

```swift
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

```swift
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
A base URL that can be added to your request. Serves as an exception to the rule. In most cases the base URL will be taken from the [CNProvider](#CNProvider). Specify this variable only when the base URL of a particular request differs from the base URL injected by Networking Provider. You can ignore this variable when creating an object. By default it returns nil.

* headerFields <br/>
Header fields that can be added to the request. Used only if you want to specify additional header fields in addition to those specified in the [CNPlugin](#CNPlugin) array. You can ignore this variable when creating an object. By default it returns nil.

* multipartBody <br/>
Variable that can return CNMultipartFormDataModel. Used to create multipart form requests. If the variable does not return nil, the body created by the CNMultipartFormDataModel will be added to the request. Do not use this and body variable at the same time. You can ignore this variable when creating an object. By default it returns nil.

# CNProvider
A class that serves as a provider to run requests to the server.

CNProvider is an implementation of the [CNProviderProtocol](#CNProviderProtocol). In this section you will learn about the accepted CNProvider parameters. You can learn more about its methods and generic types in [CNProviderProtocol](#CNProviderProtocol).

CNProvider has several initializers. One of them uses the standard implementation of the [CNErrorHandler](#CNErrorHandler) protocol - CNErrorHandlerImpl.

```swift
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

```swift
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
Type of object subscribed to the [CNRequestBuilder](#CNRequestBuilder) protocol. Responsible for describing and creating the URLRequest object.

* ErrorHandler <br/>
The object type subscribed to the [CNErrorHandler](#CNErrorHandler) protocol. Responsible for handling errors received in CNProvider.


You will use the following methods to run the request to the server:
* ```generalPerform(_:)```<br/>
A method that starts a request task. Returns the publisher with the Data, or your custom error, which type is defined in CNErrorHandler.

* ```perform<T: Decodable>(_:)```<br/>
A method that starts a request task and decodes the response into an object, relying on a generic parameter. Returns the publisher with the decoded object, or your custom error, which type is defined in CNErrorHandler.

* ```perform<DecodableType: Decodable, Abstraction>(_:, decodableType:)```<br/>
A method that starts a request task and decodes the response into an object, relying on a decodableType parameter. Returns the publisher with the generic abstraction object – protocol of the decoded object, or your custom error, which type is defined in CNErrorHandler.

* ```perform(_:)```<br/>
A method that starts a request task. Returns the publisher, which can be completed successfully or with your custom error, which type is defined in CNErrorHandler.

# Example of usage
Follow these steps to set up your networking layer. Steps marked as optional can be skipped.

1. [Creating CNPlugin implementations](#Creating-CNPlugin-implementations)
2. [Creating a CNErrorProtocol implementation](#Creating-a-CNErrorProtocol-implementation) – optional
3. [Creating a CNErrorHandler implementation](#Creating-a-CNErrorHandler-implementation) – optional
4. [Creating a CNReachabilityManager implementation](#Creating-a-CNReachabilityManager-implementation) – optional
5. [Creating CNRequestBuilder implementations](#Creating-CNRequestBuilder-implementations)
6. [Creating CNProvider implementations](#Creating-CNProvider-implementations)
7. [Creating and using a network client](#Creating-and-using-a-network-client)

# Creating CNPlugin implementations
Create a [CNPlugin](#CNPlugin) object for every possible header that can be added to the request.

```swift
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

# Creating a CNErrorProtocol implementation
###### Optional

Create your own CNErrorProtocol implementation **if the CNError implementation does not suit you**. All kinds of errors that your networking can return will be described here.

*You can skip this step and use the standard implementation of CNErrorProtocol - CNError.*

```swift
enum CustomErrorTypeName: CNErrorProtocol {
    case badURLError
    case clientError
    case serverError
    
    // Mandatory errors according to CNErrorProtocol.
    case reachabilityError
    case decodingError
    case unspecifiedError
    // -----
    
    var localizedDescription: String {
        switch self {
        case .badURLError:
            return "Bad URL Error. Please try again later."
        case .clientError:
            return "An error occurred on the client side. Please try again later."
        case .serverError:
            return "An error occurred on the server side. Please try again later."
        case .reachabilityError:
            return "Internet connection problem. Please check your internet connection."
        case .decodingError:
            return "We were unable to identify the data that came from the server. Please try again later."
        case .unspecifiedError:
            return "For unknown reasons, something went wrong. Please try again later."
        }
    }
}
```

# Creating a CNErrorHandler implementation
###### Optional

Create your own implementation of the [CNErrorHandler](#CNErrorHandler) protocol **if the default CNErrorHandlerImpl implementation is not suitable for you**. This object will handle the response from the server, and return the type of error you specified (step #2).

*You can skip this step and use the standard implementation of CNErrorHandler - CNErrorHandlerImpl.*

```swift
struct CustomErrorHandlerTypeName: CNErrorHandler {
    public func outputHandling(
        _ output: NetworingOutput,
        _ retryMethod: @autoclosure () -> AnyPublisher<Data, CustomErrorTypeName>
    ) -> AnyPublisher<Data, CustomErrorTypeName> {
            
        guard let httpResponse = output.response as? HTTPURLResponse else {
            return Fail(error: CustomErrorTypeName.unspecifiedError)
                .eraseToAnyPublisher()
        }
        
        switch httpResponse.statusCode {
        case 200...399:
            return Just(output.data)
                .setFailureType(to: CustomErrorTypeName.self)
                .eraseToAnyPublisher()
            
        case 400...499:
            return Fail(error: CustomErrorTypeName.clientError)
                .eraseToAnyPublisher()
            
        case 500...599:
            return Fail(error: CustomErrorTypeName.serverError)
                .eraseToAnyPublisher()
            
        default:
            return Fail(error: CustomErrorTypeName.unspecifiedError)
                .eraseToAnyPublisher()
        }
    }
    
    public func convert(error: NSError) -> CustomErrorTypeName {
        switch error.code {
        case NSURLErrorBadURL:
            return .badURLError
            
        case NSURLErrorNotConnectedToInternet, NSURLErrorCallIsActive,
            NSURLErrorNetworkConnectionLost, NSURLErrorDataNotAllowed:
            return .reachabilityError
            
        default: return .unspecifiedError
        }
    }
}
```

# Creating a CNReachabilityManager implementation
###### Optional

Create your own implementation of the [CNReachabilityManager](#CNReachabilityManager) protocol **if the default CNReachabilityManagerImpl implementation is not suitable for you**. This object monitors the ability to connect to the network before launching a request to the server.

*You can skip this step and use the standard implementation of CNReachabilityManager - CNReachabilityManagerImpl.*

```swift
class ReachabilityManager: CNReachabilityManager {
    private static let queueLabel = "MyCustomeQueue"
    
    public var isInternetConnectionAvailable: Bool = {
        return false
    }()
    
    private var connectionMonitor = NWPathMonitor()
    
    public init() {
        let queue = DispatchQueue(
            label: ReachabilityManager.queueLabel
        )
        
        self.connectionMonitor.pathUpdateHandler = { pathUpdateHandler in
            self.isInternetConnectionAvailable = pathUpdateHandler.status == .satisfied
        }
        
        self.connectionMonitor.start(queue: queue)
    }
}
```

# Creating CNRequestBuilder implementations
Create an implementation of the [CNRequestBuilder](#CNRequestBuilder) as an enum. Try to logically separate the [CNRequestBuilder](#CNRequestBuilder) implementation.

```swift
enum DogRequestBuilder: CNRequestBuilder {
    case searchBy(name: String)
    
    // DogRequestModel – some encodable model
    case create(dog: DogRequestModel)
    
    var path: String {
        switch self {
        case .searchBy:
            return "/dog/search"
        case .create:
            return "/dog/create"
        }
    }
    
    var query: QueryItems? {
        switch self {
        case .searchBy(let name):
            return ["dog_name": name]
            
        case .create:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .searchBy(_):
            return nil
            
        case .create(let model):
            return try? JSONEncoder().encode(model)
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .searchBy(_):
            return .get
            
        case .create(let model):
            return .post
        }
    }
}

enum HumanRequestBuilder: CNRequestBuilder {
    case search(name: String)
    
    var path: String {
        switch self {
        case .search: return "/human/search"
        }
    }
    
    var query: QueryItems? {
        switch self {
        case .search(let name):
            return ["human_name": name]
        }
    }
    
    var body: Data? { return nil }
    var method: HTTPMethod { return .get }
}
```

# Creating CNProvider implementations
The [CNProvider](#CNProvider) implementation takes all the elements you created earlier. It is responsible for launching a request to the network.

```swift
    ...
    let baseURL = URL(string: "https://api.example.com/v1")!
    let authPlugin = AuthPlugin(token: "my_token")
    
    let reachabilityManager = ReachabilityManager()
    let errorHandler = CustomErrorHandlerTypeName()
    
    let provider = CNProvider(
        baseURL: baseURL,
        reachability: reachabilityManager,
        session: URLSession.shared,
        errorHandler: errorHandler,
        requestBuilder: DogRequestBuilder.self,
        plugins: [authPlugin],
        decoder: JSONDecoder()
    )
    
    let myClientForWork = DogClient(provider)
    ...
```

# Creating and using a network client
With the [CNProvider](#CNProvider) configured, you can easily create a client to work with the server. If protocols are important to you, you can use [CNProviderProtocol](#CNProviderProtocol).

```swift
// Creating a class using CNProviderProtocol
class DogClient<Provider: CNProviderProtocol> where Provider.RequestBuilder == DogRequestBuilder, Provider.ErrorHandler == CustomErrorHandlerTypeName {

    private let provider: Provider
    
    init(provider: Provider) {
        self.provider = provider
    }
}

extension DogClient: DogClientProtocol {
    // Response – decodable model or error
    func search(name: String) -> AnyPublisher<DogDecodableModel, CustomErrorTypeName> {
        provider.perform(
            .search(name: name)
        )
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    // Response – decodable model as abstraction or error
    func search(name: String) -> AnyPublisher<DogModelProtocol, CustomErrorTypeName> {
        provider.perform(
            .search(name: name),
            decodableType: DogDecodableModel.self
        )
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    // Response – success or error completion
    func create(dog: DogRequestModel) -> AnyPublisher<Never, CustomErrorTypeName> {
        provider.perform(
            .create(dog: dog)
        )
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

// Creating a class without using CNProviderProtocol
class HumanClient {
    private let provider: CNProvider<HumanRequestBuilder, CNErrorHandlerImpl>
    
    init(with provider: CNProvider<HumanRequestBuilder, CNErrorHandlerImpl>) {
        self.provider = provider
    }
}
```

# Multipart request
With [CNRequestBuilder](#CNRequestBuilder) you can describe multipart data. To do this, create a multipartBody variable inside your [CNRequestBuilder](#CNRequestBuilder).

It is a CNMultipartFormDataModel structure that is initialized with the CNMultipartFormItem array. CNMultipartFormItem is a description of one part of your data.

multipartBody replaces the data variable in [CNRequestBuilder](#CNRequestBuilder), so do not use them simultaneously.

```swift
enum HumanRequestBuilder: CNRequestBuilder {
    case setHuman(image: Data)
    
    var path: String {
        switch self {
        case .setHuman: return "/human/image"
        }
    }
    
    var query: QueryItems? {
        switch self {
        case .setHuman(_):
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .setHuman(_):
            return nil
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .setHuman(_):
            return .post
        }
    }
    
    // MARK: - Multipart Request
    var multipartBody: CNMultipartFormDataModel? {
        switch self {
        case .setHuman(let image):
            let multipartItem = CNMultipartFormItem(
                name: "human_image_request_key",
                fileName: "my_image",
                mimeType: "image/jpg", // Optional
                data: image
            )
            
            return CNMultipartFormDataModel(items: [multipartItem])
        }
    }
}
```

# Installation
Combine Networking available through [Swift Package Manager](https://swift.org/package-manager/).

in `Package.swift` add the following:

```swift
dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(url: "https://github.com/kvasnetskyi/CombineNetworking.git", from: "1.0.1")
],
targets: [
    .target(
        name: "MyProject",
        dependencies: [..., "CombineNetworking"]
    )
    ...
]
```

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
