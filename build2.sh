#!/bin/bash
BEGIN_TIME=`date +%s`
TOTAL_DOWNLOAD_TIME=0
# Directories and Files
RENDER96EX_MASTER_GIT=./Render96ex-master/.git/
SM64EXCOOP_GIT=./sm64ex-coop/.git/
MASTER_GIT=./sm64ex-master/.git/
SM64PORT_MASTER_GIT=./sm64-port-master/.git/
NIGHTLY_GIT=./sm64ex-nightly/.git/
MACHINE_TYPE=`uname -m`

# Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

# Dependencies
DEPENDENCIES64BIT=("git" "make" "python3" "zip" "unzip" "unrar" "mingw-w64-x86_64-gcc" "mingw-w64-x86_64-glew" "mingw-w64-x86_64-SDL2" "mingw-w64-x86_64-SDL")
DEPENDENCIES32BIT=("git" "make" "python3" "zip" "unzip" "unrar" "mingw-w64-i686-gcc" "mingw-w64-i686-glew" "mingw-w64-i686-SDL2" "mingw-w64-i686-SDL")

gitClone() {
	DOWNLOAD_START_TIME=`date +%s`
	git clone $@
	DOWNLOAD_END_TIME=`date +%s`
	DOWNLOAD_TIME=$(( DOWNLOAD_END_TIME - DOWNLOAD_START_TIME ))
	TOTAL_DOWNLOAD_TIME=$(( TOTAL_DOWNLOAD_TIME + DOWNLOAD_TIME ))
}

download () {
	DOWNLOAD_START_TIME=`date +%s`
	wget $@
	DOWNLOAD_END_TIME=`date +%s`
	DOWNLOAD_TIME=$(( DOWNLOAD_END_TIME - DOWNLOAD_START_TIME ))
	TOTAL_DOWNLOAD_TIME=$(( TOTAL_DOWNLOAD_TIME + DOWNLOAD_TIME ))
}

#if [ -f "build2.sh" ]; then
	#rm "build2.sh"
#fi

# Antivirus fuck you message
if [ -d "C:/Program Files/Avast Software/" ] || [ -d "C:/Program Files (x86)/Avast Software/" ]; then
	echo -e "\n${RED}Avast Detected${RESET}\n\n${YELLOW}Uninstall Avast. It's garbage and will fuck up your install.\nAt the very least make sure it's disabled.${RESET}\n"
	sleep 3
fi

if [ -d "C:/Program Files/AVG/" ] || [ -d "C:/Program Files (x86)/AVG/" ]; then
	echo -e "\n${RED}AVG Detected${RESET}\n\n${YELLOW}Uninstall AVG. It's garbage and will fuck up your install.\nAt the very least make sure it's disabled.${RESET}\n"
	sleep 3
fi

if [ -d "C:/Program Files/Norton Security/" ] || [ -d "C:/Program Files (x86)/Norton Security/" ]; then
	echo -e "\n${RED}Norton Security Detected${RESET}\n\n${YELLOW}Uninstall Norton Security. It's garbage and will fuck up your install.\nAt the very least make sure it's disabled.${RESET}\n"
	sleep 3
fi

if [ -d "C:/Program Files/McAfee/" ] || [ -d "C:/Program Files (x86)/McAfee/" ]; then
	echo -e "\n${RED}McAfee Detected${RESET}\n\n${YELLOW}Uninstall McAfee. It's garbage and will fuck up your install.\nAt the very least make sure it's disabled.${RESET}\n"
	sleep 3
fi

if [ -d "C:/Program Files/Kaspersky Lab/" ] || [ -d "C:/Program Files (x86)/Kaspersky Lab/" ]; then
	echo -e "\n${RED}Kaspersky Detected${RESET}\n\n${YELLOW}Uninstall Kaspersky. It's garbage and will fuck up your install.\nAt the very least make sure it's disabled.${RESET}\n"
	sleep 3
fi

buildOptions=("$@")

# Check dependencies

if [[ " ${buildOptions[@]} " =~ " INSTALLDEP64BIT " ]] || [[ ! $(command -v git) ]]; then
	for i in ${DEPENDENCIES64BIT[@]}; do
		if [[ ! $(pacman -Q $i 2> /dev/null) ]]; then
			echo -e "\n${RED}Dependencies are missing. Proceeding with installation... ${RESET}\n" >&2
			pacman -S $i --noconfirm
		else
			echo -e "\n${GREEN}$i is installed.${RESET}\n"
		fi
	done
	pacman -Syuu --noconfirm
fi

if [[ " ${buildOptions[@]} " =~ " INSTALLDEP32BIT " ]] || [[ ! $(command -v git) ]]; then
	for i in ${DEPENDENCIES32BIT[@]}; do
		if [[ ! $(pacman -Q $i 2> /dev/null) ]]; then
			echo -e "\n${RED}Dependencies are missing. Proceeding with installation... ${RESET}\n" >&2
			pacman -S $i --noconfirm
		else
			echo -e "\n${GREEN}$i is installed.${RESET}\n"
		fi
	done
	pacman -Syuu --noconfirm
fi

if [ ! -f "$MINGW_HOME/bin/zenity.exe" ]; then
	download -O "$MINGW_HOME/bin/zenity.exe" https://cdn.discordapp.com/attachments/718584345912148100/721406762884005968/zenity.exe
fi

if [[ " ${buildOptions[@]} " =~ " INSTALLCLANGDEP64BIT " ]]; then
	if [[ ! $(pacman -Q mingw-w64-x86_64-clang) ]]; then
		echo -e "\n${RED}mingw-w64-x86_64-clang is missing. Proceeding with installation... ${RESET}\n"
		pacman -S mingw-w64-x86_64-clang --noconfirm
	else
		echo -e "\n${GREEN}mingw-w64-x86_64-clang is installed.${RESET}\n"
	fi
fi

if [[ " ${buildOptions[@]} " =~ " INSTALLCLANGDEP32BIT " ]]; then
	if [[ ! $(pacman -Q mingw-w64-i686-clang) ]]; then
		echo -e "\n${RED}mingw-w64-i686-clang is missing. Proceeding with installation... ${RESET}\n"
		pacman -S mingw-w64-i686-clang --noconfirm
	else
		echo -e "\n${GREEN}mingw-w64-i686-clang is installed.${RESET}\n"
	fi
fi

# Auto Launch

if [[ " ${buildOptions[@]} " =~ " AUTOLAUNCH " ]]; then
    Auto_Launch=true
fi

# Versions

VERSION=us

if [[ " ${buildOptions[@]} " =~ " VERSION=jp " ]]; then
	VERSION=jp
fi

if [[ " ${buildOptions[@]} " =~ " VERSION=eu " ]]; then
	VERSION=eu
fi

ROM_CHECK=./roms/baserom."$VERSION".z64
BINARY=./build/"$VERSION"_pc/sm64*

# Clone and extract assets

if [[ " ${buildOptions[@]} " =~ " CLONEONLY " ]]; then
	if  [[ ! $(command -v git) || ! $(command -v python3) ]]; then
		pacman -S git python3 --noconfirm
	fi
	if [[ " ${buildOptions[@]} " =~ " RENDER96EX " ]]; then
		if [ -d "./Render96ex-master" ]; then
			rm -f -r "Render96ex-master"
		fi
		gitClone https://github.com/Render96/Render96ex.git "Render96ex-master"
		cd "./Render96ex-master"
	fi
	if [[ " ${buildOptions[@]} " =~ " SM64EXCOOP " ]]; then
		if [ -d "./sm64ex-coop" ]; then
			rm -f -r "sm64ex-coop"
		fi
		gitClone https://github.com/djoslin0/sm64ex-coop.git
		cd "./sm64ex-coop"
	fi
	if [[ " ${buildOptions[@]} " =~ " SM64EX " ]] && [ "$1" = nightly ]; then
		if [ -d "./sm64ex-nightly" ]; then
			rm -f -r "sm64ex-nightly"
		fi
		gitClone https://github.com/sm64pc/sm64ex.git -b nightly "sm64ex-nightly"
		cd "./sm64ex-nightly"
	fi
	if [[ " ${buildOptions[@]} " =~ " SM64EX " ]] && [ "$1" = master ]; then
		if [ -d "./sm64ex-master" ]; then
			rm -f -r "sm64ex-master"
		fi
		gitClone https://github.com/sm64pc/sm64ex.git "sm64ex-master"
		cd "./sm64ex-master"
	fi
	if [[ " ${buildOptions[@]} " =~ " SM64PORT " ]]; then
		if [ -d "./sm64-port-master" ]; then
			rm -f -r "sm64-port-master"
		fi
		gitClone https://github.com/sm64-port/sm64-port.git "sm64-port-master"
		cd "./sm64-port-master"
	fi
	cp '../roms/baserom.'"$VERSION"'.z64' 'baserom.'"$VERSION"'.z64'
	echo -e "\n${CYAN}Extracting assets...${RESET}\n"
	./extract_assets.py "$VERSION"
	exit
fi

# Update master check

pull_master () {
	if [[ " ${buildOptions[@]} " =~ " NOUPDATE " ]]; then
		echo -e "\n${YELLOW}Skipping master updates...${RESET}\n"
		sleep 1
		return
	fi
	echo -e "\n${YELLOW}Downloading available master updates...${RESET}\n"
	git stash push
	git stash drop
	git pull
	sleep 2
}

# Update nightly check

pull_nightly () {
	if [[ " ${buildOptions[@]} " =~ " NOUPDATE " ]]; then
		echo -e "\n${YELLOW}Skipping nightly updates...${RESET}\n"
		sleep 1
		return
	fi
	echo -e "\n${YELLOW}Downloading available nightly updates...${RESET}\n"
	git stash push
	git stash drop
	git pull
	sleep 2
}

# Update coop check

pull_coop () {
	if [[ " ${buildOptions[@]} " =~ " NOUPDATE " ]]; then
		echo -e "\n${YELLOW}Skipping coop updates...${RESET}\n"
		sleep 1
		return
	fi
	echo -e "\n${YELLOW}Downloading available coop updates...${RESET}\n"
	git stash push
	git stash drop
	git pull
	sleep 2
}

#----- Render96ex repo -----#

