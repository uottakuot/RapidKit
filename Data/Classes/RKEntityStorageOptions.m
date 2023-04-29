// MIT License
//
// Copyright (c) Uottakuot Software
// https://github.com/uottakuot/RapidKit
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "RKEntityStorageOptions.h"
#import "RKDataPrivate.h"

@implementation RKEntityStorageOptions

- (void)setEntityName:(NSString*)name forClass:(Class)class {
    if ([self entityNames] == nil) {
        [self setEntityNames:[NSMutableDictionary dictionary]];
    }
    
    [[self entityNames] setOrRemoveObject:name forKey:NSStringFromClass(class)];
}

- (void)setTransientPropertyNames:(NSArray*)names forClass:(Class)class {
    if ([self transientPropertyNames] == nil) {
        [self setTransientPropertyNames:[NSMutableDictionary dictionary]];
    }
    
    [[self transientPropertyNames] setOrRemoveObject:names forKey:NSStringFromClass(class)];
}

- (void)setIndexedPropertyNames:(NSArray*)names forClass:(Class)class {
    if ([self indexedPropertyNames] == nil) {
        [self setIndexedPropertyNames:[NSMutableDictionary dictionary]];
    }
    
    [[self indexedPropertyNames] setOrRemoveObject:names forKey:NSStringFromClass(class)];
}

- (void)setFullTextSearchPropertyNames:(NSArray*)names forClass:(Class)class {
    if ([self fullTextSearchPropertyNames] == nil) {
        [self setFullTextSearchPropertyNames:[NSMutableDictionary dictionary]];
    }
    
    [[self fullTextSearchPropertyNames] setOrRemoveObject:names forKey:NSStringFromClass(class)];
}

@end
