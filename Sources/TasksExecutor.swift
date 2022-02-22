
import Foundation
public class TasksExecutor: TasksExecutorProtocol{
    private let decoder = JSONDecoder()
    public func execute(session: URLSession, request: URLRequest, group: DispatchGroup?, completion: @escaping (Data?, Error?) -> ()){
        var task: URLSessionTask?
        task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            let httpResponse = response as? HTTPURLResponse
            let statuscode = httpResponse?.statusCode
            task?.cancel()
            completion(data, error)
            if(group != nil){
                group!.leave()
            }
        })
        task!.resume()
    }
    public func execute(session: URLSession, request: URLRequest, completion: @escaping (Data?, Error?) -> ()){
        execute(session: session, request: request, group: nil){(data, error) in
            completion(data, error)
        }
    }
}
