# GitHub Actions - Release Workflow

Este repositorio incluye un workflow automatizado para generar releases y ejecutables de Windows.

## 📋 Archivos de Workflow

### 1. `.github/workflows/ci.yml`
- **Propósito**: Builds automáticos en cada push/PR
- **Genera**: Builds de desarrollo (`dev-build` pre-release)
- **Plataformas**: Windows, Linux (PyInstaller + AppImage)

### 2. `.github/workflows/release.yml` ⭐ **NUEVO**
- **Propósito**: Crear releases oficiales y de prueba
- **Genera**: Releases etiquetados con archivos ZIP
- **Plataformas**: Windows (expandible a Linux)

## 🚀 Cómo Crear un Release

### Opción 1: Manual (Recomendado para pruebas)

1. Ve a la pestaña **Actions** en GitHub
2. Selecciona **"Create Release"** en la lista de workflows
3. Haz clic en **"Run workflow"**
4. Configura los parámetros:
   - **Version tag**: `test-v1.0.0` (para pruebas) o `v1.0.0` (para releases oficiales)
   - **Mark as pre-release**: ✅ (para pruebas) o ❌ (para releases oficiales)
5. Haz clic en **"Run workflow"**

### Opción 2: Automático (mediante tags)

```bash
# Para un release de prueba
git tag test-v1.0.0
git push origin test-v1.0.0

# Para un release oficial
git tag v1.0.0  
git push origin v1.0.0
```

## 📦 Qué se Genera

### Artefactos del Build
- `Twitch.Drops.Miner.Windows.v{version}.zip`
  - Ejecutable principal
  - `manual.txt` (si existe)
  - `BUILD_INFO.txt` con información del build
  - `CHANGELOG.md` (si existe)

### Release en GitHub
- **Título**: `Twitch Drops Miner v{version}`
- **Descripción**: Notas de release automáticas con:
  - Información del build
  - Instrucciones de instalación
  - Notas de seguridad
  - Enlaces útiles
- **Archivos**: ZIP con el ejecutable
- **Tags**: Automático basado en la versión

## 🛡️ Características de Seguridad

### Builds Seguros
- ✅ **Sin credenciales hardcodeadas** en el código
- ✅ **Dependencias verificadas** antes del build
- ✅ **Validación de archivos** de lenguaje
- ✅ **Cache inteligente** para dependencias y herramientas
- ✅ **Logs detallados** para debugging

### Artefactos Seguros
- ✅ **Build reproducible** con información de commit
- ✅ **UPX compresión** (puede generar falsos positivos en antivirus)
- ✅ **No firmado digitalmente** (recomendación: agregar code signing)

## ⚙️ Configuración Avanzada

### Variables de Entorno
```yaml
env:
  PYTHON_VERSION: '3.10'  # Versión de Python a usar
```

### Personalizar el Build
Para modificar el proceso de build, edita:
- `build.spec` - Configuración de PyInstaller
- `requirements.txt` - Dependencias de Python
- `version.py` - Versión base del proyecto

### Limpieza Automática
El workflow incluye limpieza automática de releases de prueba:
- Mantiene solo los 3 releases de prueba más recientes
- Elimina automáticamente releases antiguos con prefijo `test-`

## 🔄 Flujo de Trabajo Recomendado

### Para Desarrollo
1. Trabaja en tu rama de feature
2. El CI automático generará builds de desarrollo
3. Usa `dev-build` para pruebas rápidas

### Para Releases de Prueba
1. Ejecuta el workflow manual con `test-v{version}`
2. Prueba el ejecutable generado
3. Si hay problemas, corrige y repite

### Para Releases Oficiales
1. Actualiza `version.py` con la versión final
2. Crea un tag `v{version}` o usa el workflow manual
3. El release se marca como "latest" automáticamente

## 🚨 Solución de Problemas

### Build Falla
- Revisa los logs del workflow en la pestaña Actions
- Verifica que `requirements.txt` esté actualizado
- Asegúrate de que todos los archivos de idioma JSON sean válidos

### Executable No Funciona
- Revisa `BUILD_INFO.txt` para verificar la versión
- Comprueba que todas las dependencias estén incluidas en `build.spec`
- Prueba en una máquina limpia sin Python instalado

### Release No se Crea
- Verifica que tengas permisos de escritura en el repositorio
- Asegúrate de que no exista un release con el mismo tag
- Revisa que el workflow tenga los permisos correctos

## 🎯 Próximos Pasos Recomendados

1. **Code Signing**: Agregar firma digital al ejecutable
2. **Multi-platform**: Extender para incluir builds de Linux
3. **Automated Testing**: Agregar tests automáticos antes del release
4. **Security Scanning**: Integrar escaneo de vulnerabilidades
5. **Release Notes**: Automatizar generación desde commits/PRs

---

💡 **Tip**: Para releases de producción, siempre usa tags con formato `v{major}.{minor}.{patch}` (ej: `v1.0.0`)
