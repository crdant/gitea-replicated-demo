{{- define "troubleshoot.collectors.shared" -}}
- clusterInfo: {}
- clusterResources: {}
- registryImages:
    namespace: {{ include "common.names.namespace" . | quote }}
    images:
      - ghcr.io/replicatedhq/replicated:v0.0.1-alpha.10
      - docker.io/bitnami/gitea:1.19.3-debian-11-r1
      - docker.io/bitnami/postgresql:15.3.0-debian-11-r0
{{- end -}}

{{- define "troubleshoot.analyzers.shared" -}}
- clusterVersion:
    checkName: Is this cluster running a supported Kubernetes verison
    outcomes:
      - fail:
          when: "< 1.19.0"
          message: This Gitea Helm chart is only supported on Kubernetes 1.19 or later
          uri: https://www.kubernetes.io
      - warn:
          when: "< 1.24.0"
          message: |
            You can run Gitea on your current cluster version, but your cluster is no longer supported 
            by the Kubernetes community. If you have extended support available from your Kubernetes
            vendor you can ignore this warning.
          uri: https://kubernetes.io
      - pass:
          message: |
            Your current Kubernetes version is able to run Gitea using this Helm chart and is a
            version currently supported by the Kubernets community.
- containerRuntime:
    checkName: Does this Kubernetes cluster use a supported container runtime
    outcomes:
      - pass:
          when: "== containerd"
          message: You are running the ContainerD runtime that is supported by this chart.
      - fail:
          message: |
            The Helm chart requires the ContainerD container runtime, which is not the runtime
            configured in your clusster.
- distribution:
    checkName: Are we installing into a supported Kubernetes distribution
    outcomes:
      - warn:
          when: "== docker-desktop"
          message: | 
            You are able to run Gitea in Docker Desktop, but we recommend using a different
            Kubernetes distribution for your production installation.
      - warn:
          when: "== microk8s"
          message: | 
            You are able to run Gitea in MicroK8s, but we recommend using a different
            Kubernetes distribution for your production installation.
      - warn:
          when: "== minikube"
          message: | 
            You are able to run Gitea in Minikube, but we recommend using a different
            Kubernetes distribution for your production installation.
      - pass:
          when: "== eks"
          message: Amazon EKS is a suppored Kubernetes distribution to run Gitea in production
      - pass:
          when: "== gke"
          message: Google Kubernetes Engine is a suppored Kubernetes distribution to run Gitea in production
      - pass:
          when: "== aks"
          message: Azure Kubernetes Services is a supported Kubernetes distributiion to run Gitea in production
      - pass:
          when: "== tanzu"
          message: VMware Tanzu is a supported Kubernetes distribution to run Gitea in production
      - pass:
          when: "== kurl"
          message: The Replicated embedded Kubernetes distribution is a supported to run Gitea in production
      - pass:
          when: "== digitalocean"
          message: DigitalOcean is a supported Kubernetes distribution to run Gitea in production
      - pass:
          message: We are unable to detect the Kubernetes distribution you are running but you should give it a try
- nodeResources:
    checkName: Are sufficient CPU resources available in the cluster
    outcomes:
      - fail:
          when: "sum(cpuAllocatable) < 250m"
          message: Your cluster currently has too few CPU resources available to install Gitea
      - pass:
          message: Your cluster has sufficient CPU resources available to install Gitea
- nodeResources:
    checkName: Is sufficient memory available in the cluster
    outcomes:
      - fail:
          when: "min(memoryAllocatable) < 256Mi" 
          message: Your cluster currently has too little memory available to install Gitea
      - pass:
          message: Your cluster has sufficient memory available to install Gitea
- registryImages:
    name: Registry Images
    collectorName: images
    outcomes:
      - fail:
          when: "missing > 0"
          message: |
            Your cluster isn't able to access any of the Gitea images from the installed namespace.
      - warn:
          when: "errors > 0"
          message: |
            Your cluster is unable to access one or more of the Gitea images from the installed namespace.
      - pass:
          message: Your cluster is able to access all required images into the required namespace
{{- end -}}
