require 'json'

class MagicWandDataModel
  attr_reader :presentationId, :diameter, :roomId , :timestamp, :cursorY, :cursorX

  def initialize(json)
    return if json.empty?
    @presentationId = json['presentationId']
    @diameter = json['diameter']
    @roomId = json['roomId']
    @timestamp = json['timestamp']
    @cursorY = json['cursorY']
    @cursorX = json['cursorX']
  end

  def as_json(options={})
    {
        timestamp: @timestamp,
        diameter: @operatorId,
        roomId: @roomId,
        presentationId: @presentationId,
        cursorY: @cursorY,
        cursorX: @cursorX
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end


end

class RecordOriginMagicWandModel

  attr_reader :type, :second, :dest, :source, :data
  def initialize(json)
    # pp "0. RecordOriginPresentationModel json : #{json}"
    @type = json['type']
    @second = json['second']
    @dest = json['dest']
    @source = json['source']
    @data = MagicWandDataModel.new(json['data'])
  end

  def as_json(options={})
    {
        type: @type,
        second: @second,
        dest: @dest,
        source: @source,
        data: @data,
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end


end