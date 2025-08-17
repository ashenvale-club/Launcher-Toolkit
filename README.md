# Launcher Toolkit

🛠️ Kit de herramientas de diagnóstico y reparación para el launcher de Ashenvale L2

## 📋 Descripción

Conjunto de herramientas especializadas para resolver automáticamente los problemas más comunes del launcher, con detección inteligente de la instalación y compatibilidad universal con Windows.

## 🔧 Herramientas Incluidas

### 1. Launcher_Fix.bat
**Solución integral automática**
- Detecta ubicación del launcher via registro de Windows
- Limpia caché y archivos temporales corruptos
- Configura certificados SSL/TLS y protocolos de seguridad
- Resetea configuración de red (DNS, Winsock, TCP/IP)
- Agrega excepciones a Windows Defender
- **Requiere:** Ejecutar como Administrador

### 2. Launcher_Diagnostic.bat
**Análisis completo del sistema**
- Verifica instalación del launcher en registro y rutas conocidas
- Detecta componentes requeridos (.NET, Visual C++, DirectX, WebView2)
- Busca el cliente L2 en rutas comunes y configuración del launcher
- Prueba conectividad con servidores de Ashenvale
- Genera informe detallado con timestamp
- **No requiere:** Permisos de administrador

### 3. Launcher_Debug.bat
**Modos especiales de ejecución**
- 8 modos diferentes de debug y solución de problemas:
  - Modo Seguro (sin GPU)
  - Modo Debug (con consola de desarrollador)
  - Modo Sin Sandbox
  - Modo Offline
  - Limpiar caché y ejecutar
  - Diagnóstico completo
  - Reparar registro
  - Ver logs
- **Uso:** Para cuando el launcher no inicia normalmente

## ⚡ Guía de Uso Rápido

### Orden recomendado:
1. **Diagnosticar** → Ejecutar `Launcher_Diagnostic.bat`
2. **Reparar** → Ejecutar `Launcher_Fix.bat` como Administrador
3. **Debug** → Si persiste el problema, usar `Launcher_Debug.bat`

## 🖥️ Compatibilidad

- ✅ Windows 7, 8, 8.1, 10 y 11
- ✅ Detecta automáticamente versión del SO
- ✅ Compatible con instalaciones antiguas (AshenvaleLauncher) y nuevas (l2ashenvale)
- ✅ Detección inteligente via registro de Windows

## ❗ Problemas Frecuentes

| Problema | Causa | Solución |
|----------|-------|----------|
| Pantalla blanca/negra en Windows 10/11 | Falta Edge WebView2 | [Descargar WebView2](https://go.microsoft.com/fwlink/p/?LinkId=2124703) |
| Error VCRUNTIME140.dll | Falta Visual C++ 2015-2022 | [x64](https://aka.ms/vs/17/release/vc_redist.x64.exe) / [x86](https://aka.ms/vs/17/release/vc_redist.x86.exe) |
| Launcher no inicia en Windows 7 | Falta .NET 4.7.2 o PowerShell 5.1 | Ejecutar Launcher_Fix.bat |
| Errores de actualización | Caché corrupto o problemas de red | Ejecutar Launcher_Fix.bat |

## 📞 Soporte

- **Discord:** [discord.com/invite/ashenvaleclub](https://discord.com/invite/ashenvaleclub)
- **Web:** [ashenvale.club](https://ashenvale.club)
- **Al reportar problemas:** Adjuntar el archivo de diagnóstico generado

## 📌 Notas Importantes

- Los scripts detectan automáticamente la ubicación del launcher
- Siempre ejecutar `Launcher_Fix.bat` como Administrador
- El diagnóstico genera un archivo timestamped con toda la información
- Los modos debug permiten identificar problemas específicos

---

**Versión:** 2.0 Universal  
**Última actualización:** Agosto 2025  
**Licencia:** Uso libre para la comunidad de Ashenvale