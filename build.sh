rm Frameworks/PMThirdUnit.framework/PMThirdUnit


#rm Frameworks/Headers/*.h
#find Pods -name *.h |xargs -I{} cp {} Frameworks/PMThirdUnit.framework/Headers/

xcodebuild -workspace PMThirdUnit.xcworkspace -scheme "PMThirdUnit" -configuration Release ARCHS='i386 x86_64' VALID_ARCHS='i386 x86_64' -sdk iphonesimulator10.3
mv Frameworks/PMThirdUnit.framework/PMThirdUnit Frameworks/autobuild-simulator

find Frameworks/ -name *.plist |xargs rm -rf

xcodebuild -workspace PMThirdUnit.xcworkspace -scheme "PMThirdUnit" -configuration Release ARCHS='armv7 arm64' VALID_ARCHS='armv7 arm64' -sdk iphoneos10.3
mv Frameworks/PMThirdUnit.framework/PMThirdUnit Frameworks/autobuild-iphone

lipo -create Frameworks/autobuild-simulator Frameworks/autobuild-iphone -output Frameworks/PMThirdUnit
mv Frameworks/PMThirdUnit Frameworks/PMThirdUnit.framework/

rm Frameworks/autobuild-*
#rm -rf Frameworks/PMThirdUnit.framework.dSYM/

