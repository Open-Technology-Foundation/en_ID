# Changes Made for glibc Submission

Based on Carlos O'Donell's feedback from Bug #19010, the following changes have been made:

## 1. Added Required Copyright Disclaimer
Added the standard GNU C Library copyright disclaimer at the beginning of the locale file:
```
% This file is part of the GNU C Library and contains locale data.
% The Free Software Foundation does not claim any copyright interest
% in the locale data contained in this file.  The foregoing does not
% affect the license of the GNU C Library as a whole.  It does not
% exempt you from the conditions of the license if your use would
% otherwise be governed by that license.
```

## 2. Converted Unicode Code Points to Characters
All Unicode sequences have been replaced with actual characters for better readability:
- `<U0049><U0044><U0052><U0020>` → `"IDR "`
- `<U0052><U0070>` → `"Rp"`
- `<U0053><U0075><U006E>` → `"Sun"`
- And all other Unicode sequences throughout the file

## 3. Updated Version Information
- revision: "2.0" (was "1.4")
- date: "2024-06-27" (was "2015 July,29")

## 4. Fixed Mailing List Reference
Updated bugzilla-update.txt to reference the correct mailing list:
- Changed from "libc-locales mailing list" to "libc-alpha@sourceware.org"

## 5. Resolved LC_NAME
Kept a minimal LC_NAME definition (as is standard for locales) instead of omitting it entirely.

## Files Ready for Submission

1. **glibc-submission/en_ID** - The locale file with all required changes
2. **glibc-submission/0001-Add-en_ID-locale-for-Indonesian-English.patch** - Properly formatted git patch
3. **glibc-submission/bugzilla-update.txt** - Response for Bug #19010
4. **glibc-submission/cover-letter.txt** - Cover letter for libc-alpha@sourceware.org

## Next Steps

1. Reply to Bug #19010 with the content from bugzilla-update.txt
2. Send the patch to libc-alpha@sourceware.org with the cover letter
3. Monitor for feedback and respond to any additional requirements