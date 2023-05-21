-- This program is used to demonstrate
-- the non-regressive noise smoothing
-- algorithm by Ian Betz: https://www.desmos.com/calculator/iwykl7r4in

-- duely note: this script has NOT been optimized

-- globals
_G["_SW"] = love.graphics.getWidth();
_G["_SH"] = love.graphics.getHeight();
_G["_E"]  = 2.71828
love.window.setTitle("noise smoothing algorithm");

-- generate a point structure
function point(x, y)
    return {
        x, y,
        x = x,
        y = y
    };
end

local noise  = { point(0, _SH / 2) };
local smoothing_factor = 0.00;
local smooth = {};

-- buffers to be drawn
local buffer  = love.graphics.newCanvas(_SW, _SH);

-- generate noise
local function noise_gen(count)
    count = count or 200;
    for i = 2, count do
        noise[i] = point(
            i * (_SW / count),
            math.random( -200, 200 ) + _SH / 2
        );
    end
end

-- smooth the noise
local function smooth_gen(res)
    smooth = {};
    res = res or 5;

    for i = 2, #noise do
        local p1 = noise[i - 1];
        local p2 = noise[i    ];

        -- smoothed points
        local step = (p2.x - p1.x) / res;
        for j = 1, res do

            -- noise smoothing equation
            local x = p2.x + (j * step);
            local y = noise[1].y
            for i = 1, #noise - 1 do

                -- the smoothing equation
                y = y - ( noise[i + 1].y - noise[i].y ) / (1 + _E ^ ( (smoothing_factor) * ( x + ( noise[i + 1].x + noise[i].x ) / -2 ) ) );
            end

            table.insert( smooth, point(x, y));
        end

    end
end


-- render to buffers
local function pre_render()

    -- noise buffer rendering
    love.graphics.setCanvas(buffer);
        love.graphics.clear();

        love.graphics.setColor(1, 0, 0, 0.5);

        -- render noise
        for i = 2, #noise do
            love.graphics.circle("fill", noise[i].x, noise[i].y, 1);
            love.graphics.line(noise[i].x, noise[i].y, noise[i - 1].x, noise[i - 1].y);
        end

        love.graphics.setColor(0, 1, 0);
        
        -- render smoothed noise
        for i = 2, #smooth do
            love.graphics.line(smooth[i].x, smooth[i].y, smooth[i - 1].x, smooth[i - 1].y);
            
        end

        love.graphics.reset();
    love.graphics.setCanvas();
end

function love.update(dt) {
        
    -- decrease smoothness
    if (love.keyboard.isDown("down") and smoothing_factor < 5) then
        smoothing_factor = smoothing_factor + 0.01;
        smooth_gen(5);
        pre_render();
    end

    -- increase smoothness
    if (love.keyboard.isDown("up") and smoothing_factor > 0) then
        smoothing_factor = smoothing_factor - 0.01;
        smooth_gen(5);
        pre_render();
    end
}

-- utility
function love.draw()
    love.graphics.draw(buffer);
        
    -- quick tips
    love.graphics.print("key: UP will increase smoothness\nkey: DOWN will decrease smoothness\nkey: R will generate a new graph");
end

-- graph regen
function love.keypressed(key)
    if (key == "r") then
        noise_gen(200);
        smooth_gen(5);
        pre_render();
    end
end
