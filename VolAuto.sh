#!/bin/bash
echo "										 ";
echo "										 ";
echo " __      __   _               _                                        	 ";
echo " \ \    / /  | |   /\        | |                                       	 ";
echo "  \ \  / /__ | |  /  \  _   _| |_ ___                                  	 ";
echo "   \ \/ / _ \| | / /\ \| | | | __/ _ \                                 	 ";
echo "    \  / (_) | |/ ____ \ |_| | || (_) |                                	 ";
echo "     \/ \___/|_/_/    \_\__,_|\__\___/                                 	 ";
echo "    __             ________________        ________________  ______	 ";
echo "   / /_  __  __   / ____/_  __/ __ \      / ____/ ____/ __ \/_  __/	 ";
echo "  / __ \/ / / /  / / __  / / / / / /_____/ /   / __/ / /_/ / / /   	 ";
echo " / /_/ / /_/ /  / /_/ / / / / /_/ /_____/ /___/ /___/ _, _/ / /    	 ";
echo "/_.___/\__, /   \____/ /_/  \____/      \____/_____/_/ |_| /_/     	 ";
echo "      /____/                                                      	 ";
echo "										 ";
echo "										 ";

# CREATE A FONCTION TO DISPLAY THE RESULT OF EACH PLUGIN IN SHELL AND INTO LOG FILE
checkStatus()
	{
	if [ $? == 0 ]; then
		echo -e "[\033[32mFINISHED\033[0m]"
	else
		echo -e "[ \033[31mFAILED\033[0m ]"
	fi
	}

# DEFINE AVAILABLE PROFILES IN VARIABLE FOR LATER CALLS
profilelist="VistaSP0x64, VistaSP0x86, VistaSP1x64, VistaSP1x86, VistaSP2x64, VistaSP2x86, Win10x64, Win10x86, Win2003SP0x86, Win2003SP1x64, Win2003SP1x86, Win2003SP2x64, Win2003SP2x86, Win2008R2SP0x64, Win2008R2SP1x64, Win2008SP1x64, Win2008SP1x86, Win2008SP2x64, Win2008SP2x86, Win2012R2x64, Win2012x64, Win7SP0x64, Win7SP0x86, Win7SP1x64, Win7SP1x86, Win81U1x64, Win81U1x86, Win8SP0x64, Win8SP0x86, Win8SP1x64, Win8SP1x86, WinXPSP1x64, WinXPSP2x64, WinXPSP2x86, WinXPSP3x86"

# TEXT EFFECTS FOR INTERACTION AND HTML
bold=$(tput bold)
normal=$(tput sgr0)
TextColour="F89406"
Timestamp=$(date "+%Y%m%d_%H%M%S")

# CHECK FOR ARGUMENTS CONTEXT AND VIABILITY
if [ -z "$1" ]; then
	echo -e "	[\033[31mERROR\033[0m] No dump file was specified. Please, be sure a dump file with is FULLPAH is specified (ex: $0 /home/user/case/dumpfile.pmem)"
	echo ""
	exit 1
elif [[ $1 =~ ^-h$|^--help$ ]]; then
	echo "VolAuto is a simple tool for Unix/Linux that performs automatic execution of Volatility, using common Windows plugins and explodes results in separate files (named with \"DATE_HOUR\")."
	echo "VolAuto can save your time and ease exploitation of results, for example using scripts to check basics or correlate different plugins results."
	echo ""
	echo "Prerequisites:"
	echo "	- You need to install \"Volatility\" (http://www.volatilityfoundation.org)"
	echo "	- Have enough free disk space to store extractions (recommended 100 GB)"
	echo ""
	echo "Usage: $0 [OPTION] <DUMP_FULLPATH>"
	echo "If no option is specified, VolAuto will execute all plugins, EXCEPT dump plugins (memdump, procdump, dlldump, malfind, dumpregistry or modump) which can take several hours."
	echo ""
	echo "Option list:"
	echo "	-h,--help	Display this help message"
	echo "	-v,--version	Display the program version"
	echo "	-q,--quick	Run a quick execution and don't perform any dump plugins or long time plugins (apihooks, shellbags and autoruns) and those listed before"
	echo "	-f,--full	Run a complete execution, including dump plugins (be sure you have enough disk space)"
	echo "	-r,--rest	Run an additional scan for quick mode. Indeed, quick scan + rest scan = full scan"
	echo ""
	echo "	-a,--auto	You will enter in the full auto mode. This mode can perform ALL dump files (.pmem) located in the specified folder, but you must respect a very drastic syntax!!!"
	echo "			Results will be written on separate folders named with \"DATE_HOUR_FileDumpName/\""
	echo "			We are aware about many improvements on this mode. You can help reporting issues or errors. Thank you!"
	echo "			Contact: 1csi8rt(at)ge4ma5lto.co9m (remove numbers)"
	echo ""
	echo "Basic use:"
	echo "Example: $0 /home/user/case/dumpfile.pmem				// DEFAULT mode to specified dumpfile. Mode interactive (you will be prompted for choices)"
	echo "Example: $0 --quick /home/user/case/dumpfile.pmem			// QUICK mode to specified dumpfile. Mode interactive (you will be prompted for choices)"
	echo "Example: $0 -f /home/user/case/dumpfile.pmem			// FULL mode to specified dumpfile. Mode interactive (you will be prompted for choices)"
	echo "Example: $0 --rest /home/user/case/dumpfile.pmem			// ADDITIONAL mode to specified dumpfile. Mode interactive (you will be prompted for choices)"
	echo ""
	echo "Advance use: (all parameters are required)"
	echo "Example: $0 --auto </my/dumps/folder/> </my/main/folder/results/> </my/volatility/vol.py>  [--hash|--nohash]  [--mono|--multi]"
	echo ""
	echo "Required arguments:"
	echo "	- </my/dumps/folder/>		The main DIRECTORY containing all the dumps you want to analyze"
	echo "	- </my/main/folder/results/>	The output DIRECTORY for your results"
	echo "	- </my/volatility/vol.py>		The full path of your Volatility binary files (SIFT/REMNux default path is /usr/bin/vol.py)"
	echo " 	- [--hash|--nohash]		If you want (or not) to compute hash values for analyzed dumps"
	echo "	- [--mono|--multi]		If you want (or not) to use multithreading mode"
	echo "* AUTO mode. Be sure about your inputs (you will NOT be prompted)"
	echo ""
	echo "Tips:"
	echo "To facilitate use of this tool, you should rename the file as \"volauto\" and copy/move it to your \"/bin\" folder."
	echo ""
	exit 0
elif [[ $1 =~ ^-v$|^--version$ ]]; then	
	echo "Dec/2017 - version 1.0"
	echo "GTO-CERT - https://www.gemalto.com/csirt"
	exit 0
elif [[ $1 =~ ^-q$|^--quick$ ]] && [ -n "$2" ]; then
	option="quick"
elif [[ $1 =~ ^-q$|^--quick$ ]] && [ -z "$2" ]; then
	echo -e "	[\033[31mERROR\033[0m] This script is not able to determine the dump file you want to analyse."
	echo "        	Please, retry using a good format (ex: $0 --quick /home/user/case/dumpfile.pmem)"
	exit 1
elif [[ $1 =~ ^-f$|^--full$ ]] && [ -n "$2" ]; then
	option="full"
elif [[ $1 =~ ^-f$|^--full$ ]] && [ -z "$2" ]; then
	echo -e "	[\033[31mERROR\033[0m] This script is not able to determine the dump file you want to analyse."
	echo "        	Please, retry using a good format (ex: $0 --full /home/user/case/dumpfile.pmem)"
	exit 1
elif [[ $1 =~ ^-r$|^--rest$ ]] && [ -n "$2" ]; then
	option="rest"
