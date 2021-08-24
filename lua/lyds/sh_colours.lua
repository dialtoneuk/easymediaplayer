--holds our computer colours
MediaPlayer.ComputedColours = MediaPlayer.ComputedColours or {}

--the colours for our stuff
MediaPlayer.Colours = {
    Black = Color(10,10,10),
    Gray = Color(145,145,145),
    PitchBlack = Color(0,0,0),
    White = Color(255,255,255),
    Red = Color(255,0,0),
    Blue = Color(0,0,255)
}

--generates some colours but only once
if (table.IsEmpty(MediaPlayer.ComputedColours)) then

    for key,colour in pairs(MediaPlayer.Colours) do
        MediaPlayer.ComputedColours[ "Faded" .. key ] = Color(colour.r, colour.g, colour.b, 200 )
        MediaPlayer.ComputedColours[ "Barely" .. key ] = Color(colour.r, colour.g, colour.b, 50 )
        MediaPlayer.ComputedColours[ "Reverse" .. key ] = Color(colour.b, colour.g, colour.r, 255 )
    end
end

--only do it once
if (!table.IsEmpty(MediaPlayer.ComputedColours)) then
    MediaPlayer.Colours = table.Merge(MediaPlayer.Colours, MediaPlayer.ComputedColours)
end