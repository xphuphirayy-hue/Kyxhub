--========================
-- DECODE KEY
--========================
local function decodeKey()
    local b64 = getgenv().Key
    local seed = getgenv().KeySeed

    if not b64 or not seed then return nil end

    local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local decoded = {}
    local i = 1
    b64 = b64:gsub("[^"..b64chars.."=]","")
    while i <= #b64 do
        local c1,c2,c3,c4 = b64:sub(i,i),b64:sub(i+1,i+1),b64:sub(i+2,i+2),b64:sub(i+3,i+3)
        local n1 = b64chars:find(c1,1,true)-1
        local n2 = b64chars:find(c2,1,true)-1
        local n3 = c3=="=" and 0 or (b64chars:find(c3,1,true)-1)
        local n4 = c4=="=" and 0 or (b64chars:find(c4,1,true)-1)
        local bits = n1*262144 + n2*4096 + n3*64 + n4
        table.insert(decoded, math.floor(bits/65536))
        if c3~="=" then table.insert(decoded, math.floor(bits/256)%256) end
        if c4~="=" then table.insert(decoded, bits%256) end
        i = i + 4
    end

    local raw = {}
    for idx, byte in ipairs(decoded) do
        table.insert(raw, string.char(bit32.bxor(byte, (seed + idx - 1) % 256)))
    end
    return table.concat(raw)
end

--========================
-- PARSE DATE  dd/mm/yyyy/HH.MM
--========================
local function parseDate(s)
    local d,mo,y,h,mi = s:match("(%d+)/(%d+)/(%d+)/(%d+)%.(%d+)")
    if not d then return nil end
    return {day=tonumber(d),month=tonumber(mo),year=tonumber(y),hour=tonumber(h),min=tonumber(mi)}
end

local function toSeconds(t)
    return t.year*365*24*3600 + t.month*30*24*3600 + t.day*24*3600 + t.hour*3600 + t.min*60
end

--========================
-- CHECK KEY EXPIRY
--========================
local function checkKey()
    local raw = decodeKey()
    if not raw then
        return false, "❌ ไม่พบ Key กรุณา Get Script ใหม่"
    end

    local parts = {}
    for p in raw:gmatch("[^|]+") do table.insert(parts,p) end

    if #parts < 2 then
        return false, "❌ Key ผิดพลาด"
    end

    local endDate = parseDate(parts[2])
    if not endDate then
        return false, "❌ Key ผิดพลาด"
    end

    local now = os.date("*t")
    local diff = toSeconds(endDate) - toSeconds(now)

    if diff <= 0 then
        return false, "❌ Key หมดอายุแล้ว"
    end

    local days  = math.floor(diff / 86400)
    local hours = math.floor((diff % 86400) / 3600)
    local mins  = math.floor((diff % 3600) / 60)

    return true, string.format("✅ Key ถูกต้อง | เหลือ %d วัน %d ชั่วโมง %d นาที", days, hours, mins)
end

--========================
-- KICK ถ้า KEY ผิด/หมดอายุ
--========================
local valid, msg = checkKey()

if not valid then
    player:Kick(msg)
    return
end
loadstring(game:HttpGet("https://raw.githubusercontent.com/xphuphirayy-hue/Kyxhub/refs/heads/main/BF/main.lua"))()
loadstring(game:HttpGet('https://raw.githubusercontent.com/xphuphirayy-hue/tast/refs/heads/main/FAS'))()
