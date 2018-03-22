class RunShell

  def run
    # one = `xcodebuild clean -workspace /Users/runs/Desktop/Work/OUClass/Project/client-ipad/OU_iPad/OU_iPad.xcworkspace -scheme OU_iPad -configuration Release`
    # puts one
    # two = `xcodebuild archive -workspace /Users/runs/Desktop/Work/OUClass/Project/client-ipad/OU_iPad/OU_iPad.xcworkspace -scheme OU_iPad -archivePath build/OU_iPad.xcarchive`
    # puts two
    # three = `xcodebuild -exportArchive -archivePath build/OU_iPad.xcarchive -exportPath build/adhoc_OU_iPad -exportOptionsPlist /Users/runs/Desktop/Work/OUClass/Project/client-ipad/OU_iPad/build/adhoc_exportOptions.plist`
    # puts three
  end

end

RunShell.new.run