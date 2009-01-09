# Include hook code here
require 'ezchart'
ActionController::Base.class_eval do
  def EzChart(*args, &block)
    ::EzChart::Chart.new(*args, &block)
  end
end