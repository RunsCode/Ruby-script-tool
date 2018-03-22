# # CONSTANT_STR = "CB20087DE2953E96B494FAFE /* Player.cpp */,"
# CONSTANT_STR = "AE0A51D120073BB7008DE7D3 /* Player.cpp */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.cpp.cpp; name = Player.cpp; path = src/widgets/player/Player.cpp; sourceTree = \"<group>\"; };"
# # CONSTANT_STR = "F72E2895882D4919B220308F /* moc_Player.cpp in Compile Sources */ = {isa = PBXBuildFile; fileRef = ADBCCB57EBB9FDD52E61666A /* moc_Player.cpp */; settings = {ATTRIBUTES = (); }; };"
# array1 =  CONSTANT_STR.to_s.split(' ')
# puts array1
# is_include = false
# array1.each { |obj|
#   puts "obj = #{obj}"
#   file_name = "Player.cpp"
#   if obj.to_s.include?(file_name) && obj.to_s.eql?(file_name)
#     puts "obj --> #{obj}"
#     new_file_name = file_name.gsub("cpp", "mm")
#     str = CONSTANT_STR
#     str.gsub!(file_name, new_file_name)
#     puts str
#     break
#   end
# }


# result = ""
# File.open(path,"r+") { |file|
#   file.each_line { |line|
#     arr = line.to_s.split(' ')
#     if arr.first.eql?("#include") && arr.last.to_s.include?('/')
#       str = arr.last.to_s.lstrip.rstrip.delete('\"')
#       codes = str.split('/')
#       line = "#include \"#{codes.last}\"\n"
#       # puts result
#     end
#     result += line
#   }
#   file.write result
# }

def read_amend(path)
  result = ""
  File.open(path,"r+") { |file|
    file.each_line { |line|
      arr = line.to_s.split(' ')
      if arr.first.eql?("#include") && arr.last.to_s.include?('/')
        str = arr.last.to_s.lstrip.rstrip.delete('\"')
        codes = str.split('/')
        line = "#include \"#{codes.last}\"\n"
        # puts result
      end
      result += line
    }
  }
  File.open(path,"w") {|file|
    file.write result
  }
end

# def write_amend
  path = "/Users/runs/Desktop/Work/OUClass/Project/client-mac/client-mac-1.0.6/basePro/src/mainwindow.mm"
#   result = read_amend(path)
#   File.open(path,"w") {|file|
#     file.write result
#   }
# end


read_amend(path)