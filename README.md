# HouseKeeperApp-1.0
A Logscape App that monitors directories and deletes specified files that reach a certain age

###########################################################################################################
#  HouseKeeperApp-1.0
#  Creator: Ben Newton
#  Contact: ben.newton@excelian.com
#
###########################################################################################################

This is a Housekeeping app designed to interact with Logscape. It will monitor the files on the system and remove them when they reach a certain age. 

For every folder, you may specify the following parameters. 

Name: The nickname of the folder, anything you like but it MUST be unique. (REQUIRED)
Target Folder: The path of the folder you wish to monitor. This may be relative or absolute. You MUST use forward slashes, even if it is a Windows Path - because the Java Properties method escapes back slashes. (REQUIRED)

Extensions: The pattern within the file that shoud be cleaned up. For example, to clean dummy.hprof, you might use .hprof. This scans the filename only, so it can be any part of the filename, again aim for uniqueness. (OPTIONAL - If not used, will use "." as the default.)

Time Limit: How old in minutes the file should be before it's deleted. (OPTIONAL - Default is 1440 minutes, which is 24 hours)

Recursion: Should child folders be scanned and cleaned as well. (OPTIONAL - Default is false. To active, use true)


You set these parameters in a .properties file, which must be stored in the lib folder. The default file is config.properties, you may use any name you wish.  

Within the file, you must provide JSON strings that allow the script to determine the correct parameters to apply. 

Here is an example contents:

targets={ "TESTNICK":"C:/Users/IDIOT/Testfolder","TESTNICK2":"C:/Users/IDIOT/AnotherTestfolder" }
extensions={ "TESTNICK":".hprof" }
timelimit={ "TESTNICK":"60" }
recursion={ "TESTNICK:"true"}

In this example, the TESTNICK directory and all subdirectories will be cleaned of any file labelled .hprof that goes 60 minuts without being modified. However, the TESTNICK2 directory will be cleaned of all filenames including a . once they go 24 hours without being modified. the folder TESTNICK2/SAFE however would remain untouched.   

Using this with Logscape, you will need to check the HouseKeeperApp-1.0.bunle file, which tells Logscape which hosts to run. Here is an example of a bundle you might wish to use:

<Bundle name="HouseKeeperApp" version="1.0" system="false">
  <status>UNINSTALLED</status>
  <owner>ben.newton@excelian.com</owner>
  <services>
    <Service>
    <name>HouseKeeper</name>
  	<resourceSelection>type containsAny WINDOWS</resourceSelection>
    <fork>true</fork>
    <background>true</background>
  	<instanceCount>-1</instanceCount>
  	<pauseSeconds>600</pauseSeconds>
    <script>HouseKeeper.groovy config.properties</script>
	</Service>  
	</services>
</Bundle>

You'll notice that you must specify which .properties file is to be used for each instance but you don't need to inform it that it will be in the lib folder. 

Fields.config is simply a Logscape config file, which will capture the logging and allow you to monitor which files have been removed on Logscape. 

