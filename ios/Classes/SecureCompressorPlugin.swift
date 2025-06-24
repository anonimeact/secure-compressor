import Flutter
import UIKit

public class SecureCompressorPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "secure_compressor", binaryMessenger: registrar.messenger())
    let instance = SecureCompressorPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getUnixId":
      let uuid = UIDevice.current.identifierForVendor?.uuidString
      result(uuid)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
