#define CHECK_TARGET
#import <PSHeader/PS.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <WebKit/WKPreferences.h>
#import <WebKit/WKWebView.h>
#import <WebKit/WKWebViewConfiguration.h>
#import <WebKit/WKUserContentController.h>
#import <WebKit/WKUserScript.h>
#import <version.h>

static void injectScript(WKWebView *webview, NSString *identifier, NSString *script) {
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:script injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    [webview.configuration.userContentController addUserScript:userScript];
}

static const void *SteamInjectedKey = &SteamInjectedKey;

static void inject(WKWebView *webview) {
    if (![webview.URL.host containsString:@"store.steampowered.com"]) return;
    WKUserContentController *controller = webview.configuration.userContentController;
    if (!controller) {
        controller = [[WKUserContentController alloc] init];
        webview.configuration.userContentController = controller;
    } else if (objc_getAssociatedObject(controller, SteamInjectedKey)) return;
    objc_setAssociatedObject(controller, SteamInjectedKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSString *assetsFolder = PS_ROOT_PATH_NS(@"/Library/Application Support/SteamWebLegacyCompat");
    NSArray *assets = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:assetsFolder error:nil];
    NSPredicate *jsPredicate = [NSPredicate predicateWithFormat:@"self ENDSWITH '.js'"];
    NSArray *jsFiles = [assets filteredArrayUsingPredicate:jsPredicate];
    for (NSString *jsFile in jsFiles) {
        NSString *filePath = [assetsFolder stringByAppendingPathComponent:jsFile];
        NSString *fileName = [jsFile stringByDeletingPathExtension];
        if ([fileName isEqualToString:@"libraries.min"] && IS_IOS_OR_NEWER(iOS_15_0)) return;
        NSString *scriptContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        injectScript(webview, fileName, scriptContent);
    }
}

%hook WKWebView

- (void)_didCommitLoadForMainFrame {
    %orig;
    inject(self);
}

%end

%ctor {
    if (!isTarget(TargetTypeApps)) return;
    %init;
}
