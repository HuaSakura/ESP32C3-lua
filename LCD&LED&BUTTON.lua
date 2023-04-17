
-- LuaTools需要PROJECT和VERSION这两个信息
PROJECT = "gpio2demo"
VERSION = "1.0.0"

log.info("main", PROJECT, VERSION)

-- sys库是标配
_G.sys = require("sys")

if wdt then
    --添加硬狗防止程序卡死，在支持的设备上启用这个功能
    wdt.init(9000)--初始化watchdog设置为9s
    sys.timerLoopStart(wdt.feed, 3000)--3s喂一次狗
end

local spi_id,pin_reset,pin_dc,pin_cs,bl = 2,10,6,7,11

spi_lcd = spi.deviceSetup(spi_id,pin_cs,0,0,8,20*1000*1000,spi.MSB,1,0)

lcd.init("st7735v",{port = "device",pin_dc = pin_dc, pin_pwr = bl, pin_rst = pin_reset,direction = 1,w = 160,h = 82,xoffset = 0,yoffset = 24},spi_lcd)

-- 如果显示颜色相反，请解开下面一行的注释，关闭反色
-- lcd.invoff()

sys.taskInit(function()
    sys.wait(1000)
    wlan.init()
    wlan.connect('Sakura-2.4G','cyyc5918')

    while not wlan.ready() do
        local ret, ip = sys.waitUntil("IP_READY", 30000)
        if ip then
            _G.wlan_ip = ip
            lcd.clear()
            lcd.setFont(lcd.font_opposansm12_chinese)
            lcd.drawStr(10,45,wlan.getIP())
        end
    end

    -- while 1 do
    --     lcd.clear()

    --     if lcd.showImage then
    --         -- lcd.showImage(0,0,"/luadb/logo.jpg")
    --         lcd.setFont(lcd.font_opposansm12_chinese)
    --         lcd.drawStr(10,25,'IP:'..wlan.getIP())
    --         lcd.drawStr(10,45,wlan.getMac())
    --         sys.wait(10000)
    --     end
    --     sys.wait(100)
    -- end
end)


local gpio_up = 9
local gpio_dw = 5
local gpio_lf = 8
local gpio_rg = 13

local P1,P2 = 12, 13
local LEDA = gpio.setup(P1, 0, gpio.PULLUP)
local LEDB = gpio.setup(P2, 0, gpio.PULLUP)

local led_valueA = 1

gpio.debounce(gpio_up, 100)
gpio.setup(gpio_up, function()
    if led_valueA == 1 then
        LEDA(led_valueA)
        LEDB(led_valueA)
        led_valueA = 0
    end
end, gpio.PULLUP)

gpio.debounce(gpio_dw, 100)
gpio.setup(gpio_dw, function()
    if led_valueA == 0 then
        LEDA(led_valueA)
        LEDB(led_valueA)
        led_valueA = 1
    end
end, gpio.PULLUP)

sys.run()
-- sys.run()之后后面不要加任何语句!!!!!
