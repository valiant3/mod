/*
	File: fn_wantedAdd.sqf
	Author: Bryan "Tonic" Boardwine
	
	Description:
	Adds or appends a unit to the wanted list.
*/
private["_uid","_type","_index","_data","_crimes","_val","_customBounty","_name"];
_uid = [_this,0,"",[""]] call BIS_fnc_param;
_name = [_this,1,"",[""]] call BIS_fnc_param;
_type = [_this,2,"",[""]] call BIS_fnc_param;
_customBounty = [_this,3,-1,[0]] call BIS_fnc_param;
if(_uid == "" OR _type == "" OR _name == "") exitWith {["diag_log",["----- Tried to launch wanted, bad data passed -----"]] call TON_fnc_logIt;}; //Bad data passed.

//What is the crime?
switch(_type) do
{
	case "187V": {_type = ["Vehicular Manslaughter",10000]};
	case "187": {_type = ["Manslaughter",50000]};
	case "188": {_type = ["Attempted Manslaughter",25000]};
	case "901": {_type = ["Escaping Jail",75000]};
	case "261": {_type = ["Rape",15000]}; //What type of sick bastard would add this?
	case "261A": {_type = ["Attempted Rape",10000]};
	case "215": {_type = ["Attempted Auto Theft",15000]};
	case "213": {_type = ["Use of illegal explosives",100000]};
	case "211": {_type = ["Robbery",25000]};
	case "207": {_type = ["Kidnapping",20000]};
	case "207A": {_type = ["Attempted Kidnapping",15000]};
	case "487": {_type = ["Grand Theft",20000]};
	case "488": {_type = ["Petty Theft",1000]};
	case "480": {_type = ["Hit and run",10000]};
	case "481": {_type = ["Drug Possession",50000]};
	case "602": {_type = ["Evading Arrest",25000]};
	case "603": {_type = ["Illegal Items",30000]};
	case "604": {_type = ["Terrorism",150000]};
	case "482": {_type = ["Intent to distribute",60000]};
	case "483": {_type = ["Drug Trafficking",60000]};
	case "459": {_type = ["Burglary",25000]};
	case "390": {_type = ["Public Intoxication",10000]};
	case "512": {_type = ["Jail Break",200000]};
	case "600": {_type = ["Possession of an Illegal Firearm",75000]};
	case "601": {_type = ["Possession of an Illegal Vehicle",75000]};
	default {_type = [];};
};

["diag_log",[
	"------------- Wanted Crime Add -------------",
	format["Player: %1",_name],
	format["Crime: %1",_type],
	"-------------------------------------------------"
]] call TON_fnc_logIt;

if(count _type == 0) exitWith {}; //Not our information being passed...
//Is there a custom bounty being sent? Set that as the pricing.
if(_customBounty != -1) then {_type set[1,_customBounty];};
//Search the wanted list to make sure they are not on it.
_index = [_uid,life_wanted_list] call TON_fnc_index;

if(_index != -1) then {
	_data = life_wanted_list select _index;
	_crimes = _data select 2;
	_crimes pushBack (_type select 0);
	_val = _data select 3;
	life_wanted_list set[_index,[_name,_uid,_crimes,(_type select 1) + _val]];
	[life_wanted_list select _index,_uid] spawn life_fnc_wantedSave;
} else {
	life_wanted_list pushBack [_name,_uid,[(_type select 0)],(_type select 1)];
	[[_name,_uid,[(_type select 0)],(_type select 1)],_uid] spawn life_fnc_wantedSave;
};