//
//  NLDBase64Code.h
//  Pods
//
//  Created by 高振伟 on 16/10/19.
//
//

#ifndef NLDBase64Code_h
#define NLDBase64Code_h

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

size_t NLDEstimateBas64EncodedDataSize(size_t inDataSize);
size_t NLDstimateBas64DecodedDataSize(size_t inDataSize);

bool NLDBase64EncodeData(const void *inInputData, size_t inInputDataSize, char *outOutputData, size_t *ioOutputDataSize);
bool NLDBase64DecodeData(const void *inInputData, size_t inInputDataSize, void *ioOutputData, size_t *ioOutputDataSize);

#endif /* NLDBase64Code_h */
