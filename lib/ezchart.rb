require 'json'

module EzChart
  def self.included(controller)
    controller.send :include, Helper
  end
  module Helper
    
    def ezchart(path, width = 600, height = 350)
      <<-EOS
      <div id="ezchart_#{id = rand(100000)}"></div>
      <script type="text/javascript">
         swfobject.embedSWF(
         "/open-flash-chart.swf","ezchart_#{id}",
         "#{width}", "#{height}", "9.0.0", "expressInstall.swf",
         {"data-file":"#{path}.json"} );
       </script>
       EOS
    end
  end
  
  class JsonObject
    def initialize(*args, &block)
      if (data = args.first).is_a? Hash
        data.each do |k, v|
          instance_variable_set("@#{k}", v)
        end
      end
      self.instance_eval(&block) if block_given?
    end
    
    def to_json(*args)
      out = {}
      @ignored_attributes ||= []
      
      (instance_variables.map { |ivar| ivar[1..-1] } - ['ignored_attributes'] - @ignored_attributes).each do |ivar|
        if value = instance_variable_get("@#{ivar}")
          out[ivar.gsub(/_(size|angle)/, '-/1')] = value 
        end
      end
      out.to_json(*args)
    end
    
    def self.attribute(*args)
      args.each do |attribute|
        class_eval <<-EOS
          def #{attribute}(value = nil)
            if value
              @#{attribute} = value
            else
              @#{attribute}
            end
          end

          def #{attribute}=(value)
            @#{attribute} = value
          end
        EOS
      end
    end
  end
  
  class Text < JsonObject
    attribute :text, :style
    def initialize(text, style = nil, &block)
      @text = text
      @style = style
      
      super
    end
    
    def to_s
      @text
    end
    
  end
  
  class Label < JsonObject
    attribute :text, :colour, :size
    
    def initialize(text)
      @text = text
      super
    end
    
  end
  
  class Labels < JsonObject
    attribute :steps, :rotate, :colour, :size, :labels
    def initialize(data, &block)
      @labels = data
      super
    end
    
    # def labels(data)
    #   @labels = data
    # end
  end
  
  class Axis < JsonObject
    attribute :stroke, :colour, :grid_colour, :labels, :min, :max, :offset
    
    def labels(*args, &block)
      @labels = Labels.new(*args, &block)
    end
    
  end
  
  
  class XAxis < Axis
    attribute :tick_height
  end
  
  class YAxis < Axis
    attribute :tick_length
  end
  
  class Element < JsonObject
    attribute :type, :alpha, :font_size, :values
    
    def initialize(title = nil, &block)
      @title = title
      @values = []
      super
    end
    
    def value(data)
      @values << data
    end
    
  end
  
  class Line < Element
    attribute :dot_size, :text, :width
    def initialize(*args, &block)
      @type = 'line'
      super
    end
  end
  
  class LineDot < Element
    attribute :dot_size, :text, :width
    def initialize(*args, &block)
      @type = 'line_dot'
      super
    end
  end
  
  class Bar < Element
    attribute :text, :colour
    def initialize(*args, &block)
      @type = 'bar'
      super
    end
    
    def value(data, text = nil)
      if text
        @values << {'value' => data, 'text' => text}
      else
        @values << data
      end
    end
  end
  
  class Hbar < Element
    def initialize(*args, &block)
      @type = 'bar'
      super
    end
    
    def left(value)
      @values << {'left' => value}
    end
    
    def right(value)
      @values << {'right' => value}
    end
    
  end

  class Pie < Element
    attribute :start_angle, :animate, :colours, :stroke
    def initialize(*args, &block)
      @type = 'bar'
      super
    end
  end
    
    
  
  class Chart < JsonObject
    attribute :elements
    
    def initialize(title = nil, &block)
      if title.is_a? String
        @title = Text.new(title)
      else
        @title = title
      end
      @elements = []
      super
    end
    
    %w(bar pie line line_dot line_hollow).each do |type|
      eval <<-EOS
        def #{type}(*args, &block)
          @elements << #{type.classify}.new(*args, &block)
        end
      EOS
    end
    
    %w(x_axis y_axis).each do |type|
      eval <<-EOS
        def #{type}(*args, &block)
          @#{type} = #{"#{type}s".classify}.new(*args, &block)
        end
      EOS
    end
    
    %w(title y_legend).each do |attribute|
      eval <<-EOS
        def #{attribute}(#{attribute} = nil, style = nil)
          !#{attribute} ? @#{attribute} : (@#{attribute} = Text.new(#{attribute}, style))
        end
    
        def #{attribute}=(value)
          if value.is_a? String
            @#{attribute} = Text.new(value)
          else
            @#{attribute} = value
          end
        end
      EOS
    end
    
    
  end  
end

ActionController::Base.send(:instance_eval) do
  def EzChart(*args, &block)
    EzChart::Chart.new(*args, &block)
  end
  helper EzChart::Helper
  
end

