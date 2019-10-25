--ANSI Snake game in Lua
--By RamiLego4Game (Rami Sabbagh)

--== ANSI Interface ==--

--Reference: http://ascii-table.com/ansi-escape-sequences.php

local ANSI = {}

do
    --Set the cursor position
    --[[Moves the cursor to the specified position (coordinates).
    If you do not specify a position, the cursor moves to the home position at the upper-left
    corner of the screen (line 0, column 0). This escape sequence works the same way as the
    following Cursor Position escape sequence.]]
    local fCursorPosition = "\27[%d;%dH"
    function ANSI.setCursorPosition(x, y)
        io.write(string.format(fCursorPosition, y, x))
    end

    --Move the cursor up
    --[[Moves the cursor up by the specified number of lines without changing columns. If the
    cursor is already on the top line, ANSI.SYS ignores this sequence.]]
    local fCursorUp = "\27[%dA"
    function ANSI.moveCursorUp(amount)
        io.write(string.format(fCursorUp, amount or 1))
    end

    --Move the cursor down
    --[[Moves the cursor down by the specified number of lines without changing columns. If the
    cursor is already on the bottom line, ANSI.SYS ignores this sequence.]]
    local fCursorDown = "\27[%dB"
    function ANSI.moveCursorDown(amount)
        io.write(string.format(fCursorDown, amount or 1))
    end
    
    --Move the cursor forward
    --[[Moves the cursor forward by the specified number of columns without changing lines. If
    the cursor is already in the rightmost column, ANSI.SYS ignores this sequence.]]
    local fCursorForward = "\27[%dC"
    function ANSI.moveCursorForward(amount)
        io.write(string.format(fCursorForward, amount or 1))
    end
    
    --Move the cursor backward
    --[[Moves the cursor back by the specified number of columns without changing lines. If the
    cursor is already in the leftmost column, ANSI.SYS ignores this sequence.]]
    local fCursorBackward = "\27[%dD"
    function ANSI.moveCursorBackward(amount)
        io.write(string.format(fCursorBackward, amount or 1))
    end

    --Save the cursor position
    --[[Saves the current cursor position. You can move the cursor to the saved cursor position
    by using the Restore Cursor Position sequence.]]
    function ANSI.saveCursorPosition() io.write("\27[s") end

    --Restore the cursor position
    --[[Returns the cursor to the position stored by the Save Cursor Position sequence.]]
    function ANSI.restoreCursorPosition() io.write("\27[u") end

    --Erase display
    --[[Clears the screen and moves the cursor to the home position (line 0, column 0).]]
    function ANSI.eraseDisplay() io.write("\27[2J") end

    --Erase line
    --[[Clears all characters from the cursor position to the end of the line (including the
    character at the cursor position).]]
    function ANSI.eraseLine() io.write("\27[K") end

    --Sets the graphics mode
    --[[Calls the graphics functions specified by the following values. These specified functions
    remain active until the next occurrence of this escape sequence. Graphics mode changes
    the colors and attributes of text (such as bold and underline) displayed on the screen.]]
    --[[
        Text attributes
        0	All attributes off
        1	Bold on
        4	Underscore (on monochrome display adapter only)
        5	Blink on
        7	Reverse video on
        8	Concealed on
        
        Foreground colors
        30	Black
        31	Red
        32	Green
        33	Yellow
        34	Blue
        35	Magenta
        36	Cyan
        37	White
        
        Background colors
        40	Black
        41	Red
        42	Green
        43	Yellow
        44	Blue
        45	Magenta
        46	Cyan
        47	White 
    ]]
    local fSetGraphicsMode = "\27[%sm"
    function ANSI.setGraphicsMode(...)
        local modes = {...}
        for k,v in pairs(modes) do modes[k] = tostring(v) end
        io.write(string.format(fSetGraphicsMode, table.concat(modes, ";")))
    end

    --Set mode
    --[[Changes the screen width or type to the mode specified by one of the following values:]]
    --[[
        Screen resolution
        0	40 x 25 monochrome (text)
        1	40 x 25 color (text)
        2	80 x 25 monochrome (text)
        3	80 x 25 color (text)
        4	320 x 200 4-color (graphics)
        5	320 x 200 monochrome (graphics)
        6	640 x 200 monochrome (graphics)
        7	Enables line wrapping
        13	320 x 200 color (graphics)
        14	640 x 200 color (16-color graphics)
        15	640 x 350 monochrome (2-color graphics)
        16	640 x 350 color (16-color graphics)
        17	640 x 480 monochrome (2-color graphics)
        18	640 x 480 color (16-color graphics)
        19	320 x 200 color (256-color graphics) 
    ]]
    local fSetMode = "\27[=%dh"
    function ANSI.setMode(mode)
        io.write(string.format(fSetMode, mode))
    end

    --Reset mode
    --[[Resets the mode by using the same values that Set Mode uses, except for 7, which
    disables line wrapping]]
    local fResetMode = "\27[=%dl"
    function ANSI.resetMode(mode)
        io.write(string.format(fResetMode, mode))
    end

    --Set keyboard strings
    --[[Redefines a keyboard key to a specified string.]]
    local fSetKeyboardStrings = "\27[%sm"
    function ANSI.setKeybaordStrings(...)
        local keys = {...}
        for k,v in pairs(keys) do keys[k] = tostring(v) end
        io.write(string.format(fSetKeyboardStrings, table.concat(keys, ";")))
    end
