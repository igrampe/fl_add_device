# fl_add_device

This is tool to add new devices to provisioning profile in one line.

At first, you need to install [Spaceship](https://github.com/fastlane/spaceship)

####NOTE: Do not use spaces in parameters

In add_device.rb replace:
* `login` with your Apple ID
* `password` with your password
* `bundle_id` with app bundle id
* `profile_name` with provisioning profile name

then run  
add_device.rb -d=`device_name` -u=`device_udid`
