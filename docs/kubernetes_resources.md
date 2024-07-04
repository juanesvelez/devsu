# Documentación de Recursos de Kubernetes

En este documento se detallan los recursos de Kubernetes utilizados para desplegar y gestionar la aplicación. A continuación se describe cada recurso y su configuración específica.

## Recursos de Kubernetes

Los principales recursos de Kubernetes utilizados son:
- Application
- Deployment
- Service
- ConfigMap
- Secret
- HorizontalPodAutoscaler

Cada recurso se configura para garantizar que la aplicación sea altamente disponible, escalable y segura.

### Application.yaml
Este archivo es crucial para la gestión continua de la aplicación en Kubernetes usando Argo CD, asegurando que los cambios en el código fuente se reflejen automáticamente en el entorno de Kubernetes.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: demo-devops-python
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'https://github.com/juanesvelez/devsu'
    targetRevision: HEAD
    path: k8s
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: devsu-demo-devops-python-ns
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

