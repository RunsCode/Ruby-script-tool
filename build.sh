#! /bin/sh
# parameters $1 => store Or adhoc
# parameters $2 => 上传fir.im 所需要的描述  打appStore 的包可不填
# Usage: ./build.sh adhoc '发布内测' #用空格隔开
DATE=$(date +%Y%m%d-%H%M%S)
THEME_NAME=OU_iPhone #target 你的工程名一般就是主target
BUILD_PATH=build/$DATE

WORK_SPACE_PATH=$THEME_NAME.xcworkspace
ARCHIVE_PATH=$BUILD_PATH/$THEME_NAME.xcarchive
IPA_PATH=$BUILD_PATH/ipa

if [ $1 = store ]; then
	IS_APPSTORE_RELEASE=1
	PLIST_NAME=ExportOptions_appStore.plist 
	echo '打包 App Store 版本， 不进行上传 完成打开对应的目录'
else
	IS_APPSTORE_RELEASE=0
	PLIST_NAME=ExportOptions_adhoc.plist
	echo '打包 AdHoc 版本， 进行上传'
fi

PLIST_PATH=build/$PLIST_NAME

echo 'worksapce path => '$WORK_SPACE_PATH
echo 'archive path => '$ARCHIVE_PATH
echo 'exportOptionsPlist path => '$PLIST_PATH

xcodebuild clean -workspace $WORK_SPACE_PATH -scheme $THEME_NAME -configuration Release
xcodebuild archive -workspace $WORK_SPACE_PATH -scheme $THEME_NAME -archivePath $ARCHIVE_PATH
xcodebuild -exportArchive -archivePath $ARCHIVE_PATH -exportPath $IPA_PATH -exportOptionsPlist $PLIST_PATH

if [ $IS_APPSTORE_RELEASE = 1 ]; then
	open $IPA_PATH
	exit 1
fi

fir login '这里填你的fir.im APItoken 写好之后去掉单引号'  
fir publish $IPA_PATH/$THEME_NAME.ipa -c $2 -s '这里填一个你想要的连接下载纯英文' -Q
open http://fir.im/'这里填一个你想要的连接下载纯英文 写好之后去掉单引号'
