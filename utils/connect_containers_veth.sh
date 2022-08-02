#!/bin/bash

#===================   COLORIZING  OUTPUT =================
declare -A colors
colors=(
	[none]='\033[0m'
	[bold]='\033[01m'
	[disable]='\033[02m'
	[underline]='\033[04m'
	[reverse]='\033[07m'
	[strikethrough]='\033[09m'
	[invisible]='\033[08m'
	[black]='\033[30m'
	[red]='\033[31m'
	[green]='\033[32m'
	[orange]='\033[33m'
	[blue]='\033[34m'
	[purple]='\033[35m'
	[cyan]='\033[36m'
	[lightgrey]='\033[37m'
	[darkgrey]='\033[90m'
	[lightred]='\033[91m'
	[lightgreen]='\033[92m'
	[yellow]='\033[93m'
	[lightblue]='\033[94m'
	[pink]='\033[95m'
	[lightcyan]='\033[96m'

)
num_colors=${#colors[@]}
# -----------------------------------------------------------

# ==================== USE THIS FUNCTION TO PRINT TO STDOUT =============
# $1: color
# $2: text to print out
# $3: no_newline - if nothing is provided newline will be printed at the end
#				 - anything provided, NO newline is indicated
function c_print () {
	color=$1
	text=$2
	no_newline=$3
	#if color exists/defined in the array
	if [[ ${colors[$color]} ]]
	then
		text_to_print="${colors[$color]}${text}${colors[none]}" #colorized output
	else
		text_to_print="${text}" #normal output
	fi

	if [ -z "$no_newline" ]
	then
		echo -e $text_to_print # newline at the end
	else
		echo -en $text_to_print # NO newline at the end
	fi

}
# -----------------------------------------------------------



function print_help {
	echo
	c_print "none" "Usage:" 0
	c_print "bold" "./connect_containers_veth.sh <container_name1> <container_name2> <veth_name_in_container1> <veth_name_in_container2>"
	echo
	exit -1
}

function clean_up {
	c_print "red" "[FAILED]\n"
	echo
	c_print "none" "Cleaning up..."
	c_print "yellow" "Removing symlink to containers ${container_name1},${container_name2}(if created)..." 0
	sudo rm -rf /var/run/netns/$container_name1 >/dev/null
  sudo rm -rf /var/run/netns/$container_name2 >/dev/null
	c_print "green" "[OK]\n"
	c_print "yellow" "Removing veth pair  ${veth_name_in_container1} - ${veth_name_in_container2} (if created)..." 0
	sudo ip netns exec $container_name1 ip link del $veth_name_in_container1 &> /dev/null
	c_print "green" "[OK]\n"
	echo
	exit -1
}

# ============ PARSE ARGS ================
if [ $# -ne 4 ]
then
	c_print "red" "Insufficient number of attributes"
	print_help
fi

container_name1=$1
container_name2=$2
veth_name_in_container1=$3
veth_name_in_container2=$4

# ----------------------------------------

# ======================= CHECKING CONTAINER RUNNING STATUS AND EXISTENCE =====================================
function check_container_existance ()
{
  # $1 container name to check
  container_name=$1
  c_print "none" "Checking whether container ${colors[bold]}${container_name}${colors[none]} is running..." 0
  #checking running container is a bit tricky - as -f name=<name> works like grep, so substring of a container_name
  #will also be printed out, but if we compare it to the actual name again, then we can filter properly
  #we need an extra $ sign at the end of name= filter to filter for that specific container and not catch any other
  #containers that might have this name as a substring in the beginning
  if [[ $(sudo docker ps -a --filter "status=running" -f "name=$container_name$" --format '{{.Names}}') != $container_name ]]
  then
  	c_print "red" "[FAILURE]"
  	c_print "red" "${container_name} is not running"
  	c_print "yellow" "Use ${colors[bold]}sudo docker ps -a${colors[none]} to find out more on your own\n"

  	clean_up
  fi
  c_print "green" "[OK]"
  c_print "green" "${container_name} is found and up and running\n"
}
#------------------------------------------------------------------------------------------------------------

#checking containers status
check_container_existance $container_name1
check_container_existance $container_name2


function create_netns_binding2container ()
{
  container_name=$1

  c_print "none" "Getting PID of the running container ${colors[bold]}${container_name}:   " 0
  pid=$(docker inspect -f '{{.State.Pid}}' $container_name)
  c_print "green" "[OK] (${pid})\n"

  c_print "none" "Creating ${colors[bold]}/var/run/netns/${colors[none]} directory..." 0
  mkdir -p /var/run/netns/
  c_print "green" "[OK]\n"

  c_print "none" "Create a symlink ${colors[bold]}${container_name}${colors[none]} in ${colors[bold]}/var/run/netns/${colors[none]} pointing to ${colors[bold]}/proc/${pid}/ns/net..." 0
  sudo ln -sf /proc/$pid/ns/net /var/run/netns/$container_name
  if [ $? -ne 0 ]
  then
  	clean_up
  fi
  c_print "green" "[OK]\n"
}

#create namespace binding for containers
create_netns_binding2container $container_name1
create_netns_binding2container $container_name2




function check_interface_existance ()
{
  container_name=$1
  veth_name=$2
  # check in the beginning whether the interfaces exist
  interface_contains_vethname=$(sudo docker exec ${container_name} ip link|grep $veth_name_in_container1|cut -d ':' -f 2 |cut -d '@' -f 1|sed "s/ //g")
  c_print "none" "Looking for existing device names as ${veth_name} in container ${container_name}..." 0
  if [[ $interface_contains_vethname == "" ]]
  then
  	found="NONE"
  	c_print "green" "[OK]"
  else
  	found=$interface_contains_vethname
  	c_print "yellow" "[WARN]"
  	c_print "none" "Similar interfaces found: ${colors[bold]}${colors[yellow]}${found}"
  fi


  #check whether that interface's is exactly the one that we are intended to add next
  if [[ $found != "NONE" ]]
  then
  	for i in $interface_contains_vethname
  	do
  		if [[ $i == $veth_name ]]
  		then
  			c_print "yellow" "There is already an interface called ${colors[bold]}${colors[red]}${veth_name} in container ${container_name}\n"
  			c_print "none" "Please use another name or remove manually by:"
  			c_print "bold" "\$ sudo ip netns exec $container_name ip link del ${veth_name}\n\n"
  			exit -1
  		fi
  	done
  fi

}

#check interface existance
check_interface_existance $container_name1 $veth_name_in_container1
check_interface_existance $container_name2 $veth_name_in_container2


c_print "none" "Interface names..." 0
c_print "green" "[OK]"
c_print "green" "Interface names are in a good shape! None of them exists!!\n\n"



function bring_up_interface ()
{
  interface=$1
  c_print "none" "Bringing up ${colors[bold]}${interface}..."
  sudo ip -4 link set $interface up
  if [ $? -ne 0 ]
  then
  	clean_up
  fi
  c_print "green" "[OK]\n"
}


c_print "none" "Create veth pair ${colors[bold]}${veth_name_in_container1} -- ${veth_name_in_container2}${colors[none]}..." 0
sudo ip link add $veth_name_in_container1 type veth peer name $veth_name_in_container2
if [ $? -ne 0 ]
then
	clean_up
fi
c_print "green" "[OK]\n"

bring_up_interface $veth_name_in_container1
bring_up_interface $veth_name_in_container2



function add_veth_to_container ()
{
  container_name=$1
  veth_name_in_container=$2
  c_print "none" "Add ${colors[bold]}${veth_name_in_container}${colors[none]} to container ${colors[bold]}${container_name}${colors[none]}..." 0
  sudo ip link set $veth_name_in_container netns $container_name
  if [ $? -ne 0 ]
  then
  	clean_up
  fi
  c_print "green" "[OK]\n"

  c_print "none" "Bring up manually the interface in the container as well..." 0
  sudo ip netns exec $container_name ip -4 addr add 0/0 dev $veth_name_in_container
  sudo ip netns exec $container_name ip -4 link set $veth_name_in_container up
  if [ $? -ne 0 ]
  then
  	clean_up
  fi
  c_print "green" "[OK]\n"
}

#add veths to containers and bring them up inside the containers
add_veth_to_container $container_name1 $veth_name_in_container1
add_veth_to_container $container_name2 $veth_name_in_container2
