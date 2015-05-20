MASERT_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' rediscluster_redismaster_1)
SLAVE_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' rediscluster_redisslave_1)
SENTINEL_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' rediscluster_sentinel_1)

echo Redis master: $MASERT_IP
echo Redis Slave: $SLAVE_IP
echo ------------------------------------------------
echo Initial status of sentinel
echo ------------------------------------------------
docker-compose run --rm redismaster redis-cli -h $SENTINEL_IP -p 26379 info Sentinel

echo ------------------------------------------------
echo Stop redis master
docker pause rediscluster_redismaster_1
sleep 5
echo Current infomation of sentinel
docker-compose run --rm redismaster redis-cli -h $SENTINEL_IP -p 26379 info Sentinel

echo ------------------------------------------------
echo Restart Redis master
docker unpause rediscluster_redismaster_1
sleep 5
echo Current infomation of sentinel
docker-compose run --rm redismaster redis-cli -h $SENTINEL_IP -p 26379 info Sentinel
