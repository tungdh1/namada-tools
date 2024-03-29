#!/bin/bash

# Define some colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

NEWCHAINID=shielded-expedition.88f17d1d14
SCRIPT_NAME="namada-aio.sh"
CURRENT_VERSION="1.4.3"

function manage_script {
    while true
    do
        echo "Choose an option:"
        echo "1/ Update script"
        echo "2/ Remove script"
        echo "3/ Go back to the previous menu"
        echo -n "Enter your choice [1-3]: "
        read script_option
        case $script_option in
            1) check_for_updates;;
            2) echo "Are you sure you want to remove the script? (Yes/No)"
               read remove_confirmation
               if [[ "${remove_confirmation,,}" == "yes" ]]; then
                   rm $SCRIPT_NAME
                   echo "The script has been removed."
               else
                   echo "Remove cancelled."
               fi;;
            3) return;;
            *) echo "Invalid choice. Please try again.";;
        esac
    done
}

function namada_service_menu {
    while true
    do
        echo "Choose an option:"
        echo "1/ Start Namada Service"
        echo "2/ Stop Namada Service"
        echo "3/ Check Namada Service Status"
        echo "4/ Remove all Namada install (CAUTION)"
        echo "5/ Go back to the previous menu"
        echo -n "Enter your choice [1-5]: "
        read service_option
        case $service_option in
            1) echo "Starting Namada Service..."
               sudo systemctl daemon-reload
               sudo systemctl enable namadad
               sudo systemctl start namadad
               echo "Namada Service has been started."
               sleep 3;;
            2) echo "Stopping Namada Service..."
               sudo systemctl stop namadad
               echo "Namada Service has been stopped."
               sleep 3;;
            3) echo "Checking Namada Service status..."
               clear
               sudo systemctl status namadad --no-pager
               echo "Press any key to continue..."
               read -n 1 -s;;
            4) echo "You have chosen 'Remove all Namada install (CAUTION)'."
               echo "The system will automatically delete the current Namada working directory and back it up to the following path: $HOME/namada_backup/. Please be careful and make sure that you have backed up the necessary files. This action cannot be undone."
               echo "Are you sure you want to proceed? (Yes/No):"
               read confirmation
               if [[ "${confirmation,,}" == "yes" ]]; then
                   echo "Please confirm again (Yes/No):"
                   read confirmation2
                   if [[ "${confirmation2,,}" == "yes" ]]; then
                       echo "Please confirm one last time (Yes/No):"
                       read confirmation3
                       if [[ "${confirmation3,,}" == "yes" ]]; then
                           echo "Removing all Namada install..."
                           cd $HOME && mkdir $HOME/namada_backup
                           cp -r $HOME/.local/share/namada/ $HOME/namada_backup/
                           systemctl stop namadad && systemctl disable namadad
                           rm /etc/systemd/system/namada* -rf
                           rm $(which namada) -rf
                           rm /usr/local/bin/namada* /usr/local/bin/cometbft -rf
                           rm $HOME/.namada* -rf
                           rm $HOME/.local/share/namada -rf
                           rm $HOME/namada -rf
                           rm $HOME/cometbft -rf
                           echo "All Namada installs have been removed."
                           sleep 3
                       else
                           echo "Operation cancelled."
                           sleep 3
                       fi
                   else
                       echo "Operation cancelled."
                       sleep 3
                   fi
               else
                   echo "Operation cancelled."
                   sleep 3
               fi;;
            5) echo "Going back to the previous menu..."
               return;;
            *) echo "Invalid choice. Please try again."
               sleep 3;;
        esac
    done
}

function namada_tool_menu {
    echo "This feature is currently under development."
    while true
    do
        echo "Choose an option:"
        echo "1/ Open RPC to Public"
        echo "2/ Turn on Prometheus"
        echo "3/ Update new Peers"
        echo "4/ Go back to the previous menu"
        echo -n "Enter your choice [1-4]: "
        read tool_option
        case $tool_option in
            1) echo "This feature is currently under development.";;
            2) echo "This feature is currently under development.";;
            3) echo "This feature is currently under development.";;
            4) return;;
            *) echo "Invalid choice. Please try again.";;
        esac
    done
}

