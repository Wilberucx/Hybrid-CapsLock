#!/usr/bin/env python3
"""
OBSIDIAN HOTKEYS MANAGER
========================
Intelligent processor for Obsidian hotkeys.json to HybridCapsLock integration

Features:
- Smart key assignment based on JSON data
- Preserves user customizations (;lock protection)
- Generates readable INI with full documentation
- Handles conflicts and suggests alternatives
- Creates organized tooltip display

Usage:
    python obsidian_manager.py --import     # Import from hotkeys.json
    python obsidian_manager.py --update     # Update existing configuration
    python obsidian_manager.py --status     # Show current status
"""

import json
import os
import sys
import re
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple, Optional
import argparse

class ObsidianHotkeysManager:
    def __init__(self, script_dir: str = None):
        """Initialize the manager with script directory"""
        self.script_dir = Path(script_dir) if script_dir else Path(__file__).parent
        self.hotkeys_json = self.script_dir / "hotkeys.json"
        self.obsidian_ini = self.script_dir / "config" / "obsidian.ini"
        
        # Key assignment priorities
        self.priority_commands = [
            'quick-switcher', 'command-palette', 'open-search', 'save-file',
            'new-note', 'close-tab', 'split-vertical', 'split-horizontal',
            'open-search-replace', 'goto-line', 'insert-link'
        ]
        
        self.mundane_commands = [
            'toggle-bold', 'toggle-italic', 'toggle-underline', 'toggle-strikethrough'
        ]
        
        # Modifier mappings
        self.modifier_map = {
            'Mod': '^',      # Ctrl on Windows, Cmd on Mac
            'Ctrl': '^',
            'Shift': '+',
            'Alt': '!',
            'Meta': '#'      # Windows key
        }
        
        # Special key mappings
        self.key_map = {
            'ArrowLeft': '{Left}', 'ArrowRight': '{Right}',
            'ArrowUp': '{Up}', 'ArrowDown': '{Down}',
            'Enter': '{Enter}', 'Tab': '{Tab}', 'Space': '{Space}',
            'Backspace': '{Backspace}', 'Delete': '{Delete}',
            'Home': '{Home}', 'End': '{End}',
            'PageUp': '{PgUp}', 'PageDown': '{PgDn}',
            'Escape': '{Esc}'
        }

    def validate_requirements(self) -> bool:
        """Validate that required files exist"""
        if not self.hotkeys_json.exists():
            print(f"❌ ERROR: hotkeys.json not found!")
            print(f"   Expected location: {self.hotkeys_json}")
            print(f"   Please export your Obsidian hotkeys and place the file there.")
            return False
        
        # Create config directory if it doesn't exist
        self.obsidian_ini.parent.mkdir(exist_ok=True)
        
        return True

    def load_hotkeys_json(self) -> Dict:
        """Load and parse the Obsidian hotkeys.json file"""
        try:
            with open(self.hotkeys_json, 'r', encoding='utf-8') as f:
                data = json.load(f)
            print(f"✅ Loaded {len(data)} commands from hotkeys.json")
            return data
        except json.JSONDecodeError as e:
            print(f"❌ ERROR: Invalid JSON format in hotkeys.json")
            print(f"   {e}")
            return {}
        except Exception as e:
            print(f"❌ ERROR: Failed to read hotkeys.json: {e}")
            return {}

    def load_existing_config(self) -> Dict[str, str]:
        """Load existing configuration and identify locked lines"""
        locked_lines = {}
        
        if not self.obsidian_ini.exists():
            return locked_lines
        
        try:
            with open(self.obsidian_ini, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Find all lines with ;lock
            for line in content.split('\n'):
                if ';lock' in line and '=' in line:
                    key = line.split('=')[0].strip()
                    locked_lines[key] = line.strip()
            
            print(f"🔒 Found {len(locked_lines)} locked customizations")
            return locked_lines
            
        except Exception as e:
            print(f"⚠️  Warning: Could not read existing config: {e}")
            return {}

    def parse_obsidian_hotkey(self, hotkey_data: List[Dict]) -> Optional[Tuple[str, bool]]:
        """Parse Obsidian hotkey data and return (key, has_shift)"""
        if not hotkey_data or not isinstance(hotkey_data, list):
            return None
        
        # Take the first hotkey definition
        hotkey = hotkey_data[0]
        
        modifiers = hotkey.get('modifiers', [])
        key = hotkey.get('key', '')
        
        if not key:
            return None
        
        # Check if Shift is present (ignore Mod/Ctrl)
        has_shift = 'Shift' in modifiers
        
        # Convert special keys
        if key in self.key_map:
            key = self.key_map[key]
        
        return (key, has_shift)

    def build_autohotkey_command(self, hotkey_data: List[Dict]) -> str:
        """Build AutoHotkey command string from Obsidian hotkey data"""
        if not hotkey_data or not isinstance(hotkey_data, list):
            return ""
        
        hotkey = hotkey_data[0]
        modifiers = hotkey.get('modifiers', [])
        key = hotkey.get('key', '')
        
        if not key:
            return ""
        
        # Build modifier string (ignore Mod since we're using CapsLock)
        modifier_str = ""
        for mod in modifiers:
            if mod in self.modifier_map and mod != 'Mod':
                modifier_str += self.modifier_map[mod]
        
        # Add Ctrl for Mod (since Obsidian Mod = Ctrl on Windows)
        if 'Mod' in modifiers:
            modifier_str = '^' + modifier_str
        
        # Convert special keys
        if key in self.key_map:
            key = self.key_map[key]
        
        return modifier_str + key

    def assign_keys_intelligently(self, obsidian_data: Dict, locked_lines: Dict[str, str]) -> Tuple[Dict[str, Tuple[str, str, str]], Dict[str, Tuple[str, str, str]]]:
        """Intelligently assign keys to commands"""
        assigned_commands = {}
        overflow_commands = {}
        used_keys = set()
        
        # First, preserve locked customizations
        for key, line in locked_lines.items():
            if key and len(key) == 1:  # Single character keys only
                used_keys.add(key.lower())
                used_keys.add(key.upper())
        
        # Sort commands by priority
        commands_by_priority = []
        
        # High priority commands first
        for cmd_id, hotkey_data in obsidian_data.items():
            is_priority = any(priority in cmd_id for priority in self.priority_commands)
            is_mundane = any(mundane in cmd_id for mundane in self.mundane_commands)
            
            priority = 0 if is_priority else (2 if is_mundane else 1)
            commands_by_priority.append((priority, cmd_id, hotkey_data))
        
        # Sort by priority (0 = highest, 2 = lowest)
        commands_by_priority.sort(key=lambda x: x[0])
        
        # Assign keys
        for priority, cmd_id, hotkey_data in commands_by_priority:
            parsed = self.parse_obsidian_hotkey(hotkey_data)
            if not parsed:
                continue
            
            original_key, has_shift = parsed
            ahk_command = self.build_autohotkey_command(hotkey_data)
            
            if not ahk_command:
                continue
            
            # Determine target key
            if len(original_key) == 1 and original_key.isalpha():
                target_key = original_key.upper() if has_shift else original_key.lower()
            else:
                # For special keys, try to find a good alternative
                target_key = self.suggest_key_for_command(cmd_id, used_keys)
            
            # Check if key is available
            if target_key and target_key not in used_keys:
                assigned_commands[target_key] = (ahk_command, cmd_id, self.get_command_description(cmd_id))
                used_keys.add(target_key)
            else:
                # Try to find alternative
                alt_key = self.find_alternative_key(cmd_id, used_keys, has_shift)
                if alt_key:
                    assigned_commands[alt_key] = (ahk_command, cmd_id, self.get_command_description(cmd_id))
                    used_keys.add(alt_key)
                else:
                    # Add to overflow
                    overflow_key = str(len(overflow_commands) + 1)
                    overflow_commands[overflow_key] = (ahk_command, cmd_id, self.get_command_description(cmd_id))
        
        print(f"📋 Assigned {len(assigned_commands)} commands to keys")
        print(f"📋 {len(overflow_commands)} commands in overflow menu")
        
        return assigned_commands, overflow_commands

    def suggest_key_for_command(self, cmd_id: str, used_keys: set) -> Optional[str]:
        """Suggest a key based on command semantics"""
        # Extract meaningful words from command ID
        words = re.findall(r'[a-zA-Z]+', cmd_id.lower())
        
        # Try first letter of each word
        for word in words:
            if word and word[0] not in used_keys:
                return word[0]
        
        # Try all available letters
        for char in 'abcdefghijklmnopqrstuvwxyz':
            if char not in used_keys:
                return char
        
        return None

    def find_alternative_key(self, cmd_id: str, used_keys: set, prefer_shift: bool = False) -> Optional[str]:
        """Find alternative key for command"""
        # Try shift variant first if preferred
        if prefer_shift:
            for char in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ':
                if char not in used_keys:
                    return char
        
        # Try regular letters
        for char in 'abcdefghijklmnopqrstuvwxyz':
            if char not in used_keys:
                return char
        
        # Try numbers
        for char in '0123456789':
            if char not in used_keys:
                return char
        
        return None

    def get_command_description(self, cmd_id: str) -> str:
        """Generate human-readable description for command"""
        # Common command mappings
        descriptions = {
            'editor:toggle-bold': 'Negrita',
            'editor:toggle-italic': 'Cursiva',
            'editor:toggle-underline': 'Subrayado',
            'editor:open-search': 'Buscar',
            'editor:open-search-replace': 'Buscar y reemplazar',
            'quick-switcher:open': 'Cambiar archivo rápido',
            'command-palette:open': 'Paleta de comandos',
            'editor:save-file': 'Guardar archivo',
            'file:new-note': 'Nueva nota',
            'workspace:close': 'Cerrar pestaña',
            'workspace:split-vertical': 'Dividir vertical',
            'workspace:split-horizontal': 'Dividir horizontal',
            'app:reload': 'Recargar aplicación',
            'editor:insert-link': 'Insertar enlace',
            'graph:open': 'Abrir vista de grafo'
        }
        
        if cmd_id in descriptions:
            return descriptions[cmd_id]
        
        # Generate description from command ID
        parts = cmd_id.split(':')
        if len(parts) >= 2:
            action = parts[1].replace('-', ' ').title()
            return action
        
        return cmd_id.replace('-', ' ').title()

    def generate_ini_content(self, assigned_commands: Dict, overflow_commands: Dict, locked_lines: Dict[str, str]) -> str:
        """Generate the complete INI file content"""
        content = []
        
        # Header
        content.append("; ============================================")
        content.append("; OBSIDIAN HOTKEYS CONFIGURATION")
        content.append("; ============================================")
        content.append("; SÍMBOLOS DE MODIFICADORES:")
        content.append("; ^ = Ctrl")
        content.append("; + = Shift")
        content.append("; ! = Alt")
        content.append("; # = Windows Key")
        content.append(";")
        content.append("; EJEMPLOS:")
        content.append("; ^f = Ctrl+F")
        content.append("; +^f = Shift+Ctrl+F")
        content.append("; !f = Alt+F")
        content.append("; ============================================")
        content.append("")
        
        # Settings section
        content.append("[Settings]")
        content.append("enable_obsidian_layer=true            ; true/false - Enable Obsidian layer")
        content.append("tooltip_columns=4                     ; Comandos por línea en tooltip")
        content.append("show_autohotkey_syntax=true           ; Mostrar sintaxis AHK en comentarios")
        content.append("feedback_duration=1500                ; Duración del tooltip de feedback")
        content.append("auto_reload_after_import=true         ; Recargar automáticamente después de importar")
        content.append("")
        
        # Commands section
        content.append("[ObsidianCommands]")
        content.append("; ============================================")
        content.append(f"; COMANDOS IMPORTADOS - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        content.append("; ============================================")
        content.append("; Para personalizar: agrega ;lock al final de cualquier línea")
        content.append("; Ejemplo: f=^f ;lock                 ; Mi configuración personalizada")
        content.append("")
        
        # Group commands by category
        categories = {
            'Texto': [],
            'Búsqueda': [],
            'Archivos': [],
            'Workspace': [],
            'Navegación': [],
            'Avanzado': []
        }
        
        # Categorize commands
        for key, (ahk_cmd, cmd_id, description) in assigned_commands.items():
            if any(x in cmd_id for x in ['toggle-', 'format-']):
                categories['Texto'].append((key, ahk_cmd, cmd_id, description))
            elif any(x in cmd_id for x in ['search', 'find', 'switcher', 'palette']):
                categories['Búsqueda'].append((key, ahk_cmd, cmd_id, description))
            elif any(x in cmd_id for x in ['file:', 'new-', 'save-', 'open-']):
                categories['Archivos'].append((key, ahk_cmd, cmd_id, description))
            elif any(x in cmd_id for x in ['workspace:', 'split-', 'close']):
                categories['Workspace'].append((key, ahk_cmd, cmd_id, description))
            elif any(x in cmd_id for x in ['goto-', 'focus-', 'navigate']):
                categories['Navegación'].append((key, ahk_cmd, cmd_id, description))
            else:
                categories['Avanzado'].append((key, ahk_cmd, cmd_id, description))
        
        # Add categorized commands
        for category, commands in categories.items():
            if commands:
                content.append(f"; === {category.upper()} ===")
                for key, ahk_cmd, cmd_id, description in sorted(commands):
                    # Check if this line is locked
                    if key in locked_lines:
                        content.append(locked_lines[key])
                    else:
                        content.append(f"{key}={ahk_cmd}                                  ; {cmd_id} - {description} ({ahk_cmd})")
                content.append("")
        
        # Overflow commands
        if overflow_commands:
            content.append("[OverflowCommands]")
            content.append("; ============================================")
            content.append("; COMANDOS ADICIONALES (Acceso con `)")
            content.append("; ============================================")
            for key, (ahk_cmd, cmd_id, description) in overflow_commands.items():
                content.append(f"{key}={ahk_cmd}                                  ; {cmd_id} - {description} ({ahk_cmd})")
            content.append("")
        
        # Generate tooltip display
        content.extend(self.generate_tooltip_display(assigned_commands))
        
        # Add personalization guide
        content.append("[PersonalizationGuide]")
        content.append("; ============================================")
        content.append("; GUÍA DE PERSONALIZACIÓN")
        content.append("; ============================================")
        content.append("; 1. Para proteger una línea: Agrega ;lock al final")
        content.append(";    Ejemplo: f=^f ;lock              ; Mi configuración")
        content.append(";")
        content.append("; 2. Para cambiar tecla: Cambia la letra antes del '='")
        content.append(";    Ejemplo: r=^f                    ; Cambiar búsqueda de 'f' a 'r'")
        content.append(";")
        content.append("; 3. Para cambiar combinación: Modifica después del '='")
        content.append(";    Ejemplo: f=^+f                   ; Cambiar Ctrl+F a Ctrl+Shift+F")
        content.append(";")
        content.append("; 4. Guarda y recarga con <leader>+c+h+r")
        
        return '\n'.join(content)

    def generate_tooltip_display(self, assigned_commands: Dict) -> List[str]:
        """Generate tooltip display configuration"""
        content = []
        content.append("[TooltipDisplay]")
        content.append("; ============================================")
        content.append("; CONFIGURACIÓN DEL MENÚ (4 comandos por línea)")
        content.append("; ============================================")
        
        # Sort commands by key for consistent display
        sorted_commands = sorted(assigned_commands.items())
        
        # Group into lines of 4
        lines = []
        current_line = []
        
        for key, (ahk_cmd, cmd_id, description) in sorted_commands:
            # Create short description for tooltip
            short_desc = description[:12] + "..." if len(description) > 15 else description
            current_line.append(f"{key} - {short_desc}")
            
            if len(current_line) == 4:
                lines.append("    ".join(current_line))
                current_line = []
        
        # Add remaining commands
        if current_line:
            lines.append("    ".join(current_line))
        
        # Add lines to content
        for i, line in enumerate(lines, 1):
            content.append(f"line{i}={line}")
        
        # Add navigation line
        content.append(f"line{len(lines)+1}=` - Más comandos    [Backspace: Back]    [Esc: Exit]")
        content.append("")
        
        return content

    def import_hotkeys(self) -> bool:
        """Import hotkeys from JSON file"""
        print("🚀 Starting Obsidian hotkeys import...")
        
        if not self.validate_requirements():
            return False
        
        # Load data
        obsidian_data = self.load_hotkeys_json()
        if not obsidian_data:
            return False
        
        locked_lines = self.load_existing_config()
        
        # Process and assign keys
        assigned_commands, overflow_commands = self.assign_keys_intelligently(obsidian_data, locked_lines)
        
        if not assigned_commands and not overflow_commands:
            print("❌ No commands could be processed")
            return False
        
        # Generate INI content
        ini_content = self.generate_ini_content(assigned_commands, overflow_commands, locked_lines)
        
        # Write to file
        try:
            with open(self.obsidian_ini, 'w', encoding='utf-8') as f:
                f.write(ini_content)
            
            print(f"✅ Successfully generated {self.obsidian_ini}")
            print(f"📋 {len(assigned_commands)} commands assigned to keys")
            print(f"📋 {len(overflow_commands)} commands in overflow menu")
            print(f"🔒 {len(locked_lines)} customizations preserved")
            
            return True
            
        except Exception as e:
            print(f"❌ ERROR: Failed to write configuration file: {e}")
            return False

    def update_hotkeys(self) -> bool:
        """Update existing hotkeys configuration"""
        print("🔄 Updating Obsidian hotkeys configuration...")
        return self.import_hotkeys()  # Same process, but preserves locked lines

    def show_status(self) -> None:
        """Show current status of the integration"""
        print("📊 OBSIDIAN INTEGRATION STATUS")
        print("=" * 40)
        
        # Check files
        print(f"hotkeys.json: {'✅ Found' if self.hotkeys_json.exists() else '❌ Missing'}")
        print(f"obsidian.ini: {'✅ Found' if self.obsidian_ini.exists() else '❌ Missing'}")
        
        if self.obsidian_ini.exists():
            try:
                with open(self.obsidian_ini, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Count commands and locked lines
                commands = len([line for line in content.split('\n') if '=' in line and not line.strip().startswith(';')])
                locked = len([line for line in content.split('\n') if ';lock' in line])
                
                print(f"Commands configured: {commands}")
                print(f"Locked customizations: {locked}")
                
            except Exception as e:
                print(f"Error reading config: {e}")

def main():
    parser = argparse.ArgumentParser(description='Obsidian Hotkeys Manager')
    parser.add_argument('--import', action='store_true', dest='import_hotkeys',
                       help='Import hotkeys from hotkeys.json')
    parser.add_argument('--update', action='store_true',
                       help='Update existing configuration')
    parser.add_argument('--status', action='store_true',
                       help='Show current status')
    parser.add_argument('--script-dir', type=str,
                       help='Directory containing the script (auto-detected if not provided)')
    
    args = parser.parse_args()
    
    # Auto-detect script directory if not provided
    script_dir = args.script_dir or str(Path(__file__).parent)
    
    manager = ObsidianHotkeysManager(script_dir)
    
    if args.import_hotkeys:
        success = manager.import_hotkeys()
        sys.exit(0 if success else 1)
    elif args.update:
        success = manager.update_hotkeys()
        sys.exit(0 if success else 1)
    elif args.status:
        manager.show_status()
    else:
        parser.print_help()

if __name__ == "__main__":
    main()