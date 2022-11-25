install=false
#functions
bannertool_check()
{
    if ! command -v bannertool &> /dev/null
    then
        echo "bannertool not installed, install it now?"
        select yn in "Yes" "No"; do
            case $yn in
                Yes )
                wget https://github.com/Steveice10/bannertool/releases/download/1.2.0/bannertool.zip
                unzip bannertool.zip
                cp linux-x86_64/bannertool ~/bin
                chmod +x ~/bin/bannertool
                rm bannertool.zip
                rm -r linux-x86_64 linux-i686 windows-x86_64 windows-i686
                break;;
                No ) exit;;
            esac
        done
    fi
}
makerom_check()
{
    if ! command -v makerom &> /dev/null
    then
        echo "MakeROM not installed, install it now?"
        select yn in "Yes" "No"; do
            case $yn in
                Yes )
                wget https://github.com/3DSGuy/Project_CTR/releases/download/makerom-v0.18.3/makerom-v0.18.3-ubuntu_x86_64.zip
                unzip makerom-v0.18.3-ubuntu_x86_64.zip
                cp makerom ~/bin
                chmod +x ~/bin/makerom
                rm makerom-v0.18.3-ubuntu_x86_64.zip
                rm makerom
                break;;
                No ) exit;;
            esac
        done
    fi
}
#Check if git is installed
if ! command -v git &> /dev/null
then
    echo "Git isn't installed"
    echo Install it now?
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) sudo apt-get install git; break;;
            No ) exit;;
        esac
    done
fi
#Ask user which version of RSDK to download
echo "Which Sonic game do you wnt to build?"
select yn in "Sonic CD" "Sonic 1/2" "Sonic Mania"; do
    case $yn in
        "Sonic CD" ) RSDK=3; break;;
        "Sonic 1/2" ) RSDK=4; break;;
        "Sonic Mania" ) RSDK=5; break;;
    esac
done
#Ask user which platform they want to build for
echo Which platform do you want to build for?
if [ $RSDK -eq 3 ]; then
    select yn in "Linux" "3DS"; do
        case $yn in
            Linux ) PLATFORM=linux; pkgs='build-essential git libsdl2-dev libvorbis-dev libogg-dev libtheora-dev libglew-dev libgdm-dev libdrm-dev'; break;;
            3DS ) PLATFORM=3ds; break;;
        esac
    done
elif [ $RSDK -eq 4 ]; then
    select yn in "Linux" "3DS"; do
        case $yn in
            Linux ) PLATFORM=linux; pkgs='build-essential git libsdl2-dev libvorbis-dev libogg-dev libglew-dev libdecor-0-dev libgdm-dev libdrm-dev'; break;;
            3DS ) PLATFORM=3ds; break;;
        esac
    done
elif [ $RSDK -eq 5 ]; then
    select yn in "Linux" "3DS" "Wii"; do
        case $yn in
            Linux ) PLATFORM=linux; pkgs='libglew-dev libglfw3-dev libsdl2-dev libtheora-dev'; break;;
            3DS ) PLATFORM=3ds; break;;
            Wii ) PLATFORM=wii; break;;
        esac
    done
fi
#Ask user if they want to build with plus if RSDK version is 5
if [ $RSDK -eq 5 ]
then
    echo Do you want to build with plus?
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) PLUS=1; break;;
            No ) PLUS=0; break;;
        esac
    done
fi
#Check if devkitpro pacman is installed if platform is 3ds or Wii
if [ $PLATFORM = "3ds" ] || [ $PLATFORM = "wii" ]
then
    if ! command -v dkp-pacman &> /dev/null
    then
        echo "Devkitpro pacman isn't installed"
        echo Install it now?
        select yn in "Yes" "No"; do
            case $yn in
                Yes ) sudo apt-get install devkitpro-pacman; break;;
                No ) exit;;
            esac
        done
    fi