if [[ " ${buildOptions[@]} " =~ " RENDER96EX " ]]; then

	if [[ " ${buildOptions[@]} " =~ " DELETEBRANCH " ]] && [ "$1" = master ]; then
		rm -f -r "Render96ex-master"
	fi

	if [ "$1" = master ] && [ -d "$RENDER96EX_MASTER_GIT" ]; then
		cd "./Render96ex-master"
		echo -e "\n"
		[ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | \
		sed 's/\// /g') | cut -f1) ] && echo -e "\n${GREEN}Render96ex-master is up to date\n${RESET}" || pull_master "${buildOptions[@]}"
		cd "../"
		I_Want_Master=true
	elif [ "$1" = master ] && [ ! -d "$RENDER96EX_MASTER_GIT" ]; then
		gitClone https://github.com/Render96/Render96ex.git "Render96ex-master"
		I_Want_Master=true
	fi

# Checks for which version the user selected & if baserom exists

	if [ "$I_Want_Master" = true ]; then
		if [ -f "$ROM_CHECK" ]; then
			echo -e "\n${GREEN}Baserom detected${RESET}\n"
			cp './roms/baserom.'"$VERSION"'.z64' './Render96ex-master/baserom.'"$VERSION"'.z64'
		else
			if [ "$VERSION" = us ]; then
				echo -e "\n${YELLOW}Place your baserom.us.z64 file in the roms folder${RESET}\n"
			elif [ "$VERSION" = jp ]; then
				echo -e "\n${YELLOW}Place your baserom.jp.z64 file in the roms folder${RESET}\n"
			elif [ "$VERSION" = eu ]; then
				echo -e "\n${YELLOW}Place your baserom.eu.z64 file in the roms folder${RESET}\n"
			fi
			read -n 1 -r -s -p $'Press Enter to continue...\n'
			cp './roms/baserom.'"$VERSION"'.z64' './Render96ex-master/baserom.'"$VERSION"'.z64'
		fi
		cd "./Render96ex-master"
	fi

	# Enable LEGACY_RES for Render96ex

	if grep -q 'LEGACY_RES ?= 1' "Makefile"; then
		echo -e "\n${GREEN}This Makefile line is already modified correctly.${RESET}\n"
	else
		sed -i 's/LEGACY_RES ?= 0/LEGACY_RES ?= 1/g' "Makefile"
	fi

	if [[ " ${buildOptions[@]} " =~ " DELETEBUILD " ]]; then
		rm -f -r "build"
	fi
fi

#----- End Render96ex repo -----#

#----- sm64ex-coop repo -----#

if [[ " ${buildOptions[@]} " =~ " SM64EXCOOP " ]]; then

	if [[ " ${buildOptions[@]} " =~ " DELETEBRANCH " ]]; then
		rm -f -r "sm64ex-coop"
	fi

	if [ -d "$SM64EXCOOP_GIT" ]; then
		cd "./sm64ex-coop"
		echo -e "\n"
		[ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | \
		sed 's/\// /g') | cut -f1) ] && echo -e "\n${GREEN}sm64ex-coop is up to date\n${RESET}" || pull_coop "${buildOptions[@]}"
		cd "../"
	elif [ ! -d "$SM64EXCOOP_GIT" ]; then
		gitClone https://github.com/djoslin0/sm64ex-coop.git
	fi

# Checks for which version the user selected & if baserom exists

	if [ -f "$ROM_CHECK" ]; then
		echo -e "\n${GREEN}Baserom detected${RESET}\n"
		cp './roms/baserom.'"$VERSION"'.z64' './sm64ex-coop/baserom.'"$VERSION"'.z64'
	else
		if [ "$VERSION" = us ]; then
			echo -e "\n${YELLOW}Place your baserom.us.z64 file in the roms folder${RESET}\n"
		elif [ "$VERSION" = jp ]; then
			echo -e "\n${YELLOW}Place your baserom.jp.z64 file in the roms folder${RESET}\n"
		elif [ "$VERSION" = eu ]; then
			echo -e "\n${YELLOW}Place your baserom.eu.z64 file in the roms folder${RESET}\n"
		fi
		read -n 1 -r -s -p $'Press Enter to continue...\n'
		cp './roms/baserom.'"$VERSION"'.z64' './sm64ex-coop/baserom.'"$VERSION"'.z64'
	fi
	cd "./sm64ex-coop"

	if [[ " ${buildOptions[@]} " =~ " DELETEBUILD " ]]; then
		rm -f -r "build"
	fi
fi

#----- End sm64ex-coop repo -----#

#----- sm64ex repo -----#

if [[ " ${buildOptions[@]} " =~ " SM64EX " ]]; then

	if [[ " ${buildOptions[@]} " =~ " DELETEBRANCH " ]] && [ "$1" = master ]; then
		rm -f -r "sm64ex-master"
	fi

	if [[ " ${buildOptions[@]} " =~ " DELETEBRANCH " ]] && [ "$1" = nightly ]; then
		rm -f -r "sm64ex-nightly"
	fi

	if [ "$1" = master ] && [ -d "$MASTER_GIT" ]; then
		cd "./sm64ex-master"
		echo -e "\n"
		[ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | \
		sed 's/\// /g') | cut -f1) ] && echo -e "\n${GREEN}sm64ex-master is up to date\n${RESET}" || pull_master "${buildOptions[@]}"
		cd "../"
		I_Want_Master=true
	elif [ "$1" = master ] && [ ! -d "$MASTER_GIT" ]; then
		gitClone https://github.com/sm64pc/sm64ex.git "sm64ex-master"
		I_Want_Master=true
	fi

	if [ "$1" = nightly ] && [ -d "$NIGHTLY_GIT" ]; then
		cd "./sm64ex-nightly"
		echo -e "\n"
		[ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | \
		sed 's/\// /g') | cut -f1) ] && echo -e "\n${GREEN}sm64ex-nightly is up to date\n${RESET}" || pull_nightly "${buildOptions[@]}"
		cd "../"
		I_Want_Nightly=true
	elif [ "$1" = nightly ] && [ ! -d "$NIGHTLY_GIT" ]; then
		gitClone https://github.com/sm64pc/sm64ex.git -b nightly "sm64ex-nightly"
		I_Want_Nightly=true
	fi

	if [ "$I_Want_Master" = true ]; then
		if [ -f "$ROM_CHECK" ]; then
			echo -e "\n${YELLOW}Baserom detected${RESET}\n"
			cp './roms/baserom.'"$VERSION"'.z64' './sm64ex-master/baserom.'"$VERSION"'.z64'
		else
			if [ "$VERSION" = us ]; then
				echo -e "\n${YELLOW}Place your baserom.us.z64 file in the roms folder${RESET}\n"
			elif [ "$VERSION" = jp ]; then
				echo -e "\n${YELLOW}Place your baserom.jp.z64 file in the roms folder${RESET}\n"
			elif [ "$VERSION" = eu ]; then
				echo -e "\n${YELLOW}Place your baserom.eu.z64 file in the roms folder${RESET}\n"
			fi
			read -n 1 -r -s -p $'Press Enter to continue...\n'
			cp './roms/baserom.'"$VERSION"'.z64' './sm64ex-master/baserom.'"$VERSION"'.z64'
		fi
		cd "./sm64ex-master"
	fi

	if [ "$I_Want_Nightly" = true ]; then
		if [ -f "$ROM_CHECK" ]; then
			echo -e "\n${YELLOW}Baserom detected${RESET}\n"
			cp './roms/baserom.'"$VERSION"'.z64' './sm64ex-nightly/baserom.'"$VERSION"'.z64'
		else
			if [ "$VERSION" = us ]; then
				echo -e "\n${YELLOW}Place your baserom.us.z64 file in the roms folder${RESET}\n"
			elif [ "$VERSION" = jp ]; then
				echo -e "\n${YELLOW}Place your baserom.jp.z64 file in the roms folder${RESET}\n"
			elif [ "$VERSION" = eu ]; then
				echo -e "\n${YELLOW}Place your baserom.eu.z64 file in the roms folder${RESET}\n"
			fi
			read -n 1 -r -s -p $'Press Enter to continue...\n'
			cp './roms/baserom.'"$VERSION"'.z64' './sm64ex-nightly/baserom.'"$VERSION"'.z64'
		fi
		cd "./sm64ex-nightly"
	fi

	if [[ " ${buildOptions[@]} " =~ " DELETEBUILD " ]]; then
		rm -f -r "build"
	fi
fi

#----- End sm64ex repo -----#

#----- sm64-port repo -----#

if [[ " ${buildOptions[@]} " =~ " SM64PORT " ]]; then

	if [[ " ${buildOptions[@]} " =~ " DELETEBRANCH " ]] && [ "$1" = master ]; then
		rm -f -r "sm64-port-master"
	fi

	if [ "$1" = master ] && [ -d "$SM64PORT_MASTER_GIT" ]; then
		cd "./sm64-port-master"
		echo -e "\n"
		[ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | \
		sed 's/\// /g') | cut -f1) ] && echo -e "\n${GREEN}sm64-port-master is up to date\n${RESET}" || pull_master "${buildOptions[@]}"
		cd "../"
		I_Want_Master=true
	elif [ "$1" = master ] && [ ! -d "$SM64PORT_MASTER_GIT" ]; then
		gitClone https://github.com/sm64-port/sm64-port.git "sm64-port-master"
		I_Want_Master=true
	fi

# Checks for which version the user selected & if baserom exists

	if [ "$I_Want_Master" = true ]; then
		if [ -f "$ROM_CHECK" ]; then
			echo -e "\n${GREEN}Baserom detected${RESET}\n"
			cp './roms/baserom.'"$VERSION"'.z64' './sm64-port-master/baserom.'"$VERSION"'.z64'
		else
			if [ "$VERSION" = us ]; then
				echo -e "\n${YELLOW}Place your baserom.us.z64 file in the roms folder${RESET}\n"
			elif [ "$VERSION" = jp ]; then
				echo -e "\n${YELLOW}Place your baserom.jp.z64 file in the roms folder${RESET}\n"
			elif [ "$VERSION" = eu ]; then
				echo -e "\n${YELLOW}Place your baserom.eu.z64 file in the roms folder${RESET}\n"
			fi
			read -n 1 -r -s -p $'Press Enter to continue...\n'
			cp './roms/baserom.'"$VERSION"'.z64' './sm64-port-master/baserom.'"$VERSION"'.z64'
		fi
		cd "./sm64-port-master"
	fi

	if [[ " ${buildOptions[@]} " =~ " DELETEBUILD " ]]; then
		rm -f -r "build"
	fi
fi

#----- End sm64-port repo -----#

# Render96 Project

