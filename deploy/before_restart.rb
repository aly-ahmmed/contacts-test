node[:deploy].each do |application, deploy_item|

  if deploy_item[:domains].map{|d| d.include? 'tayaservice.com'}.include? true
    puts deploy_item[:rails_env].inspect.to_s
    ENV['CDN_YAHKI2'] = 'cdn2.yahki.com'
  end
	execute "Lib folder shortcut" do
	  environment 'CDN_YAHKI' => "cdn.yahki.com"
	  command "ls"
	  action :run
	end

end