end

--== Load external libraries ==--

local curses = require("curses")
local sleep = require("socket").sleep

--== Snake Game ==--

local Window = curses.initscr()

local TWidth, THeight = curses.cols(), curses.lines()
local MWidth, MHeight = TWidth, THeight-1

local TickTime = 0.05 --The time between each movement tick
local HorizentalTick = TickTime --Tick time when moving horizentally
local VerticalTick = HorizentalTick*2 --Tick time when moving vertically
local StartTime = os.time() --The time when the game started

local SnakePieces = {} --A table containing sub-tables which are the coordinations of each snake piece
local SnakeDirection = 1 --0: Up, 1: Right, 2: Down, 3: Left

local InitialFruits = 6 --The count of fruits to spawn at start
local Fruits = {} --A table containing sub-tables which are the coordinates and the id of each fruit.
local AvailableFruits = {
    {"*", 32, 41}, --Apple, Green FG, Red BG
    {"'", 30, 43}, --Banana
    {"*", 32, 45} --Eggplant
}

local Dead = false --If the snake is dead or not

local function DirectionToVector(direction)
    if direction == 0 then return 0, -1
    elseif direction == 1 then return 1, 0
    elseif direction == 2 then return 0, 1
    elseif direction == 3 then return -1, 0
    else return 0,0 end
end

--Draw terminal background
local function DrawBackground()
    ANSI.setCursorPosition(1, 1)
    ANSI.setGraphicsMode(0, 1, Dead and 31 or 30, 40)

    local lineString = string.rep(".", MWidth)

    for y=1, MHeight do
        ANSI.setCursorPosition(0, y)
        io.write(lineString)
    end
end

--Draw the snake
local function DrawSnake()
    ANSI.setGraphicsMode(0, 1, 42)

    for k, piece in pairs(SnakePieces) do
        ANSI.setCursorPosition(piece[1], piece[2])
        io.write(" ")
    end
end

--Draw the fruits
local function DrawFruits()
    for id, Fruit in pairs(Fruits) do
        ANSI.setCursorPosition(Fruit[1], Fruit[2])
        local fType = Fruit[3]
        local fInfo = AvailableFruits[fType]
        ANSI.setGraphicsMode(1, fInfo[2], fInfo[3])
        io.write(fInfo[1])
    end
end

