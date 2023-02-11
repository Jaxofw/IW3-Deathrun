init()
{
    loadPlugin( plugins\_savedDvars::init );
    LoadPlugin( plugins\_doubleXp::init );
    LoadPlugin( plugins\_speedMeter::init );
    LoadPlugin( plugins\_spectator::init );
    LoadPlugin( plugins\_ghostrun::init );
}

loadPlugin( script )
{
    thread [[ script ]]();
}