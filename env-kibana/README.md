[![Docker Repository on Quay](https://quay.io/repository/7insyde/kibana/status "Docker Repository on Quay")](https://quay.io/repository/7insyde/kibana)


Example to run kibana:
```
docker run -d -e HOST=<elastic_host> -e PORT=<elastic_port> --name kibana -p 5601:5601 kibana
```

after start you can access the kibana dashboard on `<elastic_host>:<elastic_port>`


Optional env parameters:

```
NODE_OPTIONS
```
