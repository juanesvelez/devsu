# CI Pipeline

La pipeline de integración continua (CI) se encarga de asegurar que cada cambio en el código se construya, se pruebe y se valide automáticamente antes de fusionarse en la rama principal. A continuación se detallan los pasos involucrados en esta pipeline.

## Pasos de la Pipeline

### Checkout del código
Este paso utiliza la acción `actions/checkout` para obtener el código del repositorio.
```yaml
- name: Checkout code
  uses: actions/checkout@v2
```

### Configuración de Python
Este paso configura la versión de Python necesaria para el proyecto utilizando `actions/setup-python`.
```yaml
- name: Set up Python
  uses: actions/setup-python@v2
  with:
    python-version: '3.11'
```

### Instalación de dependencias
Se instalan todas las dependencias listadas en el archivo `requirements.txt`.
```yaml
- name: Install dependencies
  run: pip install -r requirements.txt
```

### Ejecución de migraciones
Este paso se encarga de ejecutar las migraciones de la base de datos de Django.
```yaml
- name: Run migrations
  run: |
    python manage.py makemigrations
    python manage.py migrate
```

### Linter de código
Este paso instala `flake8` y lo ejecuta para verificar la calidad del código.
```yaml
- name: Lint code
  run: pip install flake8 && flake8 .
```

### Ejecución de pruebas unitarias
Este paso ejecuta las pruebas unitarias del proyecto.
```yaml
- name: Run unit tests
  run: python manage.py test
```

### Generación de informe de cobertura
Este paso instala la herramienta de cobertura de código `coverage`, ejecuta las pruebas para generar un informe de cobertura y guarda el informe en formato XML.
```yaml
- name: Generate coverage report
  run: |
    pip install coverage
    coverage run --source='.' manage.py test
    coverage report
    coverage xml -o coverage/coverage.xml
    coverage report -m
```

### Cargar el informe de coverage
Este paso usa `actions/upload-artifact@v2` para cargar el informe de coverage generado como un artefacto en GitHub Actions. Esto permite que el informe esté disponible para su descarga y revisión.
```yaml
- name: Upload coverage report
  uses: actions/upload-artifact@v2
  with:
    name: coverage-report
    path: coverage/coverage.xml
```

### Iniciar sesión en el Registro de Contenedores de GitHub
Este paso inicia sesión en el Registro de Contenedores de GitHub (GHCR) utilizando un token de acceso personal (GHCR_PAT) almacenado en los secretos de GitHub.
```yaml
- name: Log in to GitHub Container Registry
  run: echo "${{ secrets.GHCR_PAT }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin
```

### Construir la imagen de Docker
Este paso construye la imagen de Docker con la etiqueta basada en el SHA del commit actual y almacena el valor de la etiqueta en una salida del paso para su uso posterior.
```yaml
- name: Build Docker image
  id: build-image
  run: |
    TAG=${{ github.sha }}
    docker build -t ghcr.io/${{ github.repository }}/demo-devops-python:${TAG} .
    echo "::set-output name=tag::${TAG}"
    echo "Built image with tag $TAG"
```

### Subir la imagen de Docker al Registro de Contenedores de GitHub
Este paso sube la imagen de Docker recién construida al GitHub Container Registry.
```yaml
- name: Push Docker image to GitHub Container Registry
  run: docker push ghcr.io/${{ github.repository }}/demo-devops-python:${{ steps.build-image.outputs.tag }}
```

### Actualizar las definiciones de Kubernetes con el nuevo tag de la imagen
Este paso actualiza el archivo `deployment.yaml` con el nuevo tag de la imagen y realiza un commit con estos cambios en el repositorio.
```yaml
- name: Update Kubernetes manifests with new image tag
  run: |
    sed -i "s#^ *image: .*#          image: ghcr.io/juanesvelez/devsu/demo-devops-python:${{ steps.build-image.outputs.tag }}#g" k8s/deployment.yaml
    git config --global user.email "action@github.com"
    git config --global user.name "GitHub Action"
    git add k8s/deployment.yaml
    git commit -m "Update image tag to ${{ steps.build-image.outputs.tag }}"
    git push
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Instalar Trivy
Este paso instala Trivy, una herramienta de análisis de vulnerabilidades para contenedores.

```yaml
- name: Install Trivy
  run: |
    sudo apt-get update -y
    sudo apt-get install wget apt-transport-https gnupg lsb-release -y
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
    echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
    sudo apt-get update -y
    sudo apt-get install trivy -y
```

### Análisis de Vulnerabilidades con Trivy
Este paso ejecuta un análisis de vulnerabilidades en la imagen Docker utilizando Trivy y guarda el informe en formato JSON.

```yaml
- name: Vulnerability scan with Trivy
  run: trivy image -f json -o trivy-report.json ghcr.io/${{ github.repository }}/demo-devops-python:latest
```

### Subir Informe de Trivy
- name: Upload Trivy scan report
  uses: actions/upload-artifact@v2
  with:
    name: trivy-scan-report
    path: trivy-report.json
```