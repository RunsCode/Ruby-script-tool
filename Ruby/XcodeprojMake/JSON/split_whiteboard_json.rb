require 'json'
class SplitWhiteboardJson

  def initialize
    load_json
    calculate_useful_data_count
    split_whiteboard_shapes_to_map
    whiteboard_data_legality_detection
    save_new_structure_whiteboard_json
  end

  def load_json
    json = File.read('source/temp_whiteboard.json')
    @obj = JSON.parse(json)
    puts "json total count = #{@obj.length}"
  end

  def calculate_useful_data_count
    @useful_data_count = 0
    @obj.each { |object|
      @useful_data_count += object.length
    }
    puts "@useful_data_count = #{@useful_data_count}"
  end

  def whiteboard_id(obj)
    obj['data']['whiteboardId']
  end

  def split_whiteboard_shapes_to_map
    last_wid = ''
    whiteboard_shapes_sub_array = []
    @obj.each { |object|
      object.each { |content|
        wid = whiteboard_id(content)
        whiteboard_shapes_sub_array.push(content)
        if wid != last_wid
          generate_key_value(wid, whiteboard_shapes_sub_array.dup)
          whiteboard_shapes_sub_array.clear
        end
        last_wid == wid
      }
    }
    debug_log
  end

  def debug_log
    puts '-'*80
    puts "@whiteboard_id_shapes_map count = #{@whiteboard_id_shapes_map.length}"
    # pp @whiteboard_id_shapes_map
    @whiteboard_id_shapes_map.map { |k,v|
      puts "key = #{k},  v = #{v.length}"
    }
  end

  def generate_key_value(key,value)
    if @whiteboard_id_shapes_map.nil?
      @whiteboard_id_shapes_map = Hash.new
    end
    array = @whiteboard_id_shapes_map[key]
    if array
      array += value
    else
      array = value
    end
    @whiteboard_id_shapes_map[key] = array
  end

  def whiteboard_data_legality_detection
    values_count = 0
    @whiteboard_id_shapes_map.map { |k, v|
      values_count += v.length
    }
    is_legal = @useful_data_count == values_count
    puts "数据是否合法 ：#{is_legal ? '合法' : '非法'}"
  end

  def save_new_structure_whiteboard_json
    File.open("generate/new_structure_whiteboard.json","w") do |f|
      f.write(JSON.pretty_generate(@whiteboard_id_shapes_map))
    end
    puts "新的拆分白板数据结构JSON 写入文件成功"
  end

end

SplitWhiteboardJson.new