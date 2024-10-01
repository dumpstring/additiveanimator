# AdditiveAnimator

by dumpstring

## Overview

`AdditiveAnimator` is a utility class designed for handling additive animations on Roblox characters.

## Features

### Animation Management

The `AdditiveAnimator` provides methods to load animations, retrieve tracks, and manage additive animation blending. You are responsible for handling the replication of animations between clients and servers.

- **Additive Animation**: Animations are blended on top of existing animations for smoother transitions and custom movements.
- **Helper Rig**: A rig is created for each animation that mimics the character's joints and parts, used to apply additive transformations.

## Installation

To use the `AdditiveAnimator` class, require the module within your script as follows:

```lua
local AdditiveAnimator = require(path.to.AdditiveAnimator)
```

## Usage

### Creating an AdditiveAnimator Instance

You can create an instance of `AdditiveAnimator` by passing the character or actor model:

```lua
local myAdditiveAnimator = AdditiveAnimator.new(character)
```

### Loading an Animation

To load an animation into the `AdditiveAnimator`, use the `LoadAnimation` method:

```lua
local animationTrack = myAdditiveAnimator:LoadAnimation(animation)
```

This method attaches the animation to the helper rig and returns the `AnimationTrack` for further control.

### Getting All Animation Tracks

You can retrieve all loaded animation tracks (whether they are playing or not) using:

```lua
local tracks = myAdditiveAnimator:GetAllTracks()
```

### Getting Currently Playing Animation Tracks

To get only the tracks that are currently playing, use:

```lua
local playingTracks = myAdditiveAnimator:GetPlayingTracks()
```

## Methods

### `GetAllTracks() -> {AnimationTrack}`

- **Description**: Returns a table containing all animation tracks loaded in the `AdditiveAnimator`, regardless of their playback state.

### `GetPlayingTracks() -> {AnimationTrack}`

- **Description**: Returns a table containing only the animation tracks that are currently playing.

### `LoadAnimation(Animation: Animation) -> AnimationTrack`

- **Description**: Loads a new animation into the `AdditiveAnimator` system, creating a helper rig to handle additive blending.
- **Parameters**:
  - `Animation`: The animation object to load.
- **Returns**: The corresponding `AnimationTrack`.

## Example

Below is an example showcasing the use of the `AdditiveAnimator`:

```lua
local AdditiveAnimator = require(path.to.AdditiveAnimator)

local character = game.Players.LocalPlayer.Character
local myAdditiveAnimator = AdditiveAnimator.new(character)

local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://123456789"
local track = myAdditiveAnimator:LoadAnimation(animation)

track:Play()
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
