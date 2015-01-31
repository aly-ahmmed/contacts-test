node[:deploy].each do |application, deploy_item|

  application.inspect
  deploy_item.inspect
	execute "Lib folder shortcut" do
	  command "ls"
	  action :run
	end

end
