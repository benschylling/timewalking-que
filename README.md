# TimewalkQue

A World of Warcraft addon that automatically selects "Random Timewalking Dungeon" in the Dungeon Finder when the weekly timewalking event is active.

## Features

- Automatically detects when timewalking events are active
- Changes the Dungeon Finder selection from "Random Heroic" to "Random Timewalking Dungeon" when opening the LFD frame
- Supports multiple locales (English, Simplified Chinese, Traditional Chinese)
- Lightweight and efficient

## Installation

1. Copy the `TimewalkQue` folder to your World of Warcraft `Interface/AddOns` directory
2. Restart the game or reload the UI
3. The addon will automatically load and work in the background

## Usage

No configuration required. The addon will:

1. Detect when timewalking events are active
2. Automatically select the timewalking dungeon option when you open the Dungeon Finder
3. Display status messages in your chat window

## Compatibility

- Works with World of Warcraft: Retail (Patch 10.0+)
- Compatible with other LFG-related addons
- Supports multiple client locales

## Files

- `TimewalkQue.toc` - Addon configuration file
- `TimewalkQue.lua` - Main addon logic
- `localization.lua` - Localization support
- `TimewalkQue.xml` - XML configuration