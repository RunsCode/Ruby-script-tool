#! /bin/sh

echo '1. 文件重命名 .mm --> .cpp'
cd basePro
mv src/mainwindow.mm src/mainwindow.cpp
echo 'src/mainwindow.mm --> mainwindow.cpp'

mv src/widgets/common/LoginWidget.mm src/widgets/common/LoginWidget.cpp
echo 'src/widgets/common/LoginWidget.mm --> LoginWidget.cpp'

mv src/widgets/common/RoomEntryWidget.mm src/widgets/common/RoomEntryWidget.cpp
echo 'ssrc/widgets/common/RoomEntryWidget.mm --> RoomEntryWidget.cpp'

mv src/widgets/player/Player.mm src/widgets/player/Player.cpp
echo 'src/widgets/player/Player.mm --> Player.cpp'
echo '-------------------------------------------------------------------------'

pwd

echo '2. 执行qmake '
qmake -spec macx-xcode basePro.pro
echo '-------------------------------------------------------------------------'

pwd

echo '3.拷贝资源文件 '
cd ../run_script
cp run_info.plist ../basePro/info.plist
echo '拷贝 info.plist'
rm -rf ../basePro/icon.iconset
cp -r run_icon.iconset ../basePro/icon.iconset
echo '拷贝 icon.iconset'
cp -rf ../basePro/Object-C sources
cp -rf sources/Object-C ../basePro
echo '拷贝 Object-C'
cp -rf ../basePro/OtherFile sources
cp -rf sources/OtherFile ../basePro
echo '拷贝 OtherFile'
echo '-------------------------------------------------------------------------'

echo '4. 修改XcodeProj文件 '
ruby run_amend_project_file.rb
echo '-------------------------------------------------------------------------'

echo '5. 新增文件至功能 部分.cpp --> .mm'
ruby run_file_assistant.rb
echo '-------------------------------------------------------------------------'

echo '6. 新增framework/Lib'
ruby run_make_file.rb
echo '-------------------------------------------------------------------------'

echo '7. 打开Xcode工程'
cd ../basePro
open OunaClass.xcodeproj
echo '-------------------------------------------------------------------------'

echo 'Enjoy yourself!'
