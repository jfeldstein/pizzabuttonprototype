//
//  AppDelegate.m
//  The Pizza Button
//
//  Created by Michael Feldstein on 11/24/13.
//  Copyright (c) 2013 Michael Feldstein. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (BOOL)fileExists: (NSString*) theFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:theFile];
    // MRC: make sure to release
}

- (void)copyFile:(NSString*) sourceFile to:(NSString*) targetPath withName:(NSString*) targetFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:targetPath withIntermediateDirectories:YES attributes:nil error:NULL];
    NSString *fullTargetFile = [targetPath stringByAppendingPathComponent:targetFile];
    
    NSLog(@"Source File for Copy: %@", sourceFile);
    NSLog(@"Target File for Copy: %@", fullTargetFile);
    
    if ( [self fileExists:fullTargetFile] )
    {
        // remove the file first. (Ick! I wish there was a better way...
        if ( [fileManager removeItemAtPath:fullTargetFile error:nil] == YES )
        {
            NSLog (@"Target successfully removed.");
        }
        else
        {
            NSLog (@"Target could not be removed prior to copy. No copy will occur.");
            return;
        }
    }
    
    if ( [fileManager copyItemAtPath:sourceFile toPath:fullTargetFile error:nil] == YES)
    {
        NSLog(@"Copy successful.");
    }
    else
    {
        NSLog(@"Copy unsuccessful.");
    }
    // MRC: don't forget to release fileManager where necessary!
}


- (BOOL)isIOS5_1OrHigher
{
    // based on: http://stackoverflow.com/a/9320041
    NSArray *versionCompatibility = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    
    if ( [[versionCompatibility objectAtIndex:0] intValue] > 5 )
    {
        return YES; // iOS 6+
    }
    
    if ( [[versionCompatibility objectAtIndex:0] intValue] < 5 )
    {
        return NO;  // iOS 4.x or lower
    }
    
    if ( [[versionCompatibility objectAtIndex:1] intValue] >= 1 )
    {
        return YES; // ios 5.<<1>> or higher
    }
    
    return NO;  // ios 5.<<0.x>> or lower
    
}

- (void)copyPersistentStorageToLocalStorage
{
    // build localStorage path: ~/Library/WebKit/LocalStorage/file__0.localstorage (for iOS < 5.1)
    //                          ~/Library/Caches/file__0.localstorage (for iOS >= 5.1 )
    NSString *localStoragePath;
    if ( [self isIOS5_1OrHigher] )
    {
        // for IOS >= 5.1
        localStoragePath =
        [
         [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]
         stringByAppendingPathComponent:@"Caches"
         ];
    }
    else
    {
        // for IOS < 5.1;
        localStoragePath =
        [
         [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]
         stringByAppendingPathComponent:@"WebKit/LocalStorage"
         ];
    }
    
    // build persistentStorage path: ~/Documents/appdata.db
    NSString *persistentStoragePath =
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *persistentStorageFile = [persistentStoragePath stringByAppendingPathComponent:@"appdata.db"];
    
    // does the persistent store exist?
    if ([self fileExists:persistentStorageFile ])
    {
        // it does, copy it over localStorage
        NSLog(@"Copying persistent storage to local storage.");
        [self copyFile:persistentStorageFile to:localStoragePath withName: @"file__0.localstorage"];
    }
    else
    {
        NSLog(@"No persistent storage to copy. Using local storage only.");
    }
}

- (void)copyLocalStorageToPersistentStorage
{
    // build localStorage path: ~/Library/WebKit/LocalStorage/file__0.localstorage (for iOS < 5.1)
    //                          ~/Library/Caches/file__0.localstorage (for iOS >= 5.1 )
    NSString *localStoragePath;
    if ( [self isIOS5_1OrHigher] )
    {
        // for IOS >= 5.1
        localStoragePath =
        [
         [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]
         stringByAppendingPathComponent:@"Caches"
         ];
    }
    else
    {
        // for IOS < 5.1;
        localStoragePath =
        [
         [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]
         stringByAppendingPathComponent:@"WebKit/LocalStorage"
         ];
    }
    
    NSString *localStorageFile = [localStoragePath stringByAppendingPathComponent:@"file__0.localstorage"];
    
    // build persistentStorage path: ~/Documents/appdata.db
    NSString *persistentStoragePath =
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    // does the local store exist? (it almost always will)
    if ([self fileExists:localStorageFile ])
    {
        // it does, copy it over persistent Storage
        NSLog(@"Copying local storage to persistent storage.");
        [self copyFile:localStorageFile to:persistentStoragePath withName:@"appdata.db"];
    }
    else
    {
        NSLog(@"No local storage to copy. Using local storage only.");
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // move the local storage data to persistent storage
    // while we're resigning so that we know our data is safe...
    [self copyLocalStorageToPersistentStorage];
    return;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // move the local storage data to persistent storage
    // while we're terminating so that we know our data is safe...
    [self copyLocalStorageToPersistentStorage];
    return;
}

@end
