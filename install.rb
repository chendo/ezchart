PLUGIN_ROOT = File.dirname(__FILE__) + '/../'
FileUtils.cp "#{PLUGIN_ROOT}requirements/open-flash-chart.swf", "#{RAILS_ROOT}/public", :verbose => true
FileUtils.cp "#{PLUGIN_ROOT}requirements/swfobject.js", "#{RAILS_ROOT}/public/javascripts", :verbose => true