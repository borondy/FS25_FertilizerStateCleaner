# FS25 Fertilizer State Cleaner

Farming Simulator 25 mod. Adds an admin console command that clears the fertilizer state (ground layer) of a field. This lets players spread fertilizer on the same field again, with different products.

## What it does

With a console command, the mod cleans the fertilizer state/layer of the specified field, or of the field the player is standing on.

- Only the fertilizer value is removed. Other spray types (manure, lime, ...) stay untouched.
- Field data such as row orientation is not changed.
- In multiplayer, only admins can run the command. The change is applied on the server.

## Command

Open the developer console and run:

```
clearFertilizerState [fieldId]
```

Clear fertilizer on field 12:

```
clearFertilizerState 12
```

Clear fertilizer on the field the player is standing on:

```
clearFertilizerState
```

## Why this mod exists

- We ran a fairly realistic multiplayer server where fields get fertilized with multiple passes of fertilizer. Because the fertilizer state was already painted, we needed a way to clear this layer so fertilizer could be spread again.
- The [Easy Development Controls](https://www.farming-simulator.com/mod.php?mod_id=324487&title=fs2025) mod by GtX can achieve the same result, but it updates multiple field properties, for example row orientation.
- RowCropSystem is used in our game, so row orientation must not be lost.
- If a crop was planted with fertilization at the same time, spreading fertilizer on the field was impossible.
