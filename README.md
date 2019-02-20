VolAuto is a simple tool for Unix/Linux that performs automatic execution of Volatility, using common Windows plugins and explodes results in separate files (named with "DATE_HOUR").<br />
VolAuto can save your time and ease exploitation of results, for example using scripts to check basics or correlate different plugins results.
<br /><br />
Prerequisites:<br />
	- You need to install "Volatility" (http://www.volatilityfoundation.org)<br />
	- Have enough free disk space to store extractions (recommended 100 GB)<br />
<br /><br />
```
Usage: $0 [OPTION] <DUMP_FULLPATH>
If no option is specified, VolAuto will execute all plugins, EXCEPT dump plugins (memdump, procdump, dlldump, malfind, dumpregistry or modump) which can take several hours.

Option list:
	-h,--help	Display this help message
	-v,--version	Display the program version
	-q,--quick	Run a quick execution and don't perform any dump plugins or long time plugins (apihooks, shellbags and autoruns) and those listed before
	-f,--full	Run a complete execution, including dump plugins (be sure you have enough disk space)
	-r,--rest	Run an additional scan for quick mode. Indeed, quick scan + rest scan = full scan

	-a,--auto	You will enter in the full auto mode. This mode can perform ALL dump files (.pmem) located in the specified folder, but you must respect a very drastic syntax!!!
			Results will be written on separate folders named with "DATE_HOUR_FileDumpName/"
			We are aware about many improvements on this mode. You can help reporting issues or errors. Thank you!
			Contact: 1csi8rt(at)ge4ma5lto.co9m (remove numbers)

Basic use:
Example: $0 /home/user/case/dumpfile.pmem				// DEFAULT mode to specified dumpfile. Mode interactive (you will be prompted for choices)
Example: $0 --quick /home/user/case/dumpfile.pmem			// QUICK mode to specified dumpfile. Mode interactive (you will be prompted for choices)
Example: $0 -f /home/user/case/dumpfile.pmem			// FULL mode to specified dumpfile. Mode interactive (you will be prompted for choices)
Example: $0 --rest /home/user/case/dumpfile.pmem			// ADDITIONAL mode to specified dumpfile. Mode interactive (you will be prompted for choices)

Advance use: (all parameters are required)
Example: $0 --auto </my/dumps/folder/> </my/main/folder/results/> </my/volatility/vol.py>  [--hash|--nohash]  [--mono|--multi]

Required arguments:
	- </my/dumps/folder/>		The main DIRECTORY containing all the dumps you want to analyze
	- </my/main/folder/results/>	The output DIRECTORY for your results
	- </my/volatility/vol.py>		The full path of your Volatility binary files (SIFT/REMNux default path is /usr/bin/vol.py)
 	- [--hash|--nohash]		If you want (or not) to compute hash values for analyzed dumps
	- [--mono|--multi]		If you want (or not) to use multithreading mode
* AUTO mode. Be sure about your inputs (you will NOT be prompted)
```
<br /><br />
Tips:<br />
To facilitate use of this tool, you should rename the file as "volauto" and copy/move it to your "/bin" folder.
