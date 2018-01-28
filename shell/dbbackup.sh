hom="/home/ubuntu/vivek";
while true
do
cd $hom
for i in `cat $hom/latfin/dbconfig.lst`;
        do
        echo $i
        db_name=$(echo $i|cut -d"|" -f1);
        host_name=$(echo $i|cut -d"|" -f2);
        port_num=$(echo $i|cut -d"|" -f3);
        user_name=$(echo $i|cut -d"|" -f4);
        password=$(echo $i|cut -d"|" -f5);
        dt=`date +"%m-%d-%y-%H-%M-%S"`;
        mongodump --db $db_name --host $host_name --port $port_num --username $user_name --password $password --out $hom/backup/$db_name/$dt
        cd $hom/backup/$db_name/;
        find . -name "*.tar.gz" -mtime 7 -exec rm -rf {} \;
        tar cf ${dt}.tar ${dt};
        gzip ${dt}.tar;
        echo "tar file created";
        rm -Rf ${dt};
        done;
sleep 86400;
done;
