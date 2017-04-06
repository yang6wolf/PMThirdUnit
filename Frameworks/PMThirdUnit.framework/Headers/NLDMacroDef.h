//
//  NLDMacroDef.h
//  Pods
//
//  Created by 高振伟 on 16/6/29.
//
//

#ifndef NLDMacroDef_h
#define NLDMacroDef_h

#ifndef LDEventCollectionDEBUG
#define LDEventCollectionDEBUG 0
#endif

#if LDEventCollectionDEBUG
#define LDECLog(...) NSLog(__VA_ARGS__)
#else
#define LDECLog(...) {}
#endif


#endif /* NLDMacroDef_h */
