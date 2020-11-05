#import "CartesianGraphPlugin.h"
#if __has_include(<cartesian_graph/cartesian_graph-Swift.h>)
#import <cartesian_graph/cartesian_graph-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "cartesian_graph-Swift.h"
#endif

@implementation CartesianGraphPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCartesianGraphPlugin registerWithRegistrar:registrar];
}
@end