elif [[ $1 =~ ^-r$|^--rest$ ]] && [ -z "$2" ]; then
	echo -e "	[\033[31mERROR\033[0m] This script is not able to determine the dump file you want to analyse."
	echo "        	Please, retry using a good format (ex: $0 --rest /home/user/case/dumpfile.pmem)"
	exit 1
# Bellow, a special block for auto mode escape
elif [[ $1 =~ ^-a$|^--auto$ ]] && [ -z "$2" ]; then
	echo "Source folder is missing."
	exit 1
elif [[ $1 =~ ^-a$|^--auto$ ]] && [ -z "$3" ]; then
	echo "Destination folder is missing."
	exit 1
elif [[ $1 =~ ^-a$|^--auto$ ]] && [ -z "$4" ]; then
	echo "Volatility binary folder is missing."
	exit 1
elif [[ $1 =~ ^-a$|^--auto$ ]] && [ -z "$5" ]; then
	echo "Checksums computing choice is missing or incorrect."
	exit 1
elif [[ $1 =~ ^-a$|^--auto$ ]] && [ -z "$6" ]; then
	echo "Threading mode choice is missing or incorrect."
	exit 1
elif [[ $1 =~ ^-a$|^--auto$ ]] && [[ $5 =~ ^--hash$|^--nohash$ ]] && [[ $6 =~ ^--multi$|^--mono$ ]]; then
	option="auto"

# If any mode have been specified, apply default mode
elif [[ ! $1 =~ ^-h$|^--help$|^-v$|^--version$|^-q$|^--quick$|^-f$|^--full$|^-r$|^--rest$|^-a$|^--auto$ ]]; then
	option="default"
else
	echo -e "	[\033[31mERROR\033[0m] An error occurred. Please, check the syntax and the dump path. Be sure you specified the FULLPATH and a correct option."
	echo ""	
	exit 1
fi

# STARTING USER INTERACTION PROCESS
# Bellow, the special block for auto mode escape
if [[ $option = "auto" ]]; then
	sleep 0
elif [ $option = "quick" -o $option = "full" -o $option = "rest" ]; then
	read -e -p "${bold}[1/6] - You specify the dump file \"$2\" for analysis. This is correct? [Y/n]${normal} " reply1
	if [[ $reply1 =~ ^[YyOo]$ ]] || [[ -z "$reply1" ]]; then	
		dump="$2"
		echo ""
	elif [[ $reply1 =~ ^[Nn]$ ]]; then
		read -e -p "	Please precise the FULLPATH of the dump you want to analyse: " reply1b
		dump="$reply1b"
		echo ""
	else
		echo -e "	[\033[31mERROR\033[0m] This script is not able to determine the dump file you want to analyse."
		echo "        	Please, retry using a good format (ex: $0 /home/user/case/dumpfile.pmem)"
		echo ""
		exit 1
	fi
elif [[ $option = "default" ]]; then
	read -e -p "${bold}[1/6] - You specify the dump file \"$1\" for analysis. This is correct? [Y/n]${normal} " reply1
	if [[ $reply1 =~ ^[YyOo]$ ]] || [[ -z "$reply1" ]]; then
		dump="$1"
		echo ""
	elif [[ $reply1 =~ ^[Nn]$ ]]; then
		read -e -p "	Please precise the FULLPATH of the dump you want to analyse:" reply1b
		dump="$reply1b"
		echo ""
	else
		echo -e "	[\033[31mERROR\033[0m] This script is not able to determine the dump file you want to analyse."# RESULTS PREPROCESSING OPTION
		echo "        	Please, retry using a good format (ex: $0 /home/user/case/dumpfile.pmem)"
		echo ""
		exit 1
	fi
else
	echo -e "	[\033[31mERROR\033[0m] An error occurred. Please, check the dump path and be sure you specified the FULLPATH."
	echo "        	Check for white space in fullpath and remove it."
	echo ""	
	exit 1
fi

# FILE INTEGRITY CHECK
# Bellow, the special block for auto mode escape
if [[ $option = "auto" ]]; then
	sleep 0
elif [ -a "$dump" ]; then
	type=$(file $dump)
	if [[ $type =~ data$ ]]; then
		sleep 0
	elif [[ $type =~ "Zip archive data," ]]; then
		echo -e "	[\033[31mERROR\033[0m] It seems that the dump file is an AFF4 format. Did you perform it with Rekall? In this case, you must convert it using \"rekall -f <input_file> imagecopy --output-image=<output_file>\"."
		echo ""
		exit 1
	else
		echo -e "	[\033[33mWARNING\033[0m] It seems the dump file is not recognized by Volatility. However, the script will try to scan it as possible."
		echo ""
	fi
	read -e -p "${bold}[2/6] - Do you want to compute checksums? [y/N]${normal} " reply2
	if [[ $reply2 =~ ^[YyOo]$ ]]; then
		echo ""
	elif [[ $reply2 =~ ^[Nn]$ ]] || [[ -z "$reply2" ]]; then
		echo -e "	[\033[33mWARNING\033[0m] Checksums will NOT be computed."
		echo ""
	else
		echo -e "	[\033[31mERROR\033[0m] This script is not able to determine your answer. Please, retry with a correct answer."
		echo ""
		exit 1	
	fi
else
	echo -e "	[\033[31mERROR\033[0m] The file cannot be found. Please, check the dump path and be sure you specified the FULLPATH."
	echo ""
	exit 1
fi

# VOLATILITY BINARY PATH DECLARATION
# You can change this parameter according to your system or preferences
vol1="/usr/bin/vol.py"
vol2="/usr/bin/volatility-2.5"
vol3="/usr/bin/volatility-2.6"

# Bellow, the special block for auto mode escape
if [[ $option = "auto" ]]; then
	vol="$4"
else
	echo "${bold}[3/6] - Please, enter the full path of your Volatility binary:${normal} "
	echo "	[1] --> /usr/bin/vol.py (SIFT/REMNux default path)"
	echo "	[2] --> /usr/bin/volatility-2.5"
	echo "	[3] --> /usr/bin/volatility-2.6"
	echo "	[4] --> Other"
	read -e -p "	Your choice: " reply3
	if [ -z "$reply3" ]; then
		echo -e "	[\033[33mWARNING\033[0m] Your answer is empty. Using the default binary location \"/usr/bin/vol.py\"."
		echo ""
		vol=$vol1
	elif [ $reply3 == "1" ]; then
		vol=$vol1
		echo ""
	elif [ $reply3 == "2" ]; then
		vol=$vol2
		echo ""
	elif [ $reply3 == "3" ]; then
		vol=$vol3
		echo ""
	elif [ $reply3 == "4" ]; then
		echo ""
		read -e -p "	Please, precise the FULLPATH of your binary (without adding \'python\' before): " reply3b
		vol=$reply3b
		echo ""
	else
		echo -e "	[\033[31mERROR\033[0m] This script is not able to determine the path of your Volatility binary."
		echo "		Please, retry using a good format (ex: /opt/volatility/volatility OR /home/user/Desktop/volatility-X.X/vol.py)"
		echo "		You can looking for using \"locate volatility\" or \"whereis vol.py\""
		echo ""	
		exit 1
	fi
fi

# VOLATILITY BINARY CONTROL AND "PYTHON PREFIX" IMPLEMENTATION FOR NON-EXECUTABLE BINARY CONTOURNEMENT
if [[ -a $vol ]]; then
	vol="python $vol"
else
	echo -e "[\033[31mERROR\033[0m] The binary cannot be found. Please, be sure your Volatility binary is correctly defined and you specified its FULLPATH."
	echo ""
	exit 1
fi

