/*
	Author: Index

	Description:
	Blah
*/
private["_house","_uid","_housePos","_query"];
_newid = [_this,0,"",[""]] call BIS_fnc_param;
_house = [_this,1,ObjNull,[ObjNull]] call BIS_fnc_param;
_houseID = _house getVariable["house_id",-1];

if(isNull _house OR _newid == "") exitWith {};


_query = format["housingSwapOwner:%1:%2",_newid,_houseID];
waitUntil{!DB_Async_Active};
[_query,1] call DB_fnc_asyncCall;