require 'pp'
require 'json'
class PresentationsModel

  attr_reader :presentationId, :slide, :type, :whiteboardId
  def initialize(json=nil)
    # pp "2. PresentationsModel json : #{json}"
    return if json.empty?
    @presentationId = json['presentationId']
    @slide = json['slide']
    @type = json['type']
    @whiteboardId = json['whiteboardId']
  end

  def as_json(options={})
    {
        presentationId: @presentationId,
        slide: @slide,
        type: @type,
        whiteboardId: @whiteboardId
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end

end

class PresentationsListModel
  attr_reader :timestamp, :operatorId, :roomId, :presentationId, :presentationShare, :presentations
  def initialize(json)
    # pp "1. PresentationsListModel json : #{json}"
    return if json.empty?
    @timestamp = json['timestamp']
    @operatorId = json['operatorId']
    @roomId = json['roomId']
    @presentationId = json['presentationId']
    @presentationShare = json['presentationShare']
    @presentations = []
    array = json['presentations']
    return if array.nil?
    array.each { |obj|
      presentation = PresentationsModel.new(obj)
      @presentations.push(presentation)
    }
  end

  def as_json(options={})
    {
        timestamp: @timestamp,
        operatorId: @operatorId,
        roomId: @roomId,
        presentationId: @presentationId,
        presentationShare: @presentationShare,
        presentations: @presentations
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end

end

class RecordOriginPresentationModel
  attr_reader :type, :second, :dest, :source, :data
  def initialize(json)
    # pp "0. RecordOriginPresentationModel json : #{json}"
    @type = json['type']
    @second = json['second']
    @dest = json['dest']
    @source = json['source']
    @data = PresentationsListModel.new(json['data'])
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
