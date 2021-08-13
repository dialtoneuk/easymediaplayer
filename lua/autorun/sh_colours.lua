MEDIA.ComputedColours = MEDIA.ComputedColours or {
    --holds our computer colours
}

--the colours for our stuff
MEDIA.Colours = {
    Black = Color(10,10,10),
    PitchBlack = Color(0,0,0),
    White = Color(255,255,255),
    Red = Color(255,0,0),
    Blue = Color(0,0,255)
}

--generates some colours but only once
if (table.IsEmpty(MEDIA.ComputedColours)) then

    for key,colour in pairs(MEDIA.Colours) do
        MEDIA.ComputedColours[ "Faded" .. key ] = Color(colour.r, colour.g, colour.b, 200 )
        MEDIA.ComputedColours[ "Barely" .. key ] = Color(colour.r, colour.g, colour.b, 50 )
        MEDIA.ComputedColours[ "Reverse" .. key ] = Color(colour.b, colour.g, colour.r, 255 )
    end

    MEDIA.Colours = table.Merge(MEDIA.Colours, MEDIA.ComputedColours)
end