# FOLDER RESULT PREPARATION & CONTROL & VIABILITY
# Check write access for user who ran the script
# Bellow, the special block for auto mode escape
if [[ $option = "auto" ]]; then
	path=$3
else
	whoami=$(whoami)
	echo "${bold}[4/6] - Please, specify now the FULLPATH for the folder result:${normal} (be sure you have write access)"
	read -e -p "	Folder results: " path
	if [ $UID == 0  ] || [ $EUID == 0 ]; then
		echo -e "	[\033[33mWARNING\033[0m] It isn't recommended to run this analysis with root privileges."
	elif  [[ $path =~ ^/root/ ]] && ([ ! $UID == 0  ] || [ ! $EUID == 0 ]); then
		echo -e "	[\033[33mWARNING\033[0m] Be sure you have write persmission in root folder."
	else
		echo ""
	fi
fi
# Checking folder location to preserve system and block malicious writes
if [[ $path =~ ^\/bin\/|^\/boot\/|^\/dev\/|^\/etc\/|^\/lib\/|^\/proc\/|^\/sbin\/|^\/usr\/|^\/var\/|^\/$ ]]; then
	echo -e "	[\033[31mERROR\033[0m] You cannot write your results into a system folder or on the root."
	echo ""
	exit 1
else
	sleep 0
fi

# Create result folder recursively and check efficiency
if [[ $path =~ /$ ]]; then
	path=$(echo $path | sed 's/\/$//g')
fi
if [ ! -d $path ]; then
	mkdir -p $path
	if [ $? == 0 ]; then
		echo -e "	[\033[33mWARNING\033[0m] The path \"$path\" did not exist, so VolAuto created it."
		echo ""
	else
		echo -e "	[\033[31mERROR\033[0m] It seems you have not the permission to create the specified folder."
		exit 1
	fi
elif [ -w $path ]; then
	sleep 0
else
	echo -e "	[\033[31mERROR\033[0m] It seems you have not the permission to write into the specified folder."
	echo ""
	exit 1
fi

# Create also a timestamped result folder (except for "auto" mode)
if [[ $option = "auto" ]]; then
	sleep 0
else
	path=$(echo $path/$Timestamp | sed 's/\/$//g')
	mkdir -p $path
fi 
# ENTERING PROFILE DETERMINATION AND SUGGESTION
# Bellow, a special block for auto mode escape
if [[ $option = "auto" ]]; then
	sleep 0
else
	read -e -p "${bold}[5/6] - Do you want the script suggests a profile? [Y/n]${normal} " reply4
	if [[ $reply4 =~ ^[YyOo]$ ]] || [[ -z "$reply4" ]]; then	
		profile=$($vol -f $dump imageinfo > $path/profile.txt 2>&1; grep -iE -o1 "Suggested profile\(s\) : ([a-z0-9]+)(, |$)?" $path/profile.txt | sed "s/Suggested Profile(s) : //g" | sed "s/, //g")
		kdbg=$(grep "KDBG : " $path/profile.txt | sed "s/^.*KDBG : //g" | sed "s/L$//g")
		dtb=$(grep "DTB : " $path/profile.txt | sed "s/^.*DTB : //g" | sed "s/L$//g")
		echo "	The script suggests to use profile \"$profile\", KDBG address \"$kdbg\" and DTB address \"$dtb\":"
		read -e -p "	Do you want to use this parameters? [Y/n] " reply4b
		if [[ $reply4b =~ ^[YyOo]$ ]] || [[ -z "$reply4b" ]]; then
			sleep 0
		elif [[ $reply4b =~ ^[Nn]$ ]]; then
			echo "	Please precise the EXACT profile you want to use:"
			echo "	List of existing profiles: $profilelist"
			read -e -p "	Selected profile: " reply4c
			if [ -z "$reply4c" ]; then
				echo -e "	[\033[31mERROR\033[0m] You answer can not be empty. Please retry with a correct profile, managed by your Volatility version."
				echo "		For further information about you Volatility version, you can try \"$vol --help\"."
				echo "		If the proposed profile isn't understandable, please check the file \"$path/profile.txt\""
				echo ""
				exit 1
			else
				profile="$reply4c"
				echo ""
			fi
		else
			echo -e "	[\033[31mERROR\033[0m] You answer is not correct. Please retry with a correct profile, managed by your Volatility version."
			echo "		For further information, you can try \"$vol --help\"."
			echo "		If the profile proposed isn't understandable, please check the file \"$path/imageinfo.txt\""
			echo ""
			exit 1
		fi
	elif [[ $reply4 =~ ^[Nn]$ ]]; then
		echo "		  Please precise the EXACT profile you want to use:"
		echo "		  List of existing profiles: $profilelist"
		read -e -p "	Selected profile: " reply4b
		if [ -z "$reply4b" ]; then
			echo -e "	[\033[31mERROR\033[0m] You answer can not be empty. Please retry with a correct profile, managed by your Volatility version."
			echo "		For further information about you Volatility version, you can try \"$vol --help\"."
			echo ""
			exit 1
		else
			profile="$reply4b"
		fi
		echo ""
	else
		echo -e "	[\033[31mERROR\033[0m] This script is not able to determine your answer. Please, retry with a correct answer."
		echo ""
		exit 1	
	fi
fi

# HERE THE SUGGESTED OR GIVEN PROFILE IS APPLIED IN VARIABLE
# Bellow, the special block for auto mode escape
if [[ $option = "auto" ]]; then
	sleep 0
elif [[ $profile = "No" ]]; then
	echo -e "	[\033[33mWARNING\033[0m] The script is not able to suggest a profile or the memory dump is corrupted."
	echo "		  Please precise the EXACT profile you want to use:"
	echo "		  List of existing profiles: $profilelist"
	echo "	$profilelist"
	read -e -p "		  Selected profile: " reply5
	if [ -z "$reply5" ]; then
		echo -e "	[\033[31mERROR\033[0m] You answer can not be empty. Please retry with a correct profile, managed by your Volatility version."
		echo "		For further information, you can try \"$vol --help\"."
		echo "		If the proposed profile isn't understandable, please check the file \"$path/imageinfo.txt\""
		echo ""
		exit 1
	else
		profile="$reply5"
		echo ""
	fi
else
	echo ""
fi

# RESULTS PREPROCESSING OPTION
# Bellow, the special block for auto mode escape
if [[ $option = "auto" ]]; then
	sleep 0
else
	read -e -p "${bold}[6/6] - Do you want to process your folder output with basic checks to accelerate analysis? [Y/n]${normal} " reply6
	if [[ $reply6 =~ ^[YyOo]$ ]] || [[ -z "$reply6" ]]; then
		echo ""
	elif [[ $reply6 =~ ^[Nn]$ ]]; then
		echo -e "	[\033[33mWARNING\033[0m] Results will NOT be processed by the script."
		echo ""
	else
		echo -e "	[\033[31mERROR\033[0m] This script is not able to determine your answer. Please, retry with a correct answer."
		echo ""
		exit 1	
	fi
fi

# SPECIFY THE VOLATILITY VARIABLES ENVIRONNEMENT & CREATE RESULT SUBFOLDERS
# Bellow, the special block for auto mode escape
if [[ $option = "auto" ]]; then
	sleep 0
else
	export VOLATILITY_LOCATION=file://$dump
	export VOLATILITY_PROFILE=$profile
	if [[ ! $kdbg = "No" ]]; then
		sleep 0		
#		export VOLATILITY_KDBG=$kdbg {This feature is disabled because it triggers some errors in plugins. It would be troubleshooted soon.}
	elif [[ $kdbg = "" ]]; then
		echo -e "	[\033[33mWARNING\033[0m] The script is not able to determine the KDBG address. It will be ignored."
	else	
		echo -e "	[\033[33mWARNING\033[0m] The script is not able to determine the KDBG address. It will be ignored."
	fi
	if [[ ! $dtb = "No" ]]; then
		sleep 0
