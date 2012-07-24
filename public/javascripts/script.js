$(function() {
	setUpShiz();
	keyShortcuts();
	refreshNotes();
  setUpActions();
  notesListActions();

	if ($(".notes li:first").attr("class")) {
		showNote($(".notes li:first").attr("class"));
		$(".notes li:first").addClass("selected");
	}

  if (window.gon.dropboxInfo != "") {
    loadDropboxInfo();
  }

  dropboxTimeout();

});

function setUpShiz() {
	windowWidth = $(window).width();
	windowHeight = $(window).height();
	textHeight = windowHeight-100;
	window.inCanvas = false;
	
	$(".notes").css({
		"height": windowHeight-40
	});
	
	$(".canvas").css({
		"width": windowWidth-301, //the 1px extra is for the border on canvas
		"height": windowHeight-40
	});

}

function notesListActions() {
  $(".notes li").on("click", function() {
    $(".notes .selected").removeClass("selected");
    openNote($(this).attr("class"));
    $(this).addClass("selected");
    window.inCanvas = true;
  });
}

function setUpActions() {
  $(".new").on("click", newNote);
	$(".delete").on("click", deleteNote);
}

function keyShortcuts() {
	k = new Kibo();
	k.down('alt h', function() {
		$(".help-modal").modal("toggle");
	});
	
	k.down('alt n', newNote);
	
	k.up('alt', function() {
		if (window.inCanvas) {
			window.inCanvas = false;
			$(".canvas input, .canvas textarea").blur();
			el = $(".notes .selected");
      el.removeClass("selected");
      showNote(el.attr("class"));
      el.addClass("selected");
		} else {
			window.inCanvas = true;
			if ($(".selected").size() < 1) {
				showNote($(".notes li:first").attr("class"));
				$(".notes li:first").addClass("selected");
			} else {
				el = $(".notes .selected");
				el.removeClass("selected");
				openNote(el.attr("class"));
				el.addClass("selected");
			}
		}
	});
	
	k.down("down", function() {
		if ( ($(".selected").size() > 0) && (window.inCanvas == false) ) {
			el = $(".notes .selected");
			el.removeClass("selected");
			nextEl = el.next();
        if (nextEl.length > 0) {
          showNote(nextEl.attr("class"));
          nextEl.addClass("selected");
        } else {
          el.addClass("selected");
        }
		}
	});
	
	k.down("up", function() {
		if ( ($(".selected").size() > 0) && (window.inCanvas == false) ) {
			el = $(".notes .selected");
			el.removeClass("selected");
			prevEl = el.prev();
            if (prevEl.length > 0) {
			        showNote(prevEl.attr("class"));
			        prevEl.addClass("selected");
            } else {
                el.addClass("selected");
            }
		}
	});
	
	
}

function refreshNotes(id) {
	$(".notes").empty();
	_.each($.jStorage.index(), function(i) {
		n = $.jStorage.get(i);
		item = '<li class="' + n.id + '">' + n.subject + '</li>'
		$(".notes").append(item);
	});
	if (id) {
        el = ".notes li."+id;
		$(el).addClass("selected");
	}
	notesListActions();
}

function newNote() {
	window.inCanvas = true;
	number = getNumber();
	note = $.jStorage.set('note-' + number, {
		id: number,
		subject: "",
		body: "type note here"
	});
	canvasHandler(note);
	refreshNotes();
}

function saveNote(id, subject, body) {
	$.jStorage.set('note-' + id, {
		id: id,
		subject: subject,
		body: body
	});
	refreshNotes(id);
  window.unsavedChanges = true;
}

function openNote(id) {
	id = "note-"+id;
	note = $.jStorage.get(id);
	canvasHandler(note); 
}

function showNote(id) {
	id = "note-"+id;
	note = $.jStorage.get(id);
	$(".canvas").empty();
	canvas = 
		'<input class="' + note.id + '" type="text" value="' + note.subject + '" />'+
		'<div class="line">'+
		'</div><textarea class="' + note.id + '" style="height: ' + textHeight + 'px;" value="' + note.body + '"></textarea>'
	$(".canvas").append(canvas);
	$(".canvas textarea").val(note.body);
}

function deleteNote() {
	el = $(".notes .selected");
	
	next = el.next();
    prev = el.prev();
    el.removeClass("selected");

    if (next > 0) {
	    select = next;
    } else if (prev > 0) {
        select = prev;
    } else {
        select = []
    }
	
	key = "note-" + el.attr("class");
	$.jStorage.deleteKey(key);
    if (select.length > 0) {
        showNote(select.attr("class"));
        refreshNotes(select.attr("class"));
    } else {
        refreshNotes();
        $(".canvas").empty();
    }
}




function canvasHandler(note) {
	$(".canvas").empty();
	canvas = 
		'<input class="' + note.id + '" type="text" value="' + note.subject + '" />'+
		'<div class="line">'+
		'</div><textarea class="' + note.id + '" style="height: ' + textHeight + 'px;" value="' + note.body + '"></textarea>'
	$(".canvas").append(canvas);
	$(".canvas textarea").val(note.body).focus(function() {
		if ($(this).val() == "type note here") {
			$(this).val("");
		}
	});
	$(".canvas input").focus();
	
	$(".canvas input, .canvas textarea").keyup(function() {
		saveNote(note.id, $(".canvas input").val(), $(".canvas textarea").val());
	});
	
	
}



function loadDropboxInfo() {
    noteArray = window.gon.dropboxInfo.split("|");
    _.each(noteArray, function(n) {
        i = n.split(",");
        
        //monkeys are commas
        i[1] = i[1].split("@('_')@").join(",");
        i[2] = i[2].split("@('_')@").join(",");
        
        console.log("hello");
        console.log(i);
        
        //mice are pipes
        i[1] = i[1].replace(/<`_}---/g, "|");
        i[2] = i[2].replace(/<`_}---/g, "|");
        
    	$.jStorage.set('note-' + i[0], {
    		id: i[0],
    		subject: i[1],
    		body: i[2]
    	}); 
    });
    
    key = _.first($.jStorage.index());
    first = $.jStorage.get(key);
    
    refreshNotes(first.id);
    showNote(first.id);
}



function dropboxTimeout() {
    setTimeout(function() {
        allNotes = []
        _.each($.jStorage.index(), function(key) {
            i = $.jStorage.get(key);
            i = _.toArray(i);
            //commas are monkeys
            i[1] = i[1].replace(/,/g, "@('_')@");
            i[2] = i[2].replace(/,/g, "@('_')@");
            
            //pipes are fish
            i[1] = i[1].replace(/(\|)/g, "<`_}---");
            i[3] = i[2].replace(/(\|)/g, "<`_}---");
            
            allNotes.push(i);
        });
        
        allNotes = allNotes.join("|");
                
        $.ajax({
            url: "/dropbox?data="+encodeURIComponent(allNotes),
            type: "POST"
        });
        window.unsavedChanges = false;
        
        dropboxTimeout();
    }, 5000)
}






//utility functions

function getNumber() {
	return Math.floor(Math.random()*1001);
}

function sanitizeThings(str) {
    
}