if [[ " ${buildOptions[@]} " =~ " RENDER96 " ]]; then
	if [ -d "../Render96ex-master" ] || [ -d "../sm64ex-coop" ]; then
		echo -e "\n${CYAN}Render96 Project 1.4.2 Luigi Pack Selected\nCleaning all folders used by Render96 to prepare for installation...${RESET}\n"
		rm -rf actors
		if [[ " ${buildOptions[@]} " =~ " RENDER96EX " ]]; then
		    rm -rf assets
		    rm -rf bin
    		rm -rf data
    		rm -rf include
    		rm -rf levels
    		rm -rf src
    		rm -rf text
    		rm -rf textures
    		rm -rf tools
		fi
		git checkout actors
		if [[ " ${buildOptions[@]} " =~ " RENDER96EX " ]]; then
    		git checkout assets
    		git checkout bin
    		git checkout data
    		git checkout include
    		git checkout levels
    		git checkout src
    		git checkout text
    		git checkout tools
    	fi
		echo -e "\n${CYAN}Extracting assets...${RESET}\n"
		./extract_assets.py "$VERSION"
		echo -e "\n${CYAN}Installing Render96 Project 1.4.2 Luigi Pack...${RESET}\n"
		if [[ " ${buildOptions[@]} " =~ " RENDER96EX " ]] && [[ -f "../models_cache/RENDER96_V1.4.2_Luigi_Fixed_Sound.zip" ]]; then
			cp "../models_cache/RENDER96_V1.4.2_Luigi_Fixed_Sound.zip" "."
			unzip -o "RENDER96_V1.4.2_Luigi_Fixed_Sound.zip"
		elif [[ " ${buildOptions[@]} " =~ " RENDER96EX " ]]; then
			download -O "../models_cache/RENDER96_V1.4.2_Luigi_Fixed_Sound.zip" https://sm64pc.info/downloads/RENDER96_V1.4.2_Luigi_Fixed_Sound.zip
			cp "../models_cache/RENDER96_V1.4.2_Luigi_Fixed_Sound.zip" "."
			unzip -o "RENDER96_V1.4.2_Luigi_Fixed_Sound.zip"
		fi
		if [[ " ${buildOptions[@]} " =~ " SM64EXCOOP " ]] && [[ -f "../models_cache/render96_coop.zip" ]]; then
			cp "../models_cache/render96_coop.zip" "."
			unzip -o "render96_coop.zip"
		elif [[ " ${buildOptions[@]} " =~ " SM64EXCOOP " ]]; then
			download -O "../models_cache/render96_coop.zip" https://sm64pc.info/downloads/model_pack/render96_coop.zip
			cp "../models_cache/render96_coop.zip" "."
			unzip -o "render96_coop.zip"
		fi
		if [[ " ${buildOptions[@]} " =~ " RENDER96EX " ]]; then
		    rm "RENDER96_V1.4.2_Luigi_Fixed_Sound.zip"
		elif [[ " ${buildOptions[@]} " =~ " SM64EXCOOP " ]]; then
		    rm "render96_coop.zip"
		fi
		echo -e "\n${GREEN}Render96 Project 1.4.2 Luigi Pack Installed${RESET}\n"
	fi
fi

#----- Misc -----#

# ReShade

if [[ " ${buildOptions[@]} " =~ " RESHADE " ]]; then
	if [[ ! -f "./ReShade_Setup_4.7.0.exe" ]]; then
		echo -e "\n${CYAN}Downloading ReShade 4.7.0 to root...${RESET}\n"
		download https://reshade.me/downloads/ReShade_Setup_4.7.0.exe
		echo -e "\n${GREEN}ReShade 4.7.0 Downloaded${RESET}\n"
	fi
fi

# 120 Star Save

if [[ " ${buildOptions[@]} " =~ " 120SAVE " ]]; then
	if [ -f "$APPDATA/sm64ex/render96_save_file_0.sav" ] && [[ " ${buildOptions[@]} " =~ " RENDER96 " ]]; then
		download https://cdn.discordapp.com/attachments/710569174472065104/748662128910794842/render96_save_file_0.sav
		mv -f "$APPDATA/sm64ex/render96_save_file_0.sav" "$APPDATA/sm64ex/render96_save_file_0.non120.sav"
		mv "render96_save_file_0.sav" "$APPDATA/sm64ex/render96_save_file_0.sav"
	elif [ -d "$APPDATA/sm64ex/" ] && [[ " ${buildOptions[@]} " =~ " RENDER96 " ]]; then
		download https://cdn.discordapp.com/attachments/710569174472065104/748662128910794842/render96_save_file_0.sav
		mv "render96_save_file_0.sav" "$APPDATA/sm64ex/render96_save_file_0.sav"
	fi
	if [ -f "$APPDATA/sm64ex/sm64_save_file_0.sav" ] && [[ " ${buildOptions[@]} " =~ " TEXTSAVES=1 " ]]; then
		download https://cdn.discordapp.com/attachments/710311726708686900/748658234793132134/sm64_save_file_0.sav
		mv -f "$APPDATA/sm64ex/sm64_save_file_0.sav" "$APPDATA/sm64ex/sm64_save_file_0.non120.sav"
		mv "sm64_save_file_0.sav" "$APPDATA/sm64ex/sm64_save_file_0.sav"
	elif [ -d "$APPDATA/sm64ex/" ] && [[ " ${buildOptions[@]} " =~ " TEXTSAVES=1 " ]]; then
		download https://cdn.discordapp.com/attachments/710311726708686900/748658234793132134/sm64_save_file_0.sav
		mv "sm64_save_file_0.sav" "$APPDATA/sm64ex/sm64_save_file_0.sav"
	fi
	if [ -f "$APPDATA/sm64pc/sm64_save_file_0.sav" ] && [[ " ${buildOptions[@]} " =~ " TEXTSAVES=1 " ]]; then
		download https://cdn.discordapp.com/attachments/710311726708686900/748658234793132134/sm64_save_file_0.sav
		mv -f "$APPDATA/sm64pc/sm64_save_file_0.sav" "$APPDATA/sm64pc/sm64_save_file_0.non120.sav"
		mv "sm64_save_file_0.sav" "$APPDATA/sm64pc/sm64_save_file_0.sav"
	elif [ -d "$APPDATA/sm64pc/" ] && [[ " ${buildOptions[@]} " =~ " TEXTSAVES=1 " ]]; then
		download https://cdn.discordapp.com/attachments/710311726708686900/748658234793132134/sm64_save_file_0.sav
		mv "sm64_save_file_0.sav" "$APPDATA/sm64pc/sm64_save_file_0.sav"
	fi
	if [ -f "$APPDATA/sm64ex/sm64_save_file.bin" ]; then
		download https://cdn.discordapp.com/attachments/710283360794181633/718232280224628796/sm64_save_file.bin
		mv -f "$APPDATA/sm64ex/sm64_save_file.bin" "$APPDATA/sm64ex/sm64_save_file.non120.bin"
		mv "sm64_save_file.bin" "$APPDATA/sm64ex/sm64_save_file.bin"
	elif [ -d "$APPDATA/sm64ex/" ]; then
		download https://cdn.discordapp.com/attachments/710283360794181633/718232280224628796/sm64_save_file.bin
		mv "sm64_save_file.bin" "$APPDATA/sm64ex/sm64_save_file.bin"
	fi
	if [ -f "$APPDATA/sm64pc/sm64_save_file.bin" ]; then
		download https://cdn.discordapp.com/attachments/710283360794181633/718232280224628796/sm64_save_file.bin
		mv -f "$APPDATA/sm64pc/sm64_save_file.bin" "$APPDATA/sm64pc/sm64_save_file.non120.bin"
		mv "sm64_save_file.bin" "$APPDATA/sm64pc/sm64_save_file.bin"
	elif [ -d "$APPDATA/sm64pc/" ]; then
		download https://cdn.discordapp.com/attachments/710283360794181633/718232280224628796/sm64_save_file.bin
		mv "sm64_save_file.bin" "$APPDATA/sm64pc/sm64_save_file.bin"
	fi
	if [ -f './build/'"$VERSION"'_pc/sm64_save_file.bin' ]; then
		download https://cdn.discordapp.com/attachments/710283360794181633/718232280224628796/sm64_save_file.bin
		mv -f './build/'"$VERSION"'_pc/sm64_save_file.bin' './build/'"$VERSION"'_pc/sm64_save_file.non120.bin'
		mv "sm64_save_file.bin" './build/'"$VERSION"'_pc/sm64_save_file.bin'
	elif [[ " ${buildOptions[@]} " =~ " SM64PORT " ]]; then
	    download https://cdn.discordapp.com/attachments/710283360794181633/718232280224628796/sm64_save_file.bin
	    if [ ! -d './build/'"$VERSION"'_pc' ]; then
		    mkdir -p 'build/'"$VERSION"'_pc'
		fi
		mv "sm64_save_file.bin" './build/'"$VERSION"'_pc/sm64_save_file.bin'
	fi
	echo -e "$\n${GREEN}120 Star Save Selected${RESET}\n"
fi

#----- End Misc -----#

#----- Patches -----#

# 60 FPS Patch (Nightly)

if [[ " ${buildOptions[@]} " =~ " 60FPSNIGHTLY " ]]; then
	if [[ -f "./enhancements/60fps_ex.patch" ]]; then
		git apply "./enhancements/60fps_ex.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}60 FPS EX Patch Selected${RESET}\n"
	else
		git checkout enhancements/60fps_ex.patch
		git apply "./enhancements/60fps_ex.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}60 FPS EX Patch Selected${RESET}\n"
	fi
fi

# Don't Exit From Star Patch

if [[ " ${buildOptions[@]} " =~ " NOEXITSTAR " ]]; then
	if [[ -f "./enhancements/stay_in_course.patch" ]]; then
		git apply "./enhancements/stay_in_course.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}Don't Exit From Star Patch Selected${RESET}\n"
	else
		cd "./enhancements"
		download https://cdn.discordapp.com/attachments/723337662479466576/723337747745734686/stay_in_course.patch
		cd "../"
		git apply "./enhancements/stay_in_course.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}Don't Exit From Star Patch Selected${RESET}\n"
	fi
fi

# Tight Controls Patch

