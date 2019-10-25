# Lua-ANSI-Snake
Terminal Snake game written in Lua, requires the lcurses library, an ANSI compliant terminal and luasocket.

> The game should work under Linux and macOS, but not on Windows, instead run it under WSL (Windows Subsystem Linux).

## Installation

To run the game you need to have `luasocket` and `lcurses` installed first.

You can do so using luarocks:

```
sudo luarocks install luasocket
sudo luarocks install lcurses
```

In-case `lcurses` fails to install, you might have to install the `libncurses5-dev` package, which could be installed under ubuntu using:

```
sudo apt install libncurses5-dev
```

Once that done, download `snake.lua` and run it using lua or luajit:

```
luajit snake.lua
```

## Screenshots

![Gif_01](https://github.com/RamiLego4Game/Lua-ANSI-Snake/raw/master/Media/Gif_01.gif)
![Screenshot_01](https://github.com/RamiLego4Game/Lua-ANSI-Snake/raw/master/Media/Screenshot_01.png)
![Screenshot_02](https://github.com/RamiLego4Game/Lua-ANSI-Snake/raw/master/Media/Screenshot_02.png)
![Screenshot_03](https://github.com/RamiLego4Game/Lua-ANSI-Snake/raw/master/Media/Screenshot_03.png)
![Screenshot_04](https://github.com/RamiLego4Game/Lua-ANSI-Snake/raw/master/Media/Screenshot_04.png)

## License

```
MIT License

Copyright (c) 2019 Rami Sabbagh

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

```