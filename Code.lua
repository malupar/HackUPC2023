
local target = nil
local cooldowns = {0, 0, 0}
local players_id = {}
--#define BASE_PLAYER_SPEED 20
--#define TICK_TIME 0.033f
--#define GAME_LENGTH 60 * 2
--#define MELEE_RANGE 2.f
--#define MELEE_DAMAGE 20.f
--#define MELEE_COOLDOWN 50
--Precomputar posiciones de jugadores visibles
function bot_init(me)
end
function bot_main(me)
    local me_pos = me:pos()
    for i = 1, 3 do
        if cooldowns[i] > 0 then
            cooldowns[i] = cooldowns[i] - 1
        end
    end
    local closest_enemy = nil
    local min_distance = math.huge
    local danger = false
    local dir_bullet = vec.new(0, 0)
    for _, p in ipairs(me:visible()) do
        if p:type() == "player" then
            local dist = vec.distance(me_pos, p:pos())

            if dist < min_distance then
                min_distance = dist
                closest_enemy = p
            end
        else
            local dist = vec.distance(me_pos, p:pos())
            if dist <= 16 and dist >= 4 then
                danger = true
                dir_bullet = me_pos:sub(p:pos())
                dir_bullet = vec.new(dir_bullet:y(), -dir_bullet:x())
            end
        end
    end
    local death = true
    if me:cod():x() == -1 then
        death = false
    end
    local target = closest_enemy
    local direction = vec.new(0, 0)
    if danger then
        direction = dir_bullet
    elseif death then
        local pos_center = vec.new(me:cod():x(), me:cod():y())
        direction = pos_center:sub(me_pos)
        if (cooldowns[2] == 0) then
            cooldowns[2] = 25
            me:cast(2, direction)
            direction = 0
        end
    elseif target then
        direction = target:pos():sub(me_pos)
        direction = vec.new(direction:y(), -direction:x())
        local direction2 = vec.new(-direction:y(), direction:x())
        local pos1 = me_pos:add(direction)
        local pos2 = me_pos:add(direction2)
        local mid = vec.new(250, 250)
        pos1 = vec.distance(pos1, mid)
        pos2 = vec.distance(pos2, mid)
        if (pos1:x() + pos1:y() > pos2:x() + pos2:y()) then
            direction = direction2
        end
        if cooldowns[1] == 0 then
            me:cast(1, direction)
            cooldowns[1] = 3
            --Bullet
        end
    else 
        local mid = vec.new(250, 250)
        direction = me_pos:sub(mid)
    end
    me:move(direction)
end