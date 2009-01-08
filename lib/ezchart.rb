require 'rubygems'
require 'json'

=begin
intended DSL:

chart = EzChart('Stats for chendo') do
  
  
end




=end
module EzChart
  class JsonObject
    def to_json
      out = {}
      @ignored_attributes ||= []
      
      (instance_variables.map { |ivar| ivar[1..-1] } - ['ignored_attributes'] - @ignored_attributes).each do |ivar|
        if value = instance_variable_get("@#{ivar}")
          out[ivar] = value 
        end
      end
      out.to_json
    end
  end
  
  class Text < JsonObject
    attr_accessor :text, :style
    def initialize(text, style = nil)
      @text = text
      @style = style
    end
  end
  
  class Axis < JsonObject
    attr_accessor :stroke, :colour, :grid_colour
  end
  
  
  class XAxis < Axis
    attr_accessor :tick_height, :labels
  end
  
  class YAxis < Axis
    attr_accessor :offset, :max, :tick_length
  end
  
  class Chart < JsonObject
    attr_accessor :title, :elements
    
    def initialize(title = nil, &block)
      if title.is_a? String
        @title = Text.new(title)
      else
        @title = title
      end
      
      self.instance_eval(&block)
    end
    
    
    def title(title, style = nil)
      self.title = Text.new(title, style)
    end
    
    def title=(value)
      if value.is_a? String
        @title = Text.new(title)
      else
        @title = value
      end
    end
    
    
  end
  
end

def EzChart(*args, &block)
  EzChart::Chart.new(*args, &block)
end

chart = EzChart do
  title 'foo', 'font-size: 20px'
  
end

puts chart.to_json