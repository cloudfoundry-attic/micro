Dir["#{File.dirname(__FILE__)}/route/**/*.rb"].each do |f|
  require f.sub(/.rb$/, '')
end
