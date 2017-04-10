//
//  CallDirectoryHandler.m
//  PhoneCallKit
//
//  Created by 张晓龙 on 2017/4/5.
//  Copyright © 2017年 张晓龙. All rights reserved.
//

#import "CallDirectoryHandler.h"

@interface CallDirectoryHandler () <CXCallDirectoryExtensionContextDelegate>
@end

@implementation CallDirectoryHandler

- (void)beginRequestWithExtensionContext:(CXCallDirectoryExtensionContext *)context {
    context.delegate = self;

    if (![self addBlockingPhoneNumbersToContext:context]) {
        NSLog(@"Unable to add blocking phone numbers");
        NSError *error = [NSError errorWithDomain:@"CallDirectoryHandler" code:1 userInfo:nil];
        [context cancelRequestWithError:error];
        return;
    }
    
    if (![self addIdentificationPhoneNumbersToContext:context]) {
        NSLog(@"Unable to add identification phone numbers");
        NSError *error = [NSError errorWithDomain:@"CallDirectoryHandler" code:2 userInfo:nil];
        [context cancelRequestWithError:error];
        return;
    }
    
    [context completeRequestWithCompletionHandler:nil];
}

- (BOOL)addBlockingPhoneNumbersToContext:(CXCallDirectoryExtensionContext *)context {
    
    
    CXCallDirectoryPhoneNumber phoneNumbers[] = { 14085555555, 18005555555 };
    NSUInteger count = (sizeof(phoneNumbers) / sizeof(CXCallDirectoryPhoneNumber));

    for (NSUInteger index = 0; index < count; index += 1) {
        CXCallDirectoryPhoneNumber phoneNumber = phoneNumbers[index];
        [context addBlockingEntryWithNextSequentialPhoneNumber:phoneNumber];
    }

    return YES;
}

- (BOOL)addIdentificationPhoneNumbersToContext:(CXCallDirectoryExtensionContext *)context {
    
    //file读取
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.ckphone.app"];
    containerURL = [containerURL URLByAppendingPathComponent:@"Library/Caches/callKitData"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfURL:containerURL];
    NSString *name = [dict objectForKey:@"name"];
    NSString *phone = [dict objectForKey:@"phone"];
    CXCallDirectoryPhoneNumber phoneNum = [phone longLongValue];
    [context addIdentificationEntryWithNextSequentialPhoneNumber:phoneNum label:name];


    return YES;
}

#pragma mark - CXCallDirectoryExtensionContextDelegate

- (void)requestFailedForExtensionContext:(CXCallDirectoryExtensionContext *)extensionContext withError:(NSError *)error {
    // An error occurred while adding blocking or identification entries, check the NSError for details.
    // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
    //
    // This may be used to store the error details in a location accessible by the extension's containing app, so that the
    // app may be notified about errors which occured while loading data even if the request to load data was initiated by
    // the user in Settings instead of via the app itself.
}

@end
