// AFCollectionJSONRequestOperation.m
//
// Copyright (c) 2012 Mattt Thompson (http://mattt.me/)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFCollectionJSONRequestOperation.h"

@interface AFCollectionJSONCollection ()
- (id)initWithAttributes:(NSDictionary *)attributes;
@end

#pragma mark -

@interface AFCollectionJSONItem ()
- (id)initWithAttributes:(NSDictionary *)attributes;
@end

#pragma mark -

@implementation AFCollectionJSONRequestOperation
@synthesize responseCollection = _responseCollection;

- (AFCollectionJSONCollection *)responseCollection {
    if (!_responseCollection) {
        _responseCollection = [[AFCollectionJSONCollection alloc] initWithAttributes:[self.responseJSON valueForKey:@"collection"]];
    }
    
    return _responseCollection;
}

#pragma mark - AFHTTPRequestOperation

+ (NSSet *)acceptableContentTypes {
    return [[super acceptableContentTypes] setByAddingObject:@"application/vnd.collection+json"];
}

- (void)setCompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success 
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    __unsafe_unretained AFCollectionJSONRequestOperation *weakSelf = self;
    self.completionBlock = ^ {
        __strong AFCollectionJSONRequestOperation *strongSelf = weakSelf;
        if ([strongSelf isCancelled]) {
            return;
        }
        
        if (strongSelf.error) {
            if (failure) {
                dispatch_async(strongSelf.failureCallbackQueue ? strongSelf.failureCallbackQueue : dispatch_get_main_queue(), ^{
                    failure(strongSelf, strongSelf.error);
                });
            }
        } else {
            if (success) {
                dispatch_async(strongSelf.successCallbackQueue ? strongSelf.successCallbackQueue : dispatch_get_main_queue(), ^{
                    success(strongSelf, strongSelf.responseCollection);
                });
            }
        }
    };  
}

@end

#pragma mark -

@implementation AFCollectionJSONCollection
@synthesize href = _href;
@synthesize version = _version;
@synthesize linksKeyedByRel = _linksKeyedByRel;
@synthesize items = _items;
@synthesize template = _template;

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _href = [NSURL URLWithString:[attributes valueForKey:@"href"]];
    _version = [attributes valueForKey:@"version"];
    
    NSMutableDictionary *mutableKeyedLinks = [NSMutableDictionary dictionary];
    for (NSDictionary *link in [attributes valueForKey:@"links"]) {
        NSURL *href = [NSURL URLWithString:[link valueForKey:@"href"]];
        NSString *rel = [link valueForKey:@"rel"];
        
        if (href && rel) {
            [mutableKeyedLinks setObject:href forKey:rel];
        }
    }
    _linksKeyedByRel = mutableKeyedLinks;
    
    NSMutableArray *mutableItems = [NSMutableArray array];
    for (NSDictionary *itemAttributes in [attributes valueForKey:@"items"]) {
        AFCollectionJSONItem *item = [[AFCollectionJSONItem alloc] initWithAttributes:itemAttributes];
        [mutableItems addObject:item];
    }
    _items = mutableItems;
    
    NSMutableDictionary *mutableTemplate = [NSMutableDictionary dictionary];
    for (NSDictionary *keyValuePair in [attributes valueForKeyPath:@"template.data"]) {
        NSString *key = [keyValuePair valueForKey:@"name"];
        NSString *value = [keyValuePair valueForKey:@"value"];
        
        if (key && value) {
            [mutableTemplate setValue:value forKey:key];
        }
    }
    _template = mutableTemplate;
    
    return self;
}

@end

#pragma mark -

@implementation AFCollectionJSONItem
@synthesize href = _href;
@synthesize linksKeyedByRel = _linksKeyedByRel;
@synthesize data = _data;

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _href = [NSURL URLWithString:[attributes valueForKey:@"href"]];
    NSMutableDictionary *mutableKeyedLinks = [NSMutableDictionary dictionary];
    for (NSDictionary *link in [attributes valueForKey:@"links"]) {
        NSURL *href = [NSURL URLWithString:[link valueForKey:@"href"]];
        NSString *rel = [link valueForKey:@"rel"];
        
        if (href && rel) {
            [mutableKeyedLinks setObject:href forKey:rel];
        }
    }
    _linksKeyedByRel = mutableKeyedLinks;
    
    NSMutableDictionary *mutableData = [NSMutableDictionary dictionary];
    for (NSDictionary *keyValuePair in [attributes valueForKey:@"data"]) {
        NSString *key = [keyValuePair valueForKey:@"name"];
        NSString *value = [keyValuePair valueForKey:@"value"];
        
        if (key && value) {
            [mutableData setValue:value forKey:key];
        }
    }
    _data = mutableData;
    
    return self;
}

- (id)valueForUndefinedKey:(NSString *)key {
    return [_data valueForKey:key];
}

@end
