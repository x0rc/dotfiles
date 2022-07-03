#!/bin/bash
#
# git clone <addr>
# Usage: ./x0r.sh  ( defaults to the menu system )
# command line arguments are valid, only catching 1 arguement
#
# Full Revision history can be found in changelog.txt
# Standard Disclaimer: Author assumes no liability for any damage


# global variables
SCRIPTNAME=x0r.sh
CLUSTER_NAME=iwcommerce-dev

# variables moved from local to global
awsprofile=""


# unicorn puke:
    red=$'\e[1;31m'
    green=$'\e[1;32m'
    blue=$'\e[1;34m'
    magenta=$'\e[1;35m'
    cyan=$'\e[1;36m'
    yellow=$'\e[1;93m'
    white=$'\e[0m'
    bold=$'\e[1m'
    norm=$'\e[21m'
    reset=$'\e[0m'

# status indicators
    greenplus='\e[1;33m[++]\e[0m'
    greenminus='\e[1;33m[--]\e[0m'
    redminus='\e[1;31m[--]\e[0m'
    redexclaim='\e[1;31m[!!]\e[0m'
    redstar='\e[1;31m[**]\e[0m'
    blinkexclaim='\e[1;31m[\e[5;31m!!\e[0m\e[1;31m]\e[0m'
    fourblinkexclaim='\e[1;31m[\e[5;31m!!!!\e[0m\e[1;31m]\e[0m'
    redblinkers='\e[1;31m[\e[5;31m!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\e[0m\e[1;31m]\e[0m'

#####################################

progress_bar () {
    for ((k = 0; k <= 10 ; k++))
    do
        echo -n "[ "
        for ((i = 0 ; i <= k; i++)); do echo -n "###"; done
        for ((j = i ; j <= 10 ; j++)); do echo -n "   "; done
        v=$((k * 10))
        echo -n " ] "
        echo -n "$green $v %" $'\r'
        sleep 0.05
    done
    echo
}

status_pods () {
    kubectl get pods -o wide -l 'app in (iwjwt,iwapi,iwshop,iwadmin,adminer,mailhog,test)' 2>/dev/null
    # if [ $? == 0 ]; then
    # echo "$red No pods are available at the moment."
    # echo "$red Call 0-800-SOMEONESGONNAGETFIRED!"
    # fi   
}

iwjwt () {
    echo "$green" $(progress_bar)
    kubectl exec -i -t $(kubectl get pod -l "app=iwjwt" -o name) -- bash 2>/dev/null
    if [ $? -ne 0 ]; then
    echo "$red Cannot connect to the selected pod."
    echo "$red To list the available pods use: --status"
    fi
}

iwapi () {
    echo "$green" $(progress_bar)
    kubectl exec -i -t $(kubectl get pod -l "app=iwapi" -o name) -- bash 2>/dev/null
    if [ $? -ne 0 ]; then
    echo "$red Cannot connect to the selected pod."
    echo "$red To list the available pods use: --status"
    fi
}

iwshop () {
    echo "$green" $(progress_bar)
    kubectl exec -i -t $(kubectl get pod -l "app=iwshop" -o name) -- bash 2>/dev/null
    if [ $? -ne 0 ]; then
    echo "$red Cannot connect to the selected pod."
    echo "$red To list the available pods use: --status"
    fi
}

iwadmin () {
    echo "$green" $(progress_bar)
    kubectl exec -i -t $(kubectl get pod -l "app=iwadmin" -o name) -- bash 2>/dev/null
    if [ $? -ne 0 ]; then
    echo "$red Cannot connect to the selected pod."
    echo "$red To list the available pods use: --status"
    fi
}

adminer () {
    echo "$green" $(progress_bar)
    kubectl exec -i -t $(kubectl get pod -l "app=adminer" -o name) -- sh 2>/dev/null
    if [ $? -ne 0 ]; then
    echo "$red Cannot connect to the selected pod."
    echo "$red To list the available pods use: --status"
    fi
}

mailhog () {
    echo "$green" $(progress_bar)
    kubectl exec -i -t $(kubectl get pod -l "app=mailhog" -o name) -- sh 2>/dev/null
    if [ $? -ne 0 ]; then
    echo "$red Cannot connect to the selected pod."
    echo "$red To list the available pods use: --status"
    fi
}

aws_setup () {
    AWS_DEFAULT_REGION=us-east-1
    CLUSTER_NAME=iwcommerce-dev    

    echo -e "$blinkexclaim $green Configuring your AWS profile..."
    read -p "$green       AWS Profile name: $red " PROFILE 
    read -p "$green       AWS Access Key ID [None]: $red " aws_access_key_id
    read -p "$green       AWS Secret Access Key [None]: $red " aws_secret_access_key
    echo -e "$green       Default region name: $red $AWS_DEFAULT_REGION"
    echo -e "$green       Default output format: $red json $AWS_DEFAULT_OUTPUT"
    read -p "$green       Are you sure? (Y/N): $red" confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
    # aws cli configuration / one liner
    aws configure --profile $PROFILE set aws_access_key_id $aws_access_key_id; aws configure --profile $PROFILE set aws_secret_access_key $aws_secret_access_key; aws configure set default.region $AWS_DEFAULT_REGION
    echo -e "$greenplus $green  Updating your kubeconfig..."
    aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_DEFAULT_REGION --profile $PROFILE
    echo -e "$greenplus $green $white$bold Access granted"
    echo $PROFILE

    }


