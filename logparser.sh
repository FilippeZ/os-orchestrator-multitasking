#!/bin/bash

#Team Members

#Filippos-Paraskevas Zygouris
std1AM="1084660"
#Niki-Aikaterini Kyriakatou
std2AM="1084624"
#Maria-Anastasia Kyriakatou
std3AM="1059656"


#Check if a file was providen as an argument in the command line
if [ $# -eq 0 ];
then
#No file provided ,so display team members IDs
echo "$std1AM|$std2AM|$std3AM"
exit 0
fi


#Check if the log file has the correct extantion
echo "Give the filename with the correct extantion:"
read filename
if [ "${filename: -4}" != ".log" ]; 
then
echo "Wrong File Argument"
echo "Instead use the correct form $filename.log"
exit 1
fi

#Check if the log file exists
if [ ! -f "$1" ]; 
then 
echo "Error! $filename.log file not found."
exit 1
fi

#Set the iternal field separator to a newline character
IFS=$'\n'

if [ -z "$2" ]; then
while read -r line; do
echo "$line"
done < "$1"
fi

#Define the mining_usernames funcion
mining_usernames(){
awk '{ user_counts[$3]++ } END {
for(user in user_counts) {
printf "%d %s\n", user_counts[user],user
}
}' "$1" | sort -k 2 
}


#Check if the option --usrid was provided
if [ "$2" = "--usrid" ]; 
then
#Check if a user role was provided
if [ -z "$3" ];
then
#None of them provided, so display the counts for all the users
mining_usernames "$1"
else
#User role provided, so display the log entries and the information for the specific user
case $3 in
root)
#Print the log entries for root
sed -n '/root/p' "$1"
;;
admin)
#Print the log entries for admin
sed -n '/admin/p' "$1"
;;
user1)
#Print the log entries for user1
sed -n '/user1/p' "$1"
;;
user2)
#Print the log entries for user2
sed -n '/user2/p' "$1"
;;
user3)
#Print the log entries for user3
sed -n '/user3/p' "$1"
;;
president)
#Print the log entries for president
sed -n '/president/p' "$1"
;;
*)
#Invalid user role
echo "ERROR: Invalid user role!"
exit 1
;;
esac
fi
fi


#Check if the option -method was provided
if [ "$2" = "-method" ]; then
#Check if a method name was provided
if [ -z "$3" ]; then
echo "Error: You should give a method name!"
exit 1
fi
#Check if method name is valid
case "$3" in
GET)
sed -n '/GET/p' "$1"
;;
POST)
sed -n '/POST/p' "$1"
;;
*)
echo "Error: You should give a correct method name! (Must be GET or POST)"
exit 1
;;
esac
fi

#Check if the option --servprot was provided
if [ "$2" = "--servprot" ]; then
#Check if a network protocol was provided
if [ -z "$3" ]; then
echo "Error: You should give a Network Protocol!"
exit 1
fi
#Check if Network Protocol is valid
case "$3" in
IPv4)
sed -n '/127.0.0.1/p' "$1"
;;
IPv6)
sed -n '/::1/p' "$1"
;;
*)
echo "Error: You should give a correct Network Protocol! (Must be IPv4 or IPv6)"
exit 1
;;
esac
fi


#Define the count_browsers function
count_browsers() {
awk '{ match($0, "Mozilla")
browser_counts[substr($0, RSTART, RLENGTH)]++
match($0, "Chrome")
browser_counts[substr($0, RSTART, RLENGTH)]++
match($0, "Safari")
browser_counts[substr($0, RSTART, RLENGTH)]++
match($0, "Edg")
browser_counts[substr($0, RSTART, RLENGTH)]++

} END {
for(browser in browser_counts) {
printf "%s %d\n", browser,browser_counts[browser]
}
}' "$1" | sort -n
}


#Check if the option --browsers was provided
if [ "$2" = "--browsers" ]; then
#Display the counts for all the browsers
count_browsers "$1" 
exit 1
fi


#Check if the option --datum was provided
if [ "$2" = "--datum" ]; 
then
datum=$3
#Check if date is a month
if [[ "$datum" =~ ^[Jj][Aa][Nn]$ ]]; then
datum="Jan"
elif [[ "$datum" =~ ^[Ff][Ee][Bb]$ ]]; then
datum="Feb"
elif [[ "$datum" =~ ^[Mm][Aa][Rr]$ ]]; then
datum="Mar"
elif [[ "$datum" =~ ^[Aa][Pp][Rr]$ ]]; then
datum="Apr"
elif [[ "$datum" =~ ^[Mm][Aa][Yy]$ ]]; then
datum="May"
elif [[ "$datum" =~ ^[Jj][Uu][Nn]$ ]]; then
datum="Jun"
elif [[ "$datum" =~ ^[Jj][Uu][Ll]$ ]]; then
datum="Jul"
elif [[ "$datum" =~ ^[Aa][Uu][Gg]$ ]]; then
datum="Aug"
elif [[ "$datum" =~ ^[Ss][Ee][Pp]$ ]]; then
datum="Sep"
elif [[ "$datum" =~ ^[Oo][Cc][Tt]$ ]]; then
datum="Oct"
elif [[ "$datum" =~ ^[Nn][Oo][Vv]$ ]]; then
datum="Nov"
elif [[ "$datum" =~ ^[Dd][Ee][Cc]$ ]]; then
datum="Dec"
else
echo "Error: Wrong Date. You should give a correct Date! (Must be Jan...Dec)"
exit 1
fi

case "$datum" in 
Jan)
sed -n '/Jan/p' "$1"
;;
Feb)
sed -n '/Feb/p' "$1"
;;
Mar)
sed -n '/Mar/p' "$1"
;;
Apr)
sed -n '/Apr/p' "$1"
;;
May)
sed -n '/May/p' "$1"
;;
Jun)
sed -n '/Jun/p' "$1"
;;
Jul)
sed -n '/Jul/p' "$1"
;;
Aug)
sed -n '/Aug/p' "$1"
;;
Sep)
sed -n '/Sep/p' "$1"
;;
Oct)
sed -n '/Oct/p' "$1"
;;
Nov)
sed -n '/Nov/p' "$1"
;;
Dec)
sed -n '/Dec/p' "$1"
;;
*)
exit 1
esac
fi
