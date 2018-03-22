require 'pathname'
require 'fileutils'
require 'find'

class PhoneNumerFormat

  def format_output(path)
    @file_path = path.first
    puts "原始文件文件目录 : #{@file_path}"
    @modify_result = ""

    File.open(@file_path,"r+") { |file|
      file.each_line {|line|
        line.gsub!(/\r\n?/, "、")
        @modify_result += line
      }
    }
    puts "---------------------------------------------------------------------------------------"
    puts @modify_result
    puts "---------------------------------------------------------------------------------------"

    format_input
  end

  def format_input
    new_dir = Pathname.new(File.dirname(@file_path)).realpath
    # puts "new_dir : #{new_dir}"
    file_dir_atrry = @file_path.split('/').last.to_s.split('.')
    new_path = "#{new_dir}/#{file_dir_atrry.first}_new.#{file_dir_atrry.last}"
    # puts "file_dir_atrry.first : " + "#{file_dir_atrry.first}"

    File.open(new_path,"w"){ |file|
      file.write @modify_result
    }
    puts "新文件目录 : #{new_path} 写入成功"
  end

end

PhoneNumerFormat.new.format_output(ARGV)