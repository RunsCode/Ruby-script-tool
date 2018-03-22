require 'xcodeproj'
require 'pathname'
require 'find'

# Dir[File.dirname(__FILE__) + '/*.rb'].each {|file| require file }

class MakeFile

  XCODE_PROJ_NAME = 'OunaClass.xcodeproj'
  OTHER_FRAMEWORK_GROUP = 'OtherFile/Framework'
  OTHER_LIB_GROUP = 'OtherFile/Lib'

  def initialize
    current_path = Pathname.new(File.dirname(__FILE__)).parent.realpath
    puts "current_path = #{current_path}"

    @project_root = "#{current_path}/basePro"
    @project_path = "#{@project_root}/#{XCODE_PROJ_NAME}"

    @project = Xcodeproj::Project.open(@project_path)

    @project_framework_array = []
    get_project_frameWork
  end


  def save
    @project.save
    puts "保存更改至 #{XCODE_PROJ_NAME}"
  end


  def get_project_frameWork
    target = @project.targets.first
    target.frameworks_build_phases.files.to_a.map do |pbf_build_file|
      pbf_build_file.file_ref.real_path.to_s
    end.select do |path|
      path_end = path.to_s.split("/").last
      if path_end.end_with?(".framework")
        @project_framework_array.push(path_end)
      end
    end
    puts "工程 #{XCODE_PROJ_NAME} 中存在framework: #{@project_framework_array.length}, 如下:"
    puts @project_framework_array
    puts "------------------------------end"
  end


  def add_systems_frameworks(names, optional = false)

    @project.targets.each { |target|
      next if target.to_s.eql?("Qt Preprocess")
      build_phase = target.frameworks_build_phase

      names.each { |name|
        framework_name = "#{name}.framework"
        if @project_framework_array.include?(framework_name)
          puts "#{framework_name} 已存在，无需添加至工程 #{XCODE_PROJ_NAME}"
          next
        end
        puts "#{framework_name} 不存在，添加至工程 #{XCODE_PROJ_NAME}"

        group = @project.frameworks_group['OS X'] || @project.frameworks_group.new_group('OS X')
        path_sdk_name = 'MacOSX'
        path = "Platforms/#{path_sdk_name}.platform/Developer/SDKs/#{path_sdk_name}.sdk/System/Library/Frameworks/#{framework_name}"
        unless ref = group.find_file_by_path(path)
          ref = group.new_file(path, :developer_dir)
        end
        build_file = build_phase.add_file_reference(ref, true)
        if optional
          build_file.settings = { 'ATTRIBUTES' => ['Weak'] }
        end
        puts "target : #{target},添加#{framework_name}，成功"
      }
    }
  end


  def add_systems_libs(names, optional = false)
    @project.targets.each {|target|
      next if target.to_s.eql?("Qt Preprocess")
      build_phase = target.frameworks_build_phase

      names.each {|name|
        if @project_framework_array.include?(name)
          puts "#{name} 已存在，无需添加至工程 #{XCODE_PROJ_NAME}"
          next
        end
        puts "#{name} 不存在，添加至工程 #{XCODE_PROJ_NAME}"

        group = @project.frameworks_group['OS X'] || @project.frameworks_group.new_group('OS X')
        path_sdk_name = 'MacOSX'
        lib_path = "Platforms/#{path_sdk_name}.platform/Developer/SDKs/#{path_sdk_name}.sdk/usr/lib/#{name}"

        unless ref = group.find_file_by_path(lib_path)
          ref = group.new_file(lib_path, :developer_dir)
        end
        build_phase.add_file_reference(ref, true)
        puts "target : #{target}, 添加#{name}，成功"
      }
    }
  end


  def add_other_framework(names)
    @project.targets.each {|target|
      next if target.to_s.eql?("Qt Preprocess")
      build_phase = target.frameworks_build_phase

      names.each {|name|
        if @project_framework_array.include?(name)
          puts "#{name} 已存在，无需添加至工程 #{XCODE_PROJ_NAME}"
          next
        end
        puts "#{name} 不存在，添加至工程 #{XCODE_PROJ_NAME}"
        group = @project.frameworks_group["Other"] || @project.frameworks_group.new_group("Other")
        framework_path = "#{@project_root}/#{OTHER_FRAMEWORK_GROUP}/#{name}"
        puts "framework_path = #{framework_path}"
        unless ref = group.find_file_by_path(framework_path)
          ref = group.new_file(framework_path, :developer_dir)
        end
        build_phase.add_file_reference(ref, true)
        puts "target : #{target}, 添加#{name}，成功"
      }
    }
    #添加 framework search paths && header search paths
    @project.build_configuration_list.build_configurations.each {|config|
      new_framework_path = "$(PROJECT_DIR)/#{OTHER_FRAMEWORK_GROUP}"
      framework_searach_paths = []
      framework_searach_paths = config.build_settings['FRAMEWORK_SEARCH_PATHS']
      if !framework_searach_paths.include?(new_framework_path)
        framework_searach_paths.push(new_framework_path)
      end

      names.each { |name|
        new_header_path = "#{new_framework_path}/#{name}/Headers"
        header_searach_paths = []
        header_searach_paths = config.build_settings['HEADER_SEARCH_PATHS']
        if !header_searach_paths.include?(new_header_path)
          header_searach_paths.push(new_header_path)
        end
      }
    }
  end


  def add_other_lib(names)
    @project.targets.each {|target|
      next if target.to_s.eql?("Qt Preprocess")
      build_phase = target.frameworks_build_phase

      names.each {|name|
        if @project_framework_array.include?(name)
          puts "#{name} 已存在，无需添加至工程 #{XCODE_PROJ_NAME}"
          next
        end
        puts "#{name} 不存在，添加至工程 #{XCODE_PROJ_NAME}"
        group = @project.frameworks_group["lib"] || @project.frameworks_group.new_group("lib")
        framework_path = "#{@project_root}/#{OTHER_LIB_GROUP}/#{name}"
        unless ref = group.find_file_by_path(framework_path)
          ref = group.new_file(framework_path, :developer_dir)
        end
        build_phase.add_file_reference(ref, true)
        puts "target : #{target}, 添加#{name}，成功"
      }
    }
    #添加 library search paths
    @project.build_configuration_list.build_configurations.each {|config|
      library_searach_paths = []
      library_searach_paths = config.build_settings['LIBRARY_SEARCH_PATHS']
      new_library_path = "$(PROJECT_DIR)/#{OTHER_LIB_GROUP}"
      if !library_searach_paths.include?(new_library_path)
        library_searach_paths.push(new_library_path)
      end
    }
  end


  def find_other_framework()
    framework_array = [];
    Find.find("#{@project_root}/#{OTHER_FRAMEWORK_GROUP}") {|path|
      if path.to_s.end_with?(".framework")
        array = path.to_s.split("/")
        framework_array.push(array.last)
      end
    }
    framework_array
  end


  def find_other_lib()
    lib_array = []
    Find.find("#{@project_root}/#{OTHER_LIB_GROUP}") { |path|
      if path.to_s.end_with?(".dylib") || path.to_s.end_with?(".a")
        array = path.to_s.split("/")
        lib_array.push(array.last)
      end
    }
    lib_array
  end


end

system_framework_new_add = [
    "CoreMedia",
    "CoreAudio",
    "CoreVideo",
    "AVFoundation",
    "Cocoa",
    "CoreWLAN",
    "VideoToolBox",
    "AudioToolBox",
]

system_lib_new_add = [
    "libresolv.tbd",
]

make = MakeFile.new
make.add_systems_frameworks(system_framework_new_add, false)
make.add_systems_libs(system_lib_new_add,false)
make.add_other_framework(make.find_other_framework)
# make.add_other_lib(make.find_other_lib)
make.save


# 此类复制添加库文件引用
# 以及添加对应的Framework search paths , Header search paths and Library search paths