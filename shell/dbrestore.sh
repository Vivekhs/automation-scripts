hom=/home/ubuntu/vivek/;
backup_loc=/home/ubuntu/vivek/backup;
declare -a dblist;

while true
do
cd $hom
declare -i count=0;
for i in `cat dbconfig.lst`;
        do
        #echo $count;
	dblist[$count]=$i;
	count+=1
        done;
db_count=$count;
echo -e "Select your database to restore :\n";

count=1;
for dbinfo in "${dblist[@]}"
	do
	#echo "$dbinfo";
	#IFS='|' read -a db_details <<< "$dbinfo";
	#echo "$count. ${db_details[0]}";
	db_name=$(echo $dbinfo|cut -d '|' -f1);
	echo "$count. ${db_name}";
	count+=1;
	done;
	read db_ch;
	if [ $db_ch -gt $db_count ];
        then
	echo -e "\n\nWrong choice!!! Please try again...\n\n\n";
	continue;
	fi;
	
	dbinfo=${dblist[$db_ch-1]};
	#echo "info is $dbinfo";
	IFS='|' read -a db_details <<< "$dbinfo";
	db_name=${db_details[0]};
	echo -e "\nSelceted database is: $db_name\n";
	mkdir -p $backup_loc/$db_name;
	cd $backup_loc/$db_name;
	rm -rf $db_name;
	#pwd;
	files=*;
	if [ $files == "*" ];
	then
	echo -e "\nNo Backup found for the selected Database...\n";
	exit 0;
	fi;
	while true
	do
	echo "Select file choice :";
	count=0;
	declare -a file_list;
	for file_name in $files
	do
	file_list[$count]=$file_name;
	count+=1;
	echo "$count. $file_name";
	done;
	read file_ch;
	if [ $file_ch -gt $count ];
	then
	echo -e "\n\nWrong choice!!! Please try again...\n\n\n";
	continue;
	fi;
	break;
	done;
	echo -e "\n\nSelected file is: "${file_list[$file_ch-1]}"\n\n\n";
	mkdir $db_name;
	file_name=$(echo ${file_list[$file_ch-1]}|cut -d"." -f1);
	#echo "$file_name";
	dt=`date +"%m-%d-%y-%H-%M-%S"`;

	#DB Backup before restore

	mongodump --db $db_name --host ${db_details[1]} --port ${db_details[2]} --username ${db_details[3]} --password ${db_details[4]} --out $backup_loc/$db_name/$dt
        tar cf ${dt}.tar ${dt};
        gzip ${dt}.tar;
        echo "tar file created";
        rm -Rf ${dt};

	tar --strip-components=2 -xvzf ${file_list[$file_ch-1]} -C ${db_details[0]} ${file_name}/${db_details[0]}
	mongorestore --host ${db_details[1]} --port ${db_details[2]} --username ${db_details[3]} --password ${db_details[4]} --db ${db_name} --drop ${db_name}
	rm -rf $db_name;
	echo -e "\n\n\nDatabase restore was successful...\n\n";
	exit 0;
done;
