
// Create top menu

$(document).ready(function(){	
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
});

// Auto show
setTimeout(function(){
	$("#top-menu").css("visibility", "visible");
	$("#main").css("visibility", "visible");
}, 100);

// Decorate
if(location.href.indexOf("#query=") != -1 && location.href.indexOf("/time_entries") != -1) {	
	var query = location.href.substr(location.href.indexOf("#query="));	
	
	// Modify form action
	$("#content form").each(function(){
		$(this).attr("action", $(this).attr("action") + decodeURIComponent(query));
	});
	
	// Modify a href
	$("#content a").each(function(){
		if($(this).attr("href") == "#") {
			$(this).attr("href", decodeURIComponent(query));
		}
		else if($(this).attr("href").indexOf("javascript:") != 0 && $(this).attr("href").indexOf("/time_entries?") != -1) {
			$(this).attr("href", $(this).attr("href") + decodeURIComponent(query));
		}
	});		
	
	$("#content div.contextual").css("margin-top", "16px");
	$("#content div.contextual").html('<a href="/spent_time_query/" class="icon icon-edit">Saved queries</a>');
	$("#content p.breadcrumb").remove();
	$("#content div.tabs").remove();
	
	$("#content h2").html($("#content h2").html() + " - " + decodeURIComponent(query.substr(query.indexOf("=") + 1)));
	
	$("#content p.pagination a").each(function(){
		$(this).attr("href", $(this).attr("href") + decodeURIComponent(query));
	});	
}
