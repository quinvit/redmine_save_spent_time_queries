
// Create top menu
var spent_time_queries_menu = $("#top-menu ul li a.spent-time-query").parent();	
var spent_time_ul = "<ul>";

$("#spent_time_queries a").each(function() {
	spent_time_ul += "<li>" + $(this).clone().wrap('<div>').parent().html() + "</li>";		
});

spent_time_ul += "</ul>";

if($('#top-menu ul').dropit && spent_time_ul != '<ul></ul>'){
	spent_time_queries_menu.append(spent_time_ul);		
	$("#top-menu ul li a.spent-time-query").html($("#top-menu ul li a.spent-time-query").html() + " ▽");	
	$('#top-menu ul').dropit({ action: 'hover' });		
}

$("#top-menu").css("visibility", "visible");
$("#main").css("visibility", "visible");

// Decorate
var href = decodeURIComponent(location.href);
if(href.indexOf("&v[query]=") != -1 && href.indexOf("/time_entries") != -1) {	
	$("#content div.contextual").css("margin-top", "16px");
	$("#content div.contextual").html('<a href="' + relative_url_root + '/spent_time_query" class="icon icon-edit">Saved queries</a>');
	$("#content p.breadcrumb").remove();
	$("#content div.tabs").remove();
}
