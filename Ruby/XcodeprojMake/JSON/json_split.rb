require 'json'
require 'pp'
class JsonSplit

  def initialize(source, dest)
    @source = source
    @dest = dest
    read_json
    # init_set
    remove_null_data
  end

  def read_json
    json = File.read(@source)
    @obj = JSON.parse(json)
    puts @obj.class
    puts "json count = #{@obj.length}"
  end

  def init_set
    # set = Set.new(@obj)
    array = Array(@obj)
    puts "Before delete null data, set count = #{array.length}"
    array.each { |arr|
      if arr.length <= 0
        array.delete(arr)
      end
    }
    puts "After  delete null data, set count = #{array.length}"
  end

  def remove_null_data
    array = []
    # origin = Array(@obj)

    # puts "origin count = #{origin.length}"
    @obj.each { |arr|
      next if arr.empty?
      array.push(arr)
    }
    puts "array count = #{array.length}"

    File.open(@dest,"w") do |f|
      f.write(JSON.pretty_generate(array))
      # f.write(array.to_sym)
      puts "文件写入: #{@dest} 成功"
    end
  end

end

JsonSplit.new('JSON/source/presentation_2-27878.json','JSON/source/temp_presentation_2-27878.json')
# JsonSplit.new('JSON/source/whiteboard.json','JSON/source/temp_whiteboard.json')
