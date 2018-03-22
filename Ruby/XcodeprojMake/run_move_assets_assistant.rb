require 'pathname'
require 'find'
require 'fileutils'

# 1.遍历目标目录
# 2.AppIcon.appiconset目录不进行移动（排除）
# 3.根目录Content.json文件不进行任何操作（排除）
# 4.遍历搜索其余目录文件的子目录结构，搜索XXXX0.imageset文件夹
# 5.找到后缀为.png或者.jpeg.jpg等图片文件
# 6.在目标文件下创建该同名一级目录,保留一级目录，去除.imageset目录,比如: origin/A -> targe/A
# 7.XXXX0.imageset内的Content.json文件不进行任何操作（排除）
# 8.直到拷贝所有文件到目标对应的目录中
#
#
# --|-----------------Origin Dir        Target Dir-----------------|--
#   |                                                              |
#   |--|------------A                              A------------|--|
#   |  |                                                        |  |
#   |  |--|-------a.imageset                          a.png-----|  |
#   |  |  |                                                     |  |
#   |  |  |-----xxx.png                               b.png-----|  |
#   |  |                                                           |
#   |  |--|-------b.imageset                                       |
#   |     |                                        B------------|--|
#   |     |-----xxx.png                                         |  |
#   |                           ----->               a1.png-----|  |
#   |                           ----->                          |  |
#   |--|------------B                                b1.png-----|  |
#   |  |                                                           |
#   |  |--|-------a1.imageset
#   |  |  |
#   |  |  |-----xxx.png
#   |  |
#   |  |
#   |  |--|-------b2.imageset
#   |     |
#   |     |-----xxx.png
#   |
#
IMAGESET_SUFFIX_NAME = '.imageset'
XCASSETS_SUFFIX_NAME = '.xcassets'

class RunMoveAssetsAssistant

  def initialize(target, filter_suffix)
    @target_dir = target
    @filter_suffix_array = filter_suffix
    if !File.exist?(@target_dir)
      FileUtils.mkdir_p(@target_dir)
    end
  end

  def filter_illegal_path?(path)
    is_include =  path.to_s.split('/').last.to_s.end_with?(XCASSETS_SUFFIX_NAME)
    if is_include
      puts "过滤路径 -> xxxx.xcassets"
      return is_include
    end
    @filter_suffix_array.each {|obj|
      path_obj_array = path.to_s.split('/')
      # puts "path_obj_array : #{path_obj_array}"
      path_obj_array.each { |in_obj|
        is_include = in_obj.end_with?(obj)
        if is_include
          puts "过滤路径 : obj -> #{obj}"
        end
        break if is_include
      }
      break if is_include
    }
    is_include
  end

  def search_root_dir(path)
    root_dir = nil
    path_dir_arr = path.to_s.split('/')
    path_dir_arr.select! { |obj|
      dir_str = obj.to_s
      !dir_str.include?(IMAGESET_SUFFIX_NAME) &&
          !dir_str.include?('.png') &&
          !dir_str.include?('.jpg') &&
          !dir_str.include?('.jpeg') &&
          !dir_str.include?('.json')
    }
    begin
      last = path_dir_arr.last
      root_dir = "#{last}/#{root_dir}"
      path_dir_arr.pop
    end until path_dir_arr.last.to_s.end_with?(XCASSETS_SUFFIX_NAME)
    root_dir.to_s.chop!
  end

  def loop_imageset_dir(dir_name, path)
    puts "图片原始二级目录 : #{dir_name}"
    Find.find(path) { |in_path|
      next if in_path.to_s.end_with?('.json')
      target_sub_dir = "#{@target_dir}/#{dir_name}"
      if !File.exist?(target_sub_dir)
        puts "目标路径: #{target_sub_dir} 不存在 创建目标路径 "
        FileUtils.mkdir_p(target_sub_dir)
      end

      image_size_sign = nil
      image_suffix_name = nil

      file_path_arr = in_path.to_s.split('/')
      file_name = file_path_arr.last

      #检测是否包含imageset
      file_path_parent = file_path_arr.reverse![1]
      if file_path_parent.to_s.end_with?(IMAGESET_SUFFIX_NAME)
        #获取imageset的文件名填充为图片名字
        file_name = file_path_parent.to_s.split('.').first
        image_origin_name = file_path_arr.first.to_s.split('.')
        image_suffix_name = ".#{image_origin_name.last}"
        #获取@2x,@3x之类的倍图标识符
        if image_origin_name.first.include?('@')
          image_size_sign = image_origin_name.first.to_s.split('@').last
          image_size_sign = "@#{image_size_sign}"
        end
      end


      target_path = "#{target_sub_dir}/#{file_name}#{image_size_sign}#{image_suffix_name}"

      FileUtils.cp_r(path, target_path)
      puts "拷贝路径:#{path} -> \n目标路径:#{target_path}"
      puts "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
    }
  end

  def search(origin_path)
    count = 0
    Find.find(origin_path) { |path|
      next if filter_illegal_path?(path)

      path_str_name = path.to_s
      if path_str_name.end_with?('.png') ||
          path_str_name.end_with?('.jpg') ||
          path_str_name.end_with?('.jpeg')

        dir_name = search_root_dir(path)
        loop_imageset_dir(dir_name, path)
        count += 1
      end
    }
    puts "共复制文件数 : #{count}"
  end

end

filter_suffix_set = [
    '.json',
    '.appiconset',
    '.DS_Store',
    'Emoji',
    'UserIcon'
];

if ARGV.length != 2
  puts "args : #{ARGV}"
  puts "参数长度错误 缺少原始文件暮落或者目标文件目录 exit"
  exit
end
origin_dir = ARGV.first

if !origin_dir.to_s.end_with?(XCASSETS_SUFFIX_NAME)
  puts "源文件路径 : #{origin_dir}"
  puts "非法源文件路径 exit"
  exit
end

target_dir = ARGV.last
if target_dir.to_s.empty?
  puts "非法输出目标文件路径 exit"
  exit
end

puts "origin_dir : #{origin_dir}"
puts "target_dir : #{target_dir}"

assisant = RunMoveAssetsAssistant.new(target_dir, filter_suffix_set)
assisant.search(origin_dir)