init()
{
    LoadPlugin( plugins\_savedDvars::init );
}

LoadPlugin( script )
{
    thread [[ script ]]();
}