fi
#Linux
if [ $PLATFORM = "linux" ]
then
    #dependencies
    for pkg in $pkgs; do
    status="$(dpkg-query -W --showformat='${db:Status-Status}' "$pkg" 2>&1)"
    if [ ! $? = 0 ] || [ ! "$status" = installed ]; then
        install=true
        break
    fi
    done
    if "$install"; then
    echo Some dependencies are missing, install them now?
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) sudo apt-get update; sudo apt-get install $pkgs; break;;
            No ) exit;;
        esac
    done
    fi
    if [ $RSDK -eq 3 ]
    then
        git clone --recursive https://github.com/Rubberduckycooly/Sonic-CD-11-Decompilation.git
        cd Sonic-CD-11-Decompilation
        make CXXFLAGS=-O2 -j5
        #cleanup
        cp ./bin/RSDKv3 ../
        cd ../
        rm -rf Sonic-CD-11-Decompilation
    fi
    if [ $RSDK -eq 4 ]
    then
        git clone --recursive https://github.com/Rubberduckycooly/Sonic-1-2-2013-Decompilation.git
        cd Sonic-1-2-2013-Decompilation
        make -j5
        cp ./bin/RSDKv4 ../
        cd ../
        rm -rf Sonic-1-2-2013-Decompilation
    fi
    if [ $RSDK -eq 5 ]
    then
        #clone the repo
        git clone --recurse-submodules --remote-submodules https://github.com/Rubberduckycooly/RSDKv5-Decompilation
        rm ./RSDKv5-Decompilation/Game
        git clone https://github.com/Rubberduckycooly/Sonic-Mania-Decompilation
        cp -r ./Sonic-Mania-Decompilation/SonicMania ./RSDKv5-Decompilation/Game
        cd RSDKv5-Decompilation
        #Check if plus is enabled and build
        if [ PLUS = 1 ];
        then
            make AUTOBUILD=1
        else
            make
        fi
        #cleanup
        cp ./bin/Linux/GL3/Game.so ../
        cp ./bin/Linux/GL3/RSDKv5 ../
        cd ../
        rm -rf ./RSDKv5-Decompilation ./Sonic-Mania-Decompilation
    fi
