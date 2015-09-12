#!/usr/bin/ruby
args = Hash[ ARGV.join(' ').scan(/--?([^=\s]+)(?:=(\S+))?/) ]

login = 'login' #replace with your Apple ID
password = 'password' #replace with your password
bundle_id = 'bundle_id' #replace with app bundle id
profile_name = 'profile_name' #repalce with profile name

exec_string = "./ss_add_device.rb -l=" + login + " -p=" + password + " -b=" + bundle_id + " -pn=" + profile_name

if args['d']
	exec_string = exec_string + " " + "-d=" + args['d']
end
if args['u']
	exec_string = exec_string + " " + "-u=" + args['u']
end

Kernel.exec(exec_string)