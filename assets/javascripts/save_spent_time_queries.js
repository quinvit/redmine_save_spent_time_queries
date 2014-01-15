
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
		$('#top-menu ul').dropit();		
	}
	
	$("#top-menu").css("visibility", "visible");
});

// Decorate
if(location.href.indexOf("#query=") != -1) {	
	var query = location.href.substr(location.href.indexOf("#query="));	
	$("#content div.contextual").css("margin-top", "16px");
	$("#content div.contextual").html('<a href="/spent_time_query/" class="icon icon-edit">Spent time queries</a>');
	$("#content p.breadcrumb").remove();
	$("#content form#query_form").remove();
	$("#content h2").html($("#content h2").html() + " - " + query.substr(query.indexOf("=") + 1));
	$("#content p.pagination a").each(function(){
		$(this).attr("href", $(this).attr("href") + query);
	});
}
