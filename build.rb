require 'sequel'

class Build

  attr_reader :filename
  attr_reader :link
  attr_reader :notes

  def initialize(filename, base_url) 

	plist_base_url = "#{base_url}/plist/" #this links will answer to plist requests
  	@filename = filename
  	@link = "itms-services://?action=download-manifest&url=#{plist_base_url}#{filename}"
  	
  	stored_build = DB.from(:builds).where(:build => filename).first
  	@notes = stored_build[:notes] if stored_build
  end
end