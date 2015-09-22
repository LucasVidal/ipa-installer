require 'sinatra/base'
require 'sinatra/reloader'
require './build.rb'

DB = Sequel.sqlite('ipa-installer-database.sqlite3')

class App < Sinatra::Base
  register Sinatra::Reloader
  also_reload './build.rb'

  configure do
    #The public addres where the devices will be downloading the ipas. 
    #Must have ssl enabled
    set :ipa_url_prefix, "https://dl.dropboxusercontent.com/u/22381470/restobuilds/"

    #The local folder where the ipas are located
    set :local_folder, "/Users/devsrestorando/Dropbox/builds"

    #plist metadata
    set :bundle_id, "com.restorando.redo-iphone"
    set :app_name, "Redo iOS beta"
  end

  get "/" do
  	@files = find_files
  	haml :'index', layout: :application
  end

  get "/build/:filename/note" do 
    @build = Build.new(params[:filename], base_url)
    haml :'build', layout: :application
  end

  post "/build/:filename/note" do 
    dataset = DB.from(:builds).where(:build => params[:filename])
    if dataset.empty?
      dataset.insert({:build => params[:filename], :notes => params[:notes]})
    else
      dataset.update(:notes => params[:notes])
    end
    redirect "/"
  end

  get "/plist/:name" do
    @destination = "#{settings.ipa_url_prefix}#{params[:name]}.ipa"
    @app_name = settings.app_name + " #{params[:name]}"
    erb :'plist'
  end

  def find_files 
    files = Dir["#{settings.local_folder}/*.ipa"]
    .sort_by { |x| File.mtime(x) }.reverse
    .each.map { 
      |f| Build.new(File.basename(f, ".ipa"), base_url) #return only filenames without extension
    } 
  end

  def base_url
    #force base_url to have https instead of using request.env['rack.url_scheme']
    @base_url ||= "https://#{request.env['HTTP_HOST']}"
  end
end
