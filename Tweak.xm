#import <UIKit/UIDevice.h>
#include <objc/runtime.h>
#include <dlfcn.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

static bool enabled = NO;

static void loadPrefs() {

	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.mtac.battprefs.plist"]];

	if (prefs) {

		enabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : enabled;

	}

}

%ctor {

  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
  NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.mtac.battprefs/settingschanged"), 
  NULL, CFNotificationSuspensionBehaviorCoalesce);
  loadPrefs();

}

@interface SBUIActionViewLabel : UIView

@property (nonatomic,copy) NSString * text;

@end

%hook SBUIActionViewLabel

- (void)layoutSubviews {

	UIDevice *device = [UIDevice currentDevice];

	[device setBatteryMonitoringEnabled:YES];

	double percentage = (float)[device batteryLevel] * 100;

	NSLog(@"%.f", percentage);

	NSString *level = [NSString stringWithFormat:@"%.f", percentage];

	NSString *textValue = MSHookIvar<NSString *>(self, "_text");

	NSString *battery = [@"Battery: " stringByAppendingString:level];

	NSString *final = [battery stringByAppendingString:@"%"];

	NSString *address = @"N/A";

	struct ifaddrs *interfaces = NULL;

	struct ifaddrs *temp_addr = NULL;

	int success = 0;

		success = getifaddrs(&interfaces);

		if (success == 0) {

			temp_addr = interfaces;

			while (temp_addr != NULL) {

				if (temp_addr->ifa_addr->sa_family == AF_INET) {
							// Check if interface is en0 which is the wifi connection on the iPhone
					if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
									// Get NSString from C String
						address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];

					}

				}

					temp_addr = temp_addr->ifa_next;

				}
			}

			freeifaddrs(interfaces);

	NSString *finalWifi = [@"Wi-Fi: " stringByAppendingString:address];

	if (enabled == YES) {

		if ([textValue isEqual:@"Battery"]) {

			[self setText:final];

		} else if ([textValue isEqual:@"Wi-Fi"]) {

			[self setText:finalWifi];

		} else if ([textValue isEqual:@"Cellular Data"]){

			// [self setText:[@"Cellular Data" stringByAppendingString:dataValue]];

		} else {

			%orig;

		}

	}

}

%end