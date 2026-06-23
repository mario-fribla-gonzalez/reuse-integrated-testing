# integrated-testing
Repositorio que Administrará  las Pruebas Automatizadas de QA en los Workflow de CI/CD de Devops.

Adicionalmente, se ajusta para la ejecución Automatizada de las Pruebas del Área de Continuidad Operativa.


# Requesitos:
## PostMan/NewMan:

```
# Instalar NodeJs
# El servidor para ejecutar las Pruebas Integradas, debe tener instalado el server NodeJS.

# Instalar Newman globalmente
npm install -g newman

# Instalar reporters adicionales
npm install -g newman-reporter-htmlextra
npm install -g newman-reporter-html
```

## Selenium:
```
# En el Servidor para ejecutar las Pruebas Integradas, debe tener instalado los siquientes aplicativos:
# - Instalar NodeJs
#   Descargar del Sitio www.nodejs.org la Últimam Version (Link: https://nodejs.org/dist/v25.2.1/node-v25.2.1-x64.msi al 24/11/2025)
#   Validar version : node -v
#
# - Instalar Pyhton 3.12 o Superior.
#   Descargar del Sitio www.python.org la Últimam Version (Link: https://www.python.org/ftp/python/3.14.0/python-3.14.0-amd64.exe al 24/11/2025)
#   

##############
# Instalar selenium-side-runner globalmente
npm install -g selenium-side-runner

# Instalar con soporte para múltiples navegadores
npm install -g selenium-side-runner @selenium-ide/cli

# Instalar los webdrivers necesarios
npm install -g chromedriver
npm install -g geckodriver

#############

# Instalar Selenium para Python
pip install selenium

# Instalar WebDriver Manager (recomendado)
pip install webdriver-manager

# O descargar WebDrivers Manualmente.
# Chrome: https://chromedriver.chromium.org/
# Edge: https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/
# Firefox: https://github.com/mozilla/geckodriver/releases
```

## Otros Requisitos son:
- Java jdk 21: https://download.oracle.com/java/21/latest/jdk-21_windows-x64_bin.zip
  - Agregar Variable Ambiente: JAVA_HOME = C:\Program Files\Java\jdk-21
  - Actualizar Variable PATH = %JAVA_HOME%\bin

- Maven 3.9.11: https://dlcdn.apache.org/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.zip (https://maven.apache.org/download.cgi)
  - Descomprimir Archivo apache-maven-3.9.11-bin.zip
  - Mover el Directorio Descomprimido apache-maven-3.9.11/ a C:\Program Files\Apache\
    - Si el Directorio C:\Program Files\Maven\ no esta creado, proceda a crear este directorio.
  - Agregar Variable Ambiente: MAVEN_HOME = C:\Program Files\Apache\apache-maven-3.9.11
  - Agregar Variable Ambiente: M2_HOME = C:\Program Files\Apache\apache-maven-3.9.11\bin
  - Actualizar Variable PATH = %MAVEN_HOME%\bin
```

---
Mario Fribla

***DevOps***