--Draw the info bar
local function DrawInfoBar()
    ANSI.setGraphicsMode(0, 1, 33, 40)
    ANSI.setCursorPosition(1, MHeight+1)
    io.write("Length: ")
    ANSI.setGraphicsMode(37)
    io.write(#SnakePieces)

    local time = tostring(math.floor((Dead or os.time()) - StartTime)).."s"
    local timestr = "Time: "
    ANSI.setCursorPosition(MWidth - (#timestr + #time), MHeight+1)
    ANSI.setGraphicsMode(33)
    io.write(timestr)
    ANSI.setGraphicsMode(37)
    io.write(time)
end

--Draw GameOver
local function DrawGameOver()
    if not Dead then return end

    local GameOver = {
    "                 ",
    "  #-----------#  ",
    "  | GAME OVER |  ",
    "  #-----------#  ",
    "                 "}

    ANSI.setGraphicsMode(0, 1, 31, 40)
    ANSI.setCursorPosition(math.floor((TWidth-string.len(GameOver[1]))/2), math.floor((THeight-#GameOver)/2))
    for k, line in ipairs(GameOver) do
        ANSI.saveCursorPosition()
        io.write(line)
        ANSI.restoreCursorPosition()
        ANSI.moveCursorDown(1)
    end
end

--Render the game
local function RenderGame()
    ANSI.setGraphicsMode(0, 37, 40)
    ANSI.eraseDisplay()
    DrawBackground()
    DrawSnake()
    DrawFruits()
    DrawInfoBar()
    DrawGameOver()
    io.flush()
end

--Spawn a new fruit
local function NewFruit()
    while true do
        local FruitX, FruitY = math.random(1, MWidth), math.random(1, MHeight)

        local continue = true

        --Check if any fruit exists at this location
        for id, Fruit in pairs(Fruits) do
            if Fruit[1] == FruitX and Fruit[2] == FruitY then
                continue = false
                break
            end
        end

        if continue then
            --Check if any snake piece exists at this location
            for id, Piece in pairs(SnakePieces) do
                if Piece[1] == FruitX and Piece[2] == FruitY then
                    continue = false
                    break
                end
            end
        end

        if continue then
            --Spawn the new fruit
            Fruits[#Fruits + 1] = {FruitX, FruitY, math.random(1, #AvailableFruits)}
            break
        end
    end
end

--Move the snake
local function MoveSnake()
    local mx, my = DirectionToVector(SnakeDirection)

    local HeadX, HeadY = SnakePieces[1][1], SnakePieces[1][2]
    HeadX, HeadY = (HeadX + mx -1)%MWidth +1, (HeadY + my-1)%MHeight +1

    local keepTail = false
    --Check if the new head location hits a fruit
    for id, Fruit in pairs(Fruits) do
        if HeadX == Fruit[1] and HeadY == Fruit[2] then
            keepTail = true --Make the snake longer
            table.remove(Fruits, id) --Remove the eaten fruit
            break
        end
    end

    table.insert(SnakePieces, 1, {HeadX, HeadY})
    if not keepTail then SnakePieces[#SnakePieces] = nil else
        NewFruit() --Spawn a new fruit
    end

    --Check if the new head location hits a snake piece
    for i=2, #SnakePieces do
        local PieceX, PieceY = SnakePieces[i][1], SnakePieces[i][2]
        if HeadX == PieceX and HeadY == PieceY then
            Dead = os.time()
            break
        end
    end
end

--Check if there's any input
local function CheckInput()
    while true do
        local input = Window:getch()
        if not input then break end --No more input queue

        if input == 27 then --Escape sequence
            if Window:getch() == 91 then --[
                local char = Window:getch()
                if char and char <= 255 then
                    char = string.char(char)

                    if char == "A" and SnakeDirection ~= 2 then --Up
                        SnakeDirection = 0
                        break
                    elseif char == "B" and SnakeDirection ~= 0 then --Down
                        SnakeDirection = 2
                        break
                    elseif char == "C" and SnakeDirection ~= 3 then --Right
                        SnakeDirection = 1
                        break
                    elseif char == "D" and SnakeDirection ~= 1 then --Left
                        SnakeDirection = 3
                        break
                    end
                end
            end
        end
    end
end

--Run the main game loop
local function RunGame()
    --Set the random seed
    math.randomseed(os.time())
    --Setup the terminal
    ANSI.setCursorPosition(0, 0)
    curses.curs_set(0) --Make the cursor invisible
    curses.cbreak(true)
    curses.echo(false)
    assert(Window:nodelay(true), "Failed to make getch non-blocking")

    --Set the starting snake pieces
    local HeadX, HeadY = math.floor(TWidth/2), math.floor(THeight/2)
    SnakePieces[1] = {HeadX, HeadY}
    SnakePieces[2] = {HeadX-1, HeadY}
    SnakePieces[3] = {HeadX-2, HeadY}
    SnakePieces[4] = {HeadX-3, HeadY}
    SnakePieces[5] = {HeadX-4, HeadY}

    --Spawn starting fruits
    for i=1, InitialFruits do NewFruit() end

    while true do
        CheckInput()
        if not Dead then MoveSnake() end
        RenderGame()

        sleep((SnakeDirection == 0 or SnakeDirection == 2) and VerticalTick or HorizentalTick)
    end

    --Termination
    ANSI.setCursorPosition(0, THeight+1)
end

--== Run the game ==--

RunGame()

--Reset graphics mode
ANSI.setGraphicsMode(0, 37)
