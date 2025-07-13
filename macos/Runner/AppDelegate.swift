import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var methodChannel: FlutterMethodChannel?
  
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
  
  override func applicationDidFinishLaunching(_ notification: Notification) {
    print("AppDelegate: applicationDidFinishLaunching called")
    super.applicationDidFinishLaunching(notification)
    
    // Set up method channel for Flutter communication
    let controller = mainFlutterWindow?.contentViewController as! FlutterViewController
    methodChannel = FlutterMethodChannel(name: "custom_slide_show/file_picker", binaryMessenger: controller.engine.binaryMessenger)
    
    methodChannel?.setMethodCallHandler { [weak self] (call, result) in
      print("AppDelegate: Method channel called with method: \(call.method)")
      if call.method == "pickFolder" {
        self?.pickFolder(result: result)
      } else if call.method == "folderDropped" {
        // This will be handled by the drag and drop events
        result(FlutterMethodNotImplemented)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    

  }
  

  
  private func pickFolder(result: @escaping FlutterResult) {
    print("pickFolder method called from Flutter")
    let panel = NSOpenPanel()
    panel.canChooseFiles = false
    panel.canChooseDirectories = true
    panel.allowsMultipleSelection = false
    panel.message = "Select a folder containing images for your slide show"
    panel.prompt = "Open"
    
    print("Opening folder selection panel...")
    panel.begin { [weak self] panelResult in
      print("Panel result: \(panelResult.rawValue)")
      if panelResult == .OK {
        if let url = panel.url {
          print("Selected folder: \(url.path)")
          result(url.path)
          self?.processSelectedFolder(url: url)
        } else {
          print("No URL selected")
          result(FlutterError(code: "NO_URL", message: "No folder selected", details: nil))
        }
      } else {
        print("User cancelled folder selection")
        result(FlutterError(code: "CANCELLED", message: "User cancelled folder selection", details: nil))
      }
    }
  }
  
  @objc func openFolder(_ sender: Any) {
    print("openFolder method called from menu")
    pickFolder { result in
      print("Menu folder picker result: \(String(describing: result))")
    }
  }
  
  @objc func startSlideshow(_ sender: Any) {
    print("startSlideshow method called from menu")
    // This will be handled by Flutter app
  }
  
  private func processSelectedFolder(url: URL) {
    let fileManager = FileManager.default
    let slideshowPath = url.appendingPathComponent("slideshow.json")
    
    // Check if slideshow.json already exists
    if fileManager.fileExists(atPath: slideshowPath.path) {
      print("slideshow.json already exists at: \(slideshowPath.path)")
      return
    }
    
    // Get all image files in the folder
    let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "webp"]
    var imageFiles: [String] = []
    
    do {
      let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
      for fileURL in contents {
        let fileExtension = fileURL.pathExtension.lowercased()
        if imageExtensions.contains(fileExtension) {
          imageFiles.append(fileURL.lastPathComponent)
        }
      }
    } catch {
      print("Error reading directory: \(error)")
      return
    }
    
    // Sort files by name (ascending order as in Finder)
    imageFiles.sort()
    
    // Create JSON structure
    var slideshowData: [[String: String]] = []
    for imageFile in imageFiles {
      slideshowData.append(["image": imageFile])
    }
    
    // Convert to JSON with pretty formatting
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: slideshowData, options: [.prettyPrinted, .sortedKeys])
      try jsonData.write(to: slideshowPath)
      print("Created slideshow.json at: \(slideshowPath.path)")
      print("JSON content:")
      if let jsonString = String(data: jsonData, encoding: .utf8) {
        print(jsonString)
      }
    } catch {
      print("Error creating slideshow.json: \(error)")
    }
  }
}
