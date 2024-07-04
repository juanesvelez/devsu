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
Este archivo es crucial para la gestión continua de la aplicación en Kubernetes usando Argo CD, asegurando que los cambios en el código fuente se reflejen automáticamente en el entorno de Kubernetes. Define una aplicación de Argo CD que se encargará de sincronizar y gestionar los recursos de Kubernetes especificados en el repositorio de GitHub. Contiene la información sobre la fuente del repositorio, la ruta de los archivos de configuración de Kubernetes, el destino donde se desplegará la aplicación y las políticas de sincronización automatizadas para mantener la consistencia del entorno de despliegue.

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

### Deployment.yaml
El archivo deployment.yaml define un Deployment de Kubernetes que especifica cómo debe ser desplegada la aplicación demo-devops-python.

	•	Replicas: Se define que deben existir 2 réplicas de la aplicación para asegurar alta disponibilidad.
	•	Selectors y Labels: Utiliza etiquetas para seleccionar los pods que forman parte del deployment.
	•	Containers:
	•	Image: La imagen Docker especificada es ghcr.io/juanesvelez/devsu/demo-devops-python.
	•	Ports: El contenedor expone el puerto 8000.
	•	Environment Variables: Las variables de entorno DATABASE_NAME y DJANGO_SECRET_KEY se configuran usando un ConfigMap y un Secret, respectivamente.
	•	VolumeMounts: Se monta un volumen en /app/data para persistir datos.
	•	Probes: Configura livenessProbe y readinessProbe para asegurar que el contenedor está vivo y listo para recibir tráfico.
	•	Resources: Se definen las solicitudes y límites de recursos de CPU y memoria.
	•	Volumes: Se utiliza un hostPath para montar un directorio del host en el contenedor, asegurando que los datos persisten entre reinicios de contenedores.

Este archivo asegura que la aplicación se despliegue de manera consistente, con alta disponibilidad, y que esté configurada correctamente con las variables de entorno y almacenamiento persistente necesario.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-devops-python
  namespace: devsu-demo-devops-python-ns
spec:
  replicas: 2
  selector:
    matchLabels:
      app: demo-devops-python
  template:
    metadata:
      labels:
        app: demo-devops-python
    spec:
      imagePullSecrets:
        - name: ghcr-secret
      containers:
        - name: demo-devops-python
          image: ghcr.io/juanesvelez/devsu/demo-devops-python:60d902f474eb4f419e4bbc128b8187459ee3e30f
          ports:
            - containerPort: 8000
          env:
            - name: DATABASE_NAME
              valueFrom:
                configMapKeyRef:
                  name: configmap-demo-devops-python
                  key: DATABASE_NAME
            - name: DJANGO_SECRET_KEY
              valueFrom:
                secretKeyRef:
                  name: secret-demo-devops-python
                  key: DJANGO_SECRET_KEY
          volumeMounts:
            - name: demo-devops-python-storage
              mountPath: /app/data
          livenessProbe:
            httpGet:
              path: /api/health
              port: 8000
            initialDelaySeconds: 60
            periodSeconds: 60
          readinessProbe:
            httpGet:
              path: /api/health
              port: 8000
            initialDelaySeconds: 60
            periodSeconds: 60
          resources:
            requests:
              memory: "64Mi"
              cpu: "100m"
            limits:
              memory: "128Mi"
              cpu: "120m"
      volumes:
        - name: demo-devops-python-storage
          hostPath:
            path: /tmp/demo-devops-python
            type: DirectoryOrCreate
```

### Gateway.yaml
El archivo gateway.yaml define un recurso Gateway de Istio que controla la entrada de tráfico HTTP hacia el clúster de Kubernetes.

	•	Namespace: Se despliega en el namespace istio-system.
	•	Selector: Utiliza el selector istio: ingressgateway para especificar que este gateway debe ser gestionado por el controlador de ingreso de Istio.
	•	Servers:
	•	Port: Define un servidor que escucha en el puerto 80 con el protocolo HTTP.
	•	Hosts: Permite que el gateway acepte tráfico de cualquier host ("*") para el puerto definido.

Este gateway actúa como punto de entrada para todo el tráfico HTTP que llega al clúster, facilitando la configuración de reglas de enrutamiento y balanceo de carga mediante Istio.

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: general-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
```

