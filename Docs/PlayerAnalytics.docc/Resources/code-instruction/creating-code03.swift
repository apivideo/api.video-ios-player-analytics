import ApiVideoPlayerAnalytics
import UIKit

class ViewController: UIViewController {
    var option: Options?

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            option = try Options(
                mediaUrl: "https://cdn.api.video/vod/vi5CVZtXoIIw4QeSl42CeuQk/hls/manifest.m3u8",
                metadata: [["string 1": "String 2"], ["string 3": "String 4"]],
                onSessionIdReceived: { id in
                    print("sessionid : \(id)")
                }
            )
        } catch {
            print("error with the url")
        }
    }
}
