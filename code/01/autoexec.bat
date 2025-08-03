:: ------------------------------------------------------------------------------
:: AUTOEXEC.BAT — Автоматическая конфигурация и запуск Windows 3.11
:: Автор: hypo69
:: Год: примерно 1993
:: Назначение: Выполняет инициализацию DOS-среды, загрузку сетевых драйверов и запуск Windows 3.11
:: ------------------------------------------------------------------------------

:: ------------------------------------------------------------------------------
:: ЛИЦЕНЗИЯ (MIT)
:: ------------------------------------------------------------------------------
:: Copyright (c) 1993 hypo69
::
:: Permission is hereby granted, free of charge, to any person obtaining a copy
:: of this software and associated documentation files (the "Software"), to deal
:: in the Software without restriction, including without limitation the rights
:: to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
:: copies of the Software, and to permit persons to whom the Software is
:: furnished to do so, subject to the following conditions:
::
:: The above copyright notice and this permission notice shall be included in all
:: copies or substantial portions of the Software.
::
:: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
:: IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
:: FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
:: AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
:: LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
:: OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
:: SOFTWARE.
:: ------------------------------------------------------------------------------

@ECHO OFF

:: Настройка приглашения командной строки
PROMPT $p$g

:: Установка переменных среды
SET TEMP=C:\TEMP
PATH=C:\DOS;C:\WINDOWS

:: Загрузка драйверов и утилит в верхнюю память
LH C:\DOS\SMARTDRV.EXE       :: Дисковый кэш
LH C:\DOS\MOUSE.COM          :: Драйвер мыши

:: Загрузка сетевых служб (актуально для Windows for Workgroups 3.11)
IF EXIST C:\NET\NET.EXE LH C:\NET\NET START

:: Автоматический запуск Windows
WIN