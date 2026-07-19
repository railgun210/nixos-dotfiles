# Hyprland Animations

Detailed reference for Hyprland's animation system. This config uses the **hyprlang syntax** (pre-0.55); see the [official wiki](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/) for the latest lua syntax.

## How Animations Work

Every animation entry follows this format:

```
NAME, ENABLED, SPEED, CURVE[, STYLE]
```

| Field | Description |
|-------|-------------|
| `NAME` | Which UI element/transition this controls (see [Animation Tree](#animation-tree) below) |
| `ENABLED` | `1` = on, `0` = off. If `0`, you can omit the remaining fields |
| `SPEED` | Duration in **deciseconds** (ds). `1 ds = 100 ms`. So `5` = 0.5s, `8` = 0.8s |
| `CURVE` | Name of a bezier/spring curve you defined, or `default` |
| `STYLE` | Optional. Varies per animation — see the tree below |

## This Config's Animations

```nix
animations = {
  enabled = true;
  bezier = "easeOutQuint, 0.23, 1, 0.32, 1";
  animation = [
    "windows, 1, 5, easeOutQuint"
    "windowsOut, 1, 5, default, popin 80%"
    "border, 1, 8, default"
    "borderangle, 1, 8, default"
    "fade, 1, 5, default"
    "workspaces, 1, 6, default, slide"
  ];
};
```

### Line-by-line breakdown

| Line | Meaning |
|------|---------|
| `windows, 1, 5, easeOutQuint` | Window open/resize — 0.5s, custom easeOutQuint curve |
| `windowsOut, 1, 5, default, popin 80%` | Window close — 0.5s, default curve, shrinks to 80% while fading |
| `border, 1, 8, default` | Border color transitions (active/inactive) — 0.8s |
| `borderangle, 1, 8, default` | Gradient angle rotation on borders — 0.8s |
| `fade, 1, 5, default` | Opacity fade in/out — 0.5s |
| `workspaces, 1, 6, default, slide` | Workspace switch — 0.6s, sliding style |

## Animation Tree

Animations are hierarchical — if a child is unset, it inherits its parent's values.

```
global
  ↳ windows          styles: slide, popin, gnomed
    ↳ windowsIn      window open
    ↳ windowsOut     window close
    ↳ windowsMove    moving, dragging, resizing
  ↳ layers           styles: slide, popin, fade
    ↳ layersIn       layer open
    ↳ layersOut      layer close
  ↳ fade
    ↳ fadeIn          fade in for window open
    ↳ fadeOut         fade out for window close
    ↳ fadeSwitch      fade on changing activewindow and its opacity
    ↳ fadeShadow      fade on changing activewindow for shadows
    ↳ fadeGlow        fade on changing activewindow for glow
    ↳ fadeDim         easing of dimming inactive windows
    ↳ fadeLayers      fade on layers
      ↳ fadeLayersIn
      ↳ fadeLayersOut
    ↳ fadePopups      fade on Wayland popups
      ↳ fadePopupsIn
      ↳ fadePopupsOut
    ↳ fadeDpms        fade when DPMS is toggled
  ↳ border            border color switch speed
  ↳ borderangle       border gradient angle — styles: once (default), loop
  ↳ shadowangle       shadow gradient angle — styles: once (default), loop
  ↳ glowangle         glow gradient angle — styles: once (default), loop
  ↳ workspaces        styles: slide, slidevert, fade, slidefade, slidefadevert
    ↳ workspacesIn
    ↳ workspacesOut
    ↳ specialWorkspace
      ↳ specialWorkspaceIn
      ↳ specialWorkspaceOut
  ↳ zoomFactor        screen zoom animation
  ↳ monitorAdded      monitor added zoom animation
```

> **Warning:** The `loop` style for `*angle` animations causes Hyprland to constantly render new frames at your monitor's refresh rate. This impacts battery life even if animations are disabled or borders are not visible. ([Source](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/))

## Available Styles per Animation

| Animation | Available Styles |
|-----------|-----------------|
| `windows`, `windowsIn`, `windowsOut`, `windowsMove` | `slide`, `popin`, `gnomed` |
| `layers`, `layersIn`, `layersOut` | `slide`, `popin`, `fade` |
| `borderangle`, `shadowangle`, `glowangle` | `once` (default), `loop` |
| `workspaces`, `workspacesIn`, `workspacesOut`, `specialWorkspace*` | `slide`, `slidevert`, `fade`, `slidefade`, `slidefadevert` |

### Style extras

- **`popin N%`** — for `windows` animations, specifies the starting size percentage. `popin 80%` means the window scales from 80% to 100%.
- **`slide N%`** — for `workspaces` animations, specifies movement percentage. `slide 20%` means windows move 20% of the screen width.
- **`slide left/right/top/bottom`** — for `windows` and `layers`, forces the slide direction.

([Source](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/))

## Curves

### Bezier Curves

A cubic [Bezier curve](https://en.wikipedia.org/wiki/B%C3%A9zier_curve) controls the rate of change over an animation's duration — does it start fast and slow down, ease in and out, overshoot and settle, etc.

```
bezier = NAME, X0, Y0, X1, Y1
```

Two control points `(X0, Y0)` and `(X1, Y1)` shape the curve between fixed start `(0,0)` and end `(1,1)`.

#### How to read a Bezier value

```
bezier = easeOutQuint, 0.23, 1, 0.32, 1
                          ↑   ↑   ↑   ↑
                          X0  Y0  X1  Y1
```

- **(X0, Y0)** = first control point — affects the curve's behavior near the start
- **(X1, Y1)** = second control point — affects the curve's behavior near the end

For `easeOutQuint`: the first point `(0.23, 1)` pulls the curve up quickly (fast start), and the second point `(0.32, 1)` keeps it near the top (slow finish).

#### Common curve patterns

| Pattern | Effect | Example curves |
|---------|--------|---------------|
| Ease-out | Fast start, slow end | `easeOutQuint`, `easeOutCubic`, `easeOutExpo` |
| Ease-in | Slow start, fast end | `easeInQuint`, `easeInCubic` |
| Ease-in-out | Slow start and end | `easeInOutQuint`, `easeInOutExpo` |
| Overshoot | Goes past target, settles back | `easeOutBack` |

#### Using easings.net to find curves

[easings.net](https://easings.net) is a visual catalog of easing functions. To use one in Hyprland:

1. Go to [easings.net](https://easings.net) and click any easing name (e.g. "easeInOutExpo")
2. The page shows the CSS `cubic-bezier(...)` value — those are your four numbers
3. Example: easeInOutExpo = `cubic-bezier(0.87, 0, 0.13, 1)` → Hyprland gets `0.87, 0, 0.13, 1`

```nix
# In your Hyprland config:
bezier = [
  "easeOutQuint, 0.23, 1, 0.32, 1"
  "easeInOutExpo, 0.87, 0, 0.13, 1"
];
animation = [
  "windows, 1, 5, easeInOutExpo"
  "workspaces, 1, 6, easeInOutExpo, slide"
];
```

Note: `bezier` becomes a **list** once you have more than one curve. Each entry is `NAME, X0, Y0, X1, Y1`, then you reference `NAME` in any animation line's curve slot.

#### Designing custom curves

Use [cssportal.com/css-cubic-bezier-generator](https://www.cssportal.com/css-cubic-bezier-generator/) to visually design and preview your own curve, then copy the four control point values.

([Source](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/))

### Spring Curves

Spring curves simulate physical spring physics (like Apple's animations). Defined by mass, stiffness, and dampening:

```lua
hl.curve( NAME, { type = "spring", mass = MASS, stiffness = STIFF, dampening = DAMP })
```

| Parameter | Effect |
|-----------|--------|
| `mass` | Keep at 1 (higher = slower, heavier feel) |
| `stiffness` | Higher = faster animation |
| `dampening` | Higher = less bounce |

Example:
```lua
hl.curve( "rubber", { type = "spring", mass = 1, stiffness = 70, dampening = 10 } )
```

([Source](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/))

## Adding New Animations

### Using the old hyprlang syntax (this config)

```nix
animations = {
  enabled = true;
  bezier = [
    "easeOutQuint, 0.23, 1, 0.32, 1"
    "easeInOutExpo, 0.87, 0, 0.13, 1"
  ];
  animation = [
    "windows, 1, 5, easeOutQuint"
    "windowsOut, 1, 5, default, popin 80%"
    "windowsMove, 1, 5, easeOutQuint"
    "border, 1, 8, default"
    "borderangle, 1, 8, default"
    "fade, 1, 5, default"
    "fadeIn, 1, 5, default"
    "fadeOut, 1, 5, default"
    "fadeSwitch, 1, 5, default"
    "fadeShadow, 1, 5, default"
    "fadeDim, 1, 5, default"
    "workspaces, 1, 6, default, slide"
    "specialWorkspace, 1, 6, default, slidevert"
  ];
};
```

### Using the new lua syntax (Hyprland 0.55+)

```lua
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })

hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, curve = "default", style = "popin 80%" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, curve = "default", style = "slide" })
```

## Runtime Control

Query or change animations at runtime with `hyprctl`:

```bash
# List current animation and bezier info
hyprctl animations

# Toggle animations on/off
hyprctl toggleanimation
```

([Source](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Using-hyprctl/))

## Tips

- **Snappier feel:** Use lower speed values (3-5) with easeOut curves
- **Smoother feel:** Use higher speed values (8-12) with easeInOut curves
- **Bouncy feel:** Use spring curves or `easeOutBack` (which overshoots)
- **Disable a specific animation:** Set `0` as the second field — no need to remove the line
- **Test curves live:** Edit the config and save — Hyprland reloads automatically

## Sources

- [Hyprland Wiki — Animations](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/) (primary reference, verified July 2026)
- [Hyprland Wiki — Using hyprctl](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Using-hyprctl/)
- [easings.net](https://easings.net) — visual easing function catalog
- [cssportal.com Bezier Generator](https://www.cssportal.com/css-cubic-bezier-generator/) — design custom curves
- [Wikipedia — Bezier curve](https://en.wikipedia.org/wiki/B%C3%A9zier_curve) — mathematical background