#		export VOLATILITY_DTB=$dtb {This feature is disabled because it triggers some errors in plugins. It would be troubleshooted soon.}
	elif [[ $dtb = "" ]]; then
		echo -e "	[\033[33mWARNING\033[0m] The script is not able to determine the DTB address. It will be ignored."
	else
		echo -e "	[\033[33mWARNING\033[0m] The script is not able to determine the DTB address. It will be ignored."
	fi
	if [[ $option =~ ^full$|^rest$ ]]; then
		mkdir $path/procdump/
		mkdir $path/memdump/
		mkdir $path/dlldump/
		mkdir $path/malfind/
		mkdir $path/moddump/
		mkdir $path/registry/
	else
		sleep 0
	fi
fi

# PLUGINS COMMANDLINE DEFINITION
# Bellow, the special block for auto mode escape
if [[ $option = "auto" ]]; then
	for dump in `ls $2 | grep -Eio "^.+\.pmem"`; do
		echo "--------------------------------------------"
		echo "Performing dump file: \"$dump\""
		type=$(file $2/$dump)
		if [[ ! $type =~ data$ ]]; then		
			echo "The file \"$dump\" seems to be different as a dump file format."
			echo ""
		else
			thispath="$(date +'%Y%m%d_%H%M%S')_$dump"
			logfile="$path/$thispath/logfile.log"
			logFonction() {	tee -a $logfile; }		
			mkdir -p $path/$thispath/procdump/
			mkdir $path/$thispath/memdump/
			mkdir $path/$thispath/dlldump/
			mkdir $path/$thispath/malfind/
			mkdir $path/$thispath/moddump/
			mkdir $path/$thispath/registry/		
			profile=$($vol -f $2/$dump imageinfo > $path/$thispath/profile.txt 2>&1; grep -iE -o1 "Suggested profile\(s\) : ([a-z0-9]+)(, |$)?" $path/$thispath/profile.txt | sed "s/Suggested Profile(s) : //g" | sed "s/, //g")
			kdbg=$(grep "KDBG : " $path/$thispath/profile.txt | sed "s/^.*KDBG : //g" | sed "s/L$//g")
			dtb=$(grep "DTB : " $path/$thispath/profile.txt | sed "s/^.*DTB : //g" | sed "s/L$//g")
			echo "Detected profile: $profile"
			export VOLATILITY_LOCATION=file://$2/$dump
			export VOLATILITY_PROFILE=$profile
#			export VOLATILITY_KDBG=$kdbg
#			export VOLATILITY_DTB=$dtb
			(
			echo "    ===== VolAuto logfile generation ====="
			echo "[*] Analysis started: $(date +'%Y-%m-%d %H:%M:%S')"
			echo "[*] Dump file processed: \"$dump\""
			echo "[*] Profile used: $profile"
			echo "[*] KDBG address: $kdbg"
			echo "[*] DTB address: $dtb"
			echo "[*] Analysis mode: $option ($6-thread)"
			if [[ $5 =~ ^--hash$ ]]; then
				md5=$(md5sum $2/$dump | grep -Eio "^[a-z0-9]{32}")
				echo "[*] MD5: $md5"
				sha1=$(sha1sum $2/$dump | grep -Eio "^[a-z0-9]{40}")
				echo "[*] SHA-1: $sha1"
				sha2=$(sha256sum $2/$dump | grep -Eio "^[a-z0-9]{64}")
				echo "[*] SHA-256: $sha2" 
			elif [[ $5 =~ ^--nohash$ ]]; then
				echo "[*] MD5: skipped by user"
				echo "[*] SHA-1: nskipped by user"
				echo "[*] SHA-256: skipped by user"
			else			
				echo "Error during fingerprint computing"
			fi
				echo "[*] Export folder: $path/$thispath" ) > $logfile
			echo "--------------------------------------------" >> $logfile
			if [[ $6 =~ ^--multi$ ]]; then
				echo "Multi-threading mode is enable. Output logfile will not contain plugin progression and status" >> $logfile
				nohup $vol imageinfo > $path/$thispath/imageinfo.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol pslist > $path/$thispath/pslist.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol pstree > $path/$thispath/pstree.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol psscan > $path/$thispath/psscan.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol psxview > $path/$thispath/psxview.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol procdump -D $path/$thispath/procdump/ > $path/$thispath/procdump.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol -D $path/$thispath/memdump/ memdump > $path/$thispath/memdump.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol dlllist > $path/$thispath/dlllist.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol ldrmodules > $path/$thispath/ldrmodules.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol dlldump -D $path/$thispath/dlldump/ > $path/$thispath/dlldump.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol modules > $path/$thispath/modules.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol modscan > $path/$thispath/modscan.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol driverscan > $path/$thispath/driverscan.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol devicetree > $path/$thispath/devicetree.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol -D $path/$thispath/moddump moddump > $path/$thispath/moddump.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol -D $path/$thispath/malfind malfind > $path/$thispath/malfind.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol handles > $path/$thispath/handles.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol connections > $path/$thispath/connections.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol connscan > $path/$thispath/connscan.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol sockets > $path/$thispath/sockets.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol netscan > $path/$thispath/netscan.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol apihooks > $path/$thispath/apihooks.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol idt > $path/$thispath/idt.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol ssdt > $path/$thispath/ssdt.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol filescan > $path/$thispath/filescan.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol userassist > $path/$thispath/userassist.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol prefetchparser > $path/$thispath/prefetchparser.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol shellbags > $path/$thispath/shellbags.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol autoruns > $path/$thispath/autoruns.txt 2>&1 </dev/null & >/dev/null &
				nohup $vol -D $path/$thispath/registry dumpregistry > $path/$thispath/dumpregistry.txt 2>&1 </dev/null & >/dev/null &
