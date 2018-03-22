require 'xcodeproj'
require 'pathname'
require 'find'
require 'fileutils'

class RunFileAssistant

  XCODE_PROJ_NAME = 'OunaClass.xcodeproj'
  OTHER_ROOT = "OtherFile"
  FRAMEWORK_DIR = "Framework"
  LIB_DIR = "Lib"

  OBJECT_C_FILE_ROOT = "Object-C"
  OBJECT_CPP_FILE_ROOT = "Object-C++"
  PROXY_DIR = "Proxy"
  PROTOCOL_DIR = "Protocol"

  FILE_NAME = 'project.pbxproj'


  def initialize
    current_path = Pathname.new(File.dirname(__FILE__)).parent.realpath
    puts "current_path = #{current_path}"
    @project_root = "#{current_path}/basePro"
    @project_path = "#{@project_root}/#{XCODE_PROJ_NAME}"
    @project_oc_cpp_root = "#{@project_root}/#{OBJECT_CPP_FILE_ROOT}"
    @project = Xcodeproj::Project.open(@project_path)
    @project_file_path = "#{@project_path}/#{FILE_NAME}"

  end

  def find_rename_file_path(rename_files)
    @rename_files_array = []
    @rename_path_array = []
    target = @project.targets.first
    rename_files.each {|obj| @rename_files_array.push(obj)}
    target.source_build_phase.files.to_a.map do |pbx_build_file|
      pbx_build_file.file_ref.real_path.to_s
    end.select do |path|
      file_name = path.to_s.split("/").last

      #移除备份文件
      if file_name.to_s.split('/').last.to_s.split('_').last.to_s.eql?('bak')
        FileUtils.remove(path)
        next
      end

      if @rename_files_array.include?(file_name)
        @rename_path_array.push(path)
        #备份
        bak_path = path.to_s + "_bak"
        FileUtils.cp_r(path, bak_path, :remove_destination => true)
      end
    end
  end

  def copy_mm_to_cpp_file
    puts "Object-C++ 文件混编目录 #{@project_oc_cpp_root}"
    if !File.exist?(@project_oc_cpp_root)
      return
    end

    mm_file_path = [];
    puts @rename_path_array

    Find.find("#{@project_oc_cpp_root}") { |path|
      next if path.to_s.eql?(@project_oc_cpp_root)
      #移除备份文件
      if path.to_s.split('/').last.to_s.split('_').last.to_s.eql?('bak')
        FileUtils.remove(path)
        next
      end
      bak_path = path.to_s + "_bak"
      #备份
      FileUtils.cp_r(path, bak_path)
      mm_file_path.push(path)
    }
    puts mm_file_path
    mm_file_path.each {|mm_path|
      @rename_path_array.each {|cpp_path|
        mm_name = mm_path.to_s.split('/').last.to_s.split('.').first
        cpp_name = cpp_path.to_s.split('/').last.to_s.split('.').first
        if mm_name.eql?(cpp_name)
          FileUtils.cp_r(mm_path, cpp_path, :remove_destination => true)
          puts "拷贝 #{mm_name}.mm --> #{cpp_name}.cpp"
          break
        end
      }
    }
  end

  def rename_cpp_flie
    new_path_array = []
    target = @project.targets.first

    @rename_path_array.each { |path|

      file_name = path.to_s.split('/').last.gsub("cpp","mm")
      new_path = "#{@project_oc_cpp_root}/#{file_name}"
      # File.rename(path, new_path)
      # 
      if !File.exist?(@project_oc_cpp_root)
        FileUtils.mkdir_p(@project_oc_cpp_root)
      end
      FileUtils.cp_r(path, new_path)
      new_path_array.push(new_path)
    }
    @rename_path_array.clear
    new_path_array.each {|obj| @rename_path_array.push(obj)}
  end

  def add_rename_file
    @rename_path_array.each { |path|
       target = @project.targets.first
       path_last = path.to_s.split("/").last
       root = path.to_s.delete(path_last)
       new_file_group = @project.main_group.find_subpath(File.join(OBJECT_CPP_FILE_ROOT), true)
       new_file_group.set_source_tree('<absolute>')
       file_ref = new_file_group.new_reference(path)

       is_existed = false
       file_ref_list = target.source_build_phase.files_references
       file_ref_list.each { |file_ref_tmp|
         if file_ref_tmp.path == path
           is_existed = true
         end
       }
       next if is_existed
       target.add_file_references([file_ref])
       puts "rename_file_path = #{path}"
    }
  end

  def output
    @modify_result = ""
    File.open(@project_file_path,"r+") { |file|
      file.each_line { |line|
        is_include = false
        @rename_files_array.each { |file_name|
          line.to_s.split(' ').each { |obj|#空格分割查找
            if obj.to_s.include?(file_name) && obj.to_s.eql?(file_name)
              is_include = true
              puts "查找到相同的文件引用 #{file_name}"
              break
            end
          }
          break if is_include
        }
        next if is_include
        @modify_result += line
      }
    }
    self
  end

  def input
    File.open(@project_file_path,"w"){ |file|

      if @modify_result.empty?
        return
      end
      file.write @modify_result
    }
  end


  def find_other_frameworks
    framework_array = [];
    Find.find("#{@project_root}/OtherFile/Framework") {|path|
      if path.to_s.end_with?(".framework")
        framework_array.push(path)
      end
    }
    framework_array
  end

  def find_other_libs
    lib_array = []
    Find.find("#{@project_root}/OtherFile/Lib") { |path|
      if path.to_s.end_with?(".dylib") || path.to_s.end_with?(".a")
        lib_array.push(path)
      end
    }
    lib_array
  end

  def find_proxy_files
    proxy_array = []
    Find.find("#{@project_root}/#{OBJECT_C_FILE_ROOT}/#{PROXY_DIR}") { |path|
      if path.to_s.end_with?('.h') || path.to_s.end_with?('.m')|| path.to_s.end_with?('.mm')
        proxy_array.push(path)
      end
    }
    proxy_array
  end

  def find_protocol_files
    protocol_array = []
    Find.find("#{@project_root}/#{OBJECT_C_FILE_ROOT}/#{PROTOCOL_DIR}") { |path|
      if path.to_s.end_with?('.h')
        protocol_array.push(path)
      end
    }
    protocol_array
  end

  def add_file(group, file_path)
    target = @project.targets.first
    file_ref_list = target.source_build_phase.files_references
    file_ref_list.each { |file_ref_tmp|
      if file_ref_tmp.path == file_path
        puts "#{file_path.to_s.split("/").last} 已经存在于该目录中"
        return
      end
    }
    puts "#{file_path.to_s.split("/").last} 不存在该目录中 添加至工程"
    file_ref = group.new_reference(file_path)
    target.add_file_references([file_ref])
  end

  def add_files(group, file_paths)
    file_paths.each {|path|
      add_file(group,path)
    }
  end

  def get_group(root, dir)
    target = @project.targets.first
    group = @project.main_group.find_subpath(File.join(root, dir), true)
    group.set_source_tree('SOURCE_ROOT')
    group
  end

  def add_framework_files
    framework_group = get_group(OTHER_ROOT,FRAMEWORK_DIR)
    add_files(framework_group, find_other_frameworks)
  end

  def add_lib_files
    lib_group = get_group(OTHER_ROOT,LIB_DIR)
    add_files(lib_group, find_other_libs)
  end

  def add_protocol_files
    protocol_group = get_group(OBJECT_C_FILE_ROOT, PROTOCOL_DIR)
    add_files(protocol_group, find_protocol_files)
  end

  def add_proxy_files
    proxy_group = get_group(OBJECT_C_FILE_ROOT, PROXY_DIR)
    add_files(proxy_group, find_proxy_files)
  end

  def add_resources_files(files)
    files.each {|file| add_resources_file(file)}
  end

  def add_resources_file(file)
    target = @project.targets.first
    file_path = "#{@project_root}/#{file.to_s}"
    file_ref_list = target.resources_build_phase.files_references
    file_ref_list.each { |file_ref_tmp|
      if file_ref_tmp.path.to_s == file_path
        puts "#{file_path.to_s.split("/").last} 已经存在于该目录中"
        return
      end
    }
    group = @project.main_group.find_subpath(File.join("Resources"), true)
    group.set_source_tree('SOURCE_ROOT')

    puts "#{file_path.to_s.split("/").last} 不存在该目录中 添加至工程"
    file_ref = group.new_reference(file_path)
    target.add_file_references([file_ref])
  end

  def amend_file_header_ref(names)
    names.each {|name|
      puts "修改#{name} 头文件引用"
      path = "#{@project_oc_cpp_root}/#{name}"
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
    }
  end

  def save
    @project.save
  end

  def run
    add_framework_files
    # add_lib_files
    add_protocol_files
    add_proxy_files
  end

end

rename_file_array = [
    "mainwindow.cpp",
    "LoginWidget.cpp",
    "RoomEntryWidget.cpp",
    "Player.cpp"
]

resources_file_array = ["icon.iconset"]

amend_header_file = ["mainwindow.mm"]

assistant = RunFileAssistant.new
assistant.run
#顺序不能错
assistant.find_rename_file_path(rename_file_array)
assistant.copy_mm_to_cpp_file
assistant.rename_cpp_flie
assistant.add_rename_file
##
assistant.add_resources_files(resources_file_array)
assistant.save
##
assistant.output.input #移除cpp引用
assistant.amend_file_header_ref(amend_header_file)

# 此类职责主要负责添加文件引用（更改工程文件结构）
# 负责添加库文件实体目录不添加引用（ 库文件引用略有不同配置需要添加 要到最后make_file.rb的执行 ）
# 负责添加 Object-C 文件以及引用
# 负责部分 .cpp 文件更名 .mm 再添加引用
# 以及添加图标资源文件实体以及引用
# 修改目标文件头文件引用