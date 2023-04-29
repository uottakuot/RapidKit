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

#import <Foundation/Foundation.h>

#define RK_SYNTH(property) @synthesize property = _##property;

typedef struct {
    Class ownerClass;
    __unsafe_unretained NSString* name;
    Class typeClass;
    char encodedTypeCharacter;
    BOOL isReadonly;
    SEL getter;
    SEL setter;
} RKPropertyInfo;

@interface NSObject (RKDataFoundationNSObjectAdditions)

/// @name Associated Objects

+ (id)objectAssociatedWithKey:(id)key;
+ (void)setObject:(id)object associatedWithKey:(id)key retain:(BOOL)retain;
- (id)objectAssociatedWithKey:(id)key;
- (void)setObject:(id)object associatedWithKey:(id)key retain:(BOOL)retain;

/// @name Runtime

+ (Class)subclassWithPrefix:(NSString*)prefix suffix:(NSString*)suffix created:(BOOL*)created;
+ (NSArray*)propertyNamesIncludingSuperclasses:(BOOL)includingSuperclasses;
+ (void)enumeratePropertiesHierarchically:(BOOL)hierarchically withBlock:(void (^)(RKPropertyInfo info))block;
+ (void)replaceInstanceMethod:(IMP)imp forSelector:(SEL)selector;
+ (IMP)instanceMethodOfSuperclassForSelector:(SEL)selector;
- (void)setClass:(Class)klass;
- (void)repeatPerformSelector:(SEL)selector afterDelay:(NSTimeInterval)delay;

@end

@interface NSMutableDictionary (RKDataFoundationNSMutableDictionaryAdditions)

- (void)setOrRemoveObject:(id)object forKey:(id<NSCopying>)key;

@end
