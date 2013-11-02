#!/usr/bin/env ruby
require 'yaml'

# Configure a stock set of Android Emulators based on settings defined in emulators.yml. 
# Emulators use the same hardware settings with the exception of screen size, and density.
class EmulatorBuilder
  
  @@packages = [
    'Android SDK Tools, revision 22.2.1',
    'Android SDK Platform-tools, revision 18.0.1',
    'Android SDK Build-tools, revision 18.1.1',
    'SDK Platform Android 4.3, API 18, revision 2',
    'Google APIs, Android API 18, revision 3',
    'SDK Platform Android 4.0.3, API 15, revision 3',
    'Google APIs, Android API 15, revision 2',
    'SDK Platform Android 2.3.3, API 10, revision 2',
    'Google APIs, Android API 10, revision 2'
  ]
  
  
  @@config = [
    'skin.dynamic=yes',
    'hw.accelerometer=yes',
    'hw.audioInput=yes',
    'hw.battery=yes',
    'hw.camera.back=none',
    'hw.camera.front=none',
    'hw.dPad=yes',
    'hw.gps=yes',
    'hw.keyboard=yes',
    'hw.mainKeys=yes',
    'hw.ramSize=1024',
    # 'hw.sdCard=no',
    'hw.sensors.orientation=yes',
    'hw.sensors.proximity=yes',
    'hw.trackBall=no',
    'vm.heapSize=128'
  ]
  
  
  def init
    check_sdk

    # If an emulator is running prompt to install the latest apk.
    if @adb_path
      str = `#{@adb_path} devices`
      str = str.strip.split("\n").pop
      if str.include?("emulator")
        install
        return
      end
    end
    
    build
  end


  def build
    puts "\n\nHi there!\n\n" 
    puts "Running this script will set up some preconfigured Android emulators."
    puts "Any required components (like the Android SDK) will also be downloaded and configured."
    puts "It might take a while. ;)\n\n"
    puts "Do you want to continue? y/n :"

    proceed = gets.strip
    if proceed != "y"
      puts "\nBye\n\n"
      return
    end
    
    puts "\nGreat! Getting started.\n\n"
    
    if @sdk_path.nil?
      puts "\nAndroid SDK missing. Please install the Android SDK."
      return
      # TODO
      # install_sdk
    end
    
    packages = check_missing_components
    if (packages.length > 0)
      install_missing_components(packages)
    end

    puts "Configuring Virtual Devices..."
    configure_emulators
    
    puts "Finished"
    spawn "#{@sdk_path} avd" #launch the virtual device manager
    
  end


  # Check the specified path for the location of the Android SDK.
  # Returns a matching substring or nil.
  def check_sdk_path(path)
    if path.nil?
      return;
    end
    
    users_dir = '/Users'
    sdk_dir = 'android-sdks'
    android_path = '/tools/android'
    adb_path = '/platform-tools/adb'
    
    idx = path.rindex(sdk_dir)
    if idx.nil?
      return
    end
    path = path[0, idx + sdk_dir.length]

    idx = path.rindex(users_dir)
    path = path[idx, path.length]
    
    if !File.directory?(path)
      return
    end
    
    tool_path = path + android_path
    if File.exists?(tool_path)
      @sdk_path = tool_path
    end
    
    tool_path = path + adb_path
    if File.exists?(tool_path)
      @adb_path = tool_path
    end
    
  end

  
  # Look for the SDKs Android tool
  def check_sdk
    puts "Looking for the Android SDK"

    # Look for the Android SDK. If we can't find it, ask for one. 
    check_sdk_path(`which android`)

    if @sdk_path.nil?
      locations = `locate "android-sdks/tools/android"`
      if locations.length > 0
        check_sdk_path(locations.split("\n").pop)
      end
    end

    if @sdk_path.nil?
      check_sdk_path(ENV['ANDROID_HOME'])
    end

    if @sdk_path.nil?
      check_sdk_path(ENV['PATH'])
    end
    
    if @sdk_path.nil?
      #hail mary
      check_sdk_path(ENV['HOME'] + '/android-sdks')
    end
    
  end
  
  
  # Check installed packages an confirm we have everything we need to build our emulators. 
  def check_missing_components
    puts "Checking installed components... \n"
    
    arr = []
    unpkgs = `#{@sdk_path} list sdk -u`
    unpkgs = unpkgs[unpkgs.index('Packages available for installation'), unpkgs.length]
    pkgs = unpkgs.split("\n")

    # for each uninstalled package, check it against our list of required packages. 
    # if found, save its id, we need to install it
    for item in pkgs
      for pkg in @@packages
        if item.index(pkg)
          arr << item.strip.to_i.to_s
          break
        end
      end
    end
    
    arr
  end
  
  
  # Try to install any missing packages
  def install_missing_components(packages)
    puts "Installing missing packages...\n\n"
    packages = packages.join(",")
    system("#{@sdk_path} update sdk --no-ui --filter #{packages}")
  end
  
  
  # Configure emulators.  Overwrites existing emulators with the same name.
  def configure_emulators
    emulators = YAML::load_file(File.join(File.dirname(File.expand_path(__FILE__)), 'emulators.yml'))
    # create each emulator in the list
    # after the emulator is created, edit its config to use our desired settings
    for emulator in emulators
      puts "Configuring : #{emulator['name']}\n"
      args = " --abi #{emulator['abi']} --skin #{emulator['skin']} --target #{emulator['target']} --name #{emulator['name']}"
      # Echo no, to decline setting up a custom hardware profile. 
      `echo no | android create avd --force --sdcard 10M #{args}`
      update_emulator_config(emulator)
    end
  end


  # Updates the emulator's config.ini with the desired settings.
  def update_emulator_config(emulator)
    # find the config file for the emulator
    path = ENV['HOME'] + '/.android/avd/' + emulator['name'] + '.avd/config.ini'
    if !File.exists?(path)
      return
    end
    
    # prep the config
    str = ''
    config = emulator['config']
    config.each {|k,v|
      str = str + "\n#{k}=#{v}"
    }

    doc = @@config.join("\n")
    doc = doc + str
    
    # open for appending
    File.open(path, 'a') { |f|
      f.write(doc)
    }
  end


  # Install the latest version of WordPress for Android on a running emulator
  def install
    puts "\n\nHi there!\n\n" 
    puts "I've detected a running emulator."
    puts "Would you like to install the latest version of WordPress or Android? y/n"

    proceed = gets.strip
    if proceed != 'y'
      puts "\nBye\n\n"
      return
    end
    
    puts "Downloading WordPress for Android \n"
    system("curl -o wpandroid.apk http://iosbuilds.automattic.com/builds/android/latest.apk")
    
    puts "Installing WordPress for Android \n"
    system("#{@adb_path} install wpandroid.apk")
    
    system("#{@adb_path} shell am start -n org.wordpress.android/org.wordpress.android.ui.posts.PostsActivity")
    puts "Finished"
  end


end

builder = EmulatorBuilder.new
builder.init
