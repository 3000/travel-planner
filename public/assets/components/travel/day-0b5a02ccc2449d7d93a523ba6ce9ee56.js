(function(){angular.module("travel-components").controller("DaysController",["$scope",function(t){var e;return e=["place","transfer","activity","comment","hotel"],t.tripService=t.$parent.tripService,t.setEdit=function(e,r){return e?t.reload(function(){return t[""+r+"_edit"]=e}):t[""+r+"_edit"]=e},t.setEditAll=function(r){var n,a,i,l;for(l=[],a=0,i=e.length;i>a;a++)n=e[a],l.push(t.setEdit(r,n));return l},t.setDay=function(e,r){return t.day_index=e,t.day=r,t.$parent.days[e]=t.day,t.$parent.toggleActivities(!1),t.$parent.toggleTransfers(!1)},t.reload=function(e){return null==e&&(e=null),t.tripService.reloadDay(t.day,function(){return t.setEditAll(!1),t.$parent.setDayCollapse(t.day,"transfers"),t.$parent.setDayCollapse(t.day,"activities"),e?e(t.day):void 0})},t.save=function(){return t.tripService.updateDay(t.day).then(function(){return t.reload()})},t.setEditAll(!1)}])}).call(this);