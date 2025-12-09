# Hybrid CapsLock - Sistema de Productividad Avanzado para AutoHotkey

![HybridCapsLock logo](img/Logo%20HybridCapsLock.png)

> [!NOTE]
> Este proyecto no está siendo matenido activamente. Para una solución más moderna y mantenida, considera usar [Kanata + AutoHotkey v2](https://github.com/Wilberucx/Hybrid-CapsLock-fork)

Este script transforma la tecla `CapsLock` en una potente herramienta de productividad con un comportamiento híbrido, inspirado en la eficiencia de editores como Vim. Ofrece un entorno de trabajo completamente personalizable para navegar, editar y gestionar tu sistema con una ergonomía mejorada.

## 🤔 ¿Por qué HybridCapsLock?

- **Eficiencia Modal:** Inspirado en Vim, el sistema de capas te permite hacer más sin levantar las manos del teclado, cambiando el comportamiento de las teclas según el contexto.
- **Ergonomía:** Reduce el movimiento de las manos y la tensión en los dedos al concentrar los atajos más comunes alrededor de la tecla `CapsLock`, una de las más accesibles y menos utilizadas.
- **Personalización Extrema:** Con un sistema de configuración modular de 5 archivos `.ini`, puedes adaptar cada capa, atajo y menú a tu flujo de trabajo específico sin tocar una línea de código.
- **Productividad Aumentada:** Automatiza tareas repetitivas, lanza programas, inserta texto y gestiona ventanas a una velocidad superior, minimizando el uso del ratón.

## ✨ Conceptos Clave

> Nota de terminología: En esta documentación usamos el término "leader" para referirnos a la combinación `CapsLock + Space`.

- **🔧 Modo Modificador (Mantener Pulsado):** `CapsLock` actúa como una tecla modificadora (similar a `Ctrl`) para atajos rápidos.
- **📝 Modo "Capa Nvim" (Toque Rápido):** Activa una capa de navegación y edición estilo Vim para moverte por el texto y el sistema de forma eficiente.
- **🎯 Modo Líder (`CapsLock + Space`):** Accede a un menú contextual con sub-capas organizadas para programas, ventanas, comandos y más.

## ⚙️ Instalación y Uso

1. **Requisito:** Instalar [AutoHotkey v2](https://www.autohotkey.com/).
2. **Ejecutar:** Doble click en `HybridCapsLock.ahk`.
3. **Inicio automático (Opcional):** Crear un acceso directo al script en la carpeta de inicio de Windows (`shell:startup`).

## 📚 Documentación Completa

Para una guía detallada sobre todos los atajos, capas, configuración avanzada y desarrollo, consulta nuestro portal de documentación:

- **[➡️ Ir a la Documentación Completa (Carpeta `/doc`)](doc/README.md)**

## 🚧 Desarrollo y Versiones

- Para ver el historial de cambios y versiones, revisa el archivo **[CHANGELOG.md](CHANGELOG.md)**.
- Las características en desarrollo y planes futuros se detallan en la documentación.



Copyright (C) 2025 Wilberucx

Este programa es software libre; puedes redistribuirlo y/o modificarlo
bajo los términos de la GNU General Public License tal como está publicada por
la Free Software Foundation; ya sea la versión 2 de la Licencia, o
(a tu elección) cualquier versión posterior.

Este programa se distribuye con la esperanza de que sea útil,
pero SIN NINGUNA GARANTÍA; ni siquiera la garantía implícita de
COMERCIABILIDAD o APTITUD PARA UN PROPÓSITO PARTICULAR. Consulta la
GNU General Public License para más detalles.

Deberías haber recibido una copia de la GNU General Public License junto
con este programa; si no, consulta <https://www.gnu.org/licenses/>.
