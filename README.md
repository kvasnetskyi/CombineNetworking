# Combine Networking
**Combine Networking** is a convenient and flexible networking layer based on Apple's native Combine and URLSession technologies.

It does not use any third-party dependencies, so there is nothing superfluous in it.

# Components
1. [CNPlugin](#CNPlugin)
2. [CNReachabilityManager](#CNReachabilityManager)
3. [CNErrorHandler](#CNErrorHandler)
4. [CNRequestBuilder](#CNRequestBuilder)
5. [CNProvider](#CNProvider)

# CNPlugin
```Ruby
public protocol CNPlugin {
    func modifyRequest(_ request: inout URLRequest)
}
```

An object protocol that can modify a URLRequest. Most often you will use it to add certain headers.

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
### You can use the default implementation - CNReachabilityManagerImpl

```Ruby
public protocol CNReachabilityManager: AnyObject {
    var isInternetConnectionAvailable: Bool { get }
}
```

Protocol object that monitors the internet connection before running the request.

You can write your own manager that will subscribe to this protocol, or use the default implementation - **CNReachabilityManagerImpl**.

# CNErrorHandler
### You can use the default implementation - CNErrorHandlerImpl

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

Manager for handling errors resulting from Combine Networking.

You can use the standard implementation of CNErrorHandler - **CNErrorHandlerImpl**. But if you need to handle errors specifically, you will use your own.

It contains:
1. **ErrorType** *associatedtype*
The error type that your Combine Networking will work with. You can use your own error type, but it must be signed to CNErrorProtocol, which contains the main errors.

2. **outputHandling** *method*
A method for processing the response from the server. Gets a server response that you can process the way you want, and a retryMethod block that can be used to retry the request after it has been processed. 

3. **convert** *method*
It often happens that a request to the network fails. For example, while launching the request, the Internet on the device has disappeared. 

This method takes such errors as NSError, and serves to convert it into your custom error.