function security_namada_menu {
    echo "This feature is currently under development."
    while true
    do
        echo "Choose an option:"
        echo "1/ Turn On/Off Port 26657"
        echo "2/ Limit Access RPC"
        echo "3/ Go back to the previous menu"
        echo -n "Enter your choice [1-3]: "
        read security_option
        case $security_option in
            1) echo "This feature is currently under development.";;
            2) echo "This feature is currently under development.";;
            3) return;;
            *) echo "Invalid choice. Please try again.";;
        esac
    done
}

function check_node_role {
    BASE_DIR="/root/.local/share/namada"
    if [ -d "$BASE_DIR/$NAMADA_CHAIN_ID" ]; then
        echo -e "You have successfully joined the ${BOLD}Namada network${NC}"
        if [ -d "$BASE_DIR/pre-genesis" ]; then
            echo -e "This node is : ${YELLOW}GENESIS VALIDATOR${NC}"
        elif [ -f "$BASE_DIR/$NAMADA_CHAIN_ID/cometbft/config/priv_validator_key.json" ]; then
            echo -e "This node is : ${GREEN}POST GENESIS VALIDATOR${NC}"
        else
            echo -e "This node is : ${BLUE}FULL NODE${NC}"
        fi
    else
        echo -e "Your node has not joined the ${BOLD}Namada Network${NC}"
        echo "Please select an option below to join Namada"
    fi
}



function join_namada_network_menu {
    while true
    do
        clear
        echo -e "=============================="
        echo -e "2/ Join ${BOLD}$(tput bold)Namada Network$(tput sgr0)${RESET}"
        echo -e "=============================="

        echo -e "To join the Namada Network, please choose one of the following options:"
        echo -e "- ${YELLOW}Genesis Validator${NC}: This role is for validators included in the Genesis file and can join/rejoin if listed in the Genesis list. If you are not selected in the Genesis list, this option will not be effective."
        echo -e "- ${GREEN}Post Genesis Validator${NC}: This role is for validators/nodes that can join after the Genesis time starts (from Block 1 onwards). You can join Namada as a Validator at any time with this option."
        echo -e "- ${BLUE}Full Node${NC}: If you only need to become a data node to serve queries from the Namada ledger or provide RPC/Indexer endpoints for DApps, this is the appropriate choice"
        echo -e "\n"

        check_node_role
        
        echo -e "\n"
        echo "Choose an option:"
        echo -e "1/ Join Namada as ${YELLOW}Genesis Validator${NC}"
        echo -e "2/ Join Namada as ${GREEN}Post Genesis Validator${NC}"
        echo -e "3/ Join Namada as ${BLUE}Full Node${NC}"
        echo "4/ Go back to the previous menu"
        echo -n "Enter your choice [1-4]: "
        read join_option
        case $join_option in
            1) echo "Joining Namada as Genesis Validator..."
               # Doing step Genesis Validator
               echo "Joined Namada as Genesis Validator."
               sleep 3;;
            2) echo "Joining Namada as Post Genesis Validator..."
               # Doing step Post Genesis Validator
               echo "Joined Namada as Post Genesis Validator."
               sleep 3;;
            3) echo "Joining Namada as Full Node..."
               # Doing step Namada as Full Node
               source ~/.bash_profile
               if [ -z "$NAMADA_CHAIN_ID" ]; then
                   echo -n "Enter NAMADA_CHAIN_ID: "
               else
                   echo -n "Current NAMADA_CHAIN_ID is $NAMADA_CHAIN_ID. Leave blank to keep the current value. If you want to change it, enter new NAMADA_CHAIN_ID: "
               fi
               read new_namada_chain_id
               if [ ! -z "$new_namada_chain_id" ]; then
                   if grep -q "export NAMADA_CHAIN_ID=" ~/.bash_profile; then
                       # If the variable is already declared in the file, replace it.
                       sed -i "s/export NAMADA_CHAIN_ID=.*/export NAMADA_CHAIN_ID=$new_namada_chain_id/" ~/.bash_profile
                   else
                       # If the variable is not declared in the file, append it.
                       echo "export NAMADA_CHAIN_ID=$new_namada_chain_id" >> ~/.bash_profile
                   fi
                   source ~/.bash_profile
               fi
               NAMADA_NETWORK_CONFIGS_SERVER="https://github.com/anoma/namada-shielded-expedition/releases/download/shielded-expedition.88f17d1d14" namada client utils join-network --chain-id $NAMADA_CHAIN_ID
               echo "Joined Namada as Full Node."
               sleep 3;;
            4) echo "Going back to the previous menu..."
               return;;
            *) echo "Invalid choice. Please try again."
               sleep 3;;
        esac
    done
}

