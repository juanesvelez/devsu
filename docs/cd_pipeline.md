### CD Pipeline

El pipeline de entrega continua (CD) se encarga de desplegar automáticamente la aplicación en el entorno de Kubernetes utilizando Argo CD después de que el pipeline de CI haya sido completado exitosamente. A continuación se detallan los pasos involucrados en esta pipeline.

## Pasos de la Pipeline

### Checkout del código

Este paso utiliza la acción `actions/checkout` para obtener el código del repositorio.

```yaml
- name: Checkout code
  uses: actions/checkout@v2
```

### Configuración de kubectl

Este paso configura `kubectl` para que pueda interactuar con el clúster de Kubernetes.

```yaml
- name: Setup kubectl
  uses: azure/setup-kubectl@v1
  with:
    version: 'latest'
```
### Creación de Secret
Para manejar información sensible como la clave secreta de Django, utilizamos Kubernetes Secrets. En este caso, el secret fue creado directamente desde el pipeline de CD utilizando un comando kubectl apply.

```yaml
    - name: Create Kubernetes Secret
      run: |
          kubectl apply -f - <<EOF
          apiVersion: v1
          kind: Secret
          metadata:
            name: secret-demo-devops-python
            namespace: devsu-demo-devops-python-ns
          type: Opaque
          stringData:
            DJANGO_SECRET_KEY: ${{ secrets.DJANGO_SECRET_KEY }}
          EOF
      env:
          DJANGO_SECRET_KEY: ${{ secrets.DJANGO_SECRET_KEY }}
```
### Instalación del plugin de autenticación de Google Cloud para GKE

Este paso instala el plugin `gke-gcloud-auth-plugin` necesario para la autenticación con GKE.

```yaml
- name: Install gke-gcloud-auth-plugin
  run: |
    sudo apt-get update && \
    sudo apt-get install -y apt-transport-https ca-certificates gnupg curl && \
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    sudo apt-get update && \
    sudo apt-get install -y google-cloud-sdk google-cloud-sdk-gke-gcloud-auth-plugin kubectl
```
### Autenticación en GKE

Este paso autentica en Google Kubernetes Engine (GKE) usando las credenciales del servicio almacenadas en los secretos de GitHub.

```yaml
- name: Authenticate to GKE
  uses: google-github-actions/auth@v0
  with:
    credentials_json: ${{ secrets.GCP_SA_KEY }}
```

### Configuración de GKE

Este paso configura el acceso al clúster de GKE utilizando las credenciales autenticadas previamente.

```yaml
- name: Set up GKE
  run: |
    gcloud container clusters get-credentials gke-test --zone us-central1-a --project gcp-certification-pnal
```

### Instalar la CLI de Argo CD

Este paso descarga e instala la herramienta de línea de comandos de Argo CD.

```yaml
- name: Install Argo CD CLI
  run: |
    curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    chmod +x /usr/local/bin/argocd
```

### Construcción de Manifiestos con Kustomize

Este paso utiliza Kustomize para construir los manifiestos de Kubernetes y los guarda en un archivo `kustomized-manifest.yaml`.

```yaml
- name: Kustomize build
  run: |
    kustomize build k8s > k8s/kustomized-manifest.yaml
```

### Aplicación del Archivo de Aplicación de Argo CD

Este paso aplica el archivo de definición de la aplicación de Argo CD (`application.yaml`) en el clúster de Kubernetes.

```yaml
- name: Apply Argo CD Application
  run: kubectl apply -f k8s/application.yaml
```

### Sincronización con Argo CD

Este paso sincroniza la aplicación de Argo CD. Primero, crea un túnel SSH a través del port-forwarding hacia el servidor de Argo CD y luego ejecuta el comando de sincronización.

```yaml
- name: Sync with Argo CD
  continue-on-error: true
  run: |
    kubectl port-forward svc/argocd-server -n argocd 8080:443 & echo $! > /tmp/port-forward-pid
    sleep 5
    argocd login --insecure --grpc-web localhost:8080 --username admin --password $ARGOCD_ADMIN_PASSWORD
    argocd app sync demo-devops-python
    kill $(cat /tmp/port-forward-pid)
  env:
    ARGOCD_ADMIN_PASSWORD: ${{ secrets.ARGOCD_ADMIN_PASSWORD }}
```

