require 'pathname'
require 'fileutils'
require 'find'
require 'tinify'


class RunImageCompression

  def initialize(target)
    @target_dir = target
    api_key_validate($TINIFY_API_KEYS.last)

    if !File.exist?(@target_dir)
      FileUtils.mkdir_p(@target_dir)
    end
  end

  def api_key_check
    compressions_this_month = Tinify.compression_count
    puts "当月压缩次数 : #{compressions_this_month}"
    if compressions_this_month == 500
      $TINIFY_API_KEYS.pop
      new_api_key = $TINIFY_API_KEYS.last
      puts "API :#{Tinify.key} 使用次数达到上限 : 500次, 切换API_KEY : #{new_api_key}"
      api_key_validate(new_api_key)
    end
  end

  def api_key_validate(api_key)
    begin
      Tinify.key = api_key
      Tinify.validate!
    rescue Tinify::AccountError => e
      puts "The error message is: " + e.message
    rescue Tinify::ClientError => e
      puts "The error message is: " + e.message
    rescue Tinify::ServerError => e
      puts "The error message is: " + e.message
    rescue Tinify::ConnectionError => e
      puts "The error message is: " + e.message
    rescue => e
    end
  end

  def compress(dir_name, image_path)
    target_sub_dir = "#{@target_dir}/#{dir_name}"
    if !File.exist?(target_sub_dir)
      puts "目标路径: #{target_sub_dir} 不存在 创建目标路径 "
      FileUtils.mkdir_p(target_sub_dir)
    end

    image_name = image_path.to_s.split('/').last
    target_image_path = "#{target_sub_dir}/#{image_name}"
    source = Tinify.from_file(image_path)
    source.to_file(target_image_path)
    puts "压缩 #{image_name} 成功"

    api_key_check
  end

  def search_root_dir(path)
    root_dir = nil
    path_dir_arr = path.to_s.split('/')
    path_dir_arr.select! { |obj|
      dir_str = obj.to_s
      !dir_str.include?('.png') &&
          !dir_str.include?('.jpg') &&
          !dir_str.include?('.jpeg')
    }
    origin_last_dir = @origin_dir.to_s.split('/').last
    begin
      last = path_dir_arr.last
      root_dir = "#{last}/#{root_dir}"
      path_dir_arr.pop
    end until path_dir_arr.last.to_s.eql?(origin_last_dir)
    root_dir.to_s.chop!
  end

  def serach(origin)
    @origin_dir = origin
    count = 0
    Find.find(origin) { |path|
      path_str_name = path.to_s
      if path_str_name.end_with?('.png') ||
          path_str_name.end_with?('.jpg') ||
          path_str_name.end_with?('.jpeg')

        dir_name = search_root_dir(path)
        compress(dir_name, path)
        count += 1
      end
    }
    puts "共压缩文件数 : #{count}"
  end
end

$TINIFY_API_KEYS = [
    '-sCxHgnYhE1L-zl9aWDPTzKDTK3Tg5_f',
    'BZMDMum6DYpipW7J6cQzB5afQ6RWdJx5',
    'VsOHGIfCM0I_REl-_O6tTW_9lnOBwPLS',
    'OSr4kKKpX2kq4Xjw7Vjb8NsKx9MTyiqK',
    'UVLvElH2mIhXZzL1DyhM9AOVQiJZJxWO',
    '1wDlcpN_7TdNNpmLd9TJKluM5qME9SQB',
    'dJ9ZFTjuUGi7f19LzcGlV6G1s_E0lJgx',
    'V0L2Lhz0UTeRu-Yx0Me3Ke_T7DUQa_ct'
]

if ARGV.length != 2
  puts "args : #{ARGV}"
  puts "参数长度错误 缺少原始文件暮落或者目标文件目录 exit"
  exit
end

origin_dir = ARGV.first
if origin_dir.to_s.empty?
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

compress = RunImageCompression.new(target_dir)
compress.serach(origin_dir)
