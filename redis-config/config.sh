redisslave_ip=$(ping -q -c 1 redisslave | grep PING | sed -e "s/).*//" | sed -e "s/.*(//")
redismaster_ip=$(ping -q -c 1 redismaster | grep PING | sed -e "s/).*//" | sed -e "s/.*(//")

echo $redisslave_ip
echo $redismaster_ip

redis-cli -h $redisslave_ip -p 6379 slaveof $redismaster_ip 6379

