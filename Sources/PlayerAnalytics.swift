import Foundation
import MobileCoreServices

@available(iOS 11.0, *)
public class PlayerAnalytics {
    
    private var options: Options
    private static let playbackDelay = 10 * 1000
    private var timer: Timer?
    private var eventsStack = [PingEvent]()
    private let loadedAt = Date().preciseLocalTime
    
    private(set) public var sessionId: String? = nil{
        didSet{
            self.options.onSessionIdReceived?(sessionId!)
        }
    }
    
    var currentTime: Float = 0
    
    
    public init(options: Options) {
        self.options = options
    }
    
    
    public func play(completion: @escaping (Result<Void, Error>) -> Void){
        schedule()
        addEventAt(Event.PLAY){(result) in
            completion(result)
        }
    }
    
    public func resume(completion: @escaping (Result<Void, Error>) -> Void){
        schedule()
        addEventAt(Event.RESUME){(result) in
            completion(result)
        }
    }
    
    public func ready(completion: @escaping (Result<Void, Error>) -> Void){
        addEventAt(Event.READY){ (result) in
            switch result{
            case .success(_):
                self.sendPing(payload: self.buildPingPayload()){ (res) in
                    completion(res)
                }
            case .failure(_):
                completion(result)
            }
            
        }
    }
    
    public func end(completion: @escaping (Result<Void, Error>) -> Void){
        unSchedule()
        addEventAt(Event.END){ (result) in
            switch result{
            case .success(_):
                self.sendPing(payload: self.buildPingPayload()){ (res) in
                    completion(res)
                }
            case .failure(_):
                completion(result)
            }
        }
    }
    
    public func pause(completion: @escaping (Result<Void, Error>) -> Void){
        unSchedule()
        addEventAt(Event.PAUSE){ (result) in
            switch result{
            case .success(_):
                self.sendPing(payload: self.buildPingPayload()){ (res) in
                    completion(res)
                }
            case .failure(_):
                completion(result)
            }
        }
    }
    
    public func seek(from:Float, to: Float, completion : @escaping (Result<Void, Error>) -> Void){
        if((from > 0) && (to > 0)){
            var event: Event
            if(from < to){
                event = .SEEK_FORWARD
            }else{
                event = .SEEK_BACKWARD
            }
            eventsStack.append(PingEvent(emittedAt: Date().preciseLocalTime, type: event, at: nil, from: from, to: to))
            completion(.success(()))
        }
    }
    
    public func destroy(completion: @escaping (Result<Void, Errors>) -> Void){
        unSchedule()
        completion(.success(()))
    }
    
    private func addEventAt(_ eventName: Event, completion: @escaping (Result<Void, Error>) -> Void){
        eventsStack.append(PingEvent(emittedAt: loadedAt, type: eventName, at: currentTime, from: nil, to: nil))
        completion(.success(()))
    }
    
    private func schedule(){
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { _ in
            self.timerAction()
        })
    }
    
    private func timerAction() {
        sendPing(payload: buildPingPayload()){ (result) in
            switch result {
              case .success(let data):
                print("schedule sended")
                print(data)
              case .failure(let error):
                print(error)
              }
            
        }
    }
    
    private func unSchedule(){
        timer?.invalidate()
    }
    
    private func buildPingPayload()-> PlaybackPingMessage{
        var session: Session
        switch options.videoInfo.videoType {
        case .LIVE:
            session = Session.buildLiveStreamSession(sessionId: sessionId, loadedAt: loadedAt, livestreamId: options.videoInfo.videoId, referrer: "", metadata: options.metadata)
        case .VOD:
            session = Session.buildVideoSession(sessionId: sessionId, loadedAt: loadedAt, videoId: options.videoInfo.videoId, referrer: "", metadata: options.metadata)
        }
        
        return PlaybackPingMessage(emittedAt: Date().preciseLocalTime, session: session, events: eventsStack)
    }

    private func sendPing(payload: PlaybackPingMessage, completion: @escaping (Result<Void, Error>) -> Void){
        var request = RequestsBuilder().postClientUrlRequestBuilder(apiPath: options.videoInfo.pingUrl)
        var body:[String : Any] = [:]
        let encoder = JSONEncoder()
        let task: TasksExecutorProtocol = TasksExecutor()
        encoder.outputFormatting = .prettyPrinted
        let jsonpayload = try! encoder.encode(payload)
        
        if let data = String(data: jsonpayload, encoding: .utf8)?.data(using: .utf8) {
            do {
                body = try (JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])!
                request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                print(error.localizedDescription)
            }
        }
        let session = RequestsBuilder().urlSessionBuilder()
        task.execute(session: session, request: request){ (data, error) in
            if(data != nil){
                let json = try? JSONSerialization.jsonObject(with: data!) as? Dictionary<String, AnyObject>
                if let mySession = json!["session"] as? String {
                    if(self.sessionId == nil){
                        self.sessionId = mySession
                    }
                }
                completion(.success(()))
            }else{
                completion(.failure(error!))
            }
        }
    }
}
extension String{
    public func toVideoType() throws -> VideoType{
        switch self.lowercased() {
        case "vod":
            return VideoType.VOD
        case "live":
            return VideoType.LIVE
        default:
            throw Errors.Error("Can't determine if video is vod or live.")
        }
    }
    public func match(_ regex: String) -> [[String]] {
        let nsString = self as NSString
        return (try? NSRegularExpression(pattern: regex, options: []))?.matches(in: self, options: [], range: NSMakeRange(0, nsString.length)).map { match in
            (0..<match.numberOfRanges).map { match.range(at: $0).location == NSNotFound ? "" : nsString.substring(with: match.range(at: $0)) }
        } ?? []
    }
}

@available(iOS 11.0, *)
extension Formatter {
    // create static date formatters for your date representations
    static let preciseLocalTime: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        
        return formatter
    }()
}

@available(iOS 11.0, *)
extension Date {
    var preciseLocalTime: String {
        return Formatter.preciseLocalTime.string(from: self)
    }
}
