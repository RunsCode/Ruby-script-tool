require 'json'
require 'pp'
Dir[File.dirname(__FILE__) + '/record_origin_presentation_model.rb'].each {|file| require file }

class SplitPresentationJson

  TOTAL_TIME = 9300

  def initialize
    load_json
    split_presentation_and_magic_wand_json
    wirte_split_new_json
    # calculate_useful_data_count
    parse_presentation_array_json
    collection_presentation_model
    fragment_presentation_action_by_type
    second_range_data_legality_detection
    save_fragment_presentation_json
  end

  def load_json
    json = File.read('JSON/source/temp_presentation_2-27878.json')
    @obj = JSON.parse(json)
    puts "json total count = #{@obj.length}"
  end

  # 拆分原始数组数据
  # 把课件数据和魔棒数据区分开，独立两个数组
  # 课件数组：@presentation_array
  # 魔棒数组：@magic_wand_array
  def split_presentation_and_magic_wand_json
    @presentation_array = []
    @magic_wand_array = []
    @obj.each { |object|
      # puts "object : #{object}"
      presentation_sub_array = []
      magic_wand_sub_array = []
      object.each { |content|
        second = content['second']
        type = content['type']
        # timestamp = content['data']['timestamp']
        if type == 261
          magic_wand_sub_array.push(content)
        else
          presentation_sub_array.push(content)
        end
      }
      if presentation_sub_array.length > 0
        @presentation_array.push(presentation_sub_array)
      end
      if magic_wand_sub_array.length > 0
        @magic_wand_array.push(magic_wand_sub_array)
      end
    }
    puts "presentation_array count = #{@presentation_array.length}"
    # puts @presentation_array
    puts "magic_wand_array count = #{@magic_wand_array.length}"
    # puts @magic_wand_array
  end

  # 将两个拆分的数组写入JSON文件持久化
  def wirte_split_new_json
    File.open("JSON/generate/split_presentation.json","w") do |f|
      f.write(JSON.pretty_generate(@presentation_array))
    end
    File.open("JSON/generate/split_magicwand.json","w") do |f|
      f.write(JSON.pretty_generate(@magic_wand_array))
    end
    puts "新的拆分数据JSON 写入文件成功"
  end


  # 计算课件与魔棒数组有效数据长度
  def calculate_useful_data_count
    presentation_count = @presentation_array.length
    @presentation_array.each { |obj|
      presentation_count += obj.length
    }
    puts "presentation_count = #{presentation_count}"
    magic_wand_count = @magic_wand_array.length
    @magic_wand_array.each { |obj|
      magic_wand_count += obj.length
    }
    puts "magic_wand_count = #{magic_wand_count}"
  end

  # 解析课件数组成Ruby对象：
  # RecordOriginPresentationModel
  # | - PresentationsListModel
  # | - | -PresentationsModel
  def parse_presentation_array_json
    presentation_action_model_array_total_count = 0
    @presentation_action_model_array = []
    @presentation_array.map { |obj|
      presentation_model_sub_array = []
      obj.map { |content|
        object = RecordOriginPresentationModel.new(content)
        next if object.nil?
        presentation_model_sub_array.push(object)
      }
      next if presentation_model_sub_array.empty?
      @presentation_action_model_array.push(presentation_model_sub_array)
      presentation_action_model_array_total_count += presentation_model_sub_array.count
    }
    # pp @presentation_action_model_array
    # puts @presentation_action_model_array
    puts "@presentation_action_model_array count = #{@presentation_action_model_array.length}"
    puts "@presentation_action_model_array_total_count = #{presentation_action_model_array_total_count}"
  end

  # 收集整理课件 为课件按时间区间分片做前期数据准备
  # 按顺序收集课件id --> @presentation_data_model_presentation_id_array
  # 按照课件映射关系 { pid => 课件模型 } --> @presentation_data_model_map
  def collection_presentation_model
    @presentation_data_model_presentation_id_array = []
    @presentation_data_model_map = Hash.new
    @presentation_action_model_array.map { |array|
      array.map { |content|
        next if content.data.presentations.length <= 0
        content.data.presentations.each { |model|
          @presentation_data_model_map[model.presentationId] = model
          next if @presentation_data_model_presentation_id_array.include?(model.presentationId)
          @presentation_data_model_presentation_id_array.push(model.presentationId)
        }
      }
    }
    puts "@presentation_data_model_map count = #{@presentation_data_model_map.length}"
    puts "@@presentation_data_model_presentation_id_array count = #{@presentation_data_model_presentation_id_array.length}"
    # pp @presentation_data_model_map
    # pp @presentation_data_model_presentation_id_array
  end

  # 课件按照时间区间分片整理 --> { 时间区间 => 课件模型 }
  # 按照课件的行为: 增删切查, 再通过不同的课件id进行分片, 总之相邻的两个时间区间里展示的课件是不同的
  # 行为拆分:
  #   删: 类型消息号 => 257, 表示删除当前课件, 默认展示上一个课件
  #   切: 类型消息号 => 258, 表示切换课件, 根据课件id, 切换到指定的课件
  #   增: 类型消息号 => 259,
  #   查: 类型消息号 => 288,
  #   说明: 259和288的逻辑行为是一样的, 都是从288拉取所有课件从所有课件里找到`当前课件id`然后直接切换到当前课件
  #   当前课件id: 获取规则是字段`presentationShare`存在值的话,即为该值, 否则就是默认原则找到课件列表字段
  #             `presentations`, 使用列表第一个课件,找到该课件里字段`presentationId`, 即为当前课件id
  # 注意:
  #   1、第一个键值开始的区间课件可能是空的, 表示没有课件展示，默认展示待定
  #   2、最后一个课件的结束区间至结束是没有的, 这种情况下处理方式, 不进行课件进行操作, 默认展示上一个课件
  #   3、所有的区间总和小于等于总时间, 否则分片就是错误的
  #

  def fragment_presentation_action_by_type
    cur_pid = ""
    start_point_second = 0

    @presentation_action_model_array.map { |array|
      array.map { |content|

        action_type = content.type
        p_share = content.data.presentationShare.to_s
        if 257 == action_type #delete
          presentation_id = content.data.presentationId
          index = @presentation_data_model_presentation_id_array.index(presentation_id)
          new_index = (index - 1) >= 0 ? (index - 1) : -1
          next if new_index <= -1
          p_share = @presentation_data_model_presentation_id_array[new_index]
        elsif 258 == action_type #switch
          p_share = content.data.presentationId
        else
          if p_share.length <= 0 && content.data.presentations.first
            p_share = content.data.presentations.first.presentationId
          end
        end

        if cur_pid == p_share
          last_content_check(array, content, start_point_second, p_share)
          next
        end

        end_point_second = content.second
        range_key = start_point_second...(end_point_second - start_point_second)
        generate_key_value(cur_pid, range_key)

        start_point_second = end_point_second
        cur_pid = p_share

        last_content_check(array, content, start_point_second, p_share)
      }
    }
    debug_log
  end

  def last_content_check(array, content, start_second, p_share)
    idx = @presentation_action_model_array.index(array)
    idx_sub = array.index(content)
    if idx == (@presentation_action_model_array.length - 1) && idx_sub == (array.length - 1)
      range_key = start_second...(TOTAL_TIME - start_second)
      generate_key_value(p_share, range_key)
      puts "Fragment Over."
    end
  end

  def generate_key_value(pid, key)
    if @second_range_map.nil?
      @second_range_map = Hash.new
    end
    model = @presentation_data_model_map[pid]
    @second_range_map[key] = model
  end

  def debug_log
    puts '-'*80
    puts "@range_key_map count = #{@second_range_map.length}"
    for k,v in @second_range_map #length = #{k.last},
      if v
        puts "loc = #{k.first},  end = #{k.first + k.last},  v = #{v.slide}"
      else
        puts "loc = #{k.first},  end = #{k.first + k.last},  v = null"
      end
    end
    # pp @range_key_map
  end

  # 检查分片时间总和是否等于播放总时长
  def second_range_data_legality_detection
    total_second = 0
    @second_range_map.keys.flat_map { |range|
      total_second += range.last
    }
    is_legal = total_second == TOTAL_TIME
    puts "数据是否合法 ：#{is_legal ? '合法' : '非法'}"
  end

  def save_fragment_presentation_json
    File.open("JSON/generate/new_structure_presentation.json","w") do |f|
      f.write(JSON.pretty_generate(@second_range_map))
    end
    File.open("JSON/generate/new_presentation_data_model.json","w") do |f|
      f.write(JSON.pretty_generate(@presentation_data_model_map))
    end
    File.open("JSON/generate/new_presentation_id.json","w") do |f|
      f.write(JSON.pretty_generate(@presentation_data_model_presentation_id_array))
    end
    puts "课件新的拆分数据结构JSON 写入文件成功"
  end

end

json = SplitPresentationJson.new
