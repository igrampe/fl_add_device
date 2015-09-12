#!/usr/bin/ruby
require "spaceship"

args = Hash[ ARGV.join(' ').scan(/--?([^=\s]+)(?:=(\S+))?/) ]

def ss_add_device(device_name, udid)
	Spaceship.device.create!(name: device_name, udid: udid)	
end

def ss_replace_profile(profile, new_device)
	print "Updating profile\n"
	profiles_dir = '~/Library/MobileDevice/Provisioning\ Profiles/'
	exec_delete_old = 'rm ' + profiles_dir
	exec_delete_old = exec_delete_old + profile.uuid + '.mobileprovision'

	certificate = profile.certificates.first

	devices = profile.devices
	devices.push(new_device)
	
	profile.delete!
	new_profile = Spaceship::Portal::ProvisioningProfile::AdHoc::create!(
		name: profile.name, 
		bundle_id: profile.app.bundle_id, 
		certificate: certificate, 
		devices: devices)

	new_file_name = new_profile.uuid + '.mobileprovision'
	File.write(new_file_name, new_profile.download)
	exec_move = 'mv ' + new_file_name + " " + profiles_dir + new_file_name

	print 'Created: ' + new_profile.uuid + "\n"
	Kernel.exec(exec_move + ' && ' + exec_delete_old)
end

def ss_create_profile(bundle_id, profile_name)
	print "Creating profile\n"
	certificates = Spaceship.certificate.production.all
	profile = Spaceship.provisioning_profile.ad_hoc.create!(
		bundle_id: bundle_id,
		certificate: certificates,
		name: profile_name)
end

def ss_update_profile(bundle_id, profile_name, device)
	profiles_adhoc = Spaceship.provisioning_profile.ad_hoc.find_by_bundle_id(bundle_id)	
	existing_profile = Spaceship::Portal::ProvisioningProfile
	profile_exists = false

	profiles_adhoc.each do |profile|		
		if profile.name == profile_name
			existing_profile = profile
			profile_exists = true
		end
   	end

   	if !profile_exists
   		print "Warning: there is no such profile\n"
   		ss_create_profile(bundle_id, profile_name)
   	else
   		ss_replace_profile(existing_profile, device)
   	end
end

def ss_try_add_device(login, password, device_name, udid, bundle_id, profile_name)	
	print "login: " + login + "\n" + "bundle_id: " + bundle_id + "\n" + "device name: " + device_name + "\n" + "udid: " + udid + "\n"

	Spaceship.login(login, password)
	all_devices = Spaceship.device.all
	device_exists = false
	new_device = Spaceship::Portal::Device
	all_devices.each do |device|
		if udid == device.udid
			device_exists = true
			new_device = device
		end   	
   	end

   	if device_exists   		
   		print "device " + device_name + " already exists\n"
   	else
   		ss_add_device(device_name, udid, bundle_id)
   	end   	

   	ss_update_profile(bundle_id, profile_name, new_device)
end

if !args['l']
	print "add login -l=login\n"
elsif !args['p']
	print "add password -p=password\n"
elsif !args['d']
	print "add device_name (without spaces) -d=device_name\n"
elsif !args['u']
	print "add udid -u=udid\n"
elsif !args['b']
	print "add bundle_id -b=bindle_id\n"
elsif !args['pn']
	print "add profile_name -pn=profile_name\n"	
else
	ss_try_add_device(args['l'], args['p'], args['d'], args['u'], args['b'], args['pn'])
end