$(function(){$(".button-checkbox").each(function(){function n(){var n=a.is(":checked");e.data("state",n?"on":"off"),e.find(".state-icon").removeClass().addClass("state-icon "+i[e.data("state")].icon),n?e.removeClass("btn-default").addClass("btn-"+o+" active"):e.removeClass("btn-"+o+" active").addClass("btn-default")}function c(){n(),0==e.find(".state-icon").length&&e.prepend('<i class="state-icon '+i[e.data("state")].icon+'"></i>\xa0')}var t=$(this),e=t.find("button"),a=t.find("input:checkbox"),o=e.data("color"),i={on:{icon:"glyphicon glyphicon-check"},off:{icon:"glyphicon glyphicon-unchecked"}};e.on("click",function(){a.prop("checked",!a.is(":checked")),a.triggerHandler("change"),n()}),a.on("change",function(){n()}),c()})});