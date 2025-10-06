# Implementation Guide: Home Row Mods for HybridCapsLock

## Document Purpose

This guide provides complete instructions for an AI assistant with repository access to implement Home Row Modifiers in the HybridCapsLock project. The implementation uses the same proven tap-hold logic that successfully resolved the CapsLock detection issues.

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [File Structure](#file-structure)
4. [Implementation Steps](#implementation-steps)
5. [Code Specifications](#code-specifications)
6. [Configuration Specifications](#configuration-specifications)
7. [Testing Requirements](#testing-requirements)
8. [Integration Checklist](#integration-checklist)

---

## Overview

### What are Home Row Mods?

Home Row Mods convert the home row keys (A, S, D, F, J, K, L, ;) into dual-function keys:

- **Tap** (< threshold): Send the letter normally
- **Hold** (≥ threshold) + another key: Act as modifier (Win, Alt, Shift, Ctrl)

### Default Layout

```
Left Hand:               Right Hand:
A = Win (when held)      J = Ctrl (when held)
S = Alt (when held)      K = Shift (when held)
D = Shift (when held)    L = Alt (when held)
F = Ctrl (when held)     ; = Win (when held)
```

### Key Requirements

1. **Use KeyWait-based approach** (same as CapsLock fix)
2. **Ignore auto-repeat events** to prevent timer resets
3. **Configurable** via INI files
4. **Non-invasive** - can be enabled/disabled
5. **Compatible** with existing layers and CapsLock system

---

## Architecture

### Design Pattern

Follow the same pattern used in `src/layer/nvim_layer.ahk` for CapsLock:

```
1. Key pressed → Record timestamp
2. KeyWait() blocks until release (ignores auto-repeats)
3. Calculate duration
4. Check if another key was pressed (otherKeyPressed flag)
5. Decide action based on:
   - If used with another key → was modifier (do nothing)
   - If duration < threshold → send letter (tap)
   - If duration ≥ threshold → do nothing (hold without use)
```

### Critical Learning from CapsLock

**DO NOT use scancode handlers** (`~SC01E::`, `~SC01F::`, etc.) as they trigger on auto-repeats.

**DO use `~*key::` with KeyWait()** as it naturally ignores auto-repeats.

---

## File Structure

Create the following files in the repository:

```
HybridCapsLock/
├── config/
│   └── homerow_mods.ini          # NEW: Home row configuration
├── src/
│   └── layer/
│       └── homerow_mods.ahk       # NEW: Implementation
├── doc/
│   ├── HOMEROW_MODS.md            # NEW: User documentation
│   └── TROUBLESHOOTING_HOMEROW.md # NEW: Troubleshooting guide
└── HybridCapsLock.ahk             # MODIFY: Add include and initialization
```

---

## Implementation Steps

### Step 1: Create Configuration File

**File:** `config/homerow_mods.ini`

**Purpose:** Store all home row mod settings

**Required Sections:**

```ini
[General]
; Enable/disable home row mods
enabled=false                    ; Default: OFF (user must opt-in)
debug_mode=false                ; Debug logs for home row

[Timing]
; Threshold for tap vs hold (milliseconds)
tap_threshold_ms=250

; Permissive hold: if true, holding without using still allows typing afterward
; if false, holding without using does nothing (like CapsLock behavior)
permissive_hold=false

[LeftHand]
; Format: key=modifier
; Modifiers: Win, Alt, Shift, Ctrl, none
a_modifier=Win
s_modifier=Alt
d_modifier=Shift
f_modifier=Ctrl

[RightHand]
j_modifier=Ctrl
k_modifier=Shift
l_modifier=Alt
semicolon_modifier=Win

[Exclusions]
; Apps where home row mods should be disabled (comma-separated)
; Use ahk_exe format
excluded_apps=notepad.exe,cmd.exe
```

**Specification Notes:**

- Default `enabled=false` to avoid surprising users
- Threshold should match CapsLock default (250ms) for consistency
- Allow per-key modifier customization
- Support disabling specific keys with `none`
- Provide app exclusions for compatibility

### Step 2: Create Implementation File

**File:** `src/layer/homerow_mods.ahk`

**Purpose:** Core home row mod logic

**Required Structure:**

```autohotkey
; ===================================================================
; HOME ROW MODS - Dual Function Home Row Keys
; Uses KeyWait-based tap-hold detection (same as CapsLock)
; ===================================================================

; ===================================================================
; GLOBAL STATE
; ===================================================================
global homeRowEnabled := false
global homeRowTapThreshold := 250
global homeRowDebug := false
global homeRowPermissiveHold := false

; Per-key state tracking
global homeRowState := Map(
    "a", {pressed: false, pressTime: 0, usedAsMod: false, modifier: "Win"},
    "s", {pressed: false, pressTime: 0, usedAsMod: false, modifier: "Alt"},
    "d", {pressed: false, pressTime: 0, usedAsMod: false, modifier: "Shift"},
    "f", {pressed: false, pressTime: 0, usedAsMod: false, modifier: "Ctrl"},
    "j", {pressed: false, pressTime: 0, usedAsMod: false, modifier: "Ctrl"},
    "k", {pressed: false, pressTime: 0, usedAsMod: false, modifier: "Shift"},
    "l", {pressed: false, pressTime: 0, usedAsMod: false, modifier: "Alt"},
    "semicolon", {pressed: false, pressTime: 0, usedAsMod: false, modifier: "Win"}
)

; Excluded apps
global homeRowExcludedApps := []

; ===================================================================
; INITIALIZATION
; ===================================================================
InitHomeRowMods() {
    global homeRowEnabled, homeRowTapThreshold, homeRowDebug
    global homeRowPermissiveHold, homeRowState, homeRowExcludedApps

    configFile := A_ScriptDir "\config\homerow_mods.ini"

    if (!FileExist(configFile)) {
        OutputDebug("[HOMEROW] Config file not found, home row mods disabled`n")
        return
    }

    ; Load general settings
    homeRowEnabled := IniRead(configFile, "General", "enabled", false)
    homeRowDebug := IniRead(configFile, "General", "debug_mode", false)

    if (!homeRowEnabled) {
        OutputDebug("[HOMEROW] Home row mods disabled in config`n")
        return
    }

    ; Load timing
    homeRowTapThreshold := IniRead(configFile, "Timing", "tap_threshold_ms", 250)
    homeRowPermissiveHold := IniRead(configFile, "Timing", "permissive_hold", false)

    ; Load left hand modifiers
    homeRowState["a"].modifier := IniRead(configFile, "LeftHand", "a_modifier", "Win")
    homeRowState["s"].modifier := IniRead(configFile, "LeftHand", "s_modifier", "Alt")
    homeRowState["d"].modifier := IniRead(configFile, "LeftHand", "d_modifier", "Shift")
    homeRowState["f"].modifier := IniRead(configFile, "LeftHand", "f_modifier", "Ctrl")

    ; Load right hand modifiers
    homeRowState["j"].modifier := IniRead(configFile, "RightHand", "j_modifier", "Ctrl")
    homeRowState["k"].modifier := IniRead(configFile, "RightHand", "k_modifier", "Shift")
    homeRowState["l"].modifier := IniRead(configFile, "RightHand", "l_modifier", "Alt")
    homeRowState["semicolon"].modifier := IniRead(configFile, "RightHand", "semicolon_modifier", "Win")

    ; Load exclusions
    excludedStr := IniRead(configFile, "Exclusions", "excluded_apps", "")
    if (excludedStr != "") {
        homeRowExcludedApps := StrSplit(excludedStr, ",")
        for index, app in homeRowExcludedApps {
            homeRowExcludedApps[index] := Trim(app)
        }
    }

    ; Register hotkeys for enabled keys
    RegisterHomeRowHotkeys()

    if (homeRowDebug)
        OutputDebug("[HOMEROW] Initialized with threshold=" homeRowTapThreshold "ms`n")
}

; ===================================================================
; REGISTER HOTKEYS DYNAMICALLY
; ===================================================================
RegisterHomeRowHotkeys() {
    global homeRowState, homeRowDebug

    for key, state in homeRowState {
        if (state.modifier = "none") {
            if (homeRowDebug)
                OutputDebug("[HOMEROW] Skipping " key " (modifier=none)`n")
            continue
        }

        ; Register the hotkey
        actualKey := (key = "semicolon") ? ";" : key

        try {
            Hotkey("~*" actualKey, (*) => HandleHomeRowKey(key))
            if (homeRowDebug)
                OutputDebug("[HOMEROW] Registered: " actualKey " -> " state.modifier "`n")
        } catch as err {
            OutputDebug("[HOMEROW] Failed to register " actualKey ": " err.Message "`n")
        }
    }
}

; ===================================================================
; CORE HANDLER - Same pattern as CapsLock
; ===================================================================
HandleHomeRowKey(key) {
    global homeRowState, homeRowTapThreshold, homeRowDebug
    global homeRowPermissiveHold, homeRowExcludedApps

    ; Check if in excluded app
    if (IsInExcludedApp()) {
        if (homeRowDebug)
            OutputDebug("[HOMEROW] In excluded app, passthrough`n")
        return
    }

    state := homeRowState[key]

    ; Initialize state
    state.pressed := true
    state.pressTime := A_TickCount
    state.usedAsMod := false

    actualKey := (key = "semicolon") ? ";" : key

    if (homeRowDebug)
        OutputDebug("[HOMEROW] " actualKey " DOWN`n")

    ; CRITICAL: KeyWait ignores auto-repeats
    KeyWait(actualKey)

    ; Calculate duration
    duration := A_TickCount - state.pressTime

    if (homeRowDebug) {
        OutputDebug("[HOMEROW] " actualKey " UP - dur=" duration
                    "ms, usedAsMod=" state.usedAsMod
                    ", threshold=" homeRowTapThreshold "ms`n")
    }

    ; Decision logic
    if (state.usedAsMod) {
        ; Was used as modifier, do nothing
        if (homeRowDebug)
            OutputDebug("[HOMEROW] " actualKey " was used as modifier`n")
    }
    else if (duration < homeRowTapThreshold) {
        ; TAP: Send the letter
        if (homeRowDebug)
            OutputDebug("[HOMEROW] " actualKey " TAP - sending letter`n")
        Send("{" actualKey "}")
    }
    else {
        ; HOLD without use
        if (homeRowPermissiveHold) {
            ; Send the letter anyway (permissive)
            if (homeRowDebug)
                OutputDebug("[HOMEROW] " actualKey " HOLD unused - sending letter (permissive)`n")
            Send("{" actualKey "}")
        } else {
            ; Do nothing (strict, like CapsLock)
            if (homeRowDebug)
                OutputDebug("[HOMEROW] " actualKey " HOLD unused - no action (strict)`n")
        }
    }

    ; Reset state
    state.pressed := false
}

; ===================================================================
; CHECK IF ANY HOME ROW KEY IS HELD
; ===================================================================
IsAnyHomeRowKeyHeld() {
    global homeRowState

    for key, state in homeRowState {
        actualKey := (key = "semicolon") ? ";" : key
        if (GetKeyState(actualKey, "P"))
            return true
    }

    return false
}

; ===================================================================
; GET ACTIVE MODIFIERS FROM HELD HOME ROW KEYS
; ===================================================================
GetActiveHomeRowModifiers() {
    global homeRowState
    modifiers := ""

    for key, state in homeRowState {
        actualKey := (key = "semicolon") ? ";" : key

        if (GetKeyState(actualKey, "P")) {
            ; Mark as used
            state.usedAsMod := true

            ; Build modifier string
            switch state.modifier {
                case "Win":
                    modifiers .= "#"
                case "Alt":
                    modifiers .= "!"
                case "Shift":
                    modifiers .= "+"
                case "Ctrl":
                    modifiers .= "^"
            }
        }
    }

    return modifiers
}

; ===================================================================
; MARK HOME ROW KEY AS USED (called by other keys)
; ===================================================================
MarkHomeRowAsModifier(key) {
    global homeRowState, homeRowDebug

    if (homeRowState.Has(key)) {
        homeRowState[key].usedAsMod := true

        if (homeRowDebug)
            OutputDebug("[HOMEROW] Marked " key " as used modifier`n")
    }
}

; ===================================================================
; CHECK IF IN EXCLUDED APP
; ===================================================================
IsInExcludedApp() {
    global homeRowExcludedApps

    if (homeRowExcludedApps.Length = 0)
        return false

    activeExe := WinGetProcessName("A")

    for app in homeRowExcludedApps {
        if (InStr(activeExe, app))
            return true
    }

    return false
}

; ===================================================================
; CONTEXT HOTKEYS - Other keys mark home row as used
; ===================================================================
; These need to be defined for every other key on the keyboard
; to detect when home row is used as modifier

#HotIf IsAnyHomeRowKeyHeld()

; Letters (excluding home row)
b::SendWithHomeRowMod("b")
c::SendWithHomeRowMod("c")
e::SendWithHomeRowMod("e")
g::SendWithHomeRowMod("g")
h::SendWithHomeRowMod("h")
i::SendWithHomeRowMod("i")
m::SendWithHomeRowMod("m")
n::SendWithHomeRowMod("n")
o::SendWithHomeRowMod("o")
p::SendWithHomeRowMod("p")
q::SendWithHomeRowMod("q")
r::SendWithHomeRowMod("r")
t::SendWithHomeRowMod("t")
u::SendWithHomeRowMod("u")
v::SendWithHomeRowMod("v")
w::SendWithHomeRowMod("w")
x::SendWithHomeRowMod("x")
y::SendWithHomeRowMod("y")
z::SendWithHomeRowMod("z")

; Numbers
1::SendWithHomeRowMod("1")
2::SendWithHomeRowMod("2")
3::SendWithHomeRowMod("3")
4::SendWithHomeRowMod("4")
5::SendWithHomeRowMod("5")
6::SendWithHomeRowMod("6")
7::SendWithHomeRowMod("7")
8::SendWithHomeRowMod("8")
9::SendWithHomeRowMod("9")
0::SendWithHomeRowMod("0")

; Special keys
Space::SendWithHomeRowMod("Space")
Enter::SendWithHomeRowMod("Enter")
Tab::SendWithHomeRowMod("Tab")
Backspace::SendWithHomeRowMod("Backspace")
Delete::SendWithHomeRowMod("Delete")
Escape::SendWithHomeRowMod("Escape")

; Arrows
Left::SendWithHomeRowMod("Left")
Right::SendWithHomeRowMod("Right")
Up::SendWithHomeRowMod("Up")
Down::SendWithHomeRowMod("Down")

#HotIf

; ===================================================================
; SEND WITH HOME ROW MODIFIER
; ===================================================================
SendWithHomeRowMod(key) {
    global homeRowDebug

    ; Get active modifiers
    mods := GetActiveHomeRowModifiers()

    if (homeRowDebug)
        OutputDebug("[HOMEROW] Sending: " mods "{" key "}`n")

    ; Send with modifiers
    Send(mods "{" key "}")
}
```

**Implementation Notes:**

1. Use Map() for state tracking (cleaner than individual globals)
2. KeyWait() handles auto-repeat naturally
3. Dynamic hotkey registration based on config
4. Context-sensitive hotkeys detect modifier usage
5. App exclusions for compatibility

### Step 3: Create User Documentation

**File:** `doc/HOMEROW_MODS.md`

**Purpose:** User-facing documentation

**Required Sections:**

1. What are Home Row Mods
2. Benefits and trade-offs
3. Configuration guide
4. Enabling/disabling
5. Customization examples
6. Troubleshooting
7. Compatibility notes

### Step 4: Create Troubleshooting Guide

**File:** `doc/TROUBLESHOOTING_HOMEROW.md`

**Purpose:** Common issues and solutions

**Required Content:**

- False taps when typing fast
- Adjusting threshold
- Permissive vs strict hold
- App-specific issues
- Debug logging instructions

### Step 5: Integrate into Main Script

**File:** `HybridCapsLock.ahk`

**Modifications Required:**

```autohotkey
; Add include after other layers
#Include src/layer/homerow_mods.ahk

; In initialization section, after LoadLayerState()
InitHomeRowMods()  ; Load and setup home row mods if enabled
```

### Step 6: Update Configuration Loader

**File:** `src/core/config.ahk`

**Modifications:**

If you have a centralized config reload function, add:

```autohotkey
ReloadConfiguration() {
    ; ... existing reload logic ...

    ; Reload home row mods if enabled
    if (homeRowEnabled) {
        ; Disable old hotkeys
        ; Re-initialize
        InitHomeRowMods()
    }
}
```

---

## Code Specifications

### Critical Requirements

1. **MUST use KeyWait pattern**

   ```autohotkey
   ~*a:: {
       ; Record time
       KeyWait("a")  // Blocks until release, ignores repeats
       ; Calculate duration
       ; Decide action
   }
   ```

2. **MUST NOT use scancode handlers**

   ```autohotkey
   ; ❌ WRONG - triggers on auto-repeat
   ~SC01E::
   ~SC01E UP::

   ; ✓ CORRECT - ignores auto-repeat
   ~*a::
   ```

3. **MUST track modifier usage**

   ```autohotkey
   ; When another key is pressed while home row held:
   state.usedAsMod := true
   ```

4. **MUST support configuration**
   - Read from homerow_mods.ini
   - Allow enable/disable
   - Configurable threshold
   - Per-key modifier assignment

5. **MUST provide debug logging**
   ```autohotkey
   if (homeRowDebug)
       OutputDebug("[HOMEROW] key action`n")
   ```

### Performance Requirements

- Minimal overhead when disabled (early return)
- No polling loops
- Event-driven only
- < 1ms latency on keypress

### Compatibility Requirements

- Must not conflict with CapsLock system
- Must not conflict with existing layers
- Must respect app exclusions
- Must work with normal typing

---

## Configuration Specifications

### homerow_mods.ini Structure

**General Section:**

- `enabled` (bool): Master enable/disable
- `debug_mode` (bool): Enable verbose logging

**Timing Section:**

- `tap_threshold_ms` (int, 100-500): Milliseconds for tap vs hold
- `permissive_hold` (bool): Whether to send letter on unused hold

**LeftHand/RightHand Sections:**

- `<key>_modifier` (string): One of Win, Alt, Shift, Ctrl, none
- Must support all 8 home row keys

**Exclusions Section:**

- `excluded_apps` (comma-separated): List of ahk_exe to exclude

### Validation Rules

1. Threshold must be 100-500ms
2. Modifiers must be one of: Win, Alt, Shift, Ctrl, none
3. App names must be valid ahk_exe format
4. Duplicate modifier assignments are allowed but warned

---

## Testing Requirements

### Manual Test Cases

Create a checklist for testing:

```markdown
## Home Row Mods Testing

### Basic Functionality

- [ ] Quick tap of 'a' produces 'a'
- [ ] Hold 'a' + press 'b' produces Win+b
- [ ] Hold 'a' for 300ms without other keys does nothing (strict mode)
- [ ] Hold 'a' for 300ms without other keys produces 'a' (permissive mode)

### All Keys

- [ ] Test each home row key (a,s,d,f,j,k,l,;)
- [ ] Verify correct modifier for each key
- [ ] Test with capital letters (Shift+homerow)

### Edge Cases

- [ ] Rapid typing doesn't trigger modifiers
- [ ] Holding multiple home row keys simultaneously
- [ ] Home row + CapsLock combos don't conflict
- [ ] Disabled keys (modifier=none) work as normal

### Configuration

- [ ] Enabling/disabling in INI works
- [ ] Changing threshold takes effect on reload
- [ ] Changing modifiers takes effect on reload
- [ ] App exclusions work correctly

### Performance

- [ ] No lag when typing normally
- [ ] No false positives when typing fast
- [ ] Debug logs show correct timing

### Compatibility

- [ ] Works in text editors
- [ ] Works in browsers
- [ ] Works in terminal
- [ ] Excluded apps bypass home row mods
```

### Debug Logging Test

With `debug_mode=true`, logs should show:

```
[HOMEROW] Initialized with threshold=250ms
[HOMEROW] Registered: a -> Win
[HOMEROW] a DOWN
[HOMEROW] Sending: #{b}
[HOMEROW] Marked a as used modifier
[HOMEROW] a UP - dur=150ms, usedAsMod=1, threshold=250ms
[HOMEROW] a was used as modifier
```

---

## Integration Checklist

Use this checklist to ensure complete integration:

### Files Created

- [ ] `config/homerow_mods.ini` exists with all sections
- [ ] `src/layer/homerow_mods.ahk` exists with complete implementation
- [ ] `doc/HOMEROW_MODS.md` exists with user documentation
- [ ] `doc/TROUBLESHOOTING_HOMEROW.md` exists with troubleshooting

### Code Integration

- [ ] `HybridCapsLock.ahk` includes homerow_mods.ahk
- [ ] `InitHomeRowMods()` called during initialization
- [ ] Config reload function updated (if exists)
- [ ] No syntax errors on load

### Configuration

- [ ] Default `enabled=false` to avoid surprises
- [ ] Threshold matches CapsLock (250ms)
- [ ] All 8 keys have modifier assignments
- [ ] Example exclusions provided

### Testing

- [ ] All manual test cases pass
- [ ] Debug logging works correctly
- [ ] No conflicts with existing hotkeys
- [ ] Performance is acceptable

### Documentation

- [ ] User documentation explains feature clearly
- [ ] Configuration examples provided
- [ ] Troubleshooting covers common issues
- [ ] README.md updated with home row mods mention (optional)

---

## Implementation Notes for AI Assistant

### Key Points to Remember

1. **Copy the pattern from nvim_layer.ahk**
   - The CapsLock implementation is the proven template
   - Use KeyWait() exactly the same way
   - Same state tracking pattern

2. **Don't overthink it**
   - The logic is identical to CapsLock
   - Just replicated for 8 keys instead of 1
   - Configuration makes it flexible

3. **Test incrementally**
   - Implement one key first (just 'a')
   - Verify tap and hold work
   - Then replicate for other 7 keys

4. **Debug logging is critical**
   - Every state change should log
   - Timing information must be visible
   - Use same format as CapsLock logs

5. **Handle edge cases**
   - Multiple home row keys held simultaneously
   - Home row + CapsLock combinations
   - Fast typing (shouldn't trigger mods)
   - Apps where it shouldn't work

### Common Pitfalls to Avoid

❌ Using scancode handlers (they trigger on auto-repeat)
❌ Not marking keys as used when modifier combos happen
❌ Forgetting to reset state after each cycle
❌ Hard-coding modifiers (must be configurable)
❌ Not providing way to disable feature
❌ Missing debug logs for troubleshooting

### Success Criteria

The implementation is successful when:

✅ User can type normally without interference
✅ Holding home row key + other key acts as modifier
✅ Quick taps produce letters
✅ Configuration changes take effect on reload
✅ Debug logs show clear timing and decisions
✅ No conflicts with existing CapsLock system
✅ Performance is imperceptible
✅ Documentation allows users to customize easily

---

## Example Implementation Session

Here's how an AI assistant might approach this:

1. **Create config file first**
   - Start with homerow_mods.ini
   - Use the specification from this document
   - Ensure all sections are present

2. **Implement core logic**
   - Create homerow_mods.ahk
   - Start with initialization function
   - Add one key handler (test with 'a')
   - Verify it works before adding others

3. **Add context detection**
   - Implement IsAnyHomeRowKeyHeld()
   - Add #HotIf context
   - Implement SendWithHomeRowMod()
   - Test with one key combination

4. **Scale to all keys**
   - Replicate for remaining 7 keys
   - Test each one individually
   - Verify no conflicts

5. **Integration**
   - Add includes to main file
   - Call Init function
   - Test full system

6. **Documentation**
   - Write user guide
   - Write troubleshooting guide
   - Add examples

7. **Validation**
   - Run through test checklist
   - Verify with debug logs
   - Test in real usage

---

## Questions for Implementation

If the AI assistant needs clarification, ask:

1. Should permissive_hold be true or false by default?
2. Should any apps be excluded by default?
3. Should home row mods work when NVIM layer is active?
4. Should there be a hotkey to toggle home row mods on/off?
5. Should home row keys work as modifiers for CapsLock combos?

---

## Version History

- v1.0 - Initial implementation guide
- Uses proven KeyWait pattern from CapsLock fix
- Configurable and non-invasive design
- Complete testing and documentation requirements

---

**This document is ready for AI consumption. An AI with repository access should be able to implement the complete Home Row Mods feature using only this specification.**