### Hpa.yaml
El archivo hpa.yaml define un recurso HorizontalPodAutoscaler (HPA) para escalar automáticamente la cantidad de réplicas del despliegue demo-devops-python basado en la utilización de CPU.

	•	Namespace: Se despliega en el namespace devsu-demo-devops-python-ns.
	•	scaleTargetRef: Especifica el recurso objetivo que será escalado, en este caso, un Deployment llamado demo-devops-python de la API apps/v1.
	•	minReplicas: El número mínimo de réplicas que el HPA mantendrá (1).
	•	maxReplicas: El número máximo de réplicas que el HPA permitirá (10).
	•	targetCPUUtilizationPercentage: El objetivo de utilización de CPU para escalar el despliegue (80%).

Este recurso garantiza que el despliegue demo-devops-python pueda escalar dinámicamente según la carga de trabajo, mejorando la disponibilidad y el rendimiento.

```yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: hpa-demo-devops-python
  namespace: devsu-demo-devops-python-ns
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: demo-devops-python
  minReplicas: 1
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
```

### Kustomization.yaml

### kustomization.yaml

El archivo `kustomization.yaml` es utilizado por Kustomize para gestionar configuraciones de Kubernetes de manera declarativa. Define los recursos a incluir, así como las configuraciones específicas como ConfigMaps.

- **resources:** Lista de recursos de Kubernetes que se gestionarán:
  - `deployment.yaml`
  - `service.yaml`
  - `hpa.yaml`
  - `virtualservice-demo-devops-python.yaml`
  
- **configMapGenerator:** Genera un ConfigMap llamado `configmap-demo-devops-python` con la siguiente configuración:
  - `DATABASE_NAME=db.sqlite3`

- **generatorOptions:** Opciones de generación, como `disableNameSuffixHash`, que desactiva la generación de hash en los nombres de los ConfigMaps y Secrets.

Este archivo permite gestionar y aplicar configuraciones de Kubernetes de manera coherente y modular, facilitando la reutilización y la organización de los recursos.

```yaml
resources:
  - deployment.yaml
  - service.yaml
  - hpa.yaml
  - virtualservice-demo-devops-python.yaml

configMapGenerator:
  - name: configmap-demo-devops-python
    literals:
      - DATABASE_NAME=db.sqlite3

generatorOptions:
  disableNameSuffixHash: true
```

### Service.yaml
### service.yaml

Este archivo define un Servicio de Kubernetes para la aplicación `demo-devops-python`, exponiéndola en el puerto 80 y redirigiendo el tráfico al puerto 8000 del contenedor.

**Componentes clave:**

- **metadata.name**: `demo-devops-python` - Nombre del servicio.
- **spec.selector**: Selecciona los Pods con la etiqueta `app=demo-devops-python`.
- **spec.ports**:
  - **port**: `80` - Puerto expuesto por el servicio.
  - **targetPort**: `8000` - Puerto al que se redirige el tráfico dentro del contenedor.

Permitir el acceso a la aplicación `demo-devops-python` dentro del clúster Kubernetes y facilitar la comunicación entre diferentes componentes del clúster.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo-devops-python
spec:
  selector:
    app: demo-devops-python
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8000
```

### virtualservice-demo-devops-python.yaml
Este archivo define un VirtualService de Istio para enrutar el tráfico HTTP a la aplicación `demo-devops-python`.

**Componentes clave:**

- **metadata.name**: `demo-devops-python-virtualservice` - Nombre del VirtualService.
- **metadata.namespace**: `devsu-demo-devops-python-ns` - Namespace donde se despliega el VirtualService.
- **spec.hosts**: `["*"]` - Define los hosts que coinciden con esta regla.
- **spec.gateways**: `["istio-system/general-gateway"]` - Define los gateways a través de los cuales se enruta el tráfico.
- **spec.http**:
  - **match.uri.prefix**: `"/api"` - Ruta de coincidencia para la API.
  - **match.uri.prefix**: `"/admin"` - Ruta de coincidencia para la interfaz de administración.
  - **route.destination.host**: `demo-devops-python.devsu-demo-devops-python-ns.svc.cluster.local` - Destino del tráfico.
  - **route.destination.port.number**: `80` - Puerto al que se redirige el tráfico dentro del contenedor.

Enrutar el tráfico HTTP entrante a los endpoints `/api` y `/admin` de la aplicación `demo-devops-python` a través del gateway `general-gateway` de Istio.

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: demo-devops-python-virtualservice
  namespace: devsu-demo-devops-python-ns
spec:
  hosts:
  - "*"
  gateways:
  - istio-system/general-gateway 
  http:
  - match:
    - uri:
        prefix: /api
    route:
    - destination:
        host: demo-devops-python.devsu-demo-devops-python-ns.svc.cluster.local
        port:
          number: 80
  - match:
    - uri:
        prefix: /admin
    route:
    - destination:
        host: demo-devops-python.devsu-demo-devops-python-ns.svc.cluster.local
        port:
          number: 80
```
