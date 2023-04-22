resource "aws_cloudwatch_log_group" "eks_logs" {
  count = length(var.insight_log_groups)
  name = "/aws/containerinsights/${var.eks_cluster_name}/${element(var.insight_log_groups,count.index)}"
  tags = merge(
    var.tags,
    var.default_tags,
    {
      "Name"        = format("%s", var.eks_cluster_name)
      "Environment" = format("%s", var.environment)
    },
  )
  retention_in_days = local.flow_logs_retention_days
}

resource "kubernetes_namespace" "amazon_cloudwatch" {
  metadata {
    name   = "amazon-cloudwatch"
    labels = {
      mylabel = "amazon-cloudwatch"
    }
  }
}

resource "kubernetes_service_account" "cloudwatch_agent" {
  metadata {
    name = "cloudwatch-agent"
    namespace = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
  }
}

resource "kubernetes_service_account" "fluentd" {
  metadata {
    name = "fluentd"
    namespace = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
  }
}

resource "kubernetes_cluster_role" "cloudwatch_agent_role" {
  metadata {
    name = "cloudwatch-agent-role"
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "nodes", "endpoints"]
    verbs      = ["list", "watch"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["replicasets"]
    verbs      = ["list", "watch"]
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes/proxy"]
    verbs      = ["get"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes/stats", "configmaps", "events"]
    verbs      = ["create"]
  }
  rule {
    api_groups      = [""]
    resources       = ["configmaps"]
    resource_names  = ["cwagent-clusterleader"]
    verbs           = ["get","update"]
  }
}

resource "kubernetes_cluster_role" "fluentd-role" {
  metadata {
    name = "fluentd-role"
  }
  rule {
    api_groups      = [""]
    resources       = ["namespaces", "pods", "pods/logs"]
    verbs           = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "cloudwatch_agent_role_binding" {
  metadata {
    name = "cloudwatch-agent-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.cloudwatch_agent_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cloudwatch_agent.metadata[0].name
    namespace = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
  }
  subject {
    kind      = "Group"
    name      = "system:masters"
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = [
    kubernetes_namespace.amazon_cloudwatch,
    kubernetes_service_account.cloudwatch_agent,
    kubernetes_cluster_role.cloudwatch_agent_role
  ]
}

resource "kubernetes_cluster_role_binding" "fluentd-role-binding" {
  metadata {
    name = "fluentd-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.fluentd-role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.fluentd.metadata[0].name
    namespace = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
  }

  depends_on = [
    kubernetes_namespace.amazon_cloudwatch,
    kubernetes_service_account.fluentd,
    kubernetes_cluster_role.fluentd-role
  ]
}

resource "kubernetes_config_map" "cwagentconfig" {
  metadata {
    name      = "cwagentconfig"
    namespace = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
  }

  data = {
    "cwagentconfig.json" = <<JSON
      {
        "logs": {
          "metrics_collected": {
            "kubernetes": {
              "cluster_name": "${var.eks_cluster_name}",
              "metrics_collection_interval": 60
            }
          },
          "force_flush_interval": 5
        }
      }
    JSON
  }

  depends_on = [
    kubernetes_namespace.amazon_cloudwatch
  ]
}

resource "kubernetes_config_map" "cluster-info" {
  metadata {
    name = "cluster-info"
    namespace = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
  }
  data = {
    "cluster.name" = var.eks_cluster_name
    "logs.region"  = data.aws_region.current.name
  }

}
resource "kubernetes_config_map" "fluentd_config" {
  metadata {
    name      = "fluentd-config"
    namespace = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
    labels = {
      "k8s-app" = "fluentd-cloudwatch"
    }
  }

  data = {
    "fluent.conf" = <<CONFIG
@include containers.conf
@include systemd.conf
@include host.conf

<match fluent.**>
  @type null
</match>
CONFIG
    "containers.conf" = <<CONTAINTERS_CONF
<source>
  @type tail
  @id in_tail_container_logs
  @label @containers
  path /var/log/containers/*.log
  exclude_path ["/var/log/containers/cloudwatch-agent*", "/var/log/containers/fluentd*"]
  pos_file /var/log/fluentd-containers.log.pos
  tag *
  read_from_head true
  <parse>
    @type json
    time_format %Y-%m-%dT%H:%M:%S.%NZ
  </parse>
</source>

<source>
  @type tail
  @id in_tail_cwagent_logs
  @label @cwagentlogs
  path /var/log/containers/cloudwatch-agent*
  pos_file /var/log/cloudwatch-agent.log.pos
  tag *
  read_from_head true
  <parse>
    @type json
    time_format %Y-%m-%dT%H:%M:%S.%NZ
  </parse>
</source>

<source>
  @type tail
  @id in_tail_fluentd_logs
  @label @fluentdlogs
  path /var/log/containers/fluentd*
  pos_file /var/log/fluentd.log.pos
  tag *
  read_from_head true
  <parse>
    @type json
    time_format %Y-%m-%dT%H:%M:%S.%NZ
  </parse>
</source>

<label @fluentdlogs>
  <filter **>
    @type kubernetes_metadata
    @id filter_kube_metadata_fluentd
  </filter>

  <filter **>
    @type record_transformer
    @id filter_fluentd_stream_transformer
    <record>
      stream_name $${tag_parts[3]}
    </record>
  </filter>

  <match **>
    @type relabel
    @label @NORMAL
  </match>
</label>

<label @containers>
  <filter **>
    @type kubernetes_metadata
    @id filter_kube_metadata
  </filter>

  <filter **>
    @type record_transformer
    @id filter_containers_stream_transformer
    <record>
      stream_name $${tag_parts[3]}
    </record>
  </filter>

  <filter **>
    @type concat
    key log
    multiline_start_regexp /^\S/
    separator ""
    flush_interval 5
    timeout_label @NORMAL
  </filter>

  <match **>
    @type relabel
    @label @NORMAL
  </match>
</label>

<label @cwagentlogs>
  <filter **>
    @type kubernetes_metadata
    @id filter_kube_metadata_cwagent
  </filter>

  <filter **>
    @type record_transformer
    @id filter_cwagent_stream_transformer
    <record>
      stream_name $${tag_parts[3]}
    </record>
  </filter>

  <filter **>
    @type concat
    key log
    multiline_start_regexp /^\d{4}[-/]\d{1,2}[-/]\d{1,2}/
    separator ""
    flush_interval 5
    timeout_label @NORMAL
  </filter>

  <match **>
    @type relabel
    @label @NORMAL
  </match>
</label>

<label @NORMAL>
  <match **>
    @type cloudwatch_logs
    @id out_cloudwatch_logs_containers
    region "#{ENV.fetch('REGION')}"
    log_group_name "/aws/containerinsights/#{ENV.fetch('CLUSTER_NAME')}/application"
    log_stream_name_key stream_name
    remove_log_stream_name_key true
    auto_create_stream true
    <buffer>
      flush_interval 5
      chunk_limit_size 2m
      queued_chunks_limit_size 32
      retry_forever true
    </buffer>
  </match>
</label>
CONTAINTERS_CONF

    "systemd.conf" = <<SYSTEMD_CONF
<source>
  @type systemd
  @id in_systemd_kubelet
  @label @systemd
  filters [{ "_SYSTEMD_UNIT": "kubelet.service" }]
  <entry>
    field_map {"MESSAGE": "message", "_HOSTNAME": "hostname", "_SYSTEMD_UNIT": "systemd_unit"}
    field_map_strict true
  </entry>
  path /var/log/journal
  <storage>
    @type local
    persistent true
    path /var/log/fluentd-journald-kubelet-pos.json
  </storage>
  read_from_head true
  tag kubelet.service
</source>

<source>
  @type systemd
  @id in_systemd_kubeproxy
  @label @systemd
  filters [{ "_SYSTEMD_UNIT": "kubeproxy.service" }]
  <entry>
    field_map {"MESSAGE": "message", "_HOSTNAME": "hostname", "_SYSTEMD_UNIT": "systemd_unit"}
    field_map_strict true
  </entry>
  path /var/log/journal
  <storage>
    @type local
    persistent true
    path /var/log/fluentd-journald-kubeproxy-pos.json
  </storage>
  read_from_head true
  tag kubeproxy.service
</source>

<source>
  @type systemd
  @id in_systemd_docker
  @label @systemd
  filters [{ "_SYSTEMD_UNIT": "docker.service" }]
  <entry>
    field_map {"MESSAGE": "message", "_HOSTNAME": "hostname", "_SYSTEMD_UNIT": "systemd_unit"}
    field_map_strict true
  </entry>
  path /var/log/journal
  <storage>
    @type local
    persistent true
    path /var/log/fluentd-journald-docker-pos.json
  </storage>
  read_from_head true
  tag docker.service
</source>

<label @systemd>
  <filter **>
    @type kubernetes_metadata
    @id filter_kube_metadata_systemd
  </filter>

  <filter **>
    @type record_transformer
    @id filter_systemd_stream_transformer
    <record>
      stream_name $${tag}-$${record["hostname"]}
    </record>
  </filter>

  <match **>
    @type cloudwatch_logs
    @id out_cloudwatch_logs_systemd
    region "#{ENV.fetch('REGION')}"
    log_group_name "/aws/containerinsights/#{ENV.fetch('CLUSTER_NAME')}/dataplane"
    log_stream_name_key stream_name
    auto_create_stream true
    remove_log_stream_name_key true
    <buffer>
      flush_interval 5
      chunk_limit_size 2m
      queued_chunks_limit_size 32
      retry_forever true
    </buffer>
  </match>
</label>
SYSTEMD_CONF

    "host.conf" = <<HOST_CONF
<source>
  @type tail
  @id in_tail_dmesg
  @label @hostlogs
  path /var/log/dmesg
  pos_file /var/log/dmesg.log.pos
  tag host.dmesg
  read_from_head true
  <parse>
    @type syslog
  </parse>
</source>

<source>
  @type tail
  @id in_tail_secure
  @label @hostlogs
  path /var/log/secure
  pos_file /var/log/secure.log.pos
  tag host.secure
  read_from_head true
  <parse>
    @type syslog
  </parse>
</source>

<source>
  @type tail
  @id in_tail_messages
  @label @hostlogs
  path /var/log/messages
  pos_file /var/log/messages.log.pos
  tag host.messages
  read_from_head true
  <parse>
    @type syslog
  </parse>
</source>

<label @hostlogs>
  <filter **>
    @type kubernetes_metadata
    @id filter_kube_metadata_host
  </filter>

  <filter **>
    @type record_transformer
    @id filter_containers_stream_transformer_host
    <record>
      stream_name $${tag}-$${record["host"]}
    </record>
  </filter>

  <match host.**>
    @type cloudwatch_logs
    @id out_cloudwatch_logs_host_logs
    region "#{ENV.fetch('REGION')}"
    log_group_name "/aws/containerinsights/#{ENV.fetch('CLUSTER_NAME')}/host"
    log_stream_name_key stream_name
    remove_log_stream_name_key true
    auto_create_stream true
    <buffer>
      flush_interval 5
      chunk_limit_size 2m
      queued_chunks_limit_size 32
      retry_forever true
    </buffer>
  </match>
</label>
HOST_CONF
  }

  depends_on = [
    kubernetes_namespace.amazon_cloudwatch
  ]
}

resource "kubernetes_daemonset" "cloudwatch_agent" {
  metadata {
    name      = "cloudwatch-agent"
    namespace = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
  }

  spec {
    selector {
      match_labels = {
        name = "cloudwatch-agent"
      }
    }

    template {
      metadata {
        labels = {
          name = "cloudwatch-agent"
        }
      }

      spec {
        container {
          image = "amazon/cloudwatch-agent:1.247345.36b249270"
          name  = "cloudwatch-agent"

          resources {
            limits = {
              cpu    = "200m"
              memory = "200Mi"
            }
            requests = {
              cpu    = "200m"
              memory = "200Mi"
            }
          }

          env {
            name = "HOST_IP"
            value_from {
              field_ref {
                field_path = "status.hostIP"
              }
            }
          }
          env {
            name = "HOST_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }
          env {
            name = "K8S_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          env {
            name  = "CI_VERSION"
            value = "k8s/1.2.2"
          }

          volume_mount {
            mount_path = "/etc/cwagentconfig"
            name       = "cwagentconfig"
          }
          volume_mount {
            mount_path = "/rootfs"
            name       = "rootfs"
            read_only  = true
          }
          volume_mount {
            mount_path = "/var/run/docker.sock"
            name       = "dockersock"
            read_only  = true
          }
          volume_mount {
            mount_path = "/var/lib/docker"
            name       = "varlibdocker"
            read_only  = true
          }
          volume_mount {
            mount_path = "/sys"
            name       = "sys"
            read_only  = true
          }
          volume_mount {
            mount_path = "/dev/disk"
            name       = "devdisk"
            read_only  = true
          }
        }

        volume {
          name = "cwagentconfig"
          config_map {
            name = "cwagentconfig"
          }
        }
        volume {
          name = "rootfs"
          host_path {
            path = "/"
          }
        }
        volume {
          name = "dockersock"
          host_path {
            path = "/var/run/docker.sock"
          }
        }
        volume {
          name = "varlibdocker"
          host_path {
            path = "/var/lib/docker"
          }
        }
        volume {
          name = "sys"
          host_path {
            path = "/sys"
          }
        }
        volume {
          name = "devdisk"
          host_path {
            path = "/dev/disk/"
          }
        }

        termination_grace_period_seconds = 60
        service_account_name             = kubernetes_service_account.cloudwatch_agent.metadata[0].name
        automount_service_account_token  = true
      }
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.eks_logs,
    kubernetes_namespace.amazon_cloudwatch,
    kubernetes_config_map.cwagentconfig,
    kubernetes_service_account.cloudwatch_agent,
    kubernetes_cluster_role.cloudwatch_agent_role,
    kubernetes_cluster_role_binding.cloudwatch_agent_role_binding
  ]
}

resource "kubernetes_daemonset" "fluentd_cloudwatch" {

  metadata {
    name = "fluentd-cloudwatch"
    namespace = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
  }
  spec {
    selector {
      match_labels = {
        k8s-app = "fluentd-cloudwatch"
      }
    }
    template {
      metadata {
        labels = {
          k8s-app = "fluentd-cloudwatch"
        }
        annotations = {
          configHash = "8915de4cf9c3551a8dc74c0137a3e83569d28c71044b0359c2578d2e0461825"
        }
      }
      spec {
        init_container {
          name    = "copy-fluentd-config"
          image   = "busybox"
          command = ["sh", "-c", "cp /config-volume/..data/* /fluentd/etc"]
          volume_mount {
            mount_path = "/config-volume"
            name       = "config-volume"
          }
          volume_mount {
            mount_path = "/fluentd/etc"
            name       = "fluentdconf"
          }
        }
        init_container {
          name    = "update-log-driver"
          image   = "busybox"
          command = ["sh", "-c", ""]
        }
        container {
          name = "fluentd-cloudwatch"
          image = "fluent/fluentd-kubernetes-daemonset:v1.7.3-debian-cloudwatch-1.0"

          resources {
            limits = {
              memory = "400Mi"
            }
            requests = {
              memory = "200Mi"
              cpu    = "100m"
            }
          }

          env {
            name = "REGION"
            value_from {
              config_map_key_ref {
                name = "cluster-info"
                key  = "logs.region"
              }
            }
          }
          env {
            name = "CLUSTER_NAME"
            value_from {
              config_map_key_ref {
                name = "cluster-info"
                key  = "cluster.name"
              }
            }
          }
          env {
            name  = "CI_VERSION"
            value = "k8s/1.2.2"
          }

          volume_mount {
            mount_path = "/config-volume"
            name       = "config-volume"
          }
          volume_mount {
            mount_path = "/fluentd/etc"
            name       = "fluentdconf"
          }
          volume_mount {
            mount_path = "/var/log"
            name       = "varlog"
          }
          volume_mount {
            mount_path = "/var/lib/docker/containers"
            name       = "varlibdockercontainers"
            read_only  = true
          }
          volume_mount {
            mount_path = "/run/log/journal"
            name       = "runlogjournal"
            read_only  = true
          }
          volume_mount {
            mount_path = "/var/log/dmesg"
            name       = "dmesg"
            read_only  = true
          }
        }

        volume {
          name = "config-volume"
          config_map {
            name = "fluentd-config"
          }
        }
        volume {
          name = "fluentdconf"
          empty_dir {}
        }
        volume {
          name = "varlog"
          host_path {
            path = "/var/log"
          }
        }
        volume {
          name = "varlibdockercontainers"
          host_path {
            path = "/var/lib/docker/containers"
          }
        }
        volume {
          name = "runlogjournal"
          host_path {
            path = "/run/log/journal"
          }
        }
        volume {
          name = "dmesg"
          host_path {
            path = "/var/log/dmesg"
          }
        }

        termination_grace_period_seconds = 30
        service_account_name             = kubernetes_service_account.fluentd.metadata[0].name
        automount_service_account_token  = true
      }
    }
  }

    depends_on = [
    aws_cloudwatch_log_group.eks_logs,
    kubernetes_namespace.amazon_cloudwatch,
    kubernetes_config_map.fluentd_config,
    kubernetes_service_account.fluentd,
    kubernetes_cluster_role.fluentd-role,
    kubernetes_cluster_role_binding.fluentd-role-binding
  ]
}