#				Just waiting for "multithreading" termination to exit the item
				wait
			elif [[ $6 =~ ^--mono$ ]]; then
				echo -ne "[$(date +'%H:%M:%S')] Applying \"imageinfo\":	"  | logFonction; echo -ne "[#                             ] (3%)\r" && $vol imageinfo > $path/$thispath/imageinfo.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"pslist\":		"  | logFonction; echo -ne "[##                            ] (6%)\r" && $vol pslist > $path/$thispath/pslist.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"pstree\":		"  | logFonction; echo -ne "[###                           ] (9%)\r" && $vol pstree > $path/$thispath/pstree.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"psscan\":		"  | logFonction; echo -ne "[####                          ] (12%)\r" && $vol psscan > $path/$thispath/psscan.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"psxview\":		"  | logFonction; echo -ne "[#####                         ] (15%)\r" && $vol psxview > $path/$thispath/psxview.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"procdum\":		"  | logFonction; echo -ne "[######                        ] (20%)\r" && $vol procdump -D $path/$thispath/procdump/ > $path/$thispath/procdump.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"memdump\":		"  | logFonction; echo -ne "[#######                       ] (25%)\r" && $vol -D $path/$thispath/memdump/ memdump > $path/$thispath/memdump.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"dlllist\":		"  | logFonction; echo -ne "[########                      ] (28%)\r" && $vol dlllist > $path/$thispath/dlllist.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"ldrmodules\":	"  | logFonction; echo -ne "[#########                     ] (31%)\r" && $vol ldrmodules > $path/$thispath/ldrmodules.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"dlldump\":		"  | logFonction; echo -ne "[##########                    ] (34%)\r" && $vol dlldump -D $path/$thispath/dlldump/ > $path/$thispath/dlldump.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"modules\":		"  | logFonction; echo -ne "[###########                   ] (37%)\r" && $vol modules > $path/$thispath/modules.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"modscan\":		"  | logFonction; echo -ne "[############                  ] (40%)\r" && $vol modscan > $path/$thispath/modscan.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"driverscan\":	"  | logFonction; echo -ne "[#############                 ] (43%)\r" && $vol driverscan > $path/$thispath/driverscan.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"devicetree\":	"  | logFonction; echo -ne "[##############                ] (50%)\r" && $vol devicetree > $path/$thispath/devicetree.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"moddump\":		"  | logFonction; echo -ne "[###############               ] (55%)\r" && $vol -D $path/$thispath/moddump moddump > $path/$thispath/moddump.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"malfind\":		"  | logFonction; echo -ne "[################              ] (60%)\r" && $vol -D $path/$thispath/malfind malfind > $path/$thispath/malfind.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"handles\":		"  | logFonction; echo -ne "[#################             ] (63%)\r" && $vol handles > $path/$thispath/handles.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"connections\":	"  | logFonction; echo -ne "[##################            ] (67%)\r" && $vol connections > $path/$thispath/connections.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"connscan\":		"  | logFonction; echo -ne "[###################           ] (70%)\r" && $vol connscan > $path/$thispath/connscan.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"sockets\":		"  | logFonction; echo -ne "[####################          ] (73%)\r" && $vol sockets > $path/$thispath/sockets.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"netscan\":		"  | logFonction; echo -ne "[#####################         ] (75%)\r" && $vol netscan > $path/$thispath/netscan.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"apihooks\":		"  | logFonction; echo -ne "[######################        ] (80%)\r" && $vol apihooks > $path/$thispath/apihooks.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"idt\":		"  | logFonction; echo -ne "[#######################       ] (83%)\r" && $vol idt > $path/$thispath/idt.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"ssdt\":		"  | logFonction; echo -ne "[########################      ] (85%)\r" && $vol ssdt > $path/$thispath/ssdt.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"filescan\":		"  | logFonction; echo -ne "[#########################     ] (88%)\r" && $vol filescan > $path/$thispath/filescan.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"userassist\":	"  | logFonction; echo -ne "[##########################    ] (90%)\r" && $vol userassist > $path/$thispath/userassist.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"prefetchparser\":	"  | logFonction; echo -ne "[###########################   ] (92%)\r" && $vol prefetchparser > $path/$thispath/prefetchparser.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"shellbags\":	"  | logFonction; echo -ne "[############################  ] (95%)\r" && $vol shellbags > $path/$thispath/shellbags.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"autorun\":		"  | logFonction; echo -ne "[############################# ] (98%)\r" && $vol autoruns > $path/$thispath/autoruns.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
				echo -ne "[$(date +'%H:%M:%S')] Applying \"dumpregistry\":	"  | logFonction; echo -ne "[############################# ] (99%)\r" && $vol -D $path/$thispath/registry dumpregistry > $path/$thispath/dumpregistry.txt 2>&1; checkStatus >> $logfile; echo -ne "\r\033[K"
			else			
				echo "Error during multi-thread/mono-thread parsing"
			fi
			echo -ne "[$(date +'%H:%M:%S')] Scan finished:	"; echo -e "[##############################] (100%)\r\n" 
			echo -n "Folder size: " | logFonction && du -hcs $path/$thispath/ | grep total | cut -f1 | logFonction;
			echo "--------------------------------------------" | logFonction;
			echo ""
			echo "[*] Analysis ended: $(date +'%Y-%m-%d %H:%M:%S')" | logFonction;
			sed -ri 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g' $logfile		
			rm -f $path/$thispath/profile.txt
		fi
		done
#		exit 0
		
else
	logfile="$path/logfile.log"
	logFonction() { tee -a $logfile; }
	p1() { echo -n "	[$(date +'%H:%M:%S')] Applying \"imageinfo\":	" | logFonction && $vol imageinfo > $path/imageinfo.txt 2>&1; checkStatus | logFonction; }
	p2() { echo -n "	[$(date +'%H:%M:%S')] Applying \"pslist\":		" | logFonction && $vol pslist > $path/pslist.txt 2>&1; checkStatus | logFonction; }
	p3() { echo -n "	[$(date +'%H:%M:%S')] Applying \"pstree\":		" | logFonction && $vol pstree > $path/pstree.txt 2>&1; checkStatus | logFonction; }
	p4() { echo -n "	[$(date +'%H:%M:%S')] Applying \"psscan\":		" | logFonction && $vol psscan > $path/psscan.txt 2>&1; checkStatus | logFonction; }
	p5() { echo -n "	[$(date +'%H:%M:%S')] Applying \"psxview\":		" | logFonction && $vol psxview > $path/psxview.txt 2>&1; checkStatus | logFonction; }
	p6() { echo -n "	[$(date +'%H:%M:%S')] Applying \"procdump\":		" | logFonction && $vol procdump -D $path/procdump/ > $path/procdump.txt 2>&1; checkStatus | logFonction; }
	p7() { echo -n "	[$(date +'%H:%M:%S')] Applying \"memdump\":		" | logFonction && $vol -D $path/memdump/ memdump > $path/memdump.txt 2>&1; checkStatus | logFonction; }
	p8() { echo -n "	[$(date +'%H:%M:%S')] Applying \"dlllist\":		" | logFonction && $vol dlllist > $path/dlllist.txt 2>&1; checkStatus | logFonction; }
	p9() { echo -n "	[$(date +'%H:%M:%S')] Applying \"ldrmodules\":	" | logFonction && $vol ldrmodules > $path/ldrmodules.txt 2>&1; checkStatus | logFonction; }
	p10() { echo -n "	[$(date +'%H:%M:%S')] Applying \"dlldump\":		" | logFonction && $vol dlldump -D $path/dlldump/ > $path/dlldump.txt 2>&1; checkStatus | logFonction; }
	p11() { echo -n "	[$(date +'%H:%M:%S')] Applying \"modules\":		" | logFonction && $vol modules > $path/modules.txt 2>&1; checkStatus | logFonction; }
	p12() { echo -n "	[$(date +'%H:%M:%S')] Applying \"modscan\":		" | logFonction && $vol modscan > $path/modscan.txt 2>&1; checkStatus | logFonction; }
	p13() { echo -n "	[$(date +'%H:%M:%S')] Applying \"driverscan\":	" | logFonction && $vol driverscan > $path/driverscan.txt 2>&1; checkStatus | logFonction; }
	p14() { echo -n "	[$(date +'%H:%M:%S')] Applying \"devicetree\":	" | logFonction && $vol devicetree > $path/devicetree.txt 2>&1; checkStatus | logFonction; }
	p15() { echo -n "	[$(date +'%H:%M:%S')] Applying \"moddump\":		" | logFonction && $vol -D $path/moddump/ moddump > $path/moddump.txt 2>&1; checkStatus | logFonction; }
	p16() { echo -n "	[$(date +'%H:%M:%S')] Applying \"malfind\":		" | logFonction && $vol -D $path/malfind/ malfind > $path/malfind.txt 2>&1; checkStatus | logFonction; }
	p17() { echo -n "	[$(date +'%H:%M:%S')] Applying \"handles\":		" | logFonction && $vol handles > $path/handles.txt 2>&1; checkStatus | logFonction; }
	p18() { echo -n "	[$(date +'%H:%M:%S')] Applying \"connections\":	" | logFonction && $vol connections > $path/connections.txt 2>&1; checkStatus | logFonction; }
	p19() { echo -n "	[$(date +'%H:%M:%S')] Applying \"connscan\":		" | logFonction && $vol connscan > $path/connscan.txt 2>&1; checkStatus | logFonction; }
	p20() { echo -n "	[$(date +'%H:%M:%S')] Applying \"sockets\":		" | logFonction && $vol sockets > $path/sockets.txt 2>&1; checkStatus | logFonction; }
	p21() { echo -n "	[$(date +'%H:%M:%S')] Applying \"netscan\":		" | logFonction && $vol netscan > $path/netscan.txt 2>&1; checkStatus | logFonction; }
	p22() { echo -n "	[$(date +'%H:%M:%S')] Applying \"apihooks\":		" | logFonction && $vol apihooks > $path/apihooks.txt 2>&1; checkStatus | logFonction; }
	p23() { echo -n "	[$(date +'%H:%M:%S')] Applying \"idt\":		" | logFonction && $vol idt > $path/idt.txt 2>&1; checkStatus | logFonction; }
	p24() { echo -n "	[$(date +'%H:%M:%S')] Applying \"ssdt\":		" | logFonction && $vol ssdt > $path/ssdt.txt 2>&1; checkStatus | logFonction; }
	p25() { echo -n "	[$(date +'%H:%M:%S')] Applying \"filescan\":		" | logFonction && $vol filescan > $path/filescan.txt 2>&1; checkStatus | logFonction; }
	p26() { echo -n "	[$(date +'%H:%M:%S')] Applying \"userassist\":	" | logFonction && $vol userassist > $path/userassist.txt 2>&1; checkStatus | logFonction; }
	p27() { echo -n "	[$(date +'%H:%M:%S')] Applying \"prefetchparser\":	" | logFonction && $vol prefetchparser > $path/prefetchparser.txt 2>&1; checkStatus | logFonction; }
	p28() { echo -n "	[$(date +'%H:%M:%S')] Applying \"shellbags\":	" | logFonction && $vol shellbags > $path/shellbags.txt 2>&1; checkStatus | logFonction; }
	p29() { echo -n "	[$(date +'%H:%M:%S')] Applying \"autoruns\":		" | logFonction && $vol autoruns > $path/autoruns.txt 2>&1; checkStatus | logFonction; }
	p30() { echo -n "	[$(date +'%H:%M:%S')] Applying \"dumpregistry\":	" | logFonction && $vol -D $path/registry/ dumpregistry > $path/dumpregistry.txt 2>&1; checkStatus | logFonction; }
