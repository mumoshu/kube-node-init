# kube-node-init

[kube-node-init](https://github.com/mumoshu/kube-node-init) is a Kubernetes daemonset for node initial configuration including:

- Write files
- Restart systemd services
- Customize kernel parameters
- Add Kubernetes node labels
- Add Kubernetes node taints

## Getting Started

```console
$ helm repo add kube-node-init-charts https://mumoshu.github.io/kube-node-init/index.yaml
$ helm install --name kube-node-init kube-node-init-charts/kube-node-init
```

This installs the followings to your nodes:

- The init `script`
- Kernel parameters

You can customze every aspect of kube-node-init via `values.yaml`. Please read the [chart's README](https://github.com/mumoshu/kube-node-init/tree/master/charts/kube-node-init#configuration) for more configuration options.

### The init `script`

The default `script` does the following to improve your EKS nodes runnin Amazon Linux 2:

- Installs a tweaked `/etc/chrony.conf` and then restarts `chrony` systemd service.
   The conf includes `allow 127.0.0.1/32`, so that Prometheus `node-exporter`'s `ntp-collector` is able to connect the `chronyd` running on the node.

#### Customizing the init script

You can create your own `values.yaml` as follows to let kube-node-init use your own script:

`values.yaml`:

```yaml
script: |
  echo your alternative, bespoke node init script here!
```

Run `helm upgrade` to let kube-node-init rerun with your script:

```console
$ helm upgrade --name kube-node-init stable/kube-node-init --values values.yaml
```

### Kernel parameters

kube-node-init also tweaks several kernel parameters [listed under the `sysctl.params` key in the default `values.yaml`](https://github.com/mumoshu/kube-node-init/blob/c4a465522118bc7537d2b90e0bddca057a67b04b/charts/kube-node-init/values.yaml#L26-L50):

> ```
> # default: 128
> net.core.somaxconn: 65535
> # default: 256
> net.ipv4.tcp_max_syn_backlog: 65535
> # dfault: 1000
> net.core.netdev_max_backlog: 16384
> # default: 32768 60999
> net.ipv4.ip_local_port_range: 1024 65535
> # default: 0
> # enable(1) to optimize against short-lived sessions
> net.ipv4.tcp_tw_reuse: 1
> # default: 7200
> net.ipv4.tcp_keepalive_time: 200
> # default: 75
> net.ipv4.tcp_keepalive_intvl: 60
> # default: 9
> net.ipv4.tcp_keepalive_probes: 3
> # default: 6
> net.ipv4.tcp_syn_retries: 5
> ```

In case you want to disable this feature, set `--set sysctl.enabled=true` while installing the chart.
