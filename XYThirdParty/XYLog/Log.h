//
//  Log.h
//  shell
//
//  Created by xieyan on 2017/3/15.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#ifndef Log_h
#define Log_h
@import CocoaLumberjack;
static NSUInteger ddLogLevel = DDLogLevelAll;
#define DLogVerbose(_parma_,...) DDLogVerbose(@"File %@ Func %s Line %d %@",[[[NSString stringWithFormat:@"%s",__FILE__] componentsSeparatedByString:@"/"] lastObject],__PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:_parma_,##__VA_ARGS__]);

#define DLogDebug(_parma_,...) DDLogDebug(@"File %@ Func %s Line %d %@",[[[NSString stringWithFormat:@"%s",__FILE__] componentsSeparatedByString:@"/"] lastObject],__PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:_parma_,##__VA_ARGS__]);

#define DLogInfo(_parma_,...) DDLogInfo(@"File %@ Func %s Line %d %@",[[[NSString stringWithFormat:@"%s",__FILE__] componentsSeparatedByString:@"/"] lastObject],__PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:_parma_,##__VA_ARGS__]);

#define DLogWarn(_parma_,...) DDLogWarn(@"File %@ Func %s Line %d %@",[[[NSString stringWithFormat:@"%s",__FILE__] componentsSeparatedByString:@"/"] lastObject],__PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:_parma_,##__VA_ARGS__]);

#define DLogError(_parma_,...) DDLogError(@"File %@ Func %s Line %d %@",[[[NSString stringWithFormat:@"%s",__FILE__] componentsSeparatedByString:@"/"] lastObject],__PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:_parma_,##__VA_ARGS__]);
#endif /* Log_h */