fi

# STARTING EXTRACTION AND LOGGING
# Bellow, the special block for auto mode escape
if [[ $option = "auto" ]]; then
	sleep 0
else
	echo "	It seems all is alright. Starting the extraction using Volatility and generating a logfile:"
	echo "	Note: You can pass each step, using CTRL+C"
	echo ""
	if [[ $reply2 =~ ^[YyOo]$ ]]; then
		echo "	Please wait while checksums are computed... (it can take several minutes)"
		md5=$(md5sum $dump | grep -Eio "^[a-z0-9]{32}")
		sha1=$(sha1sum $dump | grep -Eio "^[a-z0-9]{40}")
		sha2=$(sha256sum "$dump" | grep -Eio "^[a-z0-9]{64}")
		echo "	Checksum MD5: $md5"
		echo "	Checksum SHA-1: $sha1"
		echo "	Checksum SHA-256: $sha2" 
	else
		sleep 0
	fi
	(
	echo "    ===== VolAuto logfile generation ====="
	echo "[*] Analysis started: $(date +'%Y-%m-%d %H:%M:%S')"
	echo "[*] Dump file processed: \"$dump\""
	echo "[*] Profile used: $profile"
	echo "[*] KDBG address: $kdbg"
	echo "[*] DTB address: $dtb"
	echo "[*] Analysis mode: $option"
	if [ -z "$md5" ] && [ -z "$sha1" ]; then
		echo "[*] MD5: skipped by user"
		echo "[*] SHA-1: skipped by user"
		echo "[*] SHA-256: skipped by user"
	else
		echo "[*] MD5: $md5"
		echo "[*] SHA-1: $sha1"
		echo "[*] SHA-256: $sha2"
	fi
		echo "[*] Export folder: $path"
		echo "--------------------------------------------" ) > $logfile
fi

# COMMON PLUGINS EXECUTION ACCORDING TO SELECTED MODE BY USER
# Bellow, the special block for auto mode escape
if [[ $option = "auto" ]]; then
	sleep 0
elif [[ $option = "default" ]]; then
	p1; p2; p3; p4; p5; p8; p9; p11; p12; p13; p14; p17; p23; p24; p25; p26; p27; p28; p29;

elif [[ $option = "quick" ]]; then
	p1; p2; p3; p4; p5; p8; p9; p11; p12; p13; p14; p17; p23; p24; p25; p26; p27;

elif [[ $option = "full" ]]; then
	p1; p2; p3; p4; p5; p6; p7; p8; p9; p10; p11; p12; p13; p14; p15; p16; p17; p22; p23; p24; p25; p26; p27; p28; p29; p30;

elif [[ $option = "rest" ]]; then
	p6; p7; p10; p15; p16; p22; p28; p29; p30;

else
	echo -e "	[\033[31mERROR\033[0m] An error occurred. Please, check the syntax and the dump path. Be sure you specified the FULLPATH and a correct option."
	echo ""	
	exit 1
fi
# SPECIFIC PLUGINS FOR OLD WINDOWS VERSIONS
# Bellow, the special block for auto mode escape
if [[ $option = "auto" ]]; then
	sleep 0
elif [[ $profile =~ ^WinXP|^Win2003 ]] && [ $option = "default" -o $option = "quick" -o $option = "full" ]; then
	p18; p19; p20;
	echo -e "	[$(date +'%H:%M:%S')] Applying \"netscan\":		[ \033[33mMISSED\033[0m ]" | logFonction;
elif [[ $profile =~ ^Vista|^Win2008|^Win2012|^Win7|^Win8 ]] && [ $option = "default" -o $option = "quick" -o $option = "full" ]; then
	echo -e "	[$(date +'%H:%M:%S')] Applying \"connections\":	[ \033[33mMISSED\033[0m ]" | logFonction;
	echo -e "	[$(date +'%H:%M:%S')] Applying \"connscan\":		[ \033[33mMISSED\033[0m ]" | logFonction;
	echo -e "	[$(date +'%H:%M:%S')] Applying \"sockets\":		[ \033[33mMISSED\033[0m ]" | logFonction;
	p21;
else
	echo -e "	[$(date +'%H:%M:%S')] Applying \"connections\":	[ \033[33mMISSED\033[0m ]" | logFonction;
	echo -e "	[$(date +'%H:%M:%S')] Applying \"connscan\":		[ \033[33mMISSED\033[0m ]" | logFonction;
	echo -e "	[$(date +'%H:%M:%S')] Applying \"sockets\":			[ \033[33mMISSED\033[0m ]" | logFonction;
	echo -e "	[$(date +'%H:%M:%S')] Applying \"netscan\":		[ \033[33mMISSED\033[0m ]" | logFonction;
fi
if [[ $option = "auto" ]]; then
	sleep 0
else
	echo "--------------------------------------------" | logFonction;
	echo "[*] Analysis ended: $(date +'%Y-%m-%d %H:%M:%S')" | logFonction;
	echo -n "[*] Folder size: " | logFonction && du -hcs $path/ | grep total | cut -f1 | logFonction;
	echo "	--> The extraction is now finished." | logFonction;
	echo ""
fi

