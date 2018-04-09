require 'json'
require 'pp'
require 'pathname'
path = Pathname.new(File.dirname(__FILE__)).parent
require "#{path}/Http/http_proxy.rb"

class DataProxy

  def initialize(root_url, room_id)
    @root_url = root_url
    @room_id = room_id
  end

  def base_url
    @root_url + '/' + @room_id
  end

  def request_json_and_save(json_name)
    json_url = base_url + '/' + json_name + '.json'
    puts "json_url = #{json_url}"
    json = HttpProxy.get(json_url).read_body
    return if json.nil? || json.empty?
    save_json(json, json_name)
  end

  def save_json(data, file_name)
    File.open("source/#{file_name}_#{@room_id}.json","w") do |f|
      # f.write(JSON.pretty_generate(data))
      f.write(data.to_sym)
    end
    puts "#{file_name}.json, 写入文件目录：JSON/source 成功"
  end

end

proxy = DataProxy.new('http://record.olacio.com/record/data/event', '2-27878')
# proxy.request_json_and_save('chat')
proxy.request_json_and_save('presentation')
# proxy.request_json_and_save('whiteboard')
