
alias genUser='
useracc="User_Accounts.txt";
cut -f 2 -d " " $useracc | sort -fi | uniq | awk '\''{print("groupadd " $1 "; useradd -m -d /home/" $1 " -g " $1 " -s /bin/bash " $1 "; passwd " $1 " < defpass.txt") | "/bin/bash"}'\'';
awk '\''{print("useradd -m -d /home/" $1 " -g " $2 " -s /bin/bash -c \"" $3 "|" $4 "|" $5 "\" " $1 "; passwd " $1 " < defpass.txt; cp Curr_Bal.txt /home/" $1 "/Current_Balance.txt; chown " $1 ":" $2 " /home/" $1 "/Current_Balance.txt; cp Trans_hist_user.txt /home/" $1 "/Transaction_History.txt; chown " $1 ":" $2 " /home/" $1 "/Transaction_History.txt; ") | "/bin/bash"}'\'' $useracc;'

alias permit='
useradd -m -d /home/OmegaCEO -s /bin/bash OmegaCEO;
passwd OmegaCEO < defpass.txt;
chmod -R 711 /home/OmegaCEO;
grep "Branch" /etc/passwd | cut -f1 -d: | awk '\''{print("chmod -R 711 /home/" $1 "; setfacl -R -m u:OmegaCEO:rx /home/" $1) | "/bin/bash"}'\'';
grep "ACC" /etc/passwd | cut -f 1,4 -d: | awk -F ":" '\''{print("chmod -R 711 /home/" $1 "; setfacl -R -m u:$(id -nu " $2 "):rwx /home/" $1) | "/bin/bash"}'\'';
grep "ACC" /etc/passwd | cut -f 1 -d: | awk -F ":" '\''{print("setfacl -R -m u:OmegaCEO:rx /home/" $1) | "/bin/bash"}'\'';'

alias updateBranch='
grp=$(id -g $USER);
grep "ACC" /etc/passwd | grep "$grp_id" | cut -f1 -d: | awk '\''BEGIN{print("branch_bal=0") | "/bin/bash"} { print("usr_bal=$(cat /home/" $1 "/Current_Balance.txt); branch_bal=$(echo \"$branch_bal+$usr_bal\" | bc -l);") | "/bin/bash" } END {print("echo $branch_bal > $HOME/Branch_Current_Balance.txt") | "/bin/bash" }'\'';
if [[ ! -e $HOME/Branch_Transaction_History.txt ]]; then
	echo "Account-number Amount Date Time" > $HOME/Branch_Transaction_History.txt
fi
grep "ACC" /etc/passwd | grep "$grp_id" | cut -f1 -d: | awk '\''{ print("tail -n +2 /home/" $1 "/Transaction_History.txt >> $HOME/Branch_Transaction_History.txt") | "/bin/bash"}'\'';'

alias allotInterest='
intrst=100;
citizen=$(echo "$(grep "citizen" $HOME/Daily_Interest_Rates.txt | cut -f 2 -d " " | cut -f1 -d%) / 100" | bc -l);
resident=$(echo "$(grep "resident" $HOME/Daily_Interest_Rates.txt | cut -f 2 -d " " | cut -f1 -d%) / 100" | bc -l);
foreigner=$(echo "$(grep "foreigner" $HOME/Daily_Interest_Rates.txt | cut -f 2 -d " " | cut -f1 -d%) / 100" | bc -l);
snrcitizen=$(echo "$(grep "seniorCitizen" $HOME/Daily_Interest_Rates.txt | cut -f 2 -d " " | cut -f1 -d%) / 100" | bc -l);
minor=$(echo "$(grep "minor" $HOME/Daily_Interest_Rates.txt | cut -f 2 -d " " | cut -f1 -d%) / 100" | bc -l);
legacy=$(echo "$(grep "legacy" $HOME/Daily_Interest_Rates.txt | cut -f 2 -d " " | cut -f1 -d%) / 100" | bc -l);
grep "ACC" /etc/passwd | grep $(id -u $USER) | cut -f 1,5 -d ":" | awk -F ":" -v citizen="$citizen" -v resident="$resident" -v foreigner="$foreigner" -v snrcitizen="$snrcitizen" -v minor="$minor" -v legacy="$legacy" '\''{ print("cum_intr=1") | "/bin/bash" ; if ( $2 ~ /citizen/ ) { print("cum_intr=$(echo \"$cum_intr+" citizen "\" | bc -l)") | "/bin/bash" } if ( $2 ~ /resident/ ) { print("cum_intr=$(echo \"$cum_intr+" resident "\" | bc -l)") | "/bin/bash" } if ( $2 ~ /foreigner/ ) { print("cum_intr=$(echo \"$cum_intr+" foreigner "\" | bc -l)") | "/bin/bash" } if ( $2 ~ /seniorCitizen/ ) { print("cum_intr=$(echo \"$cum_intr+" snrcitizen" \" | bc -l)") | "/bin/bash" } if ( $2 ~ /minor/ ) { print("cum_intr=$(echo \"$cum_intr+" minor "\" | bc -l)") | "/bin/bash" } if ( $2 ~ /legacy/ ) { print("cum_intr=$(echo \"$cum_intr+" legacy "\" | bc -l)") | "/bin/bash" } print("net_bal=$(echo \"scale=2; $(cat /home/" $1 "/Current_Balance.txt)*$cum_intr\" | bc); echo $net_bal > /home/" $1 "/Current_Balance.txt;") | "/bin/bash" }'\'';'

