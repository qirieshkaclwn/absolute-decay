# Absolute Decay

A mod for **Factorio 2.1+ (Space Age)** that adds a decay mechanic for all items in the game. Instead of simply turning into useless spoilage, items degrade back down their crafting chain.

## Features

1. **Degradation Chain (Spoiling into Ingredients)**:
   Every crafted item spoils over time into its most expensive solid ingredient (based on recipe cost).
   *Examples:*
   * Processing unit (blue) $\rightarrow$ Advanced circuit (red)
   * Advanced circuit (red) $\rightarrow$ Electronic circuit (green)
   * Electronic circuit (green) $\rightarrow$ Iron plate
   * Iron plate $\rightarrow$ Iron ore

2. **Resource Decay**:
   Basic resources with no crafting recipes (e.g., ores, coal, stone, wood) decay into standard `spoilage`.

3. **GUI Protection**:
   Blueprints, blueprint books, deconstruction/upgrade planners, and copy-paste tools are protected from decay to prevent breaking game interfaces.

4. **Time Configuration**:
   You can configure the lifetime of items before they spoil in the mod's startup settings. The default is **30 minutes** (108,000 ticks).

## Configuration

1. You can change the base spoilage time in the menu:
   `Settings` $\rightarrow$ `Mod settings` $\rightarrow$ `Startup` $\rightarrow$ `Spoilage Time (in ticks)`.
