node[:deploy].each do |application, deploy_item|

  puts application.inspect.to_s
  puts deploy_item.inspect.to_s
	execute "Lib folder shortcut" do
	  command "ls"
	  action :run
	end

end
