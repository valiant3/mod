#include "..\..\script_macros.hpp"
/*
	File: fn_weaponShopBuySell.sqf
	Author: Bryan "Tonic" Boardwine
	
	Description:
	Master handling of the weapon shop for buying / selling an item.
*/
disableSerialization;
private["_price","_item","_itemInfo","_bad"];
if((lbCurSel 38403) == -1) exitWith {hint localize "STR_Shop_Weapon_NoSelect"};
_price = lbValue[38403,(lbCurSel 38403)]; if(isNil "_price") then {_price = 0;};
_item = lbData[38403,(lbCurSel 38403)];
_itemInfo = [_item] call life_fnc_fetchCfgDetails;

_bad = "";

if((_itemInfo select 6) != "CfgVehicles") then {
	if((_itemInfo select 4) in [4096,131072]) then {
		if(!(player canAdd _item) && (uiNamespace getVariable["Weapon_Shop_Filter",0]) != 1) exitWith {_bad = (localize "STR_NOTF_NoRoom")};
	};
};

if(_bad != "") exitWith {hint _bad};


_toSelect = ((life_capture_list) select 0);
if((uiNamespace getVariable["Weapon_Shop_Filter",0]) == 1) then {
	CASH = CASH + _price;
	[_item,false] call life_fnc_handleItem;
	hint parseText format[localize "STR_Shop_Weapon_Sold",_itemInfo select 1,[_price] call life_fnc_numberText];
	[nil,(uiNamespace getVariable["Weapon_Shop_Filter",0])] call life_fnc_weaponShopFilter; //Update the menu.
} else {
	private["_hideout"];
	_hideout = (nearestObjects[getPosATL player,["Land_u_Barracks_V2_F","Land_i_Barracks_V2_F"],25]) select 0;
	if(!isNil "_hideout" && {!isNil {grpPlayer getVariable "gang_bank"}} && {(grpPlayer getVariable "gang_bank") >= _price}) then {
		_action = [
			format[(localize "STR_Shop_Virt_Gang_FundsMSG")+ "<br/><br/>" +(localize "STR_Shop_Virt_Gang_Funds")+ " <t color='#8cff9b'>$%1</t><br/>" +(localize "STR_Shop_Virt_YourFunds")+ " <t color='#8cff9b'>$%2</t>",
				[(grpPlayer getVariable "gang_bank")] call life_fnc_numberText,
				[CASH] call life_fnc_numberText
			],
			localize "STR_Shop_Virt_YourorGang",
			localize "STR_Shop_Virt_UI_GangFunds",
			localize "STR_Shop_Virt_UI_YourCash"
		] call BIS_fnc_guiMessage;
		if(_action) then {
			hint parseText format[localize "STR_Shop_Weapon_BoughtGang",_itemInfo select 1,[_price] call life_fnc_numberText];
			_funds = grpPlayer getVariable "gang_bank";
			_funds = _funds - _price;
			grpPlayer setVariable["gang_bank",_funds,true];
			[_item,true] spawn life_fnc_handleItem;
			[1,grpPlayer] remoteExecCall ["TON_fnc_updateGang",RSERV];
		} else {
			if(_price > CASH && life_inv_debit < 1) exitWith {hint localize "STR_NOTF_NotEnoughMoney"};
			if(_price > CASH && _price > BANK && life_inv_debit > 0) exitWith {hint localize "STR_NOTF_NotEnoughMoney"};
			if(_price > CASH && life_inv_debit > 0 && _price > 30000) exitWith {hint "Debit cards only work for prices under $30,000"};
			hint parseText format[localize "STR_Shop_Weapon_BoughtItem",_itemInfo select 1,[_price] call life_fnc_numberText];
			if(_price < CASH) then {SUB(CASH,_price);} else {SUB(BANK,_price);};
			[_item,true] spawn life_fnc_handleItem;
		};
	} else {
		if(_price > CASH) exitWith {hint localize "STR_NOTF_NotEnoughMoney"};
		hint parseText format[localize "STR_Shop_Weapon_BoughtItem",_itemInfo select 1,[_price] call life_fnc_numberText];
		CASH = CASH - _price;
		[_item,true] spawn life_fnc_handleItem;
	};
};
[5,grpPlayer,_toSelect select 0,500] remoteExecCall ["TON_fnc_updateGang",RSERV];
[] call life_fnc_saveGear;