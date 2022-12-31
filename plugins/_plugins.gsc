init()
{
    LoadPlugin( plugins\_savedDvars::init );
    LoadPlugin( plugins\_speedMeter::init );
}

LoadPlugin( script )
{
    thread [[ script ]]();
}