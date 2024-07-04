# Explicación de Dockerfile

En este documento se detalla cómo se ha construido y configurado la imagen Docker para la aplicación. La imagen Docker se crea y gestiona a través de una pipeline de CI, asegurando que todos los cambios en el código se reflejen automáticamente en la imagen de Docker.

## Dockerfile

El archivo `Dockerfile` es crucial para definir cómo se construye la imagen Docker. A continuación, se muestra el `Dockerfile` utilizado en este proyecto.

```Dockerfile
FROM python:3.11-slim
WORKDIR /usr/src/app

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV PYTHONUNBUFFERED=1

CMD ["sh", "-c", "python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]
```

### Base Image
Se utiliza una imagen base oficial de Python, versión 3.11 slim. Esta imagen es más ligera y eficiente para construir la aplicación.
```code
FROM python:3.11-slim
```

### Working Directory
Se establece el directorio de trabajo dentro del contenedor en /usr/src/app.
```code
WORKDIR /usr/src/app
```

### Copia de Dependencias
Se copia el archivo requirements.txt al directorio de trabajo.
```code
COPY requirements.txt ./
```
### Instalación de Dependencias
Se instalan las dependencias listadas en requirements.txt sin utilizar la caché de pip para mantener la imagen ligera.
```code
RUN pip install --no-cache-dir -r requirements.txt
```

### Copia del Código
Se copia el resto del código de la aplicación al directorio de trabajo del contenedor.
```code
COPY . .
```

### Variables de Entorno
Se configura una variable de entorno para asegurar que la salida de Python no esté almacenada en el buffer.
```code
ENV PYTHONUNBUFFERED=1
```

### Comando de Ejecución
Se define el comando que se ejecutará cuando el contenedor se inicie. En este caso, se ejecuta python manage.py migrate para aplicar las migraciones de la base de datos y luego se inicia el servidor de desarrollo de Django en 0.0.0.0:8000.
```code
CMD ["sh", "-c", "python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]
```