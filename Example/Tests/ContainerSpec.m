//
//  ContainerSpec.m
//  XXShield_Tests
//
//  Created by nero on 2017/11/1.
//  Copyright © 2017年 ValiantCat. All rights reserved.
//

QuickSpecBegin(ContainerSpec)

//describe(@"Container test222", ^{
//    context(@"NSCache test111", ^{
//        // 往NSCache中出入空值不会crash
//        it(@"2222222222222", ^{
//            NSString *aa = @"11";
//            expect(aa, @"11");
//        });
//    });
//});

describe(@"Container test", ^{
    context(@"NSCache test", ^{
        // 往NSCache中出入空值不会crash
        it(@"should avoid crash by insert nil value  to NSCache", ^{
            NSCache *cache = [[NSCache alloc] init];
            id stub = nil;
            [cache setObject:@"val" forKey:@"key"]; //
            [cache setObject:stub forKey:@"key"];
            
            expect([cache objectForKey:@"key"]).to(equal(@"val"));
            
            // 通常情况下，这个消耗值是对象的字节大小。如果这些信息不是现成的，则我们不应该去计算它，
            // 因为这样会使增加使用缓存的成本。如果我们没有可用的值传递，则直接传递0，
            // 或者是使用-setObject:forKey:方法，这个方法不需要传入一个消耗值。[http://southpeak.github.io/2015/02/11/cocoa-foundation-nscache/]
            [cache setObject:@"value" forKey:@"anotherKey" cost:10];
            [cache setObject:stub forKey:@"anotherKey" cost:10];
            expect([cache objectForKey:@"anotherKey"]).to(equal(@"value"));
        });
    });
    
    context(@"NSArray(Private SubClass) test", ^{
        it(@"should avoid crash by using subscribe method objectAtIndex while index out of bounds.", ^{
            NSArray *arr = @[];
            NSString *clazzName = [[NSString alloc] initWithUTF8String:object_getClassName(arr)];
            expect(clazzName).to(equal(@"__NSArray0"));
            expect(arr[10]).to(beNil());
            
            arr = @[@1];
            clazzName = [[NSString alloc] initWithUTF8String:object_getClassName(arr)];
            expect(clazzName).to(equal(@"__NSSingleObjectArrayI"));
            expect(arr[10]).to(beNil());
            
            arr = @[@1, @2];
            clazzName = [[NSString alloc] initWithUTF8String:object_getClassName(arr)];
            expect(clazzName).to(equal(@"__NSArrayI"));
            expect(arr[10]).to(beNil());
            
            arr = @[@"11", @"22"];
            clazzName = [[NSString alloc] initWithUTF8String:object_getClassName(arr)];
            NSLog(@"clazzName = %@", clazzName);
            expect(clazzName).to(equal(@"__NSArrayI"));
            expect(arr[10]).to(beNil());
        });
        
        it(@"should avoid crash by using convience constructor arrayWithObjects:count: while object appear nil.", ^{
            const id os[] = { @"1",nil};
            NSArray *arr = [NSArray arrayWithObjects:os count:2];
            expect(arr).to(equal(@[@"1"]));
        });
    });
    
    context(@"NSDictionary test", ^{
        it(@"should avoid crash by using convience constructor dictionaryWithObjects:forKeys:count: while object or key appear nil.", ^{
            NSString *nilValue = nil;
            NSDictionary *dict = @{
                                   @"name" : @"zs",
                                   @"age" : nilValue,
                                   nilValue : @""
                                   };
            
            expect(dict).to(equal(@{@"name" : @"zs"}));
        });
    });
    
    context(@"NSMutableArray(Private SubClass) test", ^{
        it(@"should avoid crash by using addObject: while object appear nil.", ^{
            NSMutableArray *arr = @[].mutableCopy;
            NSString *clazzName = [[NSString alloc] initWithUTF8String:object_getClassName(arr)];
            expect(clazzName).to(equal(@"__NSArrayM"));
            id nilValue = nil;
            [arr addObject:@1];
            [arr addObject:nilValue];
            [arr addObject:@3];
            expect(arr).to(equal(@[@1, @3]));
        });
        
        it(@"should avoid crash by using objectAtIndex: while index out of bounds.", ^{
            NSMutableArray *arr = @[].mutableCopy;
            NSString *clazzName = [[NSString alloc] initWithUTF8String:object_getClassName(arr)];
            expect(clazzName).to(equal(@"__NSArrayM"));
            [arr addObject:@1];
            [arr addObject:@3];
            expect(arr[100]).to(beNil());
        });
        
        it(@"should avoid crash by using removeObjectAtIndex: while index out of bounds.", ^{
            NSMutableArray *arr = @[].mutableCopy;
            NSString *clazzName = [[NSString alloc] initWithUTF8String:object_getClassName(arr)];
            expect(clazzName).to(equal(@"__NSArrayM"));
            [arr addObject:@1];
            [arr addObject:@3];
            [arr removeObjectAtIndex:2];
            expect(arr).to(equal(@[@1, @3]));
        });
        
        it(@"should avoid crash by using insertObject:atIndex: while object appear nil.", ^{
            NSMutableArray *arr = @[].mutableCopy;
            NSString *clazzName = [[NSString alloc] initWithUTF8String:object_getClassName(arr)];
            expect(clazzName).to(equal(@"__NSArrayM"));
            [arr addObject:@1];
            [arr addObject:@3];
            id nilValue = nil;
            [arr insertObject:nilValue atIndex:10];
            expect(arr).to(equal(@[@1, @3]));
        });
        
        it(@"should avoid crash by using setObject:atIndexedSubscript: while object appear nil or idx out of bounds.", ^{
            NSMutableArray *arr = @[].mutableCopy;
            NSString *clazzName = [[NSString alloc] initWithUTF8String:object_getClassName(arr)];
            expect(clazzName).to(equal(@"__NSArrayM"));
            [arr addObject:@1];
            [arr addObject:@3];
            
            id nilValue = nil;
            [arr setObject:nilValue atIndexedSubscript:1];
            expect(arr).to(equal(@[@1, @3]));
            arr[1] = nilValue;
            expect(arr).to(equal(@[@1, @3]));
            
            [arr setObject:@"xx" atIndexedSubscript:100];
            expect(arr).to(equal(@[@1, @3]));
            arr[100] = @"xx";
            expect(arr).to(equal(@[@1, @3]));
        });
    });
    
    context(@"NSMutableDictionary(Private SubClass) test", ^{
        it(@"should avoid crash by using setObject:forKey: while object or key appear nil.", ^{
            NSMutableDictionary *dict = @{
                                          @"name" : @"zs"
                                          }.mutableCopy;
            NSString *clazzName = [[NSString alloc] initWithUTF8String:object_getClassName(dict)];
            expect(clazzName).to(equal(@"__NSDictionaryM"));
            
            id nilValue = nil;
            [dict setObject:nilValue forKey:@"xx"];
            expect(dict).to(equal(@{ @"name" : @"zs"}));
            dict[@"xx"] = nilValue;
            expect(dict).to(equal(@{ @"name" : @"zs"}));
            
            [dict setObject:@"xx" forKey:nilValue];
            expect(dict).to(equal(@{ @"name" : @"zs"}));
            dict[nilValue] = @"xx";
            expect(dict).to(equal(@{ @"name" : @"zs"}));
        });
    });

});

QuickSpecEnd
