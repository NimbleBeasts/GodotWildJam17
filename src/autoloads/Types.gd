extends Node

enum Direction { Top, Right, Down, Left }
enum GameStates {Menu, Game, Settings} 

const TileVframes = 4
const TileHframes = 4
const ObstaclesCount = 3
enum Tile { Buildings,Mountains,Forest,Factory,Rail_UD,Rail_LR,Rail_LD,Rail_RD,Rail_UL,Rail_UR,Rail_ULRD,Station_UD,Station_LR,Park,Generator,Repair}