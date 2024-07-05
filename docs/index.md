# Documentación del Proyecto

Este documento describe la implementación de una aplicación web utilizando Docker, Kubernetes y GitHub Actions para CI/CD. A continuación, se detallan los componentes del proyecto, las decisiones técnicas tomadas y los pasos seguidos para cumplir con los requisitos de la prueba técnica.

## Contenido
- [Introducción](#introducción)
- [CI Pipeline](ci_pipeline.md)
- [CD Pipeline](cd_pipeline.md)
- [Dockerfile](docker.md)
- [Recursos de Kubernetes](kubernetes_resources.md)
- [Gestión de Secretos](secrets_management.md)
- [Diagrama](diagrams.md)

## Estructura del proyecto

El proyecto está organizado de la siguiente manera:

- **.github/**
  - **workflows/**: Contiene los archivos de configuración para los pipelines de CI y CD.
    - **ci_pipeline.yaml**: Define el pipeline de integración continua.
    - **cd_pipeline.yaml**: Define el pipeline de entrega continua.

- **.pytest_cache/**: Directorio utilizado por pytest para almacenar archivos de caché temporales.

- **api/**: Contiene el código relacionado con las APIs de la aplicación.

- **demo/**: Incluye ejemplos y scripts de demostración.

- **docs/**: Documentación del proyecto, incluyendo los archivos markdown para GitHub Pages.

- **k8s/**: Manifiestos de Kubernetes para desplegar la aplicación.
  - **deployment.yaml**: Define el despliegue de la aplicación en Kubernetes.
  - **service.yaml**: Define el servicio de Kubernetes para la aplicación.
  - **hpa.yaml**: Define el Horizontal Pod Autoscaler para la aplicación.
  - **virtualservice-demo-devops-python.yaml**: Define el VirtualService de Istio para la aplicación.
  - **application.yaml**: Define la aplicación de Argo CD.
  - **kustomization.yaml**: Archivo de Kustomize para gestionar los manifiestos de Kubernetes.

- **terraform/**: Archivos de Terraform para la creación y gestión de la infraestructura en Google Cloud Platform.
  - **main.tf**: Define los recursos principales.
  - **variables.tf**: Define las variables utilizadas en la configuración de Terraform.
  - **outputs.tf**: Define las salidas de Terraform.
  - **backend.tf**: Configura el backend para almacenar el estado de Terraform en un bucket de GCP.

- **.env**: Archivo de configuración de variables de entorno.

- **.gitignore**: Define los archivos y directorios que deben ser ignorados por Git.

- **db.sqlite3**: Base de datos SQLite utilizada por la aplicación.

- **docker-compose.yaml**: Archivo de configuración de Docker Compose para la ejecución local de la aplicación.

- **Dockerfile**: Define cómo se construye la imagen Docker de la aplicación.

- **manage.py**: Script de gestión de Django.

- **README.md**: Archivo de lectura inicial con información general sobre el proyecto.

- **requirements.txt**: Lista de dependencias de Python necesarias para la aplicación.
## Acceso a Argo CD
Puedes acceder a la interfaz de Argo CD en el siguiente enlace: [Argo CD](https://34.30.114.5/argocd).

![Argo CD Sync Status](./argocd_sync_status.jpg)

## Ejemplos de cURL

### Crear un usuario
```bash
curl -X POST http://35.224.250.136/api/users/ -H "Content-Type: application/json" -d '{"dni": "12345678", "name": "John Doe"}'
```
### Obtener todos los usuarios
```bash
curl -X GET http://35.224.250.136/api/users/ | jq
```

### Clonar Repo 
```bash
git@github.com:juanesvelez/devsu.git
```