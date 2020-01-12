# NbKickstarter
Kickstart Project


## About
This is a simple kickstarter project for NimbleBeasts projects. It comes with some standard features and little helpers as well as a some stuff, no one has time for in a game jam.

## Structure

- assets -> All the resources needed
  - art -> All the art stuff
  - fonts -> Fonts
  - sounds -> Obviously sounds :D

- src -> Scenes and Sources
  - autoloads -> Singletons: types -> global -> debug
  - Levels -> (Can be removed if static level)
  - Menu -> Menu Scene and Code

## Game Manager
The idea is to get rid of most get_parent() cascade and introduce a game manager which holds most of the stuff. The game manager is accessible by the global singleton, e.g:
Global.gm.loadLevel(0)
or
Global.getGameManager().loadLevel(0)

## Starting Point
By default src/Levels/Level0.tscn is added to the gameViewport and serves as a first starting point.
Tipp: Hide the BootSplash node in the GameManager scene for faster loading :)


