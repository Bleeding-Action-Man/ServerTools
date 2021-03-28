Class Boost extends Info;

static function bool GiveBoost( Pawn Target)
{
  Target.Spawn(Class'BoostMe');
  return true;
}
