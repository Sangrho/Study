#!/bin/bash
##################### 
# Changeable Input #
#####################
#Each namespace
SOURCE_NAMESPACE=""
SOURCE_NN1=""
SOURCE_NN2=""
DEST_NAMESPACE=""
DEST_NN1=""
DEST_NN2=""

#Each hive connection (Example : 'beeline --showHeader=false --outputformat=tsv2 -u "jdbc:hive2://lnthhmbe1504.nhnjp.ism:10000/default;principal=hive/_HOST@MUSIC.ITSC.COM"')
SOURCE_HIVE=''
DEST_HIVE=''
HIVE_META_DB_USER=''
HIVE_META_DB_PASSWORD=''
HIVE_META_DB_URL=''
HIVE_META_DB_PORT=''
PARTITION_LIMIT=''

#Distcp Option
BANDWIDTH=''
MAPPER=''

#Set HA Option
HA_OPTION=" \
-Ddfs.nameservices=${SOURCE_NAMESPACE},${DEST_NAMESPACE} \
-Ddfs.ha.namenodes.${SOURCE_NAMESPACE}=nn1,nn2 \
-Dmapreduce.job.hdfs-servers.token-renewal.exclude=${SOURCE_NAMESPACE} \
-Ddfs.namenode.rpc-address.${SOURCE_NAMESPACE}.nn1=${SOURCE_NN1}:8020 \
-Ddfs.namenode.rpc-address.${SOURCE_NAMESPACE}.nn2=${SOURCE_NN2}:8020 \
-Ddfs.namenode.http-address.${SOURCE_NAMESPACE}.nn1=${SOURCE_NN1}:50070 \
-Ddfs.namenode.http-address.${SOURCE_NAMESPACE}.nn2=${SOURCE_NN2}:50070 \
-Ddfs.client.failover.proxy.provider.${SOURCE_NAMESPACE}=org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider \
-Ddfs.ha.namenodes.${DEST_NAMESPACE}=nn1,nn2 \
-Ddfs.namenode.rpc-address.${DEST_NAMESPACE}.nn1=${DEST_NN1}:8020 \
-Ddfs.namenode.rpc-address.${DEST_NAMESPACE}.nn2=${DEST_NN2}:8020 \
-Ddfs.namenode.http-address.${DEST_NAMESPACE}.nn1=${DEST_NN1}:50070 \
-Ddfs.namenode.http-address.${DEST_NAMESPACE}.nn2=${DEST_NN2}:50070 \
-Ddfs.client.failover.proxy.provider.${DEST_NAMESPACE}=org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider \
-Dipc.client.fallback-to-simple-auth-allowed=true"

#Set Kerberos setting
KINIT='echo "password" | kinit fdd'

#Set default setting
USER=`whoami`
BIN_DIR="/home1/$USER"
FILE="$BIN_DIR/server_list.csv"

#HQL
HQL_SCHEMA="show create table "
HQL_REPAIR="msck repair table "
HQL_CREATE_DATABASE="create database if not exists "
HQL_CHECK_PARTITION="show partitions "
HQL_ADD_PARTITION="add partitions "
#Hadoop command
CHECK_SIZE="hdfs dfs -D ipc.client.fallback-to-simple-auth-allowed=true -du -h "
PARTITION=""

#Run HQL
function hive_query() {
    $1 -e "$2"
}
function check_partition() {
    if [ (wc -l <<< "$1") -lt $PARTITION_LIMIT ];then
    	echo "big"
    else
    	echo "small"
    fi
}
function add_partition(){
    while read line
    do
            IFS='/' read -a ARRAY <<< $line
            PARTITION_NUMBER=$((${#ARRAY[@]} - 1))
            for NUMBER in $(eval echo {0..$PARTITION_NUMBER})
            do
                    PARTITION+="${ARRAY[$NUMBER]}"
                    if [ $PARTITION_NUMBER != $NUMBER ];then
                            PARTITION+=","
                    fi
            done
            DIRECTORY=$(sed "s/,/\//g" <<< "$PARTITION")
            hive_query "$DEST_HIVE" "$HQL_ADD_PARTITION "\(" $PARTITION "\)" $2$DIRECTORY"
            PARTITION=""
    done < <(printf '%s\n' "$1")
}
#Run distcp
function distcp() {
    hdfs dfs -mkdir -p $2
    hadoop distcp $HA_OPTION -bandwidth $BANDWIDTH -m $MAPPER -update -skipcrccheck $1 $2
}
#Run regex expression
function regex() {
    echo $(sed "s/$SOURCE_NAMESPACE/$DEST_NAMESPACE/g" <<< "$1")
}
#Check HDFS Size
function check_hdfs_size(){
    if [ $1 == $2 ];then
            echo "Size is same"
    else
            echo "Size is not same"
    fi
}
#Check Hive partition number
function check_partition_number(){
    if [ $(wc -l <<< "$1") == $(wc -l <<< "$2") ];then
            echo "The number of partitions is same"
    else
            echo "The number of partitions not same"
    fi
}
function download_list(){
        mysql -u $HIVE_META_DB_USER -P $HIVE_META_DB_PORT -p $HIVE_META_DB_PASSWORD -h $HIVE_META_DB_URL -e "use metastore; select LOCATION, NAME, TBL_NAME from SDS,TBLS,DBS where TBLS.SD_ID = SDS.SD_ID and TBLS.DB_ID = DBS.DB_ID;" >> $FILE
}

#################
# Main function #
#################
#renewal kerberos ticket
$KINIT
#download table list
download_list
while read line
do
    IFS=',' read -a ARRAY <<< $line
    SOURCE_HDFS=${ARRAY[0]}
    DB=${ARRAY[1]}
    TABLE=${ARRAY[2]}
    DEST_HDFS=$(regex $SOURCE_HDFS)
    #distcp
    distcp $SOURCE_HDFS $DEST_HDFS
    SOURCE_SIZE=$($CHECK_SIZE $SOURCE_HDFS | awk '{print $1}')
    DEST_SIZE=$($CHECK_SIZE $DEST_HDFS | awk '{print $1}')
    #check distcp is success
    check_hdfs_size $SOURCE_SIZE $DEST_SIZE

    #create hive table
    SOURCE_DDL=`hive_query "$SOURCE_HIVE" "$HQL_SCHEMA "$DB.$TABLE""`
    DEST_DDL=$(regex1 "$SOURCE_DDL")
    hive_query "$DEST_HIVE" "$HQL_CREATE_DATABASE $DB"
    hive_query "$DEST_HIVE" "$DEST_DDL"
    SOURCE_PARTITION=`hive_query "$SOURCE_HIVE" "$HQL_CHECK_PARTITION "$DB.$TABLE""`
    PARTITION_STATUS=`check_partition $SOURCE_PARTITION`
    if [ $PARTITION_STATUS > "big" ];then
    	add_partition "$DEST_HIVE" "$DEST_HDFS"
    else
    	hive_query "$DEST_HIVE" "$HQL_REPAIR $DB.$TABLE"
    fi
    DEST_PARTITION=`hive_query "$DEST_HIVE" "$HQL_CHECK_PARTITION "$DB.$TABLE""`
    #check hive table is correctly created
    check_partition_number $SOURCE_PARTITION $DEST_PARTITION

    echo $DB.$TABLE "is finished."

    #renewal kerberos ticket
    $KINIT
done < $FILE