# RESULTS PROCESSING
process()
	{
		report="$path/Report.html"
		mkdir -p $path/Report
#		DETECT HIDDEN PROCESSES
#		"pslist" and "psscan" comparison:
		ProcComp=$(diff -yi --suppress-common-lines <(cut -d ' ' -f 2 $path/pslist.txt | sort) <(cut -d ' ' -f 2 $path/psscan.txt | sort))
#		False values in psxview:
		PsxFalse=$(grep -iE "false|okay" $path/psxview.txt)
#		DLL LOAD ANALYSIS
#		DLL names and count:
		grep -iPo "0x.*\\\\\K.+$" $path/dlllist.txt | sort | uniq -ic | sort -n >> $path/Report/DLL_names.txt
#		DLL extensions and count:
		DllExt=$(grep -iPo "0x.*\K\..+$" $path/dlllist.txt | sort | uniq -ic | sort -n)
#		DLL pathes and count:
		DllPath=$(grep -iPo "0x.*0x.*0x[a-f0-9]+\s\K.*\\\\" $path/dlllist.txt | sort -f | uniq -ic | sort -n)
#		DLL filename without any vowels (Conficker detection):
		DllFile=$(grep -hiPo '\\windows\\system32\\\w{1,10}.dll' $path/dlllist.txt | sort -f | sed 's/\\windows\\system32\\//gi' | grep -Piv "[aeiouy]|\d" | uniq -ic)
#		DLL commandlines and count:
		DllCmd=$(grep -i "command line" $path/dlllist.txt | sort)
#		DLL Hijacking:
		DllHijack=$(for i in $(sed -n "s/0x.*\\\\\(.*\)/\1/p" $path/dlllist.txt | sort -f | uniq -i) ; do echo "-- $i" ; grep -i "$i$" $path/dlllist.txt | sed -nr "s/0x.*0x.*0x[a-f0-9]+ (.*\\\\).*/\1/p" | sort -f | uniq -ic | grep -Pz " +[0-9]{1,}.*\n +[0-9]{1,}"; done | grep -B1 -Ev "\-\- ")
#	 	DETECT HIDDEN DLL
#		"dlllist" and "ldrmodules" comparison:
		diff -yi <(grep -ioP "\s\S+:\\\\\K.*$" $path/dlllist.txt | sort | uniq -i) <(grep -ioP "\s\\\\\K.*$" $path/ldrmodules.txt | sort | uniq -i) >> $path/Report/DLL-LDR_comparison.txt
#		False values in "ldrmodules":
		LdrFalse=$(grep -i "false" $path/ldrmodules.txt  | grep -Ev ".exe$")
#		Mappedpath:
		MapPath=$(grep -iE "\s(-[^-]*)?$" $path/ldrmodules.txt)
#		DRIVERS LOAD ANALYSIS
#		Names in "modules" and "modscan":
		awk -F ' ' '{print $5}' $path/modules.txt | awk -F '\' '{print $NF}' | sort -u >> $path/Report/Modules_names.txt
		awk -F ' ' '{print $5}' $path/modscan.txt | awk -F '\' '{print $NF}' | sort -u >> $path/Report/Modscan_names.txt
#		Pathes in "modules" and "modscan":
		ModPath=$(awk -F ' ' '{$1=$2=$3=$4=""; print $0}' $path/modules.txt | rev | cut -d\\ -f 2- | rev | sort | uniq -ic | sort -n -k 1,1)
		ModsPath=$(awk -F ' ' '{$1=$2=$3=$4=""; print $0}' $path/modscan.txt | rev | cut -d\\ -f 2- | rev | sort | uniq -ic | sort -n -k 1,1)
#		DETECT HIDDEN DRIVERS
#		Ouput differences between "modules" and "modscan":
		ModDiff=$(diff -yi --suppress-common-lines <(awk -F ' ' '{$1=$2=$3=$4=""; print $0}' $path/modules.txt | sort | uniq -i ) <(awk -F ' ' '{$1=$2=$3=$4=""; print $0}' $path/modscan.txt | sort | uniq -i))
#		Ouput differences between "driverscan"-"modules" and "driverscan"-"modscan":
		DriveMod=$(diff -yi --suppress-common-lines <(grep -iPo "^0x\S+\s+\d+\s+\d+\s+\K0x\S+" $path/driverscan.txt | sort -u) <(grep -iPo "^0x\S+\s+\S+\s+\K0x\S+" $path/modules.txt | sort -u ))
		DriveMods=$(diff -yi --suppress-common-lines <(grep -iPo "^0x\S+\s+\d+\s+\d+\s+\K0x\S+" $path/driverscan.txt | sort -u) <(grep -iPo "^0x\S+\s+\S+\s+\K0x\S+" $path/modscan.txt | sort -u ))
		if [[ $option = "full" ]] || [[ $option = "rest" ]] || [[ $option = "auto" ]]; then
#			CODE INJECTION
#			Look for PE in "malfind" folder:
			MalPE=$(grep -i -B 5 "MZ" $path/malfind.txt | grep -iE "^Process" | awk -F ' Address' '{print $1}' | sort | uniq -ic | sort -n -k 1,1)
#			Look for JMP/CALL/RET redirections in "malfind":
			MalRedir=$(grep -iE -A 13 "^process:" $path/malfind.txt)
#			Look for PE in "procump" folder:
			ProcPE=$(for i in `ls $path/procdump/`; do strings $path/procdump/$i | grep "MZ"; done)
#			API HOOKS
#			Processes victims of "hooks":
			HookProc=$(grep -iE "^Process:" $path/apihooks.txt | sort | uniq -ic | sort -n -k 1,1)
#			Hooked functions:
			HookFunct=$(grep -iE "^Function" $path/apihooks.txt | cut -d " " -f 2 | sort | uniq -ic | sort -n -k 1,1)
#			Modules that contain executed code:
			HookMod=$(grep -iE "^Hooking module" $path/apihooks.txt | cut -d " " -f 3 | sort | uniq -ic | sort -n -k 1,1)
#			COMPUTED FINGERPRINTS
#			Computed SHA-256 for "procdump" (limited to 10MB file size only):
			for i in `ls $path/procdump/`; do if [ "$(wc -c $path/procdump/$i | grep -Eo '^[0-9]+')" -ge 10000000 ]; then sha256sum $path/procdump/$i >> $path/Report/files_hash.txt; fi; done
#			Computed SHA-256 for "memdump" (limited to 10MB file size only):
			for i in `ls $path/memdump/`; do if [ "$(wc -c $path/memdump/$i | grep -Eo '^[0-9]+')" -ge 10000000 ]; then sha256sum $path/memdump/$i >> $path/Report/files_hash.txt; fi; done
#			Computed SHA-256 for "dlldump" (limited to 10MB file size only):
			for i in `ls $path/dlldump/`; do if [ "$(wc -c $path/dlldump/$i | grep -Eo '^[0-9]+')" -ge 10000000 ]; then sha256sum $path/dlldump/$i >> $path/Report/files_hash.txt; fi; done
#			Computed SHA-256 for "moddump" (limited to 10MB file size only):
			for i in `ls $path/moddump/`; do if [ "$(wc -c $path/moddump/$i | grep -Eo '^[0-9]+')" -ge 10000000 ]; then sha256sum $path/moddump/$i >> $path/Report/files_hash.txt; fi; done
#			Computed SHA-256 for "malfind" (limited to 10MB file size only):
			for i in `ls $path/malfind/`; do if [ "$(wc -c $path/malfind/$i | grep -Eo '^[0-9]+')" -ge 10000000 ]; then sha256sum $path/malfind/$i >> $path/Report/files_hash.txt; fi; done
		fi
#	 	REPORT GENERATION
		(
		echo "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">"
		echo "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\">"
		echo "<head>"
		echo "	<meta http-equiv=\"Content-type\" content=\"text/html; charset=utf-8\" />"
		echo "	<title>VolAuto - Output Analysis</title>"
		echo "	<style>"
		echo "		t1 { display: table; border: 3px double black; border-collapse: collapse; width: 100%; }"
		echo "		t2 { display: table; border: 1px solid black; border-collapse: collapse; width: 80%; text-align: center; color: #$TextColour; font-weight: bold; font-size: large; }"
		echo "		pre { display: table; border: 1px solid black; border-collapse: collapse; width: 50%; }"
		echo "	</style>"
		echo "</head>"
		echo "<body>"
		echo "	<!-- Start Page -->"
		echo "	<div id=\"page\">"
		echo "	<table>"
		echo " 		<t1><center><b>~ Incident response VolAuto data analysis script ~</b></center>"
		echo "		<center><b>Starting analysis</b></center>"
		echo "		<center><b>$(date '+%Y-%m-%d %H:%M:%S %z%Z')</b></center></t1>"
		echo "	</table>"
		echo "	<br />"
		echo "	<center><img src=\"data:image/png;base64,xxxLOGOxxx\" align=\"center\" height=\"118,10\" width=\"350\"></center>"
		echo "	<br /><br />"
		echo "			<t2>DETECT HIDDEN PROCESSES</t2>"
		echo "		<br />"
		echo "		- <b>\"pslist\" and \"psscan\" comparison:</b>"
		echo "		<pre>$ProcComp</pre><br />"
		echo "		- <b>False values in \"psxview\":</b>"
		echo "		<pre>$PsxFalse</pre><br />"
		echo "	<br /><br />"
		echo "			<t2>DLL LOAD ANALYSIS</t2>"
		echo "		<br />"
		echo "		- <b>DLL names and count:</b> <a href=\"./Report/DLL_names.txt\" target=\"_blank\">click here for details</a><br />"
		echo "		- <b>DLL extensions and count:</b>"
		echo "		<pre>$DllExt</pre><br />"
		echo "		- <b>DLL pathes and count:</b>"
		echo "		<pre>$DllPath</pre><br />"
		echo "		- <b>DLL filename without any vowels loaded from Windows\system32 (Conficker detection):</b>"
		echo "		<pre>$DllFile</pre><br />"
		echo "		- <b>DLL commandlines and count:</b>"
		echo "		<pre>$DllCmd</pre><br />"
		echo "		- <b>DLL Hijacking:</b>"
		echo "		<pre>$DllHijack</pre><br />"
		echo "	<br /><br />"
		echo "			<t2>DETECT HIDDEN DLLs</t2>"
		echo "		<br />"
		echo "		- <b>\"dlllist\" and \"ldrmodules\" comparison:</b> <a href=\"./Report/DLL-LDR_comparison.txt\" target=\"_blank\">click here for details</a><br />"
		echo "		- <b>False values in \"ldrmodules\":</b>"
		echo "		<pre>$LdrFalse</pre><br />"
		echo "		- <b>Mappedpath:</b>"
		echo "		<pre>$MapPath</pre><br />"
		echo "	<br /><br />"
		echo "			<t2>DRIVERS LOAD ANALYSIS</t2>"
		echo "		<br />"
		echo "		- <b>Names in \"modules\":</b> <a href=\"./Report/Modules_names.txt\" target=\"_blank\">click here for details</a><br />"
		echo "		- <b>Names in \"modscan\":</b> <a href=\"./Report/Modscan_names.txt\" target=\"_blank\">click here for details</a><br />"
		echo "		- <b>Pathes in \"modules\" and \"modscan\":</b>"
		echo "		<pre>$ModPath</pre><br />"
		echo "		<pre>$ModsPath</pre><br />"
		echo "	<br /><br />"
		echo "			<t2>DETECT HIDDEN DRIVERS</t2>"
		echo "		<br />"
		echo "		- <b>Ouput differences between \"modules\" and \"modscan\":</b>"
		echo "		<pre>$ModDiff</pre><br />"
		echo "		- <b>Ouput differences between \"driverscan\"-\"modules\" and \"driverscan\"-\"modscan\":</b>"
		echo "		<pre>$DriveMod</pre><br />"
		echo "		<pre>$DriveMods</pre><br />"
		if [[ $option = "full" ]] || [[ $option = "rest" ]] || [[ $option = "auto" ]]; then
			echo "	<br /><br />"
			echo "			<t2>CODE INJECTION</t2>"
			echo "		<br />"
			echo "		- <b>Look for PE in \"malfind\" folder:</b>"
			echo "		<pre>$MalPE</pre><br />"
			echo "		- <b>Look for JMP/CALL/RET redirections in \"malfind\":</b>"
			echo "		<pre>$MalRedir</pre><br />"
			echo "		- <b>Look for PE in \"procump\" folder:</b>"
			echo "		<pre>$ProcPE</pre><br />"
			echo "	<br /><br />"
			echo "			<t2>API HOOKS</t2>"
			echo "		<br />"
			echo "		- <b>Processes victims of \"hooks\":</b>"
			echo "		<pre>$HookProc</pre><br />"
			echo "		- <b>Hooked functions:</b>"
			echo "		<pre>$HookFunct</pre><br />"
			echo "		- <b>Modules that contain executed code:</b>"
			echo "		<pre>$HookMod</pre><br />"
			echo "	<br /><br />"
			echo "			<t2>COMPUTED FINGERPRINTS</t2>"
			echo "		<br />"
			echo "		- <b>Computed SHA-256 for \"procdump\", \"memdump\"; \"dlldump\", \"moddump\" and \"malfind\":</b> <a href=\"./Report/files_hash.txt\" target=\"_blank\">click here for details</a><br />"
			echo "		  <i>You should run VT-Checker or Munin to request Virustotal and Hybrid-Analysis about those hashes!</i>"
		fi
		echo "	<br /><br />"
		echo "# $(date "+%Y-%m-%d %H:%M:%S %z%Z"): All tasks completed. Exiting."
		echo "	</div>"
		echo "</body>"
		echo "</html>"
		) >> $report
	}