function print_header {
    echo -e "\e[6;1mWelcome to OriginStake - Namada AIO Install Script${NC}"

    # Check for updates
    check_for_updates
}

function check_for_updates {
    # Get the latest version number from the 'version.txt' file in your GitHub repository
    latest_version=$(curl -s https://aio.namada.cc/version.txt | tr -d '\r')

    # Check if the latest version is greater than the current version
    if [[ "$latest_version" > "$CURRENT_VERSION" ]]; then
        echo -e "${RED}A new version of the script is available. Would you like to update? (Yes/No)${NC}"
        read update_confirmation
        if [[ "${update_confirmation,,}" == "yes" ]]; then
            echo -ne "Updating: ["

            for i in {1..20}; do
                echo -ne "#"
                sleep 0.25
            done

            echo -ne "] 100%     \n"

            # Download the latest version of the script and replace the current version
            wget -O $SCRIPT_NAME https://aio.namada.cc/$SCRIPT_NAME
            chmod +x $SCRIPT_NAME
            echo -e "${GREEN}The script has been updated to version $latest_version.${NC}"
            NEW_SCRIPT_NAME="namadaio"
            sudo mv $SCRIPT_NAME /usr/local/bin/$NEW_SCRIPT_NAME
            sudo chmod +x /usr/local/bin/$NEW_SCRIPT_NAME
            echo "The script has been copied to /usr/local/bin/$NEW_SCRIPT_NAME."
            exec "$(realpath $BASH_SOURCE)" #Restart the script
        else
            echo "Update cancelled."
        fi
    else
        echo -e "${GREEN}Version $CURRENT_VERSION (latest version).${NC}"
    fi
    echo -e "\n"
}

function print_settings {
    echo -e "${BOLD}Here are your current settings:${NC}"
    echo -e "${BOLD}ChainID:${NC} ${GREEN}$NEWCHAINID${NC}"
    if command -v namada &> /dev/null; then
        namada_version=$(namada --version | cut -d ' ' -f 2)
        echo -e "${BOLD}Namada version:${NC} ${GREEN}$namada_version${NC}"
    else
        echo -e "${BOLD}Namada:${NC} ${RED}Not installed${NC}"
    fi
    if command -v cometbft &> /dev/null; then
        echo -e "${BOLD}CometBFT version:${NC} ${GREEN}$(cometbft version)${NC}"
    else
        echo -e "${BOLD}CometBFT:${NC} ${RED}Not installed${NC}"
    fi
    echo -e "\n"
}

function install_namada {
    echo "You have chosen 'Install Namada - All in One Script'."
    echo "Please choose your operating system:"
    echo "1/ Linux"
    echo -n "Enter your choice [1]: "
    read os_option
    case $os_option in
        1) OPERATING_SYSTEM="linux"; OPERATING_SYSTEM_CAP="Linux";;
        *) echo "Invalid choice. Please try again."
            sleep 3
            return;;
    esac
    ARCHITECTURE="x86_64"

    echo "Updating and upgrading the system..."
    sudo apt update -y && sudo apt upgrade -y

    if ! command -v jq &> /dev/null
    then
        echo "jq is not installed. Installing..."
        case $OPERATING_SYSTEM in
            "linux") sudo apt-get install -y jq;;
        esac
        echo "jq has been installed successfully."
    else
        echo "jq is already installed."
    fi

    # Check if bc is installed
    if ! command -v bc &> /dev/null
    then
        echo "bc is not installed. Installing..."
        case $OPERATING_SYSTEM in
            "linux") sudo apt-get install -y bc;;
        esac
        echo "bc has been installed successfully."
    else
        echo "bc is already installed."
    fi

    echo "Checking Namada..."
    if ! command -v namada &> /dev/null && ! command -v namadaw &> /dev/null && ! command -v namadan &> /dev/null && ! command -v namadac &> /dev/null
    then
        echo "Namada is not installed. Installing..."
        latest_release_url=$(curl -s "https://api.github.com/repos/anoma/namada/releases/latest" | jq -r ".assets[] | select(.name | test(\"$OPERATING_SYSTEM_CAP-$ARCHITECTURE\")) | .browser_download_url")
        if [ -z "$latest_release_url" ]; then
            echo "Unable to determine download URL. Please check again."
            return
        fi
        curl -L $latest_release_url -o namada.tar.gz
        if [ $? -ne 0 ]; then
            echo "Unable to download the file. Please check again."
            return
        fi
        tar -xvf namada.tar.gz
        if [ $? -ne 0 ]; then
            echo "Unable to extract the file. Please check again."
            return
        fi
        dirname=$(tar -tzf namada.tar.gz | head -1 | cut -f1 -d"/")
        sudo mv $dirname/* /usr/local/bin/
        rm -r $dirname namada.tar.gz
        namada_version=$(namada --version | cut -d ' ' -f 2)
        echo "You have successfully installed Namada Binary, the current version is $namada_version"
    else
        echo "Namada is already installed."
        namada_version=$(namada --version | cut -d ' ' -f 2)
        echo "The current version of Namada is $namada_version"
    fi

    echo "Checking CometBFT..."
    if ! command -v cometbft &> /dev/null
    then
        echo "CometBFT is not installed. Installing..."
        cometbft_release_info=$(curl -s "https://api.github.com/repos/cometbft/cometbft/releases/tags/v0.37.2")
        machine=$(uname -m)
        if [ "$machine" == "x86_64" ]; then
            machine="amd64"
        fi
        cometbft_download_url=$(echo $cometbft_release_info | jq -r ".assets[] | select(.name | test(\"$OPERATING_SYSTEM\")) | select(.name | test(\"$machine\")) | .browser_download_url")
        if [ "$cometbft_download_url" == "null" ]; then
            echo "There are no binaries to download from this tag."
            return
        fi
        wget "$cometbft_download_url"
        tar -xzvf cometbft*.tar.gz
        sudo cp ./cometbft /usr/local/bin/
        rm cometbft*.tar.gz
        rm CHANGELOG.md LICENSE README.md SECURITY.md UPGRADING.md cometbft
        cometbft_version=$(cometbft version)
        echo "You have successfully installed CometBFT Binary, the current version is $cometbft_version"
    else
        echo "CometBFT is already installed."
        cometbft_version=$(cometbft version)
        echo "The current version of CometBFT is $cometbft_version"
    fi

    echo "Creating namadad service file..."
    sudo bash -c "cat > /etc/systemd/system/namadad.service" << EOF
[Unit]
Description=namada
After=network-online.target
[Service]
User=$(whoami)
WorkingDirectory=/root/.local/share/namada
Environment=TM_LOG_LEVEL=p2p:none,pex:error
Environment=NAMADA_CMT_STDOUT=true
Environment=NAMADA_LOG=info
ExecStart=/usr/local/bin/namada node ledger run 
StandardOutput=journal
StandardError=journal
Restart=always
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl enable namadad
    echo "The namadad service file has been created and activated."

    clear
    echo -e "${BOLD}You have successfully completed the installation of the OriginStake - Namada All in One script. Here is the current information:${NC}"
    echo -e "${BOLD}- Namada Version:${NC} ${GREEN}$namada_version${NC}"
    echo -e "${BOLD}- CometBFT Version:${NC} ${GREEN}$cometbft_version${NC}"
    echo "- A namadad.service file has been created. You can return to the main menu and start Namada."
    sleep 3
}

function check_env_wallet_info {
    while true
    do
        echo "Choose an option:"
        echo "1/ Check ENV"
        echo "2/ Check Wallet info"
        echo "3/ Update ENV info"
        echo "4/ Go back to the previous menu"
        echo -n "Enter your choice [1-4]: "
        read env_wallet_option
        case $env_wallet_option in
            1) clear
               echo -e "=============================="
               echo -e "Check ${BOLD}$(tput bold)NAMADA ENV$(tput sgr0)${RESET}"
               echo -e "These are your current environment variables in the ~/.bash_profile configuration file. These settings serve the purpose of installing Namada as well as using the Namada Binary. If you need to change any ENV, please select the Update ENV info menu below."
               echo -e "=============================="
               echo -e "\n"
               source ~/.bash_profile
               echo -e "NAMADA_TAG = \033[1;33m$NAMADA_TAG\033[0m"
               echo -e "CBFT = \033[1;33m$CBFT\033[0m"
               echo -e "NAMADA_CHAIN_ID = \033[1;33m$NAMADA_CHAIN_ID\033[0m"
               echo -e "WALLET_ADDRESS = \033[1;33m$WALLET_ADDRESS\033[0m"
               echo -e "BASE_DIR = \033[1;33m$BASE_DIR\033[0m"
               echo -e "VALIDATOR_ALIAS = \033[1;33m$VALIDATOR_ALIAS\033[0m"
               echo -e "VALIDATOR_EMAIL = \033[1;33m$VALIDATOR_EMAIL\033[0m"
               echo -e "KEY_ALIAS = \033[1;33m$KEY_ALIAS\033[0m"
               echo -e "\n"
               ;;
            2) echo "This feature is currently under development.";;
            3) update_env_info;;
            4) return;;
            *) echo "Invalid choice. Please try again.";;
        esac
    done
}

function update_env_info {
    echo "Enter new values for the ENV variables. Leave blank to keep the current value."

    declare -A env_vars
    env_vars=(["NAMADA_TAG"]=$NAMADA_TAG ["CBFT"]=$CBFT ["NAMADA_CHAIN_ID"]=$NAMADA_CHAIN_ID ["BASE_DIR"]=$BASE_DIR ["WALLET_ADDRESS"]=$WALLET_ADDRESS ["KEY_ALIAS"]=$KEY_ALIAS ["VALIDATOR_ALIAS"]=$VALIDATOR_ALIAS ["VALIDATOR_EMAIL"]=$VALIDATOR_EMAIL)

    declare -a order=("NAMADA_TAG" "CBFT" "NAMADA_CHAIN_ID" "BASE_DIR" "WALLET_ADDRESS" "KEY_ALIAS" "VALIDATOR_ALIAS" "VALIDATOR_EMAIL")

    for var in "${order[@]}"; do
        echo -n "$var (current: ${env_vars[$var]}): "
        read new_value
        if [ ! -z "$new_value" ]; then
            if grep -q "export $var=" ~/.bash_profile; then
                # If the variable is already declared in the file, replace it.
                sed -i "s/export $var=.*/export $var=$new_value/" ~/.bash_profile
            else
                # If the variable is not declared in the file, append it.
                echo "export $var=$new_value" >> ~/.bash_profile
            fi
        fi
    done

    # Refresh environment variables
    source ~/.bash_profile
}

function main_menu {
    while true
    do
        clear
        print_header
        print_settings

        # menuList

        echo "Please choose an option:"
        echo "1/ Install Namada - All in One Script"
        echo "2/ Join Namada Network"
        echo "3/ Start/Stop/Check/Remove Namada Service"
        echo "4/ Namada Tool (UD)"
        echo "5/ Security Namada node/validator (UD)"
        echo "6/ Check ENV & Wallet info"
        echo "7/ Manage Script AIO"
        echo "8/ Exit"
        echo -n "Enter your choice [1-8]: "

        read option
        case $option in
            1) install_namada;;
            2) join_namada_network_menu;;
            3) namada_service_menu;;
            4) namada_tool_menu;;
            5) security_namada_menu;;
            6) check_env_wallet_info;;
            7) manage_script;;
            8) echo "You have chosen 'Exit'."
               exit 0;;
            *) echo "Invalid choice. Please try again."
               sleep 3;;
        esac
    done
}

main_menu