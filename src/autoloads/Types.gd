extends Node

enum Direction { Top, Left, Right, Down }
enum GameStates {Menu, Game, Settings} 

const TileVframes = 4
const TileHframes = 4
const ObstaclesCount = 3
enum Tile { Buildings, Mountains, Forest, Factory, Rail_UD, Rail_LR, Rail_LD, Rail_RD, Rail_UL, Rail_UR, Rail_ULRD, Station_UD, Station_LR, Park, Generator, Repair}
const TileStr = ["Buildings", "Mountains", "Forest", "Factory", "Rail_UD", "Rail_LR", "Rail_LD", "Rail_RD", "Rail_UL", "Rail_UR", "Rail_ULRD", "Station_UD", "Station_LR", "Park", "Generator", "Repair"]
const TileDirs = [[], [], [], [], [Direction.Top, Direction.Down], [Direction.Left, Direction.Right], [Direction.Left, Direction.Down], [Direction.Right, Direction.Down], [Direction.Top, Direction.Left], [Direction.Top, Direction.Right], [Direction.Top, Direction.Down, Direction.Left, Direction.Right], [Direction.Top, Direction.Down], [Direction.Left, Direction.Right], [Direction.Top, Direction.Down, Direction.Left, Direction.Right], [Direction.Top, Direction.Down, Direction.Left, Direction.Right], [Direction.Top, Direction.Down, Direction.Left, Direction.Right]]