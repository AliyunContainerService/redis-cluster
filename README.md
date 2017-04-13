# redis-cluster 
**Redis cluster with Docker Compose** 

Using Docker Compose to setup a redis cluster with sentinel.

This project is inspired by the project of [https://github.com/mdevilliers/docker-rediscluster][1]

## Prerequisite

Install [Docker][4] and [Docker Compose][3] in testing environment

If you are using Windows, please execute the following command before "git clone" to disable changing the line endings of script files into DOS format

```
git config --global core.autocrlf false
```

## Docker Compose template of Redis cluster

The template defines the topology of the Redis cluster

```
master:
  image: redis:3
slave:
  image: redis:3
  command: redis-server --slaveof redis-master 6379
  links:
    - master:redis-master
sentinel:
  build: sentinel
  environment:
    - SENTINEL_DOWN_AFTER=5000
    - SENTINEL_FAILOVER=5000    
  links:
    - master:redis-master
    - slave
```

There are following services in the cluster,

* master: Redis master
* slave:  Redis slave
* sentinel: Redis sentinel


The sentinels are configured with a "mymaster" instance with the following properties -

```
sentinel monitor mymaster redis-master 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel parallel-syncs mymaster 1
sentinel failover-timeout mymaster 5000
```

The details could be found in sentinel/sentinel.conf

The default values of the environment variables for Sentinel are as following

* SENTINEL_QUORUM: 2
* SENTINEL_DOWN_AFTER: 30000
* SENTINEL_FAILOVER: 180000



## Play with it

Build the sentinel Docker image

```
docker-compose build
```

Start the redis cluster

```
docker-compose up -d
```

Check the status of redis cluster

```
docker-compose ps
```

The result is 

```
         Name                        Command               State          Ports        
--------------------------------------------------------------------------------------
rediscluster_master_1     docker-entrypoint.sh redis ...   Up      6379/tcp            
rediscluster_sentinel_1   docker-entrypoint.sh redis ...   Up      26379/tcp, 6379/tcp 
rediscluster_slave_1      docker-entrypoint.sh redis ...   Up      6379/tcp     
```

Scale out the instance number of sentinel

```
docker-compose scale sentinel=3
```

Scale out the instance number of slaves

```
docker-compose scale slave=2
```

Check the status of redis cluster

```
docker-compose ps
```

The result is 

```
         Name                        Command               State          Ports        
--------------------------------------------------------------------------------------
rediscluster_master_1     docker-entrypoint.sh redis ...   Up      6379/tcp            
rediscluster_sentinel_1   docker-entrypoint.sh redis ...   Up      26379/tcp, 6379/tcp 
rediscluster_sentinel_2   docker-entrypoint.sh redis ...   Up      26379/tcp, 6379/tcp 
rediscluster_sentinel_3   docker-entrypoint.sh redis ...   Up      26379/tcp, 6379/tcp 
rediscluster_slave_1      docker-entrypoint.sh redis ...   Up      6379/tcp            
rediscluster_slave_2      docker-entrypoint.sh redis ...   Up      6379/tcp            
```

Execute the test scripts
```
./test.sh
```
to simulate stop and recover the Redis master. And you will see the master is switched to slave automatically. 

Or, you can do the test manually to pause/unpause redis server through

```
docker pause rediscluster_master_1
docker unpause rediscluster_master_1
```
And get the sentinel infomation with following commands

```
docker exec rediscluster_sentinel_1 redis-cli -p 26379 SENTINEL get-master-addr-by-name mymaster
```

## References

[https://github.com/mdevilliers/docker-rediscluster][1]

[https://registry.hub.docker.com/u/joshula/redis-sentinel/] [2]

[1]: https://github.com/mdevilliers/docker-rediscluster
[2]: https://registry.hub.docker.com/u/joshula/redis-sentinel/
[3]: https://docs.docker.com/compose/
[4]: https://www.docker.com

## License

Apache 2.0 license 

## Contributors

* Li Yi (<denverdino@gmail.com>)
* Ty Alexander (<ty.alexander@gmail.com>)

