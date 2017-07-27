ProjectName=$(find . -depth 1 -name "*.xcworkspace")
ProjectName=$(expr "$ProjectName" : "./\(.*\).xcworkspace")

if [ -z "$ProjectName" ]; then
  echo "\033[31mCan not locate project file!!!\033[0m"
  exit 0
fi

#Timing-Start
start=$(date "+%s")

#Buid Begin:wq
rm Frameworks/$ProjectName.framework/$ProjectName


#rm Frameworks/Headers/*.h
#find Pods -name *.h |xargs -I{} cp {} Frameworks/$ProjectName.framework/Headers/

xcodebuild -workspace $ProjectName.xcworkspace -scheme "$ProjectName" -configuration Release ARCHS='i386 x86_64' VALID_ARCHS='i386 x86_64' -sdk iphonesimulator
mv Frameworks/$ProjectName.framework/$ProjectName Frameworks/autobuild-simulator

find Frameworks/ -name *.plist |xargs rm -rf

xcodebuild -workspace $ProjectName.xcworkspace -scheme "$ProjectName" -configuration Release ARCHS='armv7 arm64' VALID_ARCHS='armv7 arm64' -sdk iphoneos
mv Frameworks/$ProjectName.framework/$ProjectName Frameworks/autobuild-iphone

lipo -create Frameworks/autobuild-simulator Frameworks/autobuild-iphone -output Frameworks/$ProjectName
mv Frameworks/$ProjectName Frameworks/$ProjectName.framework/

rm Frameworks/autobuild-*
#rm -rf Frameworks/$ProjectName.framework.dSYM/


START=`date +%s%N`

#Timing-End
now=$(date "+%s")
time=$((now-start))
echo "\033[31mUse $time seconds to build!\033[0m"
