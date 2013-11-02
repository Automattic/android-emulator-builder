# Android Emulator Builder

Android Emulator Builder is a ruby script designed to quickly install a set of pre-configured emulators of popular Android devices.

Created emulators match the screen size and pixel density of their target devices based on device information available on Wikipeda.

- [List of displays by pixel density](http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density)
- [Comparison of Android devices](http://en.wikipedia.org/wiki/Comparison_of_Android_devices)

Other hardware settings are based on common configuration. The reasoning behind this is to create emulators with tolerable performance and still be reasonably useful for testing web and app UIs.

##Requirments:
Running this script requires:

- Mac OS X
- Ruby 1.9.x or later
- An internet connection.
- An installed copy of the [Android SDK](http://developer.android.com/sdk/index.html)

##Usage

1. Download and unzip this project or clone the repo 
2. Launch a terminal window
3. cd to where the script is located
4. Run the script in a terminal window by typing 

	$> ruby emulators.rb

###Configuring Emulators

The normal operation of the script is to configure a stock set of emulators. You will be prompted to confirm this action. The script will inspect your local copy of the Android SDK and attempt to install any missing packages.  Finally it will configure the emulators, and launch the Android Virtual Device manager.
Note that running this script will overwrite any previously created emulators with the same name.

###Installing WordPress for Android

If you run this script while there is a running emulator, you will be prompted to install the latest copy of WordPress for Android.  If you answer (y) the application .apk will be downloaded to your working directory and installed in the running emulator. Once its installed it will be launched automatically.


##Wish List
Somethings that might be nice to have in future versions. 

- Build a single, specific emulator and install its apps.
- Install Simplenote for Mac
- Support for x86 architecture (once its fixed for Mavericks)
- Automagically install the Android SDK if its missing and a package manager like Brew is available. 