alias makeTransaction='
curbal=$(cat $HOME/Current_Balance.txt);
echo "Welcome to Omega Bank";
echo "Your current balance is: $curbal";
echo "Do you wish to Withdraw(w) or Deposit(d)";
read action;
if [ "$action" == "w" ];
then
	echo "Enter amount to withdraw";
	read amount;
	if (( $(echo "$amount > 0" | bc -l) ));
	then
		bal_left=$(echo "scale=2; $curbal-$amount" | bc);

		if (( $(echo "$curbal > $amount" | bc -l) ));
		then
			echo $bal_left > $HOME/Current_Balance.txt;
			echo "$USER -$amount $(date +%F) $(date +%T)" >> $HOME/Transaction_History.txt;
		else
			echo "Insufficient balance";
		fi;
	else
		echo "Enter positive amount";
	fi;
elif [ "$action" == "d" ];
then
	echo "Enter amount to deposit";
	read amount;
	bal_left=$(echo "scale=2; $curbal+$amount" | bc);
	if (( $(echo "$amount > 0" | bc -l) ));
	then
		echo $bal_left > $HOME/Current_Balance.txt;
		echo "$USER +$amount $(date +%F) $(date +%T)" >> $HOME/Transaction_History.txt;
	else
		echo "Enter positive amount";
	fi;
else
	echo "Invalid option";
fi;'

alias genSummary='
echo "Enter filename to obtain data or leave blank to take existing data"
read tran_file
if [[ $tran_file != *.txt ]];
then
	tran_file=Branch_Transaction_History.txt
fi
tail -n +2 $tran_file | sort -nrt " " -k3,3d -k2,2Vd | tac > sort_tran.txt
sed -i -e "s/+//" sort_tran.txt
echo "Transactions by highest value each month:" >> Summary.txt
echo "" >> Summary.txt
val=""
yr_mn=0
while read -r line; do
	dtecmp=$(echo $line | cut -f 3 -d " " | cut -f 1,2 -d "-")
	if [[ $yr_mn != $dtecmp ]];
	then
		yr_mn=$dtecmp
		echo $line >> Summary.txt
		val=$line
	fi
	if [[ $val != "_._" ]];
	then
		prod=$(echo "$(echo $val | cut -f2 -d\ ) * $(echo $line | cut -f2 -d\ )" | bc -l)
		if [[ $(echo "$prod < 0" | bc -l) -eq 1 ]];
		then
			echo $line >> Summary.txt
			echo "" >> Summary.txt
			val="_._"
		fi
	fi
done < sort_tran.txt
exp=0
c=0
yr_mn=0

while read -r line; do
	dtecmp=$(echo $line | cut -f 3 -d " " | cut -f 1,2 -d "-")
	val=$(echo $line | cut -f 2 -d " ")
	if [[ $yr_mn == $dtecmp ]];
	then
		if [[ $(echo "$val < 0" | bc -l) -eq 1 ]];
		then
			c=$((c+1))
			exp=$(echo "$exp + $val" | bc -l)
		fi
	else
		if [[ $c -gt 0 ]];
		then
			echo mean of expenditure for $yr_mn = $(echo "$exp / $c" | bc -l) >> Summary.txt
			
			if [[ $c%2 -eq 1 ]];
			then
				med=$(grep $yr_mn sort_tran.txt | cut -f 2 -d " " | grep "-" | head -n $(((c+1)/2)) | tail -n 1)
			else
				med=$(echo "$(grep $yr_mn sort_tran.txt | cut -f 2 -d\ | grep - | head -n $((c+1)) | tail -n 2 | paste -sd+ | bc -l) / 2" | bc -l)
			fi
			echo "median of expenditure for $yr_mn = $med" >> Summary.txt
			
			grep $yr_mn sort_tran.txt | cut -f 2 -d " " | grep "-" | uniq -c | cut -f 7,8 -d " " | sort -nr -k1 > mode_list.txt
			printf "mode of expenditure for $yr_mn is:" >> Summary.txt
			echo $(head -n 1 mode_list.txt | cut -f2 -d " ") >> Summary.txt
			
			echo "" >> Summary.txt
		fi
		yr_mn=$dtecmp
		c=1
		exp=$val
	fi
done < sort_tran.txt

if [[ $c -gt 0 ]];
then
	echo mean of expenditure for $yr_mn = $(echo "$exp / $c" | bc -l) >> Summary.txt
	
	if [[ $c%2 -eq 1 ]];
	then
		med=$(grep $yr_mn sort_tran.txt | cut -f 2 -d " " | grep "-" | head -n $(((c+1)/2)) | tail -n 1)
	else
		med=$(echo "$(grep $yr_mn sort_tran.txt | cut -f 2 -d\ | grep - | head -n $((c+1)) | tail -n 2 | paste -sd+ | bc -l) / 2" | bc -l)
	fi
	echo median of expenditure for $yr_mn = $med >> Summary.txt
	
	grep $yr_mn sort_tran.txt | cut -f 2 -d " " | grep "-" | uniq -c | cut -f 7,8 -d " " | sort -nr -k1 > mode_list.txt
	printf "mode of expenditure for $yr_mn is:" >> Summary.txt
	echo $(head -n 1 mode_list.txt | cut -f2 -d " ") >> Summary.txt
	
	echo "check Summary.txt for generated branch summary"
fi'


