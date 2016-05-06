//
//  SystemVersionVerificationHelper.h
//  GeoFenceDemo01
//
//  Created by Sebastián Badea on 6/5/16.
//  Copyright © 2016 Sebastian Badea. All rights reserved.
//

/*
 *  System Versioning Preprocessor Macros
 */

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

/*
 *  Usage
 */

//if (SYSTEM_VERSION_LESS_THAN(@"4.0")) {
//    ...
//}
//
//if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"3.1.1")) {
//    ...
//}