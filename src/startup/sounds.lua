-- procedurally synthesized sound effects, so no binary audio assets are
-- needed in version control. Every effect is built once here into the
-- global `sounds` table; call sites only ever do sounds.<name>:clone():play(),
-- so a synthesized tone can later be swapped for a real asset file without
-- touching any call site.
local SAMPLE_RATE = 22050

-- writes a fading sine tone into soundData starting at startSample, returns the sample count written
local function writeTone(soundData, startSample, freq, duration, amplitude)
    local sampleCount = math.floor(SAMPLE_RATE * duration)
    for i = 0, sampleCount - 1 do
        local t = i / SAMPLE_RATE
        local envelope = 1 - (i / sampleCount) -- linear fade-out avoids a click at the end
        local sample = math.sin(2 * math.pi * freq * t) * amplitude * envelope
        soundData:setSample(startSample + i, sample)
    end
    return sampleCount
end

local function buildChaChing()
    local totalDuration = 0.2
    local soundData = love.sound.newSoundData(math.floor(SAMPLE_RATE * totalDuration), SAMPLE_RATE, 16, 1)

    local offset = 0
    offset = offset + writeTone(soundData, offset, 1046.5, 0.08, 0.5) -- C6
    offset = offset + math.floor(SAMPLE_RATE * 0.02) -- brief gap between blips
    writeTone(soundData, offset, 1568.0, 0.08, 0.5) -- G6

    return soundData
end

local function buildStepComplete()
    local duration = 0.12
    local soundData = love.sound.newSoundData(math.floor(SAMPLE_RATE * duration), SAMPLE_RATE, 16, 1)
    writeTone(soundData, 0, 880.0, duration, 0.4)
    return soundData
end

sounds = {
    chaChing = love.audio.newSource(buildChaChing()),
    stepComplete = love.audio.newSource(buildStepComplete())
}