fi
#3DS
if [ $PLATFORM = 3ds ];
then
    #Check if dependencies are installed
    if ! dkp-pacman -Qi 3ds-sdl 3ds-sdl_mixer 3ds-cmake 3ds-examples 3ds-pkg-config citro2d citro3d devkitarm-cmake devkitarm-crtls libctru 3dslink 3dstools devkit-env devkitARM devkitARM-gdb general-tools picasso tex3ds 3ds-libvorbisidec 3ds-libtheora 3ds-mikmod 3ds-libmad 3ds-tinyxml2 &> /dev/null ; then
        echo "Some dependencies appear to be missing"
        echo Install them now?
        select yn in "Yes" "No"; do
            case $yn in
                Yes ) sudo dkp-pacman -S --needed 3ds-tinyxml2 3ds-sdl-libs 3ds-dev 3ds-libvorbisidec 3ds-libtheora 3ds-mikmod 3ds-libmad; break;;
                No ) exit;;
            esac
        done
    fi
    #RSDKv3 3ds build
    if [ $RSDK -eq 3 ]
    then
        #Ask user if they want to build the hardware rendered version or the software rendered version
        echo Do you want to build the hardware rendered version or the software rendered version?
        select yn in "Hardware" "Software"; do
            case $yn in
                Hardware ) HW=1; break;;
                Software ) HW=0; break;;
            esac
        done
        #Ask user if they want to build a CIA
        echo Do you want to build a CIA?
        select yn in "Yes" "No"; do
            case $yn in
                Yes ) CIA=1; break;;
                No ) CIA=0; break;;
            esac
        done
        git clone --recurse-submodules --remote-submodules https://github.com/SaturnSH2x2/Sonic-CD-11-3DS
        #Check if HW is 0, if so edit RetroEngine.hpp to use hardware rendering
        if [ $HW -eq 0 ]
        then
            sed -i 's/#define RETRO_USING_C2D        (1)/#define RETRO_USING_C2D        (0)/' Sonic-CD-11-3DS/RSDKv3/RetroEngine.hpp
        fi
        cd Sonic-CD-11-3DS
        if [ $CIA -eq 1 ]
        then
            #checks
            makerom_check
            bannertool_check
            #build
            make -f Makefile.3ds cia
            mv SonicCD.cia ../SonicCD.cia
        else
            make -f Makefile.3ds
        fi
        #cleanup
        mv SonicCD.3dsx ../SonicCD.3dsx
        mv SonicCD.smdh ../SonicCD.smdh
        mv SonicCD.elf ../SonicCD.elf
        cd ..
        #rm -rf Sonic-CD-11-3DS
    fi
    #RSDKv4 3ds build
    if [ $RSDK -eq 4 ]
    then
        bannertool_check
        #ask user if they want to build 1 or 2
        echo Which game do you want to build?
        select yn in "Sonic the Hedgehog 1" "Sonic the Hedgehog 2"; do
            case $yn in
                "Sonic the Hedgehog 1" ) sonic=1; break;;
                "Sonic the Hedgehog 2" ) sonic=2; break;;
            esac
        done
        #ask user if they want to build a CIA
        echo Do you want to build a CIA?
        select yn in "Yes" "No"; do
            case $yn in
                Yes ) CIA=1; break;;
                No ) CIA=0; break;;
            esac
        done
        #Clone the repo
        git clone --recurse-submodules --remote-submodules https://github.com/JeffRuLz/Sonic-1-2-2013-Decompilation
        cd Sonic-1-2-2013-Decompilation/dependencies/all/
        #Download stb-image
        git clone https://github.com/nothings/stb
        mv stb stb-image
        cd ../../
        #Build the game
        if [ $sonic -eq 1 ]
        then
            cd ./Sonic1Decomp.3DS
        else
            cd ./Sonic2Decomp.3DS
        fi
        if [ $CIA -eq 1 ]
        then
            #makerom check
            makerom_check
            #build
            make cia
            mv Sonic*.cia ../../
        else
            make
        fi
        #cleanup
        mv Sonic*.3dsx ../../
        mv Sonic*.smdh ../../
        mv Sonic*.elf ../../
        cd ../../
        rm -rf Sonic-1-2-2013-Decompilation
    fi
    #RSDKv5 3ds build
    if [ $RSDK -eq 5 ]
    then
        #Clone the repo
        git clone --recurse-submodules --remote-submodules -b 3ds-main https://github.com/SaturnSH2x2/RSDKv5-Decompilation
        rm ./RSDKv5-Decompilation/Game
        git clone https://github.com/Rubberduckycooly/Sonic-Mania-Decompilation
        cp -r ./Sonic-Mania-Decompilation/SonicMania ./RSDKv5-Decompilation/Game
        cd RSDKv5-Decompilation
        #check if plus is enabled and build
        if [ PLUS = 1 ];
        then
            make PLATFORM=3DS AUTOBUILD=1
        else
            make PLATFORM=3DS
        fi
        #cleanup
        mv bin/3DS/CTR/RSDKv5.elf ../RSDKv5.elf
        mv bin/3DS/CTR/RSDKv5.3dsx ../RSDKv5.3dsx
        cd ..
        rm -rf ./Sonic-Mania-Decompilation ./RSDKv5-Decompilation
    fi  
fi
#Wii
if [ $PLATFORM = wii ];
then
    #RSDKv5 Wii build
    if [ $RSDK -eq 5 ]
    then
        #Clone the repo
        git clone --recurse-submodules --remote-submodules https://github.com/Mefiresu/RSDKv5-Decompilation
        cd RSDKv5-Decompilation
        #check if plus is enabled and build
        if [ PLUS = 1 ];
        then
            make PLATFORM=Wii AUTOBUILD=1
        else
            make PLATFORM=Wii
        fi
        #cleanup
        mv bin/Wii/RSDKv5.dol ../RSDKv5.dol
        cd ..
        rm -rf ./Sonic-Mania-Decompilation ./RSDKv5-Decompilation
    fi
fi