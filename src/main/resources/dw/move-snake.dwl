%dw 2.0
import some, indexOf from dw::core::Arrays
import isNumeric from dw::core::Strings
output application/json

var body = payload.you.body
var board = payload.board
var head = body[0] // First body part is always head
var neck = body[1]
var snakes = payload.board.snakes //array of arrays of (x,y) objects
var food = payload.board.food

var moves = ["up", "down", "left", "right"]

fun wallHere(x,y) = x > board.width - 1 or x < 0 or y > board.height - 1 or y < 0

fun snakePartHere(x,y) = snakes some (snake) -> (snake.body some (segment) -> (segment.x == x and segment.y == y))

fun locationAvailable(x, y) = (not snakePartHere(x,y)) and (not wallHere(x,y))

var xdist = food map (disc) -> head.x - disc.x
var xAbsDist = xdist map (value) -> abs(value)
var xMin = min(xAbsDist) default 0
var xFindIndex = indexOf(xAbsDist, xMin)
var closestHorizontal = xdist[xFindIndex]

var ydist = food map (disc) -> head.y - disc.y
var yAbsDist = ydist map (value) -> abs(value)
var yMin = min(yAbsDist) default 0
var yFindIndex = indexOf(yAbsDist, yMin)
var closestVertical = ydist[yFindIndex]

var checkedPositions = {
	"left": locationAvailable(head.x - 1, head.y),
	"right": locationAvailable(head.x + 1, head.y),
	"up": locationAvailable(head.x, head.y + 1),
	"down": locationAvailable(head.x, head.y - 1)
}

var preferredMoves = {
	"left": if(typeOf(closestHorizontal) == Number)
            	isNumeric(closestHorizontal as String) and closestHorizontal != 0
        	else
            	false,
	"right": if(typeOf(closestHorizontal) == Number)
                (not isNumeric(closestHorizontal as String)) and closestHorizontal != 0
            else
                false,
	"up": if(typeOf(closestVertical) == Number)
                (not isNumeric(closestVertical as String)) and closestVertical != 0
          else
               false,
	"down": if(typeOf(closestVertical) == Number)
                isNumeric(closestVertical as String) and closestVertical != 0
            else
                false
}

fun calcLastMove(pt1,pt2) =
	if(pt1.x > pt2.x)
		"right"
	else if (pt1.x < pt2.x)
		"left"
	else if (pt1.y > pt2.y)
		"up"
	else
		"down"
		
var lastMove = calcLastMove(head,neck)

var safeMoves = moves filter (move) -> checkedPositions[move]
var safePreferred = safeMoves filter (move) -> preferredMoves[move]


var nextMove = 
	if ((isEmpty(safePreferred)) and (safeMoves contains lastMove))
		lastMove
	else if (isEmpty(safePreferred))
		safeMoves[randomInt(sizeOf(safeMoves))]
	else
		safePreferred[randomInt(sizeOf(safePreferred))]

---
{
	move: nextMove,
	shout: "Moving $(nextMove)"
}
// checkedPositions