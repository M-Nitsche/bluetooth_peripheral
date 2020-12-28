#import "BluetoothPeripheralPlugin.h"
#if __has_include(<bluetooth_peripheral/bluetooth_peripheral-Swift.h>)
#import <bluetooth_peripheral/bluetooth_peripheral-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "bluetooth_peripheral-Swift.h"
#endif

@implementation BluetoothPeripheralPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBluetoothPeripheralPlugin registerWithRegistrar:registrar];
}
@end
