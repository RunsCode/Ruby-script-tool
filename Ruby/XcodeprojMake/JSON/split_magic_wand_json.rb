require 'json'
require 'pp'
Dir[File.dirname(__FILE__) + '/record_origin_magic_wand_model.rb'].each {|file| require file }


class SplitMagicWandJson

  def initialize
    load_json
    parse_magic_wand_json_to_model
    split_magic_wand_coordinate_to_map
    second_data_legality_detection
    save_fragment_magic_wand_json
  end

  def load_json
    json = File.read('generate/split_magicwand.json')
    @obj = JSON.parse(json)
    puts "JSON total count = #{@obj.length}"
    if @obj.length <= 0
      exit
    end
  end

  def parse_magic_wand_json_to_model
    @magic_wand_model_array = []
    @obj.each { |object|
      object.each { |content|
        model = RecordOriginMagicWandModel.new(content)
        next if model.nil?
        @magic_wand_model_array.push(model)
      }
    }
    puts "magic_wand_model_array count = #{@magic_wand_model_array.length}"
  end

  # 拆分魔棒数据结构模型 拆分成 { second => [coordinate]} 时间点映射坐标的集合
  def split_magic_wand_coordinate_to_map
    last_second = 0
    magic_wand_model_sub_array = []
    @magic_wand_model_array.each { |coordinate|
      second = coordinate.second
      magic_wand_model_sub_array.push(coordinate.data)
      if second != last_second
        generate_key_value(second, magic_wand_model_sub_array.dup)
        magic_wand_model_sub_array.clear
      end
      last_second == second
    }
    debug_log
  end

  def debug_log
    puts '-'*80
    puts "@second_coordinate_map count = #{@second_coordinate_map.length}"
    # pp @second_coordinate_map
    @second_coordinate_map.map { |k,v|
      # puts "key = #{k},  v = #{v.length}"
    }
  end

  def generate_key_value(key,value)
    if @second_coordinate_map.nil?
      @second_coordinate_map = Hash.new
    end
    array = @second_coordinate_map[key]
    if array
      array += value
    else
      array = value
    end
    @second_coordinate_map[key] = array
  end

  # 检查改时间点是否空数据以及总长度是否等于JSON数组长度
  def second_data_legality_detection
    is_legal = @obj.length == @second_coordinate_map.length
    @second_coordinate_map.map { |k,v|
      if v.nil? || v.length <= 0
        is_legal = false
        break
      end
    }
    puts "数据是否合法 ：#{is_legal ? '合法' : '非法'}"
    is_legal
  end

  def save_fragment_magic_wand_json
    File.open("generate/new_structure_magic_wand.json","w") do |f|
      f.write(JSON.pretty_generate(@second_coordinate_map))
    end
    puts "新的拆分魔棒数据结构JSON 写入文件成功"
  end

end

magic_wand = SplitMagicWandJson.new
# arr1 = [1,2,3]
# arr2 = [4,5,6]
# arr1 += arr2
# puts arr1