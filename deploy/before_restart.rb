node[:deploy].each do |application, deploy_item|

  puts deploy_item[:rails_env].inspect.to_s
	execute "Lib folder shortcut" do
	  command "ls"
	  action :run
	end

end
