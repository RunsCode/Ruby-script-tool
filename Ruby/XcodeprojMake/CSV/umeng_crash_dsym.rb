require 'csv'
require 'open3'
require 'pathname'
require 'fileutils'

class UmengCrashDSYM

  DSYM_PREFIX_PATH =  '/Users/runs/Desktop/Work/OUClass/Project/client-ios/OU_iPhone/build'
  DSYM_PREFIX_PATH_DEFAULT =  '~/Library/Developer/Xcode'

  def initialize(argv)
    parse_csv(argv.first)

    if argv.first.equal?(argv.last)
      exec_shell_cmd(nil)
      return
    end
    exec_shell_cmd(argv.last)
  end


  def parse_csv(csv_path)
    @error_address_array = []
    arr_csv = CSV.read(csv_path)
    version_idx = arr_csv.first.index('应用版本')
    @app_version = arr_csv.last[version_idx]

    arr_csv.last.each { |item|
      collection_str = item.to_s
      if collection_str.include?("UUID")  and collection_str.include?("CPU") and collection_str.include?("Slide Address")
        arr = collection_str.split(",")
        @error_desc = arr.first.to_s.split('*').last.delete!('\"')
        puts "Error : #{@error_desc}"
        arr.each { |obj|
          if obj.to_s.include?("UUID")
            @dsym_uuid = obj.to_s.split(" ").last.delete!('\"')
            puts "UUID = #{@dsym_uuid}"
          end
          if obj.to_s.include?("Slide")
            @slide_address = obj.to_s.split(" ").last.delete!('\"')
            puts "Slide Address = #{@slide_address}"
          end
          if obj.to_s.include?("CPU Type")
            @cpu_type = obj.to_s.split(" ").last.delete!('\"')
            puts "CPU Type = #{@cpu_type}"
          end
        }
      end
      if item.to_s.start_with?('0x')
        @error_address_array.push(item)
      end
    }

  end

  def exec_shell_cmd(dsym_path)
    dsym_file_path = dsym_path
    if dsym_file_path.nil?
      find_dsym_cmd = "(find #{DSYM_PREFIX_PATH_DEFAULT} -iname '*.dSYM' -print0 | xargs -0 dwarfdump -u | grep #{@dsym_uuid} | sed -E 's/^[^/]+//' | head -n 1)"
      stdin, stdout, stderr = Open3.popen3(find_dsym_cmd)
      stdout.each { |line|
        dsym_file_path = line
      }
    end

    if dsym_file_path.nil?
      find_dsym_cmd = "(find #{DSYM_PREFIX_PATH} -iname '*.dSYM' -print0 | xargs -0 dwarfdump -u | grep #{@dsym_uuid} | sed -E 's/^[^/]+//' | head -n 1)"
      stdin, stdout, stderr = Open3.popen3(find_dsym_cmd)
      stdout.each { |line|
        dsym_file_path = line
      }
    end

    if dsym_file_path.nil?
      puts "dSYM 文件未找到 exit"
      exit
    end

    @project_name = dsym_file_path.split('/').last.rstrip!

    # puts "find_dsym_cmd = #{find_dsym_cmd}"
    puts "dsym_file_path = #{dsym_file_path}"
    split_result(dsym_file_path)
  end

  def split_result(dsym_file_path)

    class_name = ""
    func_name = ""
    start_line_number = ""
    end_line_number = ""

    error = ""
    @error_address_array.each { |address|
      idx = @error_address_array.index(address)
      cmd = "dwarfdump --arch=#{@cpu_type} --lookup #{address} #{dsym_file_path}"
      # puts "cmd = #{cmd}"

      stdin, stdout, stderr = Open3.popen3(cmd)
      stdout.each { |line|

        if line.include?('AT_name')
          func_name = line.delete!(')').split('(').last.delete!('\"').rstrip!.lstrip!
        end

        if line.include?('AT_decl_line')
          start_line_number = line.delete!(')').split(' ').last
        end

        if line.include?('Line table file:')
          arr_file = line.split('line')
          end_line_number = arr_file.last.split(',').first.lstrip!
          class_name = arr_file.first.delete!(' ').split('\'').last
        end

        if line.include?('AT_producer')
          @system_version = line.split('version').last.split(' ').first
        end

        if @class_path.nil? and line.include?('AT_decl_file')
          @class_path = line.delete!(')').split('(').last.delete!('\"').delete!(' ')
        end
        # puts line

      }
      new_line = "#{idx}. #{address}  #{func_name} in #{class_name}  #{start_line_number}-#{end_line_number}\n"
      # puts new_line
      error += new_line
      # puts line
    }
    puts "@app_version : #{@app_version}"
    puts "@system_version : #{@system_version}"
    puts "@class_path : #{@class_path}"
    # puts "@project_name : #{@project_name}"
    open_xcode
    write_error_to_file(error)
  end

  def open_xcode
    project_file_path = @class_path.split(@project_name).first + @project_name
    # puts "project_file_path = #{project_file_path}"

    find_project_name_cmd = "find #{project_file_path} -iname '*.xcworkspace'"
    project_file_full_path = nil
    stdin, stdout, stderr = Open3.popen3(find_project_name_cmd)
    stdout.each { |line|
      if line
        project_file_full_path = line
        break
      end
    }

    if project_file_full_path.nil?
      find_project_name_cmd = "find #{project_path} -iname '*.xcodeproj'"
      stdin, stdout, stderr = Open3.popen3(find_project_name_cmd)
      stdout.each { |line|
        if line
          project_file_full_path = line
          break
        end
      }
    end

    if project_file_full_path.nil?
      puts "打开Xcode 失败 找不到工程文件"
      exit
    end

    puts "Xcode 工程目录 ： #{project_file_full_path}"
    # Open3.popen3("open #{project_file_full_path}")
  end

  def write_error_to_file(error_report)

    file_dir = nil
    stdin, stdout, stder = Open3.popen3("cd ~; cd Documents; pwd")
    stdout.each { |line|
      puts line
      file_dir = "#{line.chomp}/dysm"
    }

    if !File.exist?(file_dir)
      FileUtils.mkdir(file_dir)
    end

    time = Time.now.strftime("%Y-%m-%d-%H-%M-%S")
    file_name = "#{time}.txt"
    file_path = "#{file_dir}/#{file_name}"
    puts "file_path : #{file_path}"


    head = "App Version : #{@app_version} \niOS Version : #{@system_version}\nCPU : #{@cpu_type}\nSlide Address : #{@slide_address}\nUUID : #{@dsym_uuid}\nError : #{@error_desc}\n\n"
    error = head + error_report

    File.open(file_path, 'w') { |file|
       file.write error
    }
    # Open3.popen3("open #{@class_path}")
    sleep(1)

    prefix = 'open -a /Applications/Sublime\ Text.app'
    app_cmd = "#{prefix} #{file_path}"
    # puts "app : #{app}"
    stdin, stdout, stder = Open3.popen3(app_cmd)

    stder.each { |line|
      puts "error : #{line} ,未找到Sublime 或者其他路径错误 默认方式打开"
      exec("open #{file_path}")
    }
  end

end


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

csv_path = 'ouiphone_1_1_0__1_2_3.csv'

UmengCrashDSYM.new(ARGV)

# exec('(find /Users/runs/Desktop/Work/OUClass/Project/client-ios/OU_iPhone/build -iname \'*.dSYM\' -print0 | xargs -0 dwarfdump -u  | grep 072BB681-7415-325B-AF5E-2E78FF711030 | sed -E \'s/^[^/]+//\' | head -n 1)')

###
# export dSYMPath="$(find /Users/runs/Desktop/Work/OUClass/Project/client-ios/OU_iPhone/build/ -iname '*.dSYM' -print0 | xargs -0 dwarfdump -u  | grep 072BB681-7415-325B-AF5E-2E78FF711030 | sed -E 's/^[^/]+//' | head -n 1)";
# dwarfdump --arch=arm64 --lookup 0x100042860 "$dSYMPath"
###