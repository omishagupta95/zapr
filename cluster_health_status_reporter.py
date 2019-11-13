import subprocess
import graphyte

METRIC_INTERVAL_SEC = 60
PREFIX = 'PROD.Polestar.cluster'
GRAPHITE_HOST = '172.16.15.226'

NUM_HOT = 11
NUM_COLD = 103

graphyte.init(GRAPHITE_HOST, prefix=PREFIX)
# graphyte.send('foo.bar', 42)

def is_cluster_healthy(cluster_type, cluster_num):

    CMD_PARAMERTERIZED = f'gcloud compute backend-services get-health {cluster_type}-backend-{cluster_num} --global --filter unhealthy'
    cmd = CMD_PARAMERTERIZED.split(' ')
    result = subprocess.run(cmd, stderr=subprocess.PIPE)
    print(result)
    
    if result.stderr is not None:
        output = result.stderr.decode('utf-8')
        if "Listed 0 items" in output:
            return True
        
    return False


def main():
    for i in range(1, NUM_HOT+1):
        metric = "hot."+str(i)
        if (is_cluster_healthy("hot", i)):
            graphyte.send(metric, 1)
        else:
            graphyte.send(metric, 0)
    
    for i in range(1, NUM_COLD+1):
        metric = "cold."+str(i)
        if (is_cluster_healthy("cold", i)):
            graphyte.send(metric, 1)
        else:
            graphyte.send(metric, 0)

main()
