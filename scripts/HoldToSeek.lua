local Command = {
    SET = 'set'
}

local KeyState = {
    UP = 'up',
    DOWN = 'down'
}

local PlayDirection = {
    FORWARD = 'forward',
    BACKWARD = 'backward'
}

local Property = {
    DURATION = 'duration',
}

local Option = {
    PLAY_DIRECTION = 'play-dir',
    SPEED = 'speed'
}

local HtsOption = {
    SPEED = 'hts_speed'
}

local options = {}
options[HtsOption.SPEED] = 2.0
require 'mp.options'.read_options(options)

local function set_default_seek_options()
    mp.commandv(Command.SET, Option.PLAY_DIRECTION, PlayDirection.FORWARD)
    mp.commandv(Command.SET, Option.SPEED, 1.0)
    mp.osd_message(string.format('⏵ %s×', 1.0))
end

-- Hold to seek wrapper that wraps the event function
local function hold_to_seek(direction)
    return function(event)
        if event.event == KeyState.DOWN then
            -- HtsOption from console takes precedence
            local speed = mp.get_opt(HtsOption.SPEED) or options[HtsOption.SPEED]
            local duration = mp.get_property_native(Property.DURATION)

            -- Display message until default is called
            if direction == PlayDirection.BACKWARD then
                mp.osd_message(string.format('⏪ %s×', speed), duration)
            else
                mp.osd_message(string.format('⏩ %s×', speed), duration)
            end

            -- Using play-dir because backward seeking using negative speed values is not possible
            mp.commandv(Command.SET, Option.PLAY_DIRECTION, direction)
            mp.commandv(Command.SET, Option.SPEED, speed)
        end

        if event.event == KeyState.UP then set_default_seek_options() end
    end
end

mp.add_key_binding(
    'alt+.',
    'hts-forward',
    hold_to_seek(PlayDirection.FORWARD),
    { complex = true }
)

mp.add_key_binding(
    'alt+,',
    'hts-backward',
    hold_to_seek(PlayDirection.BACKWARD),
    { complex = true }
)