if  [[ $option = "auto" ]] || [[ $reply6 =~ ^[YyOo]$ ]] || [[ -z "$reply6" ]]; then
	if [[ $option = "auto" ]]; then
		for path in `find $path -type d -iname "*.pmem"`; do
			if [ ! -d "$path" ]; then
				echo -e "	[\033[33mWARNING\033[0m] An error occurred analysing the folder $path. Be sure you specified a correct FULLPATH and the parent folder doesn't contain file extension \".pmem\"."
			fi
		process;
		done
	elif [[ $reply6 =~ ^[YyOo]$ ]] || [[ -z "$reply6" ]]; then
		echo "[*] You choose to process automatically the results in $path ; looking for commons checks. Checks that will be made are not exaustive."
		process;
		echo "	--> The analysis is now finished."
		echo ""
	fi
elif [[ $reply6 =~ ^[Nn]$ ]]; then
		echo "[!] You choose to do NOT process automatically the results. You can work on the results on $path/"
		echo ""
fi
if [[ $option = "auto" ]]; then
	sleep 0
else
	echo "The log file can be accessed on $path/logfile.log"
	echo "Good luck!"
	rm -f $path/profile.txt
	sed -ri 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g' $logfile
fi

# Bonus feature: Add a compagny logo in the output. (to change $CERTLogo variable, use: 'cat my_cie_logo.png | base64 -w0' and paste the output bellow.)
CERTLogo="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"
if [[ $option = "auto" ]] || [[ $reply6 =~ ^[YyOo]$ ]] || [[ -z "$reply6" ]]; then
	if [[ $option = "auto" ]]; then
		for file in `find $path -name "Report.html"`; do sed -i "s#xxxLOGOxxx#${CERTLogo}#" $file; done
	elif [[ $reply6 =~ ^[YyOo]$ ]] || [[ -z "$reply6" ]]; then
		sed -i "s#xxxLOGOxxx#${CERTLogo}#" $report
	fi
fi
exit 0
# EOF
