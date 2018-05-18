require 'pathname'
require 'find'


# def hello(a)
#    puts a
# end
#
# hello(ARGV)
#
# puts   __FILE__
# puts Pathname.new(__FILE__).realpath
# puts Pathname.new(File.dirname(__FILE__)).realpath
# puts Pathname.new(File.dirname(__FILE__)).parent.realpath
# puts Time.now.strftime("%Y-%m-%d %H:%M:%S")
exec('git status')

# CSV.open(csv_path, "rb").each { |row|
#   puts row.class
#   row.each { |item|
#    # puts  item.class
#     if item.to_s.start_with?("0x")
#       puts item
#     end
#   }
# }

# require 'xcodeproj'
#
# XCODE_PROJ_NAME = 'OunaClass.xcodeproj'
# OTHER_ROOT = "OtherFile"
# FRAMEWORK_DIR = "Framework"
# LIB_DIR = "Lib"
#
# OBJECT_C_FILE_ROOT = "Object-C"
# OBJECT_CPP_FILE_ROOT = "Object-C++"
# PROXY_DIR = "Proxy"
# PROTOCOL_DIR = "Protocol"

# FILE_NAME = 'project.pbxproj'
#
# # "/Users/runs/Desktop/Work/OUClass/Project/client-ios/OU_iPhone/OU_iPhone.xcodeproj"
# current_path = '/Users/runs/Desktop/Work/OUClass/Project/client-mac/client-mac-1.0.6'# Pathname.new(File.dirname(__FILE__)).realpath
# @project_root = "#{current_path}/basePro"
# @project_path = "#{@project_root}/#{XCODE_PROJ_NAME}"
# @project_oc_cpp_root = "#{@project_root}/#{OBJECT_CPP_FILE_ROOT}"
# @project = Xcodeproj::Project.open(@project_path)
# target = @project.targets.first
#
# @mm_file_path = []
# Find.find("#{@project_oc_cpp_root}") {|path|
#   @mm_file_path.push(path)
# }
# puts @mm_file_path
#
#
# rename_files = [
#     "mainwindow.cpp",
#     "LoginWidget.cpp",
#     "RoomEntryWidget.cpp",
#     "Player.cpp"
# ]
#
# @rename_path_array = []
# target = @project.targets.first
# target.source_build_phase.files.to_a.map do |pbx_build_file|
#   pbx_build_file.file_ref.real_path.to_s
# end.select do |path|
#   file_name = path.to_s.split("/").last
#   if rename_files.include?(file_name)
#     @rename_path_array.push(path)
#   end
# end
# puts @rename_path_array
#
#
# @mm_file_path.each {|mm_path|
#   @rename_path_array.each {|cpp_path|
#     mm_name = mm_path.to_s.split('/').last.to_s.split('.').first
#     cpp_name = cpp_path.to_s.split('/').last.to_s.split('.').first
#     if mm_name.eql?(cpp_name)
#       FileUtils.cp_r(mm_path, cpp_path)
#       puts "拷贝 #{mm_name}.mm --> #{cpp_name}.cpp"
#       break
#     end
#   }
# }



# puts "project_path = #{@project_path}"
# @project = Xcodeproj::Project.open(@project_path)
# target = @project.targets.first
# puts target
# @project.build_configuration_list.build_configurations.each {|config|
#   puts config
#   # framework_searach_paths = []
#   # framework_searach_paths = config.build_settings['FRAMEWORK_SEARCH_PATHS']
#   # framework_searach_paths.push("$(PROJECT_DIR)/OtherFile/Framework")
#
#   header_searach_paths = []
#   header_searach_paths = config.build_settings['HEADER_SEARCH_PATHS']
#   header_searach_paths.push("$(PROJECT_DIR)/OtherFile/Framework/QtAVWidgets.framework/Headers")
#   header_searach_paths.push("$(PROJECT_DIR)/OtherFile/Framework/QtAV.framework/Headers")
#   header_searach_paths.push("$(PROJECT_DIR)/OtherFile/Framework/AgoraRtcEngineKit.framework/Headers")
#
#   @project.save
# }
#
# @project.build_configuration_list.build_configurations.each {|config|
#   puts config
#   framework_searach_paths = []
#   framework_searach_paths = config.build_settings['FRAMEWORK_SEARCH_PATHS']
#   framework_searach_paths.each {|path| puts path.to_s}
#
#   header_searach_paths = config.build_settings['HEADER_SEARCH_PATHS']
#   header_searach_paths.each {|path| puts path.to_s}
#   puts "-------------------------------------------------------------- #{config}"
#
# }


#('FRAMEWORK_SEARCH_PATHS')
# target.build_configurations.each do |config|
#    # arr = []
#    # puts config
#    # puts arr
#
# end

#
# path = '/Users/runs/Desktop.png/Work/OUClass.jpg/Project/client-iosng/OU_iPhonep.ng'
# def find_root_dir(path)
#   root_dir = nil
#   path_dir_arr = path.to_s.split('/')
#   puts "Before path_dir_arr = #{path_dir_arr}"
#   path_dir_arr.select! { |obj|
#     dir_str = obj.to_s
#     # !dir_str.end_with?('png') &&
#         # !dir_str.end_with?('.jpg') &&
#         !dir_str.include?('.ng')
#   }
#   puts "After path_dir_arr = #{path_dir_arr}"
#   root_dir = path_dir_arr.last
#   puts "root_dir = #{root_dir}"
# end
# find_root_dir(path)
#
# path = '/Users/runs/Desktop/Work/OUClass/Project/client-ios/OU_iPhone/OU_iPhone/Assets.xcassets/www/classroom/BottomNavigationBar/classroom_bottom_icon_1.imageset/classroom_video_icon@3x.png'
# def search_root_dir(path)
#   root_dir = nil
#   path_dir_arr = path.to_s.split('/')
#   path_dir_arr.select! { |obj|
#     dir_str = obj.to_s
#     !dir_str.include?('.imageset') &&
#         !dir_str.include?('.png') &&
#         !dir_str.include?('.jpg') &&
#         !dir_str.include?('.jpeg') &&
#         !dir_str.include?('.json')
#   }
#   begin
#     last = path_dir_arr.last
#     root_dir = "#{last}/#{root_dir}"
#     path_dir_arr.pop
#   end until path_dir_arr.last.to_s.end_with?('.xcassets')
#   puts "root_dir : #{root_dir}"
#
# end
# search_root_dir(path)

# Dir[File.dirname(__FILE__) + '/Http/http_proxy.rb'].each {|file| require file }


# require 'uri'
# require 'net/http'
#
# url = URI("http://record.olacio.com/record/data/event/1-2623/whiteboard.json")
#
# http = Net::HTTP.new(url.host, url.port)
#
# request = Net::HTTP::Get.new(url)
# request["content-type"] = 'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW'
# request["cache-control"] = 'no-cache'
# request["postman-token"] = '6fd13013-d7a7-ff73-7dc2-3a4c9488bd49'
# request.body = "------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"Content-Type\"; filename=\"1.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW--"
#
# response = http.request(request)
# puts response.read_body

# puts HttpProxy.get("http://record.olacio.com/record/data/event/1-2623/whiteboard.json")