if [[ " ${buildOptions[@]} " =~ " TIGHTCONTROLS " ]]; then
	if [[ -f "./enhancements/tight_controls.patch" ]]; then
		git apply "./enhancements/tight_controls.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}Tight Controls Patch Selected${RESET}\n"
	else
		cd "./enhancements"
		download https://cdn.discordapp.com/attachments/725049835534942229/725051214940733451/tight_controls.patch
		cd "../"
		git apply "./enhancements/tight_controls.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}Tight Controls Patch Selected${RESET}\n"
	fi
fi

# Captain Toad Patch

if [[ " ${buildOptions[@]} " =~ " CAPTAINTOAD " ]]; then
	if [[ -f "./enhancements/captain_toad_stars.patch" ]]; then
		git apply "./enhancements/captain_toad_stars.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}Captain Toad Patch Selected${RESET}\n"
	else
		cd "./enhancements"
		download https://cdn.discordapp.com/attachments/725049835534942229/725051233378893894/captain_toad_stars.patch
		cd "../"
		git apply "./enhancements/captain_toad_stars.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}Captain Toad Patch Selected${RESET}\n"
	fi
fi

# Return To Title Screen From Ending Patch

if [[ " ${buildOptions[@]} " =~ " TITLERETURN " ]]; then
	if [[ -f "./enhancements/leave_ending_screen.patch" ]]; then
		git apply "./enhancements/leave_ending_screen.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}Leave Ending Screen v2 Patch Selected${RESET}\n"
	else
		cd "./enhancements"
		download https://sm64pc.info/downloads/patches/leave_ending_screen.patch
		cd "../"
		git apply "./enhancements/leave_ending_screen.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}Leave Ending Screen v2 Patch Selected${RESET}\n"
	fi
fi

#3D Coin

if [[ " ${buildOptions[@]} " =~ " 3DCOIN " ]]; then
	if [[ -f "./enhancements/3d_coin_v2_nightly.patch" ]]; then
		git apply "./enhancements/3d_coin_v2_nightly.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}3D Coin Patch v2 Selected${RESET}\n"
	else
		cd "./enhancements"
		download https://cdn.discordapp.com/attachments/721806706547490868/725041183700680807/3d_coin_v2_nightly.patch
		cd "../"
		git apply "./enhancements/3d_coin_v2_nightly.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}3D Coin Patch v2 Selected${RESET}\n"
	fi
fi

#Exit Course 50 Coin Fix

if [[ " ${buildOptions[@]} " =~ " EXIT50COIN " ]]; then
	if [[ -f "./enhancements/exit_course_50_coin_fix.patch" ]]; then
		git apply "./enhancements/exit_course_50_coin_fix.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}Exit Course 50 Coin Fix Selected${RESET}\n"
	else
		cd "./enhancements"
		download https://cdn.discordapp.com/attachments/721818545087840257/725094603258200105/exit_course_50_coin_fix.patch
		cd "../"
		git apply "./enhancements/exit_course_50_coin_fix.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}Exit Course 50 Coin Fix Selected${RESET}\n"
	fi
fi

#Mouse Fix

if [[ " ${buildOptions[@]} " =~ " MOUSEFIX " ]]; then
	if [[ -f "./enhancements/0001-WIP-Added-mouse-support-and-some-fixes-for-reshade-1.patch" ]]; then
		git apply "./enhancements/0001-WIP-Added-mouse-support-and-some-fixes-for-reshade-1.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}Mouse Fix Selected${RESET}\n"
	else
		cd "./enhancements"
		download https://cdn.discordapp.com/attachments/710569174472065104/725894098141184000/0001-WIP-Added-mouse-support-and-some-fixes-for-reshade-1.patch
		cd "../"
		git apply "./enhancements/0001-WIP-Added-mouse-support-and-some-fixes-for-reshade-1.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}Mouse Fix Selected${RESET}\n"
	fi
fi

#Exit to Title

if [[ " ${buildOptions[@]} " =~ " TITLEEXIT " ]]; then
	if [[ -f "./enhancements/Added-exit-button.patch" ]]; then
		git apply "./enhancements/Added-exit-button.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}Exit to Title Selected${RESET}\n"
	else
		cd "./enhancements"
		download https://cdn.discordapp.com/attachments/710569174472065104/728642716665380904/Added-exit-button.patch
		cd "../"
		git apply "./enhancements/Added-exit-button.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}Exit to Title Selected${RESET}\n"
	fi
fi

#Star Select Delay

if [[ " ${buildOptions[@]} " =~ " STARDELAY " ]]; then
	if [[ -f "./enhancements/increase_delay_on_star_select.patch" ]]; then
		git apply "./enhancements/increase_delay_on_star_select.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}Star Select Delay Selected${RESET}\n"
	else
		cd "./enhancements"
		download https://cdn.discordapp.com/attachments/710569174472065104/725894126624571503/increase_delay_on_star_select.patch
		cd "../"
		git apply "./enhancements/increase_delay_on_star_select.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}Star Select Delay Selected${RESET}\n"
	fi
fi

# Puppycam (sm64-port)

if [[ " ${buildOptions[@]} " =~ " PUPPYCAM " ]]; then
	if [[ -f "./enhancements/puppycam.patch" ]]; then
		git apply ./enhancements/puppycam.patch --ignore-whitespace --reject
		echo -e "\n${GREEN}Puppycam 3.1 Selected${RESET}\n"
	else
		cd ./enhancements
		download https://github.com/FazanaJ/puppycam/releases/download/Puppy3.1/puppycam.patch
		cd ../
		git apply ./enhancements/puppycam.patch --ignore-whitespace --reject
		echo -e "\n${GREEN}Puppycam 3.1 Selected${RESET}\n"
	fi
fi

# 60 FPS Patch (sm64-port)

if [[ " ${buildOptions[@]} " =~ " 60FPSPORT " ]]; then
	if [[ -f "./enhancements/60fps.patch" ]]; then
		git apply "./enhancements/60fps.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}60 FPS Patch Selected${RESET}\n"
	else
		cd "./enhancements"
		download https://cdn.discordapp.com/attachments/710569174472065104/729445185158905926/60fps.patch
		cd "../"
		git apply "./enhancements/60fps.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}60 FPS Patch Selected${RESET}\n"
	fi
fi

# Stay in Level After Star (Every Repo and Branch)

if [[ " ${buildOptions[@]} " =~ " STAYINLEVEL " ]]; then
	if [[ -f "./enhancements/nonstop_mode_always_enabled.patch" ]]; then
		git apply "./enhancements/nonstop_mode_always_enabled.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}Stay in Level After Star Selected${RESET}\n"
	else
		cd "./enhancements"
		download https://cdn.discordapp.com/attachments/716459185230970880/729819298964570142/nonstop_mode_always_enabled.patch
		cd "../"
		git apply "./enhancements/nonstop_mode_always_enabled.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}Stay in Level After Star Selected${RESET}\n"
	fi
fi

# Blarggs

#if [[ " ${buildOptions[@]} " =~ " BLARGGS " ]]; then
#	if [[ -f "./enhancements/blarggs.patch" ]]; then
#		git apply "./enhancements/blarggs.patch" --ignore-whitespace --reject
#		echo -e "\n${GREEN}Blarggs Selected${RESET}\n"
#	else
#		cd "./enhancements"
#		download https://cdn.discordapp.com/attachments/719344371291521024/733104874585325618/blarggs.patch
#		cd "../"
#		git apply "./enhancements/blarggs.patch" --ignore-whitespace --reject
#		echo -e "\n${GREEN}Blarggs Selected${RESET}\n"
#	fi
#fi

# Dynamic Options System

if [[ " ${buildOptions[@]} " =~ " DYNOS " ]]; then
	cd "./enhancements"
	download -O "DynOS.patch" https://sm64pc.info/downloads/patches/DynOS.patch
	cd "../"
	git apply "./enhancements/DynOS.patch" --ignore-whitespace --reject
	echo -e "\n${GREEN}Dynamic Options System v0.3 Selected${RESET}\n"
fi

# Time Trials

if [[ " ${buildOptions[@]} " =~ " TIMETRIALS " ]]; then
	cd "./enhancements"
	download -O "time_trials.patch" https://sm64pc.info/downloads/patches/time_trials.patch
	cd "../"
	git apply "./enhancements/time_trials.patch" --ignore-whitespace --reject
	echo -e "\n${GREEN}Time Trials v2.0 Selected${RESET}\n"
fi

# Odyssey Moveset

if [[ " ${buildOptions[@]} " =~ " ODYSSEYMOVESET " ]]; then
	cd "./enhancements"
	download -O "smo.patch" https://sm64pc.info/downloads/patches/smo.patch
	cd "../"
	git apply "./enhancements/smo.patch" --ignore-whitespace --reject
	echo -e "\n${GREEN}Super Mario Odyssey - Mario Moveset v2.0.2 Selected${RESET}\n"
fi

# CHEATER

if [[ " ${buildOptions[@]} " =~ " CHEATER " ]]; then
	cd "./enhancements"
	if [[ " ${buildOptions[@]} " =~ " RENDER96EX " ]]; then
	    download -O "CHEATERRender96ex.patch" https://sm64pc.info/downloads/patches/CHEATERRender96ex.patch
	elif [[ " ${buildOptions[@]} " =~ " SM64EXCOOP " ]]; then
		download -O "CHEATER-coop.patch" https://sm64pc.info/downloads/patches/CHEATER-coop.patch
	elif [ "$1" = nightly ]; then
		download -O "CHEATER.patch" https://sm64pc.info/downloads/patches/CHEATER.patch
	fi
	cd "../"
	if [[ " ${buildOptions[@]} " =~ " RENDER96EX " ]]; then
	    git apply "./enhancements/CHEATERRender96ex.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}CHEATERRender96ex Selected${RESET}\n"
	elif [[ " ${buildOptions[@]} " =~ " SM64EXCOOP " ]]; then
		git apply "./enhancements/CHEATER-coop.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}CHEATER Co-opv1 Selected${RESET}\n"
	elif [ "$1" = nightly ]; then
		git apply "./enhancements/CHEATER.patch" --ignore-whitespace --reject
		echo -e "\n${GREEN}CHEATERv7 Selected${RESET}\n"
	fi
fi

#Custom Patches

