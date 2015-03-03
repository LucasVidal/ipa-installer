require 'sinatra/base'

class App < Sinatra::Base

  configure do
    #The public addres where the devices will be downloading the ipas. 
    #Must have ssl enabled
    set :ipa_url_prefix, "https://dl.dropboxusercontent.com/u/22381470/releases-redo/"

    #The local folder where the ipas are located
    set :local_folder, "/Users/lucasvidal/Dropbox/Public/releases-redo" 

    #plist metadata
    set :bundle_id, "com.restorando.iphone"
    set :app_name, "Redo iOS beta"
  end

  get "/" do
  	@files = find_files
  	haml :'index', layout: :application
  end

  get "/plist/:name" do
    @destination = "#{settings.ipa_url_prefix}#{params[:name]}.ipa"
    @app_name = settings.app_name + " #{params[:name]}"
    erb :'plist'
  end

  def find_files 
    files = Dir["#{settings.local_folder}/*.ipa"].each.map { 
      |f| item_for(File.basename(f, ".ipa")) #return only filenames without extension
    } 
  end

  def item_for(f) 
    plist_base_url = "#{base_url}/plist/" #this links will answer to plist requests
    hash = {}
  	hash[:filename] = f
  	hash[:link] = "itms-services://?action=download-manifest&url=#{plist_base_url}#{f}"
    hash
  end

  def base_url
    #force base_url to have https instead of using request.env['rack.url_scheme']
    @base_url ||= "https://#{request.env['HTTP_HOST']}"
  end
end