readme () {
    clear
    echo -e "

                    $fourblinkexclaim"$redclaim$white$bold" USERS MANUAL"$redclaim$white$bold" $fourblinkexclaim

  $bold In order to make this script useful and gain access to IWCommerce EKS,
   you need to do three things:

    1. Setup your AWS profile.
        Later, to update your kubeconfig file, the script
        needs to know which AWS profile you are using. 

    2. Make sure you have kubectl installed in your system.
        kubectl a cli tool for communicating with
        a Kubernetes cluster's control plane, using the Kubernetes API 
        that allows you to run commands against Kubernetes clusters.

    3. Get the kubeconfig.
        A kubeconfig file is a file used to configure access 
        to Kubernetes when used in conjunction with the kubectl.

    If you already have aws-cli, kubectl && *_accessKeys.csv 
    file prepared, you can:
        a) ./$SCRIPTNAME --setup
        b) ./$SCRIPTNAME & press "0"

    "
    read -n1 -p "  Press$red$bold Enter$white$bold to get back to the menu or $red$bold X $white$bold to exit: " menuinput
    case $menuinput in
    enter) iwjwt;;
      x|X) echo -e "\n\n Exiting $SCRIPTNAME - See yah! \n" ;;
      *) iwck8s_menu ;;
    esac
    }



iwck8s_menu () {
    clear
    echo -e "$red Hello $USER,"
    echo -e "\n $red $bold This is IWCommerce pod manager v2.0"  
    echo -e "\n    What would you like to do?"
    echo -e "\n Key  Menu Option:             Description:"
    echo -e " ---  ------------             ------------" 
    echo -e "  1 - Connect to iwjwt         (interactive tty shell session with the pod)"                          # iwjwt
    echo -e "  2 - Connect to iwapi         (interactive tty shell session with the pod)"                          # iwapi
    echo -e "  3 - Connect to iwshop        (interactive tty shell session with the pod)"                          # iwshop    
    echo -e "  4 - Connect to iwadmin       (interactive tty shell session with the pod)"                          # iwadmin 
    echo -e "  5 - Connect to adminer       (interactive tty shell session with the pod)"                          # adminer
    echo -e "  6 - Connect to mailhog       (interactive tty shell session with the pod)"                          # mailhog
    echo -e "  S - Status                   (list pods in ps output format)"                                       # status_pods
    echo -e "  9 - AWS Setup                (configuring your AWS profile)"                       # aws_setup
    echo -e "  0 - Users Manual             (srsly, read it)"                                                     # readme
    echo -e "  H - Help                     (prints the valid command arguments)"    
    echo -e "\n$(weather)"    
    echo -e "\n"                                                                          
    echo -e "\n"
    read -n1 -p "  Press key for menu item selection or press $red $bold X  to exit: " menuinput
    echo -e "\n"

    case $menuinput in
        1) iwjwt;;
        2) iwapi;;     
        3) iwshop;;     
        4) iwadmin;;   
        5) adminer;; 
        6) mailhog;; 
      s|S) status_pods;; 
        h) iwck8s_menu_help;; 
      k|K) get_kubeconfig;;
        9) aws_setup;;         
        0) readme;;  
      x|X) echo -e "\n\n Exiting $SCRIPTNAME - See yah! \n" ;;
      *) iwck8s_menu ;;
    esac
    }

iwck8s_menu_help () {
    # do not edit this echo statement, spacing has been fixed and is correct for display in the terminal
    echo -e "\n $red valid command line arguements are:        "
    echo " --aws                                         "
    echo " --kubeconfig                                  "
    echo -e "\n $red other command line arguements are:  "
    echo " --jwt                                    "
    echo " --api                                    "
    echo " --shop                                   "
    echo " --admin                                  "
    echo " --adminer                                "
    echo " --mailhog                                "
    echo " --status                                 "
    echo " --aws                                    "
    echo " --help                                   "

    exit
    }

check_arg () {
    if [ "$1" == "" ]
      then iwck8s_menu
     else
      case $1 in
            --menu) iwcommerce_menu                  ;;
             --jwt) iwjwt                            ;;
             --api) iwapi                            ;;
            --shop) iwshop                           ;;
           --admin) iwadmin                          ;;  
         --mailhog) mailhog                          ;;
         --adminer) adminer                          ;;  
          --status) status_pods                      ;;
           --setup) aws_setup                        ;;
        *) iwck8s_menu_help ; exit 0                 ;;
    esac
    fi
    }

weather() {
    curl -s 'wttr.in/{Skopje,Bitola,Prilep}?format=3'
}

exit_screen () {
    echo "$green$(progress_bar)"
    echo -e "$green\n\n    All Done! o7! \n"
    exit
    }

check_arg "$1"
exit_screen