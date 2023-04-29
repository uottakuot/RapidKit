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

@class RKEntityStorage;

typedef NS_ENUM(NSInteger, RKEntityModifier) {
    RKEntityModifierOneToOne = 0,
    RKEntityModifierOneToMany = 1,
    RKEntityModifierManyToOne = 2,
    RKEntityModifierManyToMany = 3
};

typedef NS_ENUM(NSInteger, RKEntityDeleteRule) {
    RKEntityDeleteRuleNoAction = 0,
    RKEntityDeleteRuleNullify = 1,
    RKEntityDeleteRuleCascade = 2,
    RKEntityDeleteRuleDeny = 3
};

@interface RKEntity : NSObject <NSCoding>

@property (nonatomic, getter = isChangeObservationEnabled) BOOL changeObservationEnabled;
@property (nonatomic, readonly, getter = isPersistent) BOOL persistent;
@property (nonatomic, weak, readonly) RKEntityStorage* entityStorage;

+ (void)registerRelationshipForClass:(Class)class1 propertyName:(NSString*)name1
                           withClass:(Class)class2 propertyName:(NSString*)name2
                     firstDeleteRule:(RKEntityDeleteRule)firstDeleteRule
                    secondDeleteRule:(RKEntityDeleteRule)secondDeleteRule
                            modifier:(RKEntityModifier)modifier;
- (void)addObject:(RKEntity*)object toCollectionNamed:(NSString*)name;
- (void)removeObject:(RKEntity*)object fromCollectionNamed:(NSString*)name;
- (void)willRegister;
- (void)didRegister;
- (void)willUnregister;
- (void)didUnregister;

@end
