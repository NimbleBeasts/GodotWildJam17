extends Node

enum Direction { Top, Left, Right, Down }
enum GameStates {Menu, Game, Settings} 
enum GameMode {Tutorial, DailyChallenge, CustomGame, MpLocalGame, MpJoinGame, MpHostGame}

const TileVframes = 4
const TileHframes = 4
const FactoriesCount = 2
enum Tile { Buildings, Mountains, Forest, Factory, Rail_UD, Rail_LR, Rail_LD, Rail_RD, Rail_UL, Rail_UR, Rail_ULRD, Station_UD, Station_LR, Park, PowerPlant, Repair}
const TileStr = ["Buildings", "Mountains", "Forest", "Factory", "Rail_UD", "Rail_LR", "Rail_LD", "Rail_RD", "Rail_UL", "Rail_UR", "Rail_ULRD", "Station_UD", "Station_LR", "Park", "PowerPlant", "Repair"]
const TileDirs = [[], [], [], [], [Direction.Top, Direction.Down], [Direction.Left, Direction.Right], [Direction.Left, Direction.Down], [Direction.Right, Direction.Down], [Direction.Top, Direction.Left], [Direction.Top, Direction.Right], [Direction.Top, Direction.Down, Direction.Left, Direction.Right], [Direction.Top, Direction.Down], [Direction.Left, Direction.Right], [Direction.Top, Direction.Down, Direction.Left, Direction.Right], [Direction.Top, Direction.Down, Direction.Left, Direction.Right], [Direction.Top, Direction.Down, Direction.Left, Direction.Right]]

const ScoreCoef = {"ConnectionToCities":5, "ConnectionToFactories":3, "Station": 5, "Rail":1, "ParkCityBonus":5, "ParkFactoryBonus":0, "LonelyPark":-5, "PowerPlantCityBonus":3, "PowerPlantFactoryBonus":5, "LonelyPowerPlant":-5, "LonelyStation":-5}
