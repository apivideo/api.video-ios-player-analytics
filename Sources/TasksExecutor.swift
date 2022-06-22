import Foundation

public class TasksExecutor: TasksExecutorProtocol {
  private let decoder = JSONDecoder()
  public static func execute(
    session: URLSession, request: URLRequest, completion: @escaping (Data?, Error?) -> Void
  ) {

    let task = session.dataTask(with: request) { (data, response, error) in
        if(data?.count == 0){
            completion(data, UrlError.jsonError("error 400"))
        }else{
            completion(data, error)
        }
    }
    task.resume()
  }
}