if [[ " ${buildOptions[@]} " =~ " CUSTOMPATCHES " ]]; then
	patches=(../patches/*)

	# iterate through array using a counter
	for ((i=0; i<${#patches[@]}; i++)); do
		git apply ${patches[$i]} --ignore-whitespace --reject
		echo "${patches[$i]}"
		sleep 2
	done
fi


#----- End Patches -----#

#----- Models -----#

# Restore Actors

if [[ " ${buildOptions[@]} " =~ " RESTOREACTORS " ]]; then
	rm -rf "actors"
	git checkout actors
	echo -e "\n${CYAN}Extracting assets...${RESET}\n"
	./extract_assets.py "$VERSION"
	echo -e "\n${GREEN}Actors have been restored${RESET}\n"
fi

# HD Mario

if [[ " ${buildOptions[@]} " =~ " HDMARIO " ]]; then
	if [[ -f "../models_cache/HD_Mario_Model.rar" ]]; then
		cp "../models_cache/HD_Mario_Model.rar" "."
		unrar x -o+ "./HD_Mario_Model.rar"
	else
		download -O "../models_cache/HD_Mario_Model.rar" https://cdn.discordapp.com/attachments/710283360794181633/717479061664038992/HD_Mario_Model.rar
		cp "../models_cache/HD_Mario_Model.rar" "."
		unrar x -o+ "./HD_Mario_Model.rar"
	fi
	rm "HD_Mario_model.rar"
	echo -e "\n${GREEN}HD Mario Selected${RESET}\n"
fi

#HD Bowser

if [[ " ${buildOptions[@]} " =~ " HDBOWSER " ]]; then
	if [[ -f "../models_cache/hd_bowser.rar" ]]; then
		cp "../models_cache/hd_bowser.rar" "."
		unrar x -o+ "./hd_bowser.rar"
	else
		download -O "../models_cache/hd_bowser.rar" https://cdn.discordapp.com/attachments/716459185230970880/718990046442684456/hd_bowser.rar
		cp "../models_cache/hd_bowser.rar" "."
		unrar x -o+ "./hd_bowser.rar"
	fi
	rm "hd_bowser.rar"
	echo -e "\n${GREEN}HD Bowser Selected${RESET}\n"
fi

#Luigi

if [[ " ${buildOptions[@]} " =~ " LUIGI " ]]; then
	if [[ -f "../models_cache/Luigi.rar" ]]; then
		cp "../models_cache/Luigi.rar" "."
		unrar x -o+ "./Luigi.rar"
	else
		download -O "../models_cache/Luigi.rar" https://cdn.discordapp.com/attachments/725049835534942229/725463078703202405/Luigi.rar
		cp "../models_cache/Luigi.rar" "."
		unrar x -o+ "./Luigi.rar"
	fi
	if grep -q '#include "mario/geo_header.h"' "./actors/group0.h"; then
		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
	else
		sed -i '/#endif/i \
#include "mario/geo_header.h"' "./actors/group0.h"
	fi
	rm "Luigi.rar"
	echo -e "\n${GREEN}Luigi Selected${RESET}\n"
fi

# Hat Kid Pack 2.0 or Bow Kid Pack 2.0

if [[ " ${buildOptions[@]} " =~ " HATKID " ]] || [[ " ${buildOptions[@]} " =~ " BOWKID " ]]; then
	if grep -q '#include "goomba/geo_header.h"' "./actors/common0.h"; then
		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
	else
		sed -i '/#endif/i \
#include "goomba/geo_header.h"' "./actors/common0.h"
	fi
	if grep -q '#include "mario/geo_header.h"' "./actors/group0.h"; then
		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
	else
		sed -i '/#endif/i \
#include "mario/geo_header.h"' "./actors/group0.h"
	fi
	if grep -q '#include "mario_cap/geo_header.h"' "./actors/common1.h"; then
		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
	else
		sed -i '/#endif/i \
#include "mario_cap/geo_header.h"' "./actors/common1.h"
	fi
	if grep -q '#include "mario_metal_cap/model.inc.c"' "./actors/common1.c"; then
		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
	else
		sed -i -e '$a\#include "mario_metal_cap/model.inc.c"' ./actors/common1.c
	fi
	if grep -q '#include "mario_metal_cap/geo_header.h"' "./actors/common1.h"; then
		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
	else
		sed -i '/#endif/i \
#include "mario_metal_cap/geo_header.h"' "./actors/common1.h"
	fi
	if grep -q '#include "mario_metal_cap/geo.inc.c"' "./actors/common1_geo.c"; then
		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
	else
		sed -i -e '$a\#include "mario_metal_cap/geo.inc.c"' "./actors/common1_geo.c"
	fi
	if grep -q '#include "mario_wing_cap/model.inc.c"' "./actors/common1.c"; then
		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
	else
		sed -i -e '$a\#include "mario_wing_cap/model.inc.c"' "./actors/common1.c"
	fi
	if grep -q '#include "mario_wing_cap/geo_header.h"' "./actors/common1.h"; then
		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
	else
		sed -i '/#endif/i \
#include "mario_wing_cap/geo_header.h"' "./actors/common1.h"
	fi
	if grep -q '#include "mario_wing_cap/geo.inc.c"' "./actors/common1_geo.c"; then
		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
	else
		sed -i -e '$a\#include "mario_wing_cap/geo.inc.c"' "./actors/common1_geo.c"
	fi
	if grep -q '#include "mario_winged_metal_cap/model.inc.c"' "./actors/common1.c"; then
		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
	else
		sed -i -e '$a\#include "mario_winged_metal_cap/model.inc.c"' "./actors/common1.c"
	fi
	if grep -q '#include "mario_winged_metal_cap/geo_header.h"' "./actors/common1.h"; then
		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
	else
		sed -i '/#endif/i \
#include "mario_winged_metal_cap/geo_header.h"' "./actors/common1.h"
	fi
	if grep -q '#include "mario_winged_metal_cap/geo.inc.c"' "./actors/common1_geo.c"; then
		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
	else
		sed -i -e '$a\#include "mario_winged_metal_cap/geo.inc.c"' "./actors/common1_geo.c"
	fi
	if grep -q '#include "star/geo_header.h"' "./actors/common1.h"; then
		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
	else
		sed -i '/#endif/i \
#include "star/geo_header.h"' "./actors/common1.h"
	fi
	if grep -q '#include "transparent_star/geo_header.h"' "./actors/common1.h"; then
		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
	else
		sed -i '/#endif/i \
#include "transparent_star/geo_header.h"' "./actors/common1.h"
	fi
	if grep -q 'mario_metal_cap' "Makefile.split"; then
		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
	else
		sed -i 's/mario_cap*/mario_cap mario_metal_cap/g' "Makefile.split"
	fi
	if grep -q 'mario_wing_cap' "Makefile.split"; then
		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
	else
		sed -i 's/mario_metal_cap*/mario_metal_cap mario_wing_cap/g' "Makefile.split"
	fi
	if grep -q 'mario_winged_metal_cap' "Makefile.split"; then
		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
	else
		sed -i 's/mario_wing_cap*/mario_wing_cap mario_winged_metal_cap/g' "Makefile.split"
	fi
fi

# Hat Kid Pack 2.0

if [[ " ${buildOptions[@]} " =~ " HATKID " ]]; then
	if [[ -f "../models_cache/hat_kid.rar" ]]; then
		cp "../models_cache/hat_kid.rar" "."
		unrar x -o+ "./hat_kid.rar"
	else
		download -O "../models_cache/hat_kid.rar" https://sm64pc.info/downloads/hat_kid.rar
		cp "../models_cache/hat_kid.rar" "."
		unrar x -o+ "./hat_kid.rar"
	fi
	rm "hat_kid.rar"
	if [ ! -d './build/'"$VERSION"'_pc/res' ]; then
		mkdir -p 'build/'"$VERSION"'_pc/res'
		mv "hat_kid_textures_sounds.zip" './build/'"$VERSION"'_pc/res/hat_kid_textures_sounds.zip'
	else
		mv "hat_kid_textures_sounds.zip" './build/'"$VERSION"'_pc/res/hat_kid_textures_sounds.zip'
	fi
	echo -e "\n${GREEN}Hat Kid Pack 2.0 Selected${RESET}\n"
fi

# Bow Kid Pack 2.0

if [[ " ${buildOptions[@]} " =~ " BOWKID " ]]; then
	if [[ -f "../models_cache/bow_kid.rar" ]]; then
		cp "../models_cache/bow_kid.rar" "."
		unrar x -o+ "./bow_kid.rar"
	else
		download -O "../models_cache/bow_kid.rar" https://sm64pc.info/downloads/bow_kid.rar
		cp "../models_cache/bow_kid.rar" "."
		unrar x -o+ "./bow_kid.rar"
	fi
	rm "bow_kid.rar"
	if [ ! -d './build/'"$VERSION"'_pc/res' ]; then
		mkdir -p 'build/'"$VERSION"'_pc/res'
		mv "bow_kid_textures_sounds.zip" './build/'"$VERSION"'_pc/res/bow_kid_textures_sounds.zip'
	else
		mv "bow_kid_textures_sounds.zip" './build/'"$VERSION"'_pc/res/bow_kid_textures_sounds.zip'
	fi
	echo -e "\n${GREEN}Bow Kid Pack 2.0 Selected${RESET}\n"
fi

#Mawio

if [[ " ${buildOptions[@]} " =~ " MAWIO " ]]; then
	download https://cdn.discordapp.com/attachments/725049835534942229/726455541232304198/mario_1.zip
	unzip -o "mario_1.zip"
	rm "mario_1.zip"
	if grep -q '#include "mario/geo_header.h"' "./actors/group0.h"; then
		echo -e "\n${RED}The fiwe is awweady modified cowwectwy.${RESET}\n"
	else
		sed -i '/#endif/i \
#include "mario/geo_header.h"' "./actors/group0.h"
	fi
	echo -e "\n${GREEN}Mawio Selected${RESET}\n"
fi

#Koopa The Quick

if [[ " ${buildOptions[@]} " =~ " KOOPAQUICK " ]]; then
	if [[ ! -f "../models_cache/koopa_the_quick.zip" ]]; then
		download -O "../models_cache/koopa_the_quick.zip" https://cdn.discordapp.com/attachments/725049835534942229/727137757201432627/koopa_the_quick.zip
	fi
	cp "../models_cache/koopa_the_quick.zip" "."
	unzip -o "koopa_the_quick.zip"
	rm "koopa_the_quick.zip"
	if grep -q '#include "koopa_shell/geo_header.h"' "./actors/common0.h"; then
		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
	else
		sed -i '/#endif/i \
#include "koopa_shell/geo_header.h"' "./actors/common0.h"
	fi
	if grep -q '#include "koopa/geo_header.h"' "./actors/group14.h"; then
		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
	else
		sed -i '/#endif/i \
#include "koopa/geo_header.h"' "./actors/group14.h"
	fi
	echo -e "\n${GREEN}Koopa The Quick Selected${RESET}\n"
fi

#Peach

if [[ " ${buildOptions[@]} " =~ " PEACH " ]]; then
	if [[ ! -f "../models_cache/peach.zip" ]]; then
		download -O "../models_cache/peach.zip" https://cdn.discordapp.com/attachments/725049835534942229/727137778357502053/peach.zip
	fi
	cp "../models_cache/peach.zip" "."
	unzip -o "peach.zip"
	rm "peach.zip"
	if [ ! -d './build/'"$VERSION"'_pc/res' ]; then
		mkdir -p 'build/'"$VERSION"'_pc/res'
		mv "peach_hd_textures.zip" './build/'"$VERSION"'_pc/res/peach_hd_textures.zip'
	else
		mv "peach_hd_textures.zip" './build/'"$VERSION"'_pc/res/peach_hd_textures.zip'
	fi
	if grep -q '#include "peach/geo_header.h"' "./actors/group10.h"; then
		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
	else
		sed -i '/#endif/i \
#include "peach/geo_header.h"' "./actors/group10.h"
	fi
	echo -e "\n${GREEN}Peach Selected${RESET}\n"
fi

#Old School Mario

if [[ " ${buildOptions[@]} " =~ " OSMARIO " ]]; then
    if [[ -f "../models_cache/Old_School_HD_Mario_Model.zip" ]]; then
        cp "../models_cache/Old_School_HD_Mario_Model.zip" "."
        unzip -o "./Old_School_HD_Mario_Model.zip"
    else
        download -O "../models_cache/Old_School_HD_Mario_Model.zip" https://cdn.discordapp.com/attachments/710569174472065104/726924093865328660/Old_School_HD_Mario_Model.zip
        cp "../models_cache/Old_School_HD_Mario_Model.zip" "."
        unzip -o "./Old_School_HD_Mario_Model.zip"
    fi
    if grep -q '#include "mario/geo_header.h"' "./actors/group0.h"; then
        echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
    else
        sed -i '/#endif/i \
#include "mario/geo_header.h"' "./actors/group0.h"
    fi
    rm "Old_School_HD_Mario_Model.zip"
    echo -e "\n${GREEN}Old School HD Mario Selected${RESET}\n"
fi

# Odyssey Mario

#if [[ " ${buildOptions[@]} " =~ " ODYSSEYMARIO " ]]; then
#	if [[ -f "../models_cache/Super_Mario.rar" ]]; then
#		cp "../models_cache/Super_Mario.rar" "."
#		unrar x -o+ "./Super_Mario.rar"
#	else
#		download -O "../models_cache/Super_Mario.rar" https://cdn.discordapp.com/attachments/731200130111504385/742140220329426976/Super_Mario.rar
#		cp "../models_cache/Super_Mario.rar" "."
#		unrar x -o+ "./Super_Mario.rar"
#	fi
#	if grep -q '#include "mario/geo_header.h"' "./actors/group0.h"; then
#		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
#	else
#		sed -i '/#endif/i \
#include "mario/geo_header.h"' "./actors/group0.h"
#	fi
#	if grep -q '#include "mario_cap/geo_header.h"' "./actors/common1.h"; then
#		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
#	else
#		sed -i '/#endif/i \
#include "mario_cap/geo_header.h"' "./actors/common1.h"
#	fi
#	rm "Super_Mario.rar"
#	echo -e "\n${GREEN}Odyssey Mario Selected${RESET}\n"
#fi

# Beta Mario

if [[ " ${buildOptions[@]} " =~ " BETAMARIO " ]]; then
	if [[ -f "../models_cache/BetaMarioPhysicsV3.rar" ]]; then
		cp "../models_cache/BetaMarioPhysicsV3.rar" "."
		unrar x -o+ "./BetaMarioPhysicsV3.rar"
	else
		download -O "../models_cache/BetaMarioPhysicsV3.rar" https://cdn.discordapp.com/attachments/737356793789022259/742164668478652537/BetaMarioPhysicsV3.rar
		cp "../models_cache/BetaMarioPhysicsV3.rar" "."
		unrar x -o+ "./BetaMarioPhysicsV3.rar"
	fi
	if grep -q '#include "mario/geo_header.h"' "./actors/group0.h"; then
		echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
	else
		sed -i '/#endif/i \
#include "mario/geo_header.h"' "./actors/group0.h"
	fi
	rm "BetaMarioPhysicsV3.rar"
	echo -e "\n${GREEN}Beta Mario model, physics, shading and voice clips V3 Selected${RESET}\n"
fi

# Realistic Mario

if [[ " ${buildOptions[@]} " =~ " REALISTICMARIO " ]]; then
    if [[ -f "../models_cache/MarioMod.zip" ]]; then
        cp "../models_cache/MarioMod.zip" "."
        unzip -o "./MarioMod.zip"
    else
        download -O "../models_cache/MarioMod.zip" https://sm64pc.info/downloads/MarioMod.zip
        cp "../models_cache/MarioMod.zip" "."
        unzip -o "./MarioMod.zip"
    fi
    if grep -q '#include "mario/geo_header.h"' "./actors/group0.h"; then
        echo -e "\n${RED}The file is already modified correctly.${RESET}\n"
    else
        sed -i '/#endif/i \
#include "mario/geo_header.h"' "./actors/group0.h"
    fi
    rm "MarioMod.zip"
    echo -e "\n${GREEN}Leaked Render96 1.5 Mario Selected${RESET}\n"
fi

#Old School Model Pack

if [[ " ${buildOptions[@]} " =~ " OLDSCHOOL " ]]; then
	if [[ -f "../models_cache/Old_School_HD_1.0.rar" ]]; then
		cp "../models_cache/Old_School_HD_1.0.rar" "."
		unrar x -o+ "./Old_School_HD_1.0.rar"
	else
		download -O "../models_cache/Old_School_HD_1.0.rar" https://sm64pc.imfast.io/Old_School_HD_1.0.rar
		cp "../models_cache/Old_School_HD_1.0.rar" "."
		unrar x -o+ "./Old_School_HD_1.0.rar"
	fi
	rm "Old_School_HD_1.0.rar"
	echo -e "\n${GREEN}Old School Model Pack Selected${RESET}\n"
fi

#----- End Models -----#

#----- Texture Packs -----#

# Mollymutt

if [[ " ${buildOptions[@]} " =~ " MOLLYMUTT " ]]; then
	if [[ ! -f "../textures_cache/mollymutt.zip" ]]; then
		download -O "../textures_cache/mollymutt.zip" https://cdn.discordapp.com/attachments/718584345912148100/719639977662611466/mollymutt.zip
	fi
	if [ ! -d './build/'"$VERSION"'_pc/res' ]; then
		mkdir -p 'build/'"$VERSION"'_pc/res'
		cp "../textures_cache/mollymutt.zip" './build/'"$VERSION"'_pc/res'
	else
		cp "../textures_cache/mollymutt.zip" './build/'"$VERSION"'_pc/res'
	fi
	echo -e "\n${GREEN}MollyMutt's Texture Pack Selected${RESET}\n"
fi

# Hypatia's Texture Pack

if [[ " ${buildOptions[@]} " =~ " HYPATIA " ]]; then
	if [[ ! -f "../textures_cache/hypatia.zip" ]]; then
		download -O "../textures_cache/hypatia.zip" https://sm64pc.info/downloads/hypatia.zip
	fi
	if [ ! -d './build/'"$VERSION"'_pc/res' ]; then
		mkdir -p 'build/'"$VERSION"'_pc/res'
		cp "../textures_cache/hypatia.zip" './build/'"$VERSION"'_pc/res'
	else
		cp "../textures_cache/hypatia.zip" './build/'"$VERSION"'_pc/res'
	fi
	echo -e "\n${GREEN}Hypatia´s Mario Craft 64 Selected${RESET}\n"
fi

# SM64 Redrawn Texture Pack

# Update redrawn check

pull_redrawn () {
	echo -e "\n${YELLOW}Downloading available SM64 Redrawn updates...${RESET}\n"
	if [[ -f "redrawn.zip" ]]; then
		rm "redrawn.zip"
	fi
	git stash push
	git stash drop
	git pull
	sleep 1
}

if [[ " ${buildOptions[@]} " =~ " REDRAWN " ]]; then
	CURRENTDIR="$(pwd)"
	if [[ ! -d "../textures_cache/sm64redrawn" ]]; then
		cd "../textures_cache"
		gitClone https://github.com/TechieAndroid/sm64redrawn.git
		cd "./sm64redrawn"
		zip -r "redrawn.zip" "gfx"
		cd "$CURRENTDIR"
	elif [[ -d "../textures_cache/sm64redrawn" ]]; then
		cd "../textures_cache/sm64redrawn"
		[ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | \
		sed 's/\// /g') | cut -f1) ] && echo -e "\n${GREEN}SM64 Redrawn is up to date\n${RESET}" || pull_redrawn
		if [[ ! -f "redrawn.zip" ]]; then
			zip -r "redrawn.zip" "gfx"
		fi
		cd "$CURRENTDIR"
	fi
	if [ ! -d './build/'"$VERSION"'_pc/res' ]; then
		mkdir -p 'build/'"$VERSION"'_pc/res'
		cp "../textures_cache/sm64redrawn/redrawn.zip" './build/'"$VERSION"'_pc/res'
	else
		cp "../textures_cache/sm64redrawn/redrawn.zip" './build/'"$VERSION"'_pc/res'
	fi
	echo -e "\n${GREEN}SM64 Redrawn Texture Pack Selected${RESET}\n"
