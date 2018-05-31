MASTER_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' redis-cluster_master_1)
SLAVE_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' redis-cluster_slave_1)
SENTINEL_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' redis-cluster_sentinel_1)

echo Redis master: $MASTER_IP
echo Redis Slave: $SLAVE_IP
echo ------------------------------------------------
echo Initial status of sentinel
echo ------------------------------------------------
docker exec redis-cluster_sentinel_1 redis-cli -p 26379 info Sentinel
echo Current master is
docker exec redis-cluster_sentinel_1 redis-cli -p 26379 SENTINEL get-master-addr-by-name mymaster
echo ------------------------------------------------

echo Stop redis master
docker pause redis-cluster_master_1
echo Wait for 10 seconds
sleep 10
echo Current infomation of sentinel
docker exec redis-cluster_sentinel_1 redis-cli -p 26379 info Sentinel
echo Current master is
docker exec redis-cluster_sentinel_1 redis-cli -p 26379 SENTINEL get-master-addr-by-name mymaster


echo ------------------------------------------------
echo Restart Redis master
docker unpause redis-cluster_master_1
sleep 5
echo Current infomation of sentinel
docker exec redis-cluster_sentinel_1 redis-cli -p 26379 info Sentinel
echo Current master is
docker exec redis-cluster_sentinel_1 redis-cli -p 26379 SENTINEL get-master-addr-by-name mymaster
