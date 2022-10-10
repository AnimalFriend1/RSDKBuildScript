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
#Check if devkitpro pacman is installed
if ! command -v dkp-pacman &> /dev/null
then
    echo "DevkitPro pacman isn't installed"
    echo Install it now?
    select yn in "Yes" "No"; do
        case $yn in
            Yes )
            wget https://apt.devkitpro.org/install-devkitpro-pacman
            chmod +x ./install-devkitpro-pacman
            sudo ./install-devkitpro-pacman
            rm ./install-devkitpro-pacman
            break;;
            No ) exit;;
        esac
    done
fi
#Ask user which platform they want to build for
echo Which platform do you want to build for?
select yn in "3DS" "Wii"; do
    case $yn in
        3DS ) PLATFORM=3ds; break;;
        Wii ) PLATFORM=wii; break;;
    esac
done
#Ask user if they want to build with plus
echo Do you want to build with plus?
select yn in "Yes" "No"; do
    case $yn in
        Yes ) PLUS=1; break;;
        No ) PLUS=0; break;;
    esac
done
if [ $PLATFORM = 3ds ];
then
    #Check if 3ds-dev is installed
    if ! command -v dkp-pacman -Q 3ds-dev &> /dev/null
    then
        echo "3ds-dev isn't installed"
        echo Install it now?
        select yn in "Yes" "No"; do
            case $yn in
                Yes ) sudo dkp-pacman -S 3ds-dev; break;;
                No ) exit;;
            esac
        done
    fi
    #Clone the repo
    git clone --recurse-submodules --remote-submodules -b 3ds-main https://github.com/SaturnSH2x2/RSDKv5-Decompilation
    rm ./RSDKv5-Decompilation/Game
    git clone https://github.com/Rubberduckycooly/Sonic-Mania-Decompilation
    cp -r ./Sonic-Mania-Decompilation/SonicMania ./RSDKv5-Decompilation/Game
    cd RSDKv5-Decompilation
    #check if plus is enabled
    if [ PLUS = 1 ];
    then
        make PLATFORM=3DS AUTOBUILD=1
    else
        make PLATFORM=3DS
    fi
    mv bin/3DS/CTR/RSDKv5.elf ../RSDKv5.elf
    mv bin/3DS/CTR/RSDKv5.3dsx ../RSDKv5.3dsx
    cd ..
    rm -rf ./Sonic-Mania-Decompilation ./RSDKv5-Decompilation
fi
if [ $PLATFORM = wii ];
then
    #Check if wii-dev is installed
    if ! command -v dkp-pacman -Q wii-dev &> /dev/null
    then
        echo "wii-dev isn't installed"
        echo Install it now?
        select yn in "Yes" "No"; do
            case $yn in
                Yes ) sudo dkp-pacman -S wii-dev; break;;
                No ) exit;;
            esac
        done
    fi
    #Clone the repo
    git clone --recurse-submodules --remote-submodules https://github.com/Mefiresu/RSDKv5-Decompilation
    cd RSDKv5-Decompilation
    #check if plus is enabled
    if [ PLUS = 1 ];
    then
        make PLATFORM=Wii AUTOBUILD=1
    else
        make PLATFORM=Wii
    fi
    mv bin/Wii/RSDKv5.dol ../RSDKv5.dol
    cd ..
    rm -rf ./Sonic-Mania-Decompilation ./RSDKv5-Decompilation
fi