fi

# RENDER96-HD-TEXTURE-PACK

# Update Render96 Texture Pack check

pull_render96_texture_pack () {
	echo -e "\n${YELLOW}Downloading available Render96 Texture Pack updates...${RESET}\n"
	if [[ -f "render96_texture_pack.zip" ]]; then
		rm "render96_texture_pack.zip"
	fi
	git stash push
	git stash drop
	git pull
	sleep 1
}

if [[ " ${buildOptions[@]} " =~ " RENDER96TEXTURE " ]]; then
	CURRENTDIR="$(pwd)"
	if [[ ! -d "../textures_cache/RENDER96-HD-TEXTURE-PACK" ]]; then
		cd "../textures_cache"
		gitClone https://github.com/pokeheadroom/RENDER96-HD-TEXTURE-PACK.git
		cd "./RENDER96-HD-TEXTURE-PACK"
		zip -r "render96_texture_pack.zip" "gfx"
		cd "$CURRENTDIR"
	elif [[ -d "../textures_cache/RENDER96-HD-TEXTURE-PACK" ]]; then
		cd "../textures_cache/RENDER96-HD-TEXTURE-PACK"
		[ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | \
		sed 's/\// /g') | cut -f1) ] && echo -e "\n${GREEN}Render96 Texture Pack is up to date\n${RESET}" || pull_render96_texture_pack
		if [[ ! -f "render96_texture_pack.zip" ]]; then
			zip -r "render96_texture_pack.zip" "gfx"
		fi
		cd "$CURRENTDIR"
	fi
	if [ ! -d './build/'"$VERSION"'_pc/res' ]; then
		mkdir -p 'build/'"$VERSION"'_pc/res'
		cp "../textures_cache/RENDER96-HD-TEXTURE-PACK/render96_texture_pack.zip" './build/'"$VERSION"'_pc/res'
	else
		cp "../textures_cache/RENDER96-HD-TEXTURE-PACK/render96_texture_pack.zip" './build/'"$VERSION"'_pc/res'
	fi
	echo -e "\n${GREEN}Render96 Texture Pack Selected${RESET}\n"
fi

# RESRGAN N64 Faithful

# Update RESRGAN N64 Faithful check

pull_resrgan_n64_faithful () {
	echo -e "\n${YELLOW}Downloading available RESRGAN N64 Faithful updates...${RESET}\n"
	if [[ -f "resrgan_n64_faithful.zip" ]]; then
		rm "resrgan_n64_faithful.zip"
	fi
	git stash push
	git stash drop
	git pull
	sleep 1
}

if [[ " ${buildOptions[@]} " =~ " RESRGANN64 " ]]; then
	CURRENTDIR="$(pwd)"
	if [[ ! -d "../textures_cache/RESRGAN-16xre-upscale-HD-texture-pack-n64-resrgan-faithful" ]]; then
		cd "../textures_cache"
		gitClone https://github.com/pokeheadroom/RESRGAN-16xre-upscale-HD-texture-pack.git -b n64-resrgan-faithful "RESRGAN-16xre-upscale-HD-texture-pack-n64-resrgan-faithful"
		cd "./RESRGAN-16xre-upscale-HD-texture-pack-n64-resrgan-faithful"
		zip -r "resrgan_n64_faithful.zip" "gfx"
		cd "$CURRENTDIR"
	elif [[ -d "../textures_cache/RESRGAN-16xre-upscale-HD-texture-pack-n64-resrgan-faithful" ]]; then
		cd "../textures_cache/RESRGAN-16xre-upscale-HD-texture-pack-n64-resrgan-faithful"
		[ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | \
		sed 's/\// /g') | cut -f1) ] && echo -e "\n${GREEN}RESRGAN N64 Faithful is up to date\n${RESET}" || pull_resrgan_n64_faithful
		if [[ ! -f "resrgan_n64_faithful.zip" ]]; then
			zip -r "resrgan_n64_faithful.zip" "gfx"
		fi
		cd "$CURRENTDIR"
	fi
	if [ ! -d './build/'"$VERSION"'_pc/res' ]; then
		mkdir -p 'build/'"$VERSION"'_pc/res'
		cp "../textures_cache/RESRGAN-16xre-upscale-HD-texture-pack-n64-resrgan-faithful/resrgan_n64_faithful.zip" './build/'"$VERSION"'_pc/res'
	else
		cp "../textures_cache/RESRGAN-16xre-upscale-HD-texture-pack-n64-resrgan-faithful/resrgan_n64_faithful.zip" './build/'"$VERSION"'_pc/res'
	fi
	echo -e "\n${GREEN}RESRGAN N64 Faithful Texture Pack Selected${RESET}\n"
fi

# RESRGAN-16xre-upscale-HD-texture-pack

# Update RESRGAN check

pull_resrgan () {
	echo -e "\n${YELLOW}Downloading available RESRGAN updates...${RESET}\n"
	if [[ -f "resrgan.zip" ]]; then
		rm "resrgan.zip"
	fi
	git stash push
	git stash drop
	git pull
	sleep 1
}

if [[ " ${buildOptions[@]} " =~ " RESRGAN " ]]; then
	CURRENTDIR="$(pwd)"
	if [[ ! -d "../textures_cache/RESRGAN-16xre-upscale-HD-texture-pack" ]]; then
		cd "../textures_cache"
		gitClone https://github.com/pokeheadroom/RESRGAN-16xre-upscale-HD-texture-pack.git
		cd "./RESRGAN-16xre-upscale-HD-texture-pack"
		zip -r "resrgan.zip" "gfx"
		cd "$CURRENTDIR"
	elif [[ -d "../textures_cache/RESRGAN-16xre-upscale-HD-texture-pack" ]]; then
		cd "../textures_cache/RESRGAN-16xre-upscale-HD-texture-pack"
		[ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | \
		sed 's/\// /g') | cut -f1) ] && echo -e "\n${GREEN}RESRGAN is up to date\n${RESET}" || pull_resrgan
		if [[ ! -f "resrgan.zip" ]]; then
			zip -r "resrgan.zip" "gfx"
		fi
		cd "$CURRENTDIR"
	fi
	if [ ! -d './build/'"$VERSION"'_pc/res' ]; then
		mkdir -p 'build/'"$VERSION"'_pc/res'
		cp "../textures_cache/RESRGAN-16xre-upscale-HD-texture-pack/resrgan.zip" './build/'"$VERSION"'_pc/res'
	else
		cp "../textures_cache/RESRGAN-16xre-upscale-HD-texture-pack/resrgan.zip" './build/'"$VERSION"'_pc/res'
	fi
	echo -e "\n${GREEN}RESRGAN Texture Pack Selected${RESET}\n"
fi

# owo Texture Pack

if [[ " ${buildOptions[@]} " =~ " OWOPACK " ]]; then
	download https://cdn.discordapp.com/attachments/725049835534942229/726455568876961822/owo.zip
	if [ ! -d './build/'"$VERSION"'_pc/res' ]; then
		mkdir -p 'build/'"$VERSION"'_pc/res'
		mv "owo.zip" './build/'"$VERSION"'_pc/res'
	else
		mv "owo.zip" './build/'"$VERSION"'_pc/res'
	fi
	echo -e "\n${GREEN}OwOify Project (WIP) Selected${RESET}\n"
fi

# P3ST's Texture Pack

# Update P3ST check

pull_p3st () {
	echo -e "\n${YELLOW}Downloading available p3st updates...${RESET}\n"
	if [[ -f "p3st-textures.zip" ]]; then
		rm "p3st-textures.zip"
		rm "p3st-sounds.zip"
	fi
	git stash push
	git stash drop
	git pull
	sleep 1
}

if [[ " ${buildOptions[@]} " =~ " P3ST " ]]; then
	CURRENTDIR="$(pwd)"
	if [[ ! -d "../textures_cache/p3st-Texture_pack" ]]; then
		cd "../textures_cache"
		gitClone https://github.com/p3st-textures/p3st-Texture_pack.git
		cd "./p3st-Texture_pack"
		zip -r "p3st-textures.zip" "gfx"
		zip -r "p3st-sounds.zip" "sound"
		cd "$CURRENTDIR"
	elif [[ -d "../textures_cache/p3st-Texture_pack" ]]; then
		cd "../textures_cache/p3st-Texture_pack"
		[ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | \
		sed 's/\// /g') | cut -f1) ] && echo -e "\n${GREEN}P3ST is up to date\n${RESET}" || pull_p3st
		if [[ ! -f "p3st-textures.zip" ]]; then
			zip -r "p3st-textures.zip" "gfx"
			zip -r "p3st-sounds.zip" "sound"
		fi
		cd "$CURRENTDIR"
	fi
	if [ ! -d './build/'"$VERSION"'_pc/res' ]; then
		mkdir -p 'build/'"$VERSION"'_pc/res'
		cp "../textures_cache/p3st-Texture_pack/p3st-textures.zip" './build/'"$VERSION"'_pc/res'
		cp "../textures_cache/p3st-Texture_pack/p3st-sounds.zip" './build/'"$VERSION"'_pc/res'
	else
		cp "../textures_cache/p3st-Texture_pack/p3st-textures.zip" './build/'"$VERSION"'_pc/res'
		cp "../textures_cache/p3st-Texture_pack/p3st-sounds.zip" './build/'"$VERSION"'_pc/res'
	fi
	echo -e "\n${GREEN}P3ST Texture Pack Selected${RESET}\n"
fi

# Cleaner Aesthetics Texture Pack

# Update CLEANER check

pull_cleaner () {
	echo -e "\n${YELLOW}Downloading available Cleaner Aesthetics Texture Pack updates...${RESET}\n"
	if [[ -f "cleaner.zip" ]]; then
		rm "cleaner.zip"
	fi
	git stash push
	git stash drop
	git pull
	sleep 1
}

if [[ " ${buildOptions[@]} " =~ " CLEANER " ]]; then
	CURRENTDIR="$(pwd)"
	if [[ ! -d "../textures_cache/Cleaner-Aesthetics" ]]; then
		cd "../textures_cache"
		gitClone https://github.com/CrashCrod/Cleaner-Aesthetics.git
		cd "./Cleaner-Aesthetics"
		zip -r "cleaner.zip" "gfx"
		cd "$CURRENTDIR"
	elif [[ -d "../textures_cache/Cleaner-Aesthetics" ]]; then
		cd "../textures_cache/Cleaner-Aesthetics"
		[ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | \
		sed 's/\// /g') | cut -f1) ] && echo -e "\n${GREEN}Cleaner Aesthetics Texture Pack is up to date\n${RESET}" || pull_cleaner
		if [[ ! -f "cleaner.zip" ]]; then
			zip -r "cleaner.zip" "gfx"
		fi
		cd "$CURRENTDIR"
	fi
	if [ ! -d './build/'"$VERSION"'_pc/res' ]; then
		mkdir -p 'build/'"$VERSION"'_pc/res'
		cp "../textures_cache/Cleaner-Aesthetics/cleaner.zip" './build/'"$VERSION"'_pc/res'
	else
		cp "../textures_cache/Cleaner-Aesthetics/cleaner.zip" './build/'"$VERSION"'_pc/res'
	fi
	echo -e "\n${GREEN}Cleaner Aesthetics Texture Pack Selected${RESET}\n"
fi

# Minecraft Texture Pack

# Update Minecraft check

pull_minecraft () {
	echo -e "\n${YELLOW}Downloading available Minecraft Texture Pack updates...${RESET}\n"
	if [[ -f "minecraft.zip" ]]; then
		rm "minecraft.zip"
	fi
	git stash push
	git stash drop
	git pull
	sleep 1
}

if [[ " ${buildOptions[@]} " =~ " MINECRAFT " ]]; then
	CURRENTDIR="$(pwd)"
	if [[ ! -d "../textures_cache/MCtexturepackSM64" ]]; then
		cd "../textures_cache"
		gitClone https://github.com/Almondatchy3/MCtexturepackSM64.git
		cd "./MCtexturepackSM64"
		zip -r "minecraft.zip" "gfx"
		cd "$CURRENTDIR"
	elif [[ -d "../textures_cache/MCtexturepackSM64" ]]; then
		cd "../textures_cache/MCtexturepackSM64"
		[ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | \
		sed 's/\// /g') | cut -f1) ] && echo -e "\n${GREEN}Minecraft Texture Pack is up to date\n${RESET}" || pull_minecraft
		if [[ ! -f "minecraft.zip" ]]; then
			zip -r "minecraft.zip" "gfx"
		fi
		cd "$CURRENTDIR"
	fi
	if [ ! -d './build/'"$VERSION"'_pc/res' ]; then
		mkdir -p 'build/'"$VERSION"'_pc/res'
		cp "../textures_cache/MCtexturepackSM64/minecraft.zip" './build/'"$VERSION"'_pc/res'
	else
		cp "../textures_cache/MCtexturepackSM64/minecraft.zip" './build/'"$VERSION"'_pc/res'
	fi
	echo -e "\n${GREEN}Minecraft Texture Pack Selected${RESET}\n"
fi

# JappaWakka & Admentus HD Texture Pack

# Update JappaWakka & Admentus HD check

pull_jappawakka_admentus_hd () {
	echo -e "\n${YELLOW}Downloading available JappaWakka & Admentus HD updates...${RESET}\n"
	if [[ -f "jappawakka_admentus_hd.zip" ]]; then
		rm "jappawakka_admentus_hd.zip"
	fi
	git stash push
	git stash drop
	git pull
	sleep 1
}

if [[ " ${buildOptions[@]} " =~ " JAPPAADMENTUSHD " ]]; then
	CURRENTDIR="$(pwd)"
	if [[ ! -d "../textures_cache/Mario64HDTexturePack_PC" ]]; then
		cd "../textures_cache"
		gitClone https://github.com/JappaWakka/Mario64HDTexturePack_PC.git
		cd "./Mario64HDTexturePack_PC"
		zip -r "jappawakka_admentus_hd.zip" "gfx"
		cd "$CURRENTDIR"
	elif [[ -d "../textures_cache/Mario64HDTexturePack_PC" ]]; then
		cd "../textures_cache/Mario64HDTexturePack_PC"
		[ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | \
		sed 's/\// /g') | cut -f1) ] && echo -e "\n${GREEN}JappaWakka & Admentus HD is up to date\n${RESET}" || pull_jappawakka_admentus_hd
		if [[ ! -f "jappawakka_admentus_hd.zip" ]]; then
			zip -r "jappawakka_admentus_hd.zip" "gfx"
		fi
		cd "$CURRENTDIR"
	fi
	if [ ! -d './build/'"$VERSION"'_pc/res' ]; then
		mkdir -p 'build/'"$VERSION"'_pc/res'
		cp "../textures_cache/Mario64HDTexturePack_PC/jappawakka_admentus_hd.zip" './build/'"$VERSION"'_pc/res'
	else
		cp "../textures_cache/Mario64HDTexturePack_PC/jappawakka_admentus_hd.zip" './build/'"$VERSION"'_pc/res'
	fi
	echo -e "\n${GREEN}JappaWakka & Admentus HD Texture Pack Selected${RESET}\n"
fi

# Beta HUD

if [[ " ${buildOptions[@]} " =~ " BETAHUD " ]]; then
	if [[ -f "../textures_cache/BetaHudModV2.5.rar" ]]; then
		cp "../textures_cache/BetaHudModV2.5.rar" "."
		unrar x -o+ "./BetaHudModV2.5.rar"
	else
		download -O "../textures_cache/BetaHudModV2.5.rar" https://cdn.discordapp.com/attachments/737356793789022259/742181711789424663/BetaHudModV2.5.rar
		cp "../textures_cache/BetaHudModV2.5.rar" "."
		unrar x -o+ "./BetaHudModV2.5.rar"
	fi
	if [ ! -d './build/'"$VERSION"'_pc/res' ]; then
		mkdir -p 'build/'"$VERSION"'_pc/res'
		mv "BetaHudModV2.5_textures.zip" './build/'"$VERSION"'_pc/res'
	else
		mv "BetaHudModV2.5_textures.zip" './build/'"$VERSION"'_pc/res'
	fi
	rm "BetaHudModV2.5.rar"
	echo -e "\n${GREEN}Beta HUD 2.5 Texture Pack Selected${RESET}\n"
fi

#----- End Texture Packs -----#

# Remove extra shit from make so it don't break

delete=(coop nightly master jslow jfast jfaster jhurtmepapi NOUPDATE DELETEBUILD DELETEBRANCH INSTALLDEP64BIT INSTALLDEP32BIT INSTALLCLANGDEP64BIT INSTALLCLANGDEP32BIT AUTOLAUNCH RENDER96EX SM64EXCOOP SM64EX SM64PORT RESHADE 120SAVE 60FPSNIGHTLY TIGHTCONTROLS CAPTAINTOAD NOEXITSTAR TITLERETURN 3DCOIN EXIT50COIN MOUSEFIX TITLEEXIT STARDELAY 60FPSPORT PUPPYCAM STAYINLEVEL TIMETRIALS ODYSSEYMOVESET CHEATER DYNOS CUSTOMPATCHES RESTOREACTORS HDMARIO LUIGI RENDER96 HATKID BOWKID MAWIO KOOPAQUICK PEACH OSMARIO REALISTICMARIO BETAMARIO HDBOWSER OLDSCHOOL MOLLYMUTT HYPATIA REDRAWN OWOPACK P3ST CLEANER RENDER96TEXTURE RESRGANN64 RESRGAN MINECRAFT JAPPAADMENTUSHD BETAHUD)

if [[ " ${buildOptions[@]} " =~ " jfast " ]]; then
	buildOptions[2]="-j$((`nproc`-1))"
fi

if [[ " ${buildOptions[@]} " =~ " jfaster " ]]; then
	buildOptions[2]="-j$((`nproc`+1))"
fi

if [[ " ${buildOptions[@]} " =~ " jhurtmepapi " ]]; then
	buildOptions[2]="-j"
fi

for target in "${delete[@]}"; do
	for i in "${!buildOptions[@]}"; do
		if [[ ${buildOptions[i]} = $target ]]; then
			unset "buildOptions[i]"
		fi
	done
done

unset "buildOptions[1]"

# Make /w Flags

echo -e "${CYAN}make ${YELLOW}${buildOptions[@]}${RESET}"
make ${buildOptions[@]}

END_TIME=`date +%s`
TIME_TAKEN=$(( END_TIME - BEGIN_TIME ))
TIME_TAKEN_WITHOUT_DOWNLOADS=$(( TIME_TAKEN - TOTAL_DOWNLOAD_TIME ))
MINUTES_TAKEN=$(( TIME_TAKEN / 60 ))
SECONDS_TAKEN=$(( TIME_TAKEN % 60 ))
MINUTES_TAKEN_WITHOUT_DOWNLOADS=$(( TIME_TAKEN_WITHOUT_DOWNLOADS / 60 ))
SECONDS_TAKEN_WITHOUT_DOWNLOADS=$(( TIME_TAKEN_WITHOUT_DOWNLOADS % 60 ))

echo "Completed in $MINUTES_TAKEN minutes, $SECONDS_TAKEN seconds"
echo "$MINUTES_TAKEN_WITHOUT_DOWNLOADS minutes, SECONDS_TAKEN_WITHOUT_DOWNLOADS seconds without downloads"

if [ "$MACHINE_TYPE" = "x86_64" ] && ls $BINARY 1> /dev/null 2>&1; then
	zenity --info \
	--text="Shits done yo.
Completed in ${MINUTES_TAKEN} minutes, ${SECONDS_TAKEN} seconds
${MINUTES_TAKEN_WITHOUT_DOWNLOADS} minutes, ${SECONDS_TAKEN_WITHOUT_DOWNLOADS} seconds without downloads"
elif [ "$MACHINE_TYPE" = "i686" ] && ls $BINARY 1> /dev/null 2>&1; then
    echo "Shits done yo." | cmd /c 'msg %username% /W '
elif [ "$MACHINE_TYPE" = "x86_64" ]; then
	zenity --info \
	--text="1.) Check the MSYS2 window for an error (usually red)
2.) Make sure the problem you are having isn't solved in #help-desk-faq or #help-faq
3.) If you haven't found a solution in those channels then post a screenshot of the red error in #help-desk or #help.
4.) Post your builder2 overview tab
5.) Right click the MSYS2 window, select all, right click again and copy. Paste the entire log into the #help-desk or #help channel
6.) Any other remarks or important information you think could help us deduce the problems
Don't hit OK until you've done this."
elif [ "$MACHINE_TYPE" = "i686" ]; then
    echo "1.) Check the MSYS2 window for an error (usually red)
2.) Make sure the problem you are having is not solved in #help-desk-faq or #help-faq
3.) If you have not found a solution in those channels then post a screenshot of the red error in #help-desk or #help.
4.) Post your builder2 overview tab
5.) Right click the MSYS2 window, select all, right click again and copy. Paste the entire log into the #help-desk or #help channel
6.) Any other remarks or important information you think could help us deduce the problems
Do not hit OK until you have done this." | cmd /c 'msg %username% /W '
fi

if ls $BINARY 1> /dev/null 2>&1; then
    cd './build/'"$VERSION"'_pc/'
	start "."
	if [ "$Auto_Launch" = true ]; then
	    sleep 1
	    start 'sm64.'"$VERSION"'.f3dex2e.exe'
	fi
fi