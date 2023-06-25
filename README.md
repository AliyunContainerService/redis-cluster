# redis-cluster 
**Redis cluster with Docker Compose** 

Using Docker Compose to setup a redis cluster with sentinel.

This project was inspired by the project of **@mdevilliers**

## Prerequisite
Install [Docker](https://docs.docker.com/engine/) and [Docker Compose](https://docs.docker.com/compose/) in testing environment.

If you are using Windows, please execute the following command before "git clone" to disable changing the line endings of script files into DOS format:
```sh
git config --global core.autocrlf false
```

## Docker Compose template of Redis cluster

The template defines the topology of the Redis cluster:
```yml
version: '3.9'

services:
master:
image: redis:latest
container_name: redis-master

slave:
image: redis:latest
container_name: redis-slave
command: redis-server --slaveof redis-master 6379
depends_on:
- master

sentinel:
build:
context: ./sentinel
dockerfile: Dockerfile
container_name: redis-sentinel
environment:
- SENTINEL_DOWN_AFTER=5000
- SENTINEL_FAILOVER=5000
depends_on:
- master
- slave
```

Notes:
1. Updated the version format to '3.9'.
2. Added the container_name parameter for each service to specify container names.
3. Replaced use of links with depends_on to define dependencies between services.
4. The Dockerfile path for the sentinel service is specified in the build parameter.
5. The path to the build context for sentinel services is specified in the context parameter.
6. The redis:latest image is used instead of a specific version to get the latest available version of Redis.
7. The declaration of links for the slave service has been removed, since it is already defined in the command section.

Please make sure the Dockerfile path for the sentinel service and the build context (./sentinel) are correctly specified and refer to your project file structure.

There are following services in the cluster:
* master: Redis master
* slave:  Redis slave
* sentinel: Redis sentinel


The sentinels are configured with a "mymaster" instance with the following properties:
```sh
sentinel monitor mymaster redis-master 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel parallel-syncs mymaster 1
sentinel failover-timeout mymaster 5000
```

The details could be found in `sentinel/sentinel.conf`.

The default values of the environment variables for Sentinel are as following:
* SENTINEL_QUORUM: 2
* SENTINEL_DOWN_AFTER: 30000
* SENTINEL_FAILOVER: 180000



## Play with it
Build the sentinel Docker image:
```sh
docker compose build .
```

Start the redis cluster:
```sh
docker compose up -d
```

Check the status of redis cluster:
```sh
docker compose ps
```

The result is:
```md
         Name                        Command               State          Ports        
--------------------------------------------------------------------------------------
rediscluster_master_1     docker-entrypoint.sh redis ...   Up      6379/tcp            
rediscluster_sentinel_1   docker-entrypoint.sh redis ...   Up      26379/tcp, 6379/tcp 
rediscluster_slave_1      docker-entrypoint.sh redis ...   Up      6379/tcp     
```

Scale out the instance number of sentinel:
```sh
docker compose scale sentinel=3
```

Scale out the instance number of slaves:
```sh
docker compose scale slave=2
```

Check the status of redis cluster:
```sh
docker compose ps
```

The result is:
```md
         Name                        Command               State          Ports        
--------------------------------------------------------------------------------------
rediscluster_master_1     docker-entrypoint.sh redis ...   Up      6379/tcp            
rediscluster_sentinel_1   docker-entrypoint.sh redis ...   Up      26379/tcp, 6379/tcp 
rediscluster_sentinel_2   docker-entrypoint.sh redis ...   Up      26379/tcp, 6379/tcp 
rediscluster_sentinel_3   docker-entrypoint.sh redis ...   Up      26379/tcp, 6379/tcp 
rediscluster_slave_1      docker-entrypoint.sh redis ...   Up      6379/tcp            
rediscluster_slave_2      docker-entrypoint.sh redis ...   Up      6379/tcp            
```

Execute the test scripts:
```sh
./test.sh
```
to simulate stop and recover the Redis master. And you will see the master is switched to slave automatically. 

Or, you can do the test manually to pause/unpause redis server through:
```sh
docker pause rediscluster_master_1
docker unpause rediscluster_master_1
```
And get the sentinel infomation with following commands:
```sh
docker exec rediscluster_sentinel_1 redis-cli -p 26379 SENTINEL get-master-addr-by-name mymaster
```

## References
1: https://github.com/mdevilliers/docker-rediscluster<br>
2: https://registry.hub.docker.com/r/bitnami/redis-sentinel<br>
3: https://docs.docker.com/compose/<br>
4: https://www.docker.com

## License
Apache 2.0 license 

## Contributors
* Li Yi (<denverdino@gmail.com>)
* Ty Alexander (<ty.alexander@gmail.com>)
* Dmitrii Zagorodnev (<dmitrii.zagorodnev@outlook.com>)

