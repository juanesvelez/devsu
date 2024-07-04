### Gestión de Secrets en GitHub Actions

En la implementación de los pipelines CI y CD, se han utilizado varios secretos para proteger información sensible. GitHub Actions proporciona un mecanismo seguro para almacenar y utilizar estos secretos sin exponerlos en el código fuente.

## Variables de Secretos Utilizados

### 1. GHCR_PAT

**Descripción**: Token de acceso personal utilizado para autenticarse en el Registro de Contenedores de GitHub (GHCR).

**Uso**:
```yaml
run: echo "\${{ secrets.GHCR_PAT }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin
```

### 2. GITHUB_TOKEN

**Descripción**: Token proporcionado automáticamente por GitHub Actions para realizar acciones en el repositorio, como crear commits y realizar push.

**Uso**:
```yaml
env:
  GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
```

### 3. GHCR_PAT

**Descripción**: Token de acceso personal para autenticarse en el GitHub Container Registry (GHCR).

**Uso**:
```yaml
- name: Log in to GitHub Container Registry
  run: echo "\${{ secrets.GHCR_PAT }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin
```

### 4. GITHUB_TOKEN

**Descripción**: Token automático generado por GitHub Actions para realizar operaciones seguras como `git push`.

**Uso**:
```yaml
- name: Update Kubernetes manifests with new image tag
  env:
    GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
  run: |
    sed -i "s#^ *image: .*#          image: ghcr.io/juanesvelez/devsu/demo-devops-python:\${{ steps.build-image.outputs.tag }}#g" k8s/deployment.yaml
```

### 5. ARGOCD_ADMIN_PASSWORD

**Descripción**: Contraseña del administrador de Argo CD utilizada para iniciar sesión y sincronizar aplicaciones.

**Uso**:
```yaml
- name: Sync with Argo CD
  continue-on-error: true
  run: |
    argocd login --insecure --grpc-web localhost:8080 --username admin --password "\${{ secrets.ARGOCD_ADMIN_PASSWORD }}"
```

### 6. DJANGO_SECRET_KEY
El DJANGO_SECRET_KEY se maneja de forma segura en el pipeline de CD mediante la creación de un Kubernetes Secret directamente desde el valor almacenado en GitHub Secrets. Esto garantiza que la clave nunca se exponga en el código fuente. Aquí está el paso del pipeline que realiza esta operación:

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
      DJANGO_SECRET_KEY: "\${{ secrets.DJANGO_SECRET_KEY }}"
    EOF
  env:
    DJANGO_SECRET_KEY: "\${{ secrets.DJANGO_SECRET_KEY }}"
```

### Protección de la Información Sensible

Las variables de entorno mencionadas se han almacenado de forma segura en los secretos de GitHub Actions. Esto permite que los valores sensibles, como tokens de acceso y claves, se utilicen en las pipelines sin que se expongan en el código fuente. A continuación se explica cómo se han utilizado estas variables en los pipelines:

- **GHCR_PAT**: Utilizado para autenticar con el Registro de Contenedores de GitHub durante la construcción y subida de imágenes Docker.
- **GITHUB_TOKEN**: Utilizado para realizar commits y push de cambios en el repositorio desde las pipelines.
- **GCP_SA_KEY**: Utilizado para autenticar con Google Cloud Platform y obtener las credenciales del clúster de Kubernetes.
- **K8S_CLUSTER_USER**: Utilizado para autenticar con el clúster de Kubernetes.
- **ARGOCD_ADMIN_PASSWORD**: Utilizado para autenticar con Argo CD y sincronizar aplicaciones.
- **DJANGO_SECRET_KEY**: Utilizado para operaciones criptográficas en la aplicación Django.

Estos secretos se han configurado en el repositorio de GitHub bajo `Settings > Secrets and variables > Actions`.
