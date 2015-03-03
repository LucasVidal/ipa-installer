# .ipa installer
Simple Web server that exposes local .ipa files synched with dropbox to allow devices to make OTA installs

Setup your data like this

    configure do
      #The public addres where the devices will be downloading the ipas. 
      #Must have ssl enabled
      set :ipa_url_prefix, "https://dl.dropboxusercontent.com/u/22381470/releases-redo/"

      #The local folder where the ipas are located
      set :local_folder, "~/Dropbox/Public/releases-redo" 

      #plist metadata
      set :bundle_id, "com.restorando.iphone"
      set :app_name, "Redo iOS beta"
    end

To run it simply execute

    bundle install
    rackup -o 0.0.0.0

And then expose your open server with any service that allows you to reverse-proxy with ssl, like ngrok

    ngrok -subdomain=[your-subdomain